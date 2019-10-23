import 'dart:async';
import 'package:Okuna/models/communities_list.dart';
import 'package:Okuna/models/community.dart';
import 'package:Okuna/models/theme.dart';
import 'package:Okuna/models/user.dart';
import 'package:Okuna/models/users_list.dart';
import 'package:Okuna/pages/home/lib/poppable_page_controller.dart';
import 'package:Okuna/pages/home/pages/search/widgets/top_posts.dart';
import 'package:Okuna/pages/home/pages/search/widgets/trending_posts.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/navigation_service.dart';
import 'package:Okuna/pages/home/pages/search/widgets/user_search_results.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/services/httpie.dart';
import 'package:Okuna/services/theme.dart';
import 'package:Okuna/services/theme_value_parser.dart';
import 'package:Okuna/services/toast.dart';
import 'package:Okuna/services/user.dart';
import 'package:Okuna/widgets/icon.dart';
import 'package:Okuna/widgets/page_scaffold.dart';
import 'package:Okuna/widgets/search_bar.dart';
import 'package:Okuna/widgets/theming/primary_color_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class OBMainSearchPage extends StatefulWidget {
  final OBMainSearchPageController controller;
  final OBSearchPageTab selectedTab;

  const OBMainSearchPage({Key key, this.controller,
    this.selectedTab = OBSearchPageTab.trending}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OBMainSearchPageState();
  }
}

class OBMainSearchPageState extends State<OBMainSearchPage> 
    with WidgetsBindingObserver, TickerProviderStateMixin {
  UserService _userService;
  ToastService _toastService;
  NavigationService _navigationService;
  LocalizationService _localizationService;
  ThemeService _themeService;
  ThemeValueParserService _themeValueParserService;

  bool _hasSearch;
  bool _isScrollingUp;
  bool _needsBootstrap;
  bool _userSearchRequestInProgress;
  bool _communitySearchRequestInProgress;
  String _searchQuery;
  List<User> _userSearchResults;
  List<Community> _communitySearchResults;
  OBTopPostsController _topPostsController;
  OBTrendingPostsController _trendingPostsController;
  TabController _tabController;
  AnimationController _animationController;
  Animation<Offset> _offset;
  double _heightTabs;
  OverlayEntry _searchBarAndTabsOverlay;

  OBUserSearchResultsTab _selectedSearchResultsTab;

  StreamSubscription<UsersList> _getUsersWithQuerySubscription;
  StreamSubscription<CommunitiesList> _getCommunitiesWithQuerySubscription;

  static const double OB_BOTTOM_TAB_BAR_HEIGHT = 50.0;
  static const double HEIGHT_SEARCH_BAR = 76.0;
  static const double HEIGHT_TABS_SECTION = 52.0;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null)
      widget.controller.attach(context: context, state: this);
    _topPostsController = OBTopPostsController();
    _trendingPostsController = OBTrendingPostsController();
    _userSearchRequestInProgress = false;
    _communitySearchRequestInProgress = false;
    _hasSearch = false;
    _isScrollingUp = true;
    _needsBootstrap = true;
    _heightTabs = HEIGHT_TABS_SECTION;
    _userSearchResults = [];
    _communitySearchResults = [];
    _selectedSearchResultsTab = OBUserSearchResultsTab.users;
    _tabController = new TabController(length: 2, vsync: this);
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    _offset = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, -1.0)).animate(_animationController);

    switch (widget.selectedTab) {
      case OBSearchPageTab.explore:
        _tabController.index = 1;
        break;
      case OBSearchPageTab.trending:
        _tabController.index = 0;
        break;
      default:
        throw "Unhandled tab index: ${widget.selectedTab}";
    }
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    _userService = openbookProvider.userService;
    _toastService = openbookProvider.toastService;
    _navigationService = openbookProvider.navigationService;
    _localizationService = openbookProvider.localizationService;
    _themeService = openbookProvider.themeService;
    _themeValueParserService = openbookProvider.themeValueParserService;

    if (_needsBootstrap) _bootstrap();

    return OBCupertinoPageScaffold(
        backgroundColor: Colors.white,
        child: OBPrimaryColorContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: _getIndexedStackWidget(),
              )
            ],
          ),
        ));
  }

  void _bootstrap() {
    Future.delayed(Duration(milliseconds: 0), () {
      this._searchBarAndTabsOverlay = this._createSearchBarAndTabsOverlayEntry();
      Overlay.of(context).insert(this._searchBarAndTabsOverlay);
    });
    _needsBootstrap = false;
  }

  Widget _getIndexedStackWidget() {
    double slidableSectionHeight = HEIGHT_SEARCH_BAR + HEIGHT_TABS_SECTION;

    return IndexedStack(
      index: _hasSearch ? 1: 0,
      children: <Widget>[
        SafeArea(
          bottom: false,
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: <Widget>[
              OBTrendingPosts(
                  controller: _trendingPostsController,
                  onScrollCallback :_onScrollPositionChange,
                  extraTopPadding: slidableSectionHeight
              ),
              OBTopPosts(
                  controller: _topPostsController,
                  onScrollCallback :_onScrollPositionChange,
                  extraTopPadding: slidableSectionHeight
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: HEIGHT_SEARCH_BAR),
          child: OBUserSearchResults(
            searchQuery: _searchQuery,
            userResults: _userSearchResults,
            userSearchInProgress: _userSearchRequestInProgress,
            communityResults: _communitySearchResults,
            communitySearchInProgress: _communitySearchRequestInProgress,
            onUserPressed: _onSearchUserPressed,
            onCommunityPressed: _onSearchCommunityPressed,
            selectedTab: _selectedSearchResultsTab,
            onScroll: _onScrollSearchResults,
            onTabSelectionChanged: _onSearchTabSelectionChanged,
          ),
        ),
      ],
    );
  }

  double _getExtraPaddingForSlidableSection() {
    MediaQueryData existingMediaQuery = MediaQuery.of(context);
    // flutter has diff heights for notched phones, see also issues with bottom tab bar
    // iphone with notches have a bottom padding, every other phone its 0
    // this adds 20.0 extra padding for notched phones
    double extraPadding = existingMediaQuery.padding.bottom != 0 ? 20.0 : 0;
    return extraPadding;
  }

  OverlayEntry _createSearchBarAndTabsOverlayEntry() {
    MediaQueryData existingMediaQuery = MediaQuery.of(context);
    final double extraPadding = _getExtraPaddingForSlidableSection();

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          left: 0,
          top: 0,
          height: HEIGHT_SEARCH_BAR + _heightTabs + extraPadding,
          width: existingMediaQuery.size.width,
          child: OBCupertinoPageScaffold(
          backgroundColor: Colors.transparent,
          child: _getSlideTransitionWidget(),
        ));
      });
  }

  Widget _getSlideTransitionWidget() {
    OBTheme theme = _themeService.getActiveTheme();
    Color tabIndicatorColor =
    _themeValueParserService.parseGradient(theme.primaryAccentColor).colors[1];
    Color tabLabelColor = _themeValueParserService.parseColor(theme.primaryTextColor);

    return SlideTransition(
      position: _offset,
      child: OBPrimaryColorContainer(
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              OBSearchBar(
                onSearch: _onSearch,
                hintText: _localizationService.user_search__search_text,
              ),
              _hasSearch ? const SizedBox(height: 0) : TabBar(
                  controller: _tabController,
                  tabs: <Widget>[
                    Tab(
                      icon: OBIcon(OBIcons.trending),
                    ),
                    Tab(
                      icon: OBIcon(OBIcons.explore),
                    ),
                  ],
                  isScrollable: false,
                  indicatorColor: tabIndicatorColor,
                  labelColor: tabLabelColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onScrollPositionChange(ScrollPosition position) {
    bool isScrollingUp = position.userScrollDirection == ScrollDirection.forward;
    _hideKeyboard();
    if (position.pixels < (HEIGHT_SEARCH_BAR + HEIGHT_TABS_SECTION)) {
      if (_offset.value.dy == -1.0) _showTabSection();
      return;
    }

    if (isScrollingUp == _isScrollingUp) return;

    if (isScrollingUp) {
      _showTabSection();
    } else {
      _hideTabSection();
    }
  }

  void _onSearch(String query) {
    _setSearchQuery(query);
    if (query.isEmpty) {
      _setHasSearch(false);
    } else {
      _setHasSearch(true);
      _searchWithQuery(query);
    }
  }

  void _onScrollSearchResults() {
    _hideKeyboard();
  }

  void _hideKeyboard() {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  Future<void> _searchWithQuery(String query) {
    return Future.wait([
      _searchForUsersWithQuery(query),
      _searchForCommunitiesWithQuery(query)
    ]);
  }

  Future<void> _searchForUsersWithQuery(String query) async {
    if (_getUsersWithQuerySubscription != null)
      _getUsersWithQuerySubscription.cancel();

    _setUserSearchRequestInProgress(true);

    _getUsersWithQuerySubscription =
        _userService.getUsersWithQuery(query).asStream().listen(
            (UsersList usersList) {
              _getUsersWithQuerySubscription = null;
              _setUserSearchResults(usersList.users);
            },
            onError: _onError,
            onDone: () {
              _setUserSearchRequestInProgress(false);
            });
  }

  Future<void> _searchForCommunitiesWithQuery(String query) async {
    if (_getCommunitiesWithQuerySubscription != null)
      _getCommunitiesWithQuerySubscription.cancel();

    _setCommunitySearchRequestInProgress(true);

    _getCommunitiesWithQuerySubscription =
        _userService.getCommunitiesWithQuery(query).asStream().listen(
            (CommunitiesList communitiesList) {
              _setCommunitySearchResults(communitiesList.communities);
            },
            onError: _onError,
            onDone: () {
              _setCommunitySearchRequestInProgress(false);
            });
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage, context: context);
    } else {
      _toastService.error(message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _onSearchTabSelectionChanged(OBUserSearchResultsTab newSelection) {
    _selectedSearchResultsTab = newSelection;
  }

  void _setUserSearchRequestInProgress(bool requestInProgress) {
    setState(() {
      _userSearchRequestInProgress = requestInProgress;
    });
  }

  void _setCommunitySearchRequestInProgress(bool requestInProgress) {
    setState(() {
      _communitySearchRequestInProgress = requestInProgress;
    });
  }

  void _hideTabSection() {
    _animationController.forward();
    setState(() {
      _isScrollingUp = false;
    });
  }

  void _showTabSection() {
    _animationController.reverse();
    setState(() {
      _isScrollingUp = true;
    });
  }

  void _setHasSearch(bool hasSearch) {
    setState(() {
      _hasSearch = hasSearch;
    });
    _setHeightTabsZero(_hasSearch);
  }

  void _setHeightTabsZero(bool hasSearch) {
    setState(() {
      _heightTabs = hasSearch == true ? 5.0 : HEIGHT_TABS_SECTION;
    });
  }

  void _setSearchQuery(String searchQuery) {
    setState(() {
      _searchQuery = searchQuery;
    });
  }

  void _setUserSearchResults(List<User> searchResults) {
    setState(() {
      _userSearchResults = searchResults;
    });
  }

  void _setCommunitySearchResults(List<Community> searchResults) {
    setState(() {
      _communitySearchResults = searchResults;
    });
  }

  void _onSearchUserPressed(User user) {
    _hideKeyboard();
    _navigationService.navigateToUserProfile(user: user, context: context);
  }

  void _onSearchCommunityPressed(Community community) {
    _hideKeyboard();
    _navigationService.navigateToCommunity(
        community: community, context: context);
  }

  void scrollToTop() {
    if (_tabController.index == 0) {
      _trendingPostsController.scrollToTop();
    } else if (_tabController.index == 1) {
      _topPostsController.scrollToTop();
    }
  }
}

class OBMainSearchPageController extends PoppablePageController {
  OBMainSearchPageState _state;

  void attach({@required BuildContext context, OBMainSearchPageState state}) {
    super.attach(context: context);
    _state = state;
  }

  void scrollToTop() {
    _state.scrollToTop();
  }
}

enum OBSearchPageTab { explore, trending }