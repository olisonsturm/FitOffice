import 'dart:async';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:fit_office/src/utils/helper/helper_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class DeepLinkService extends GetxService {

  static Future<void> initDeepLinks() async {
    // Handle initial dynamic link
    final PendingDynamicLinkData? initialLink =
    await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      handleDeepLink(initialLink.link.toString());
    }

    // Listen for dynamic links when app is in foreground
    // TODO: Migrating from Firebase Dynamic Links to Branch.io in the future. Will be deprecated in August 2024.
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      handleDeepLink(dynamicLinkData.link.toString());
    }).onError((error) {
      debugPrint('Dynamic Link error: $error');
    });
  }

  static void handleDeepLink(String link) {
    debugPrint('Received deep link: $link');
    final uri = Uri.parse(link);

    // Handle friend request parameter from both URI schemes and HTTPS links
    final userId = uri.queryParameters['userId'];
    if (userId != null) {
      _handleFriendRequest(userId);
      return;
    }

    // Legacy path-based routing
    switch(uri.path) {
      case '/friend-request':
        final pathUserId = uri.queryParameters['userId'];
        if (pathUserId != null) {
          _handleFriendRequest(pathUserId);
        } else {
          debugPrint('Friend request missing userId parameter');
        }
        break;
      default:
        debugPrint('Unknown deep link path: ${uri.path}');
    }
  }

  static Future<String> generateFriendRequestLink(String userId) async {
    final dynamicLinkParams = DynamicLinkParameters(
      uriPrefix: 'https://fitoffice.page.link',
      link: Uri.parse('https://fitoffice.page.link/friend-request?userId=$userId'),
      androidParameters: const AndroidParameters(
        packageName: 'de.dhbwravensburg.fitoffice',
        minimumVersion: 0,
      ),
      // TODO: Not working on IOS yet, developer account/team needed for Universal Links! Only with signed app and provisioning profile.
      iosParameters: const IOSParameters(
        bundleId: 'de.dhbw-ravensburg.FitOffice',
        minimumVersion: '0',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
          title: 'Friend Request',
          description: 'Add me as a friend on FitOffice@DHBW!'
      ),
    );

    final shortLink = await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
    return shortLink.shortUrl.toString();
  }

  Future<void> shareFriendRequestLink(String currentUserId) async {
    try {
      final link = await DeepLinkService.generateFriendRequestLink(currentUserId);
      SharePlus.instance.share(
        ShareParams(
          text: 'Add me as a friend on FitOffice@DHBW!\n$link',
          subject: 'Friend Request'
        )
      );
    } catch (e) {
      debugPrint('Link Generation Failed');
      Helper.errorSnackBar(title: 'Share Error', message: 'Could not generate friend request link');
    }
  }
  static void _handleFriendRequest(String userId) {
    debugPrint('Processing friend request for user: $userId');
    // Example: UserRepository().sendFriendRequest(userId);

    // Show confirmation to user
    Helper.successSnackBar(title: 'Friend Request', message: 'Friend request sent successfully');
  }
}