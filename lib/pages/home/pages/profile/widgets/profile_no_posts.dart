import 'package:Openbook/models/user.dart';
import 'package:Openbook/provider.dart';
import 'package:Openbook/services/localization.dart';
import 'package:Openbook/services/user.dart';
import 'package:Openbook/widgets/alerts/button_alert.dart';
import 'package:Openbook/widgets/icon.dart';
import 'package:flutter/material.dart';

class OBProfileNoPosts extends StatelessWidget {
  final User user;
  final VoidCallback onWantsToRefreshProfile;

  OBProfileNoPosts(this.user, {@required this.onWantsToRefreshProfile});

  @override
  Widget build(BuildContext context) {
    var provider = OpenbookProvider.of(context);
    UserService _userService = provider.userService;
    bool isLoggedInUser = _userService.isLoggedInUser(user);
    LocalizationService localizationService = provider.localizationService;
    String name = user.getProfileName();

    return OBButtonAlert(
      text: isLoggedInUser ? localizationService.post__have_not_shared_anything: localizationService.post__user_has_not_shared_anything(name),
      onPressed: onWantsToRefreshProfile,
      buttonText: localizationService.post__trending_posts_refresh,
      buttonIcon: OBIcons.refresh,
      assetImage: 'assets/images/stickers/perplexed-owl.png',
    );
  }
}
