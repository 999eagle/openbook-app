import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Openbook/models/emoji.dart';
import 'package:Openbook/models/emoji_group_list.dart';
import 'package:Openbook/models/post.dart';
import 'package:Openbook/models/post_comment.dart';
import 'package:Openbook/models/post_comment_list.dart';
import 'package:Openbook/models/post_reaction.dart';
import 'package:Openbook/models/post_reaction_list.dart';
import 'package:Openbook/models/post_reactions_emoji_count_list.dart';
import 'package:Openbook/models/posts_list.dart';
import 'package:Openbook/models/user.dart';
import 'package:Openbook/services/auth_api.dart';
import 'package:Openbook/services/emojis_api.dart';
import 'package:Openbook/services/httpie.dart';
import 'package:Openbook/services/posts_api.dart';
import 'package:Openbook/services/storage.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

class UserService {
  Storage _userStorage;

  static const STORAGE_KEY_AUTH_TOKEN = 'authToken';
  static const STORAGE_KEY_USER_DATA = 'data';
  static const STORAGE_FIRST_POSTS_DATA = 'firstPostsData';

  AuthApiService _authApiService;
  HttpieService _httpieService;
  PostsApiService _postsApiService;
  EmojisApiService _emojisApiService;

  // If this is null, means user logged out.
  Stream<User> get loggedInUserChange => _loggedInUserChangeSubject.stream;

  User _loggedInUser;

  String _authToken;

  final _loggedInUserChangeSubject = ReplaySubject<User>(maxSize: 1);

  void setAuthApiService(AuthApiService authApiService) {
    _authApiService = authApiService;
  }

  void setPostsApiService(PostsApiService postsApiService) {
    _postsApiService = postsApiService;
  }

  void setEmojisApiService(EmojisApiService emojisApiService) {
    _emojisApiService = emojisApiService;
  }

  void setHttpieService(HttpieService httpieService) {
    _httpieService = httpieService;
  }

  void setStorageService(StorageService storageService) {
    _userStorage = storageService.getSecureStorage(namespace: 'user');
  }

  Future<void> logout() async {
    await _removeStoredFirstPostsData();
    await _removeStoredUserData();
    await _removeStoredAuthToken();
    _httpieService.removeAuthorizationToken();
    _removeLoggedInUser();
  }

  Future<void> loginWithCredentials(
      {@required String username, @required String password}) async {
    HttpieResponse response = await _authApiService.loginWithCredentials(
        username: username, password: password);

    if (response.isOk()) {
      var parsedResponse = response.parseJsonBody();
      var authToken = parsedResponse['token'];
      await loginWithAuthToken(authToken);
    } else if (response.isUnauthorized()) {
      throw CredentialsMismatchError('The provided credentials do not match.');
    } else {
      throw HttpieRequestError(response);
    }
  }

  Future<void> loginWithAuthToken(String authToken) async {
    await _setAuthToken(authToken);
    await refreshUser();
  }

  User getLoggedInUser() {
    return _loggedInUser;
  }

  bool isLoggedInUser(User user) {
    return user.id == _loggedInUser.id;
  }

  Future<void> refreshUser() async {
    if (_authToken == null) throw AuthTokenMissingError();

    try {
      HttpieResponse response =
          await _authApiService.getUserWithAuthToken(_authToken);
      _checkResponseIsOk(response);
      var userData = response.body;
      _setUserWithData(userData);
    } on HttpieConnectionRefusedError {
      // Response failed. Use stored user.
      String userData = await this._getStoredUserData();
      if (userData != null) {
        var user = _makeUser(userData);
        _setLoggedInUser(user);
      }
      rethrow;
    }
  }

  Future<User> updateUser({
    dynamic avatar,
    dynamic cover,
    String name,
    String username,
    String url,
    String password,
    DateTime birthDate,
    bool followersCountVisible,
    String bio,
    String location,
  }) async {
    HttpieStreamedResponse response = await _authApiService.updateUser(
        avatar: avatar,
        cover: cover,
        name: name,
        username: username,
        url: url,
        password: password,
        birthDate: DateFormat('dd-MM-yyyy').format(birthDate),
        followersCountVisible: followersCountVisible,
        bio: bio,
        location: location);

    _checkResponseIsOk(response);

    String userData = await response.readAsString();
    return _makeUser(userData);
  }

  Future<bool> loginWithStoredAuthToken() async {
    var token = await _getStoredAuthToken();
    if (token == null) throw AuthTokenMissingError();

    await loginWithAuthToken(token);
  }

  Future<bool> hasAuthToken() async {
    String authToken = await _getStoredAuthToken();
    return authToken != null;
  }

  bool isLoggedIn() {
    return _loggedInUser != null;
  }

  Future<PostsList> getTimelinePosts(
      {List<int> listIds,
      List<int> circleIds,
      int maxId,
      int count,
      String username,
      bool areFirstPosts = false}) async {
    try {
      HttpieResponse response = await _postsApiService.getTimelinePosts(
          listIds: listIds,
          circleIds: circleIds,
          maxId: maxId,
          count: count,
          username: username,
          authenticatedRequest: true);
      _checkResponseIsOk(response);
      String postsData = response.body;
      if (areFirstPosts) {
        this._storeFirstPostsData(postsData);
      }
      return _makePostsList(postsData);
    } on HttpieConnectionRefusedError {
      if (areFirstPosts) {
        // Response failed. Use stored first posts.
        String firstPostsData = await this._getStoredFirstPostsData();
        if (firstPostsData != null) {
          var postsList = _makePostsList(firstPostsData);
          return postsList;
        }
      }
      rethrow;
    }
  }

  Future<Post> createPost(
      {String text, List<int> circleIds, File image}) async {
    HttpieStreamedResponse response = await _postsApiService.createPost(
        text: text, circleIds: circleIds, image: image);

    _checkResponseIsCreated(response);

    // Post counts have changed
    refreshUser();

    String responseBody = await response.readAsString();
    return Post.fromJson(json.decode(responseBody));
  }

  Future<void> deletePost(Post post) async {
    HttpieResponse response = await _postsApiService.deletePostWithId(post.id);
    _checkResponseIsOk(response);
  }

  Future<PostReaction> reactToPost(
      {@required Post post, @required Emoji emoji}) async {
    HttpieResponse response =
        await _postsApiService.reactToPost(postId: post.id, emojiId: emoji.id);
    _checkResponseIsCreated(response);
    return PostReaction.fromJson(json.decode(response.body));
  }

  Future<void> deletePostReaction(
      {@required PostReaction postReaction, @required Post post}) async {
    HttpieResponse response = await _postsApiService.deletePostReaction(
        postReactionId: postReaction.id, postId: post.id);
    _checkResponseIsOk(response);
  }

  Future<PostReactionList> getReactionsForPost(Post post,
      {int count, int maxId, Emoji emoji}) async {
    HttpieResponse response = await _postsApiService
        .getReactionsForPostWithId(post.id, count: count, maxId: maxId);

    _checkResponseIsOk(response);

    return PostReactionList.fromJson(json.decode(response.body));
  }

  Future<PostReactionsEmojiCountList> getReactionsEmojiCountForPost(
      Post post) async {
    HttpieResponse response =
        await _postsApiService.getReactionsEmojiCountForPostWithId(post.id);

    _checkResponseIsOk(response);

    return PostReactionsEmojiCountList.fromJson(json.decode(response.body));
  }

  Future<PostComment> commentPost(
      {@required Post post, @required String text}) async {
    HttpieResponse response =
        await _postsApiService.commentPost(postId: post.id, text: text);
    _checkResponseIsCreated(response);
    return PostComment.fromJson(json.decode(response.body));
  }

  Future<void> deletePostComment(
      {@required PostComment postComment, @required Post post}) async {
    HttpieResponse response = await _postsApiService.deletePostComment(
        postCommentId: postComment.id, postId: post.id);
    _checkResponseIsOk(response);
  }

  Future<PostCommentList> getCommentsForPost(Post post,
      {int count, int maxId}) async {
    HttpieResponse response = await _postsApiService
        .getCommentsForPostWithId(post.id, count: count, maxId: maxId);

    _checkResponseIsOk(response);

    return PostCommentList.fromJson(json.decode(response.body));
  }

  Future<EmojiGroupList> getEmojiGroups() async {
    HttpieResponse response = await this._emojisApiService.getEmojiGroups();

    _checkResponseIsOk(response);

    return EmojiGroupList.fromJson(json.decode(response.body));
  }

  Future<User> getUserWithUsername(String username) async {
    HttpieResponse response = await _authApiService
        .getUserWithUsername(username, authenticatedRequest: true);
    _checkResponseIsOk(response);
    return User.fromJson(json.decode(response.body));
  }

  Future<User> _setUserWithData(String userData) async {
    await _storeUserData(userData);
    var user = _makeUser(userData);
    _setLoggedInUser(user);
    return user;
  }

  void _checkResponseIsCreated(HttpieBaseResponse response) {
    if (response.isCreated()) return;
    throw HttpieRequestError(response);
  }

  void _checkResponseIsOk(HttpieBaseResponse response) {
    if (response.isOk()) return;
    throw HttpieRequestError(response);
  }

  void _setLoggedInUser(User user) {
    _loggedInUser = user;
    _loggedInUserChangeSubject.add(user);
  }

  void _removeLoggedInUser() {
    _loggedInUser = null;
    _loggedInUserChangeSubject.add(null);
  }

  Future<void> _setAuthToken(String authToken) async {
    _authToken = authToken;
    _httpieService.setAuthorizationToken(authToken);
    await _storeAuthToken(authToken);
  }

  Future<void> _storeAuthToken(String authToken) {
    return _userStorage.set(STORAGE_KEY_AUTH_TOKEN, authToken);
  }

  Future<String> _getStoredAuthToken() async {
    String authToken = await _userStorage.get(STORAGE_KEY_AUTH_TOKEN);
    if (authToken != null) _authToken = authToken;
    return authToken;
  }

  Future<void> _removeStoredAuthToken() async {
    _userStorage.remove(STORAGE_KEY_AUTH_TOKEN);
  }

  Future<void> _storeUserData(String userData) {
    return _userStorage.set(STORAGE_KEY_USER_DATA, userData);
  }

  Future<void> _removeStoredUserData() async {
    _userStorage.remove(STORAGE_KEY_USER_DATA);
  }

  Future<String> _getStoredUserData() async {
    return _userStorage.get(STORAGE_KEY_USER_DATA);
  }

  Future<void> _storeFirstPostsData(String firstPostsData) {
    return _userStorage.set(STORAGE_FIRST_POSTS_DATA, firstPostsData);
  }

  Future<void> _removeStoredFirstPostsData() async {
    _userStorage.remove(STORAGE_FIRST_POSTS_DATA);
  }

  Future<String> _getStoredFirstPostsData() async {
    return _userStorage.get(STORAGE_FIRST_POSTS_DATA);
  }

  User _makeUser(String userData) {
    return User.fromJson(json.decode(userData));
  }

  PostsList _makePostsList(String postsData) {
    return PostsList.fromJson(json.decode(postsData));
  }
}

class CredentialsMismatchError implements Exception {
  final String msg;

  const CredentialsMismatchError(this.msg);

  String toString() => 'CredentialsMismatchError: $msg';
}

class AuthTokenMissingError implements Exception {
  const AuthTokenMissingError();

  String toString() => 'AuthTokenMissingError: No auth token was found.';
}

class NotLoggedInUserError implements Exception {
  const NotLoggedInUserError();

  String toString() => 'NotLoggedInUserError: No user is logged in.';
}
