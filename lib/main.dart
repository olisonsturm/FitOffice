import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fit_office/src/utils/services/deep_link_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

/// Firebase Messaging Background Handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Wird aufgerufen, wenn eine Nachricht im Hintergrund/terminated State ankommt
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Handling a background message: ${message.messageId}');
  }
}

/// Main function to initialize the app
Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  /// GetX Local Storage
  await GetStorage.init();

  /// Await Splash until other items Load
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  /// Initialize Firebase & Authentication Repository
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((_) {
    Get.put(AuthenticationRepository());

    Get.put(ExerciseTimerController(), permanent: true);
    Get.put(FriendsController(), permanent: true);
  });

  /// Ensure Firebase authentication is initialized before calling updateFcmTokenIfAuthenticated
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// Initialize Deep Links
  await DeepLinkService.initDeepLinks();

  /// Shared Preferences for Locale
  final prefs = await SharedPreferences.getInstance();
  final localeCode = prefs.getString('locale') ?? 'en';

  /// Initialize Messaging & Local Notifications
  // Android
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/launcher_icon');
  // iOS TODO: Will not work without Developer Account because of APNS!!! So no push notifications on iOS!!!
  const DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  /// Initialize Flutter Local Notifications Plugin
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Register notification channel before any notifications are shown (Android)
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'friend_request_channel',
    'Friend Request Notifications',
    description: 'Channel for friend request notifications',
    importance: Importance.max,
  );
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  /// Set preferred orientations to portrait only
  /// This is important to ensure the app does not rotate
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(App(initialLocale: Locale(localeCode)));
  });

  /// Initialize Global Overlay
  WidgetsBinding.instance.addPostFrameCallback((_) {
    GlobalExerciseOverlay().init(Get.context!);
  });
}
