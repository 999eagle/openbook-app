import 'package:Openbook/models/circle.dart';
import 'package:Openbook/models/community.dart';
import 'package:Openbook/models/emoji.dart';
import 'package:Openbook/models/follows_list.dart';
import 'package:Openbook/models/post.dart';
import 'package:Openbook/models/post_comment.dart';
import 'package:Openbook/models/post_reactions_emoji_count.dart';
import 'package:Openbook/models/user.dart';
import 'package:Openbook/models/user_invite.dart';
import 'package:Openbook/pages/home/modals/accept_guidelines/pages/confirm_reject_guidelines.dart';
import 'package:Openbook/pages/home/modals/confirm_block_user.dart';
import 'package:Openbook/pages/home/modals/create_post/pages/share_post/pages/share_post_with_circles.dart';
import 'package:Openbook/pages/home/modals/create_post/pages/share_post/pages/share_post_with_community.dart';
import 'package:Openbook/pages/home/modals/create_post/pages/share_post/share_post.dart';
import 'package:Openbook/pages/home/modals/post_reactions/post_reactions.dart';
import 'package:Openbook/pages/home/pages/community/community.dart';
import 'package:Openbook/pages/home/pages/community/pages/community_members.dart';
import 'package:Openbook/pages/home/pages/community/pages/manage_community/manage_community.dart';
import 'package:Openbook/pages/home/pages/community/pages/manage_community/pages/community_administrators/community_administrators.dart';
import 'package:Openbook/pages/home/pages/community/pages/manage_community/pages/community_administrators/modals/add_community_administrator/pages/confirm_add_community_administrator.dart';
import 'package:Openbook/pages/home/pages/community/pages/manage_community/pages/community_banned_users/community_banned_users.dart';
import 'package:Openbook/pages/home/pages/community/pages/manage_community/pages/community_banned_users/modals/ban_community_user/pages/confirm_ban_community_user.dart';
import 'package:Openbook/pages/home/pages/community/pages/manage_community/pages/community_closed_posts/community_closed_posts.dart';
import 'package:Openbook/pages/home/pages/community/pages/manage_community/pages/community_moderators/community_moderators.dart';
import 'package:Openbook/pages/home/pages/community/pages/manage_community/pages/community_moderators/modals/add_community_moderator/pages/confirm_add_community_moderator.dart';
import 'package:Openbook/pages/home/pages/community/pages/manage_community/pages/delete_community.dart';
import 'package:Openbook/pages/home/pages/community/pages/manage_community/pages/leave_community.dart';
import 'package:Openbook/pages/home/pages/menu/pages/community_guidelines.dart';
import 'package:Openbook/pages/home/pages/menu/pages/connections_circle/connections_circle.dart';
import 'package:Openbook/pages/home/pages/menu/pages/connections_circles/connections_circles.dart';
import 'package:Openbook/pages/home/pages/menu/pages/delete_account/delete_account.dart';
import 'package:Openbook/pages/home/pages/menu/pages/delete_account/pages/confirm_delete_account.dart';
import 'package:Openbook/pages/home/pages/menu/pages/followers.dart';
import 'package:Openbook/pages/home/pages/menu/pages/following.dart';
import 'package:Openbook/pages/home/pages/menu/pages/follows_list/follows_list.dart';
import 'package:Openbook/pages/home/pages/menu/pages/follows_lists/follows_lists.dart';
import 'package:Openbook/pages/home/pages/menu/pages/settings/pages/account_settings/account_settings.dart';
import 'package:Openbook/pages/home/pages/menu/pages/settings/pages/account_settings/pages/blocked_users.dart';
import 'package:Openbook/pages/home/pages/menu/pages/settings/pages/application_settings.dart';
import 'package:Openbook/pages/home/pages/menu/pages/settings/settings.dart';
import 'package:Openbook/pages/home/pages/menu/pages/useful_links.dart';
import 'package:Openbook/pages/home/pages/menu/pages/user_invites/pages/user_invite_detail.dart';
import 'package:Openbook/pages/home/pages/menu/pages/user_invites/user_invites.dart';
import 'package:Openbook/pages/home/pages/menu/pages/themes/themes.dart';
import 'package:Openbook/pages/home/pages/notifications/pages/notifications_settings.dart';
import 'package:Openbook/pages/home/pages/post/post.dart';
import 'package:Openbook/pages/home/pages/post_comments/post_comments_page.dart';
import 'package:Openbook/pages/home/pages/post_comments/widgets/post_comment/widgets/post_comments_page_controller.dart';
import 'package:Openbook/pages/home/pages/profile/profile.dart';
import 'package:Openbook/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Openbook/widgets/routes/slide_right_route.dart';
import 'package:Openbook/widgets/theming/primary_color_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationService {
  void navigateToUserProfile(
      {@required User user, @required BuildContext context}) async {
    await Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSlideProfileView'),
            widget: OBProfilePage(
              user,
            )));
  }

  Future navigateToCommunity(
      {@required Community community, @required BuildContext context}) async {
    await Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSlideCommunityPage'),
            widget: OBCommunityPage(
              community,
            )));
  }

  Future<bool> navigateToConfirmAddCommunityAdministrator(
      {@required Community community,
      @required User user,
      @required BuildContext context}) async {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSlideConfirmAddCommunityAdministratorPage'),
            widget: OBConfirmAddCommunityAdministrator(
              community: community,
              user: user,
            )));
  }

  Future<bool> navigateToConfirmDeleteAccount(
      {@required String userPassword, @required BuildContext context}) async {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSlideConfirmDeleteAccount'),
            widget: OBConfirmDeleteAccount(
              userPassword: userPassword,
            )));
  }

  Future<bool> navigateToDeleteAccount({@required BuildContext context}) async {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSlideDeleteAccount'), widget: OBDeleteAccountPage()));
  }

  Future<bool> navigateToConfirmAddCommunityModerator(
      {@required Community community,
      @required User user,
      @required BuildContext context}) async {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSlideConfirmAddCommunityModeratorPage'),
            widget: OBConfirmAddCommunityModerator(
              community: community,
              user: user,
            )));
  }

  Future<bool> navigateToConfirmBanCommunityUser(
      {@required Community community,
      @required User user,
      @required BuildContext context}) async {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSlideConfirmBanCommunityMemberPage'),
            widget: OBConfirmBanCommunityUser(
              community: community,
              user: user,
            )));
  }

  Future<void> navigateToManageCommunity(
      {@required Community community, @required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obEditCommunityPage'),
            widget: OBManageCommunityPage(
              community: community,
            )));
  }

  Future<void> navigateToLeaveCommunity(
      {@required Community community, @required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obLeaveCommunityPage'),
            widget: OBLeaveCommunityPage(
              community: community,
            )));
  }

  Future<void> navigateToDeleteCommunity(
      {@required Community community, @required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obDeleteCommunityPage'),
            widget: OBDeleteCommunityPage(
              community: community,
            )));
  }

  Future<void> navigateToCommunityAdministrators(
      {@required Community community, @required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obCommunityAdministratorsPage'),
            widget: OBCommunityAdministratorsPage(
              community: community,
            )));
  }

  Future<void> navigateToCommunityMembers(
      {@required Community community, @required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obCommunityMembersPage'),
            widget: OBCommunityMembersPage(
              community: community,
            )));
  }

  Future<void> navigateToCommunityModerators(
      {@required Community community, @required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obCommunityModeratorsPage'),
            widget: OBCommunityModeratorsPage(
              community: community,
            )));
  }

  Future<void> navigateToCommunityBannedUsers(
      {@required Community community, @required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obCommunityBannedUsersPage'),
            widget: OBCommunityBannedUsersPage(
              community: community,
            )));
  }

  Future<void> navigateToCommunityClosedPosts(
      {@required Community community, @required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obCommunityClosedPostsPage'),
            widget: OBCommunityClosedPostsPage(
              community,
            )));
  }

  Future navigateToCommentPost(
      {@required Post post, @required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSlidePostComments'),
            widget: OBPostCommentsPage(
                post:post,
                showPostPreview: false,
                autofocusCommentInput: true)));
  }

  Future navigateToPostComments(
      {@required Post post, @required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSlideViewComments'),
            widget: OBPostCommentsPage(
                post: post,
                showPostPreview: false,
                pageType: PostCommentsPageType.comments,
                autofocusCommentInput: false)
        ));
  }

  Future navigateToPostCommentReplies(
      {@required Post post,
        @required PostComment postComment,
        @required BuildContext context,
        Function(PostComment) onReplyDeleted,
        Function(PostComment) onReplyAdded
      }) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSlideViewComments'),
            widget: OBPostCommentsPage(
                post: post,
                showPostPreview: false,
                postComment: postComment,
                onCommentDeleted: onReplyDeleted,
                onCommentAdded: onReplyAdded,
                autofocusCommentInput: false)));
  }

  Future navigateToPostCommentsLinked(
      {@required PostComment postComment, @required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSlideViewCommentsLinked'),
            widget: OBPostCommentsPage(
                post: postComment.post,
                showPostPreview: true,
                pageType: PostCommentsPageType.comments,
                linkedPostComment: postComment,
                autofocusCommentInput: false)));
  }

  Future navigateToPostCommentRepliesLinked(
      {@required PostComment postComment, @required PostComment parentComment, @required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSlideViewCommentsLinked'),
            widget: OBPostCommentsPage(
                post: postComment.post,
                postComment: parentComment,
                showPostPreview: true,
                pageType: PostCommentsPageType.replies,
                linkedPostComment: postComment,
                autofocusCommentInput: false)));
  }

  Future navigateToPost({@required Post post, @required BuildContext context}) {
    return Navigator.push(context,
        OBSlideRightRoute(key: Key('obSlidePost'), widget: OBPostPage(post)));
  }

  Future navigateToSettingsPage({@required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obMenuViewSettings'), widget: OBSettingsPage()));
  }

  Future navigateToFollowersPage({@required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obFollowersPage'), widget: OBFollowersPage()));
  }

  Future navigateToFollowingPage({@required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obFollowingPage'), widget: OBFollowingPage()));
  }

  Future navigateToAccountSettingsPage({@required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obAccountSettingsPage'),
            widget: OBAccountSettingsPage()));
  }

  Future navigateToApplicationSettingsPage({@required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obApplicationSettingsPage'),
            widget: OBApplicationSettingsPage()));
  }

  Future navigateToThemesPage({@required BuildContext context}) {
    return Navigator.push(context,
        OBSlideRightRoute(key: Key('obMenuThemes'), widget: OBThemesPage()));
  }

  Future navigateToUsefulLinksPage({@required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obMenuUsefulLinks'), widget: OBUsefulLinksPage()));
  }

  Future navigateToCommunityGuidelinesPage({@required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obCommunityGuidelinesPage'),
            widget: OBCommunityGuidelinesPage()));
  }

  Future navigateToConfirmRejectGuidelinesPage(
      {@required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obConfirmRejectGuidelinesPage'),
            widget: OBConfirmRejectGuidelines()));
  }

  Future<Post> navigateToSharePost(
      {@required BuildContext context, @required SharePostData sharePostData}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSharePostPage'),
            widget: OBSharePostPage(
              sharePostData: sharePostData,
            )));
  }

  Future<Post> navigateToSharePostWithCircles(
      {@required BuildContext context, @required SharePostData sharePostData}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSharePostWithCirclesPage'),
            widget: OBSharePostWithCirclesPage(
              sharePostData: sharePostData,
            )));
  }

  Future<Post> navigateToSharePostWithCommunity(
      {@required BuildContext context, @required SharePostData sharePostData}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSharePostWithCommunityPage'),
            widget: OBSharePostWithCommunityPage(
              sharePostData: sharePostData,
            )));
  }

  Future navigateToFollowsLists({@required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSeeFollowsLists'), widget: OBFollowsListsPage()));
  }

  Future navigateToUserInvites({@required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSeeUserInvites'), widget: OBUserInvitesPage()));
  }

  Future navigateToShareInvite(
      {@required BuildContext context, @required UserInvite userInvite}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obShareUserInvitePage'),
            widget: OBUserInviteDetailPage(
                userInvite: userInvite, showEdit: false)));
  }

  Future navigateToInviteDetailPage(
      {@required BuildContext context, @required UserInvite userInvite}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSeeUserInviteDetail'),
            widget: OBUserInviteDetailPage(
                userInvite: userInvite, showEdit: true)));
  }

  Future navigateToConnectionsCircles({@required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSeeConnectionsCircles'),
            widget: OBConnectionsCirclesPage()));
  }

  Future navigateToConnectionsCircle(
      {@required Circle connectionsCircle, @required BuildContext context}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSeeConnectionsCircle'),
            widget: OBConnectionsCirclePage(connectionsCircle)));
  }

  Future navigateToFollowsList({
    @required FollowsList followsList,
    @required BuildContext context,
  }) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSeeFollowsList'),
            widget: OBFollowsListPage(followsList)));
  }

  Future<void> navigateToPostReactions(
      {@required Post post,
      @required List<PostReactionsEmojiCount> reactionsEmojiCounts,
      @required BuildContext context,
      Emoji reactionEmoji}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obPostReactionsModal'),
            widget: OBPostReactionsModal(
              post: post,
              reactionsEmojiCounts: reactionsEmojiCounts,
              reactionEmoji: reactionEmoji,
            )));
  }

  Future<void> navigateToNotificationsSettings({
    @required BuildContext context,
  }) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obNotificationsSettingsPage'),
            widget: OBNotificationsSettingsPage()));
  }

  Future<void> navigateToBlockedUsers({
    @required BuildContext context,
  }) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obBlockedUsersPage'), widget: OBBlockedUsersPage()));
  }

  Future<void> navigateToConfirmBlockUser(
      {@required BuildContext context, @required User user}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obConfirmBlockUser'),
            widget: OBConfirmBlockUserModal(
              user: user,
            )));
  }

  Future<void> navigateToBlankPageWithWidget(
      {@required BuildContext context,
      @required String navBarTitle,
      @required Key key,
      @required Widget widget}) {
    return Navigator.push(
        context,
        OBSlideRightRoute(
            key: key,
            widget: CupertinoPageScaffold(
              navigationBar: OBThemedNavigationBar(
                title: navBarTitle,
              ),
              child: OBPrimaryColorContainer(
                child: widget,
              ),
            )));
  }
}
