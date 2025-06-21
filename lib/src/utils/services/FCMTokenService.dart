import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'dart:io';

import '../../repository/authentication_repository/authentication_repository.dart';

class FCMTokenService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Initialize FCM and get token with proper APNS handling
  static Future<void> initializeFCM() async {
    try {
      // Request notification permissions first
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print('User granted permission');
        }

        // Get and update FCM token
        await _getFCMTokenSafely();

        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen((token) {
          updateFcmToken(token);
        });
      } else {
        if (kDebugMode) {
          print('User declined or has not accepted permission');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error initializing FCM: $e");
      }
    }
  }

  /// Safely get FCM token with APNS handling for iOS
  static Future<void> _getFCMTokenSafely() async {
    try {
      String? token;

      if (Platform.isIOS) {
        // For iOS, ensure APNS token is available first
        String? apnsToken = await _firebaseMessaging.getAPNSToken();

        if (apnsToken == null) {
          if (kDebugMode) {
            print("APNS token not available yet, waiting...");
          }

          // Wait for APNS token with timeout
          int attempts = 0;
          const maxAttempts = 10;
          const delayDuration = Duration(seconds: 1);

          while (apnsToken == null && attempts < maxAttempts) {
            await Future.delayed(delayDuration);
            apnsToken = await _firebaseMessaging.getAPNSToken();
            attempts++;

            if (kDebugMode) {
              print("Waiting for APNS token... Attempt $attempts/$maxAttempts");
            }
          }

          if (apnsToken == null) {
            if (kDebugMode) {
              print("APNS token still not available after $maxAttempts attempts");
            }
            return;
          }
        }

        if (kDebugMode) {
          print("APNS token available: ${apnsToken.substring(0, 10)}...");
        }
      }

      // Now get FCM token
      token = await _firebaseMessaging.getToken();

      if (token != null) {
        updateFcmToken(token);
        if (kDebugMode) {
          print("FCM token obtained: ${token.substring(0, 10)}...");
        }
      } else {
        if (kDebugMode) {
          print("Failed to get FCM token");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting FCM token: $e");
      }
    }
  }

  /// Update FCM token in Firestore
  static void updateFcmToken(String token) {
    try {
      final userId = Get.find<AuthenticationRepository>().getUserID;
      if (userId.isNotEmpty) {
        final doc = FirebaseFirestore.instance.collection('users').doc(userId);
        doc.set({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
          'platform': Platform.isIOS ? 'ios' : 'android',
        }, SetOptions(merge: true));

        if (kDebugMode) {
          print("FCM token updated successfully for user: $userId");
        }
      } else {
        if (kDebugMode) {
          print("User ID is empty. Cannot update FCM token.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating FCM token: $e");
      }
    }
  }
}