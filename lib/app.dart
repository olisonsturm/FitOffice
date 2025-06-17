import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fit_office/src/repository/authentication_repository/authentication_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/utils/app_bindings.dart';
import 'package:fit_office/src/utils/theme/theme.dart';
import 'dart:io';

import 'main.dart';

class App extends StatefulWidget {
  final Locale initialLocale;
  const App({super.key, required this.initialLocale});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    _appLocale = widget.initialLocale;

    // Berechtigungen anfragen (iOS)
    FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    Future<void> saveFcmToken() async {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (kDebugMode) {
          print("Firebase Messaging Token: $token");
        }
        final authRepo = Get.find<AuthenticationRepository>();
        final userId = authRepo.getUserID;
        if (userId.isNotEmpty) {
          final doc = FirebaseFirestore.instance.collection('users').doc(userId);
          await doc.set({
            'fcmToken': token,
          }, SetOptions(merge: true));
        } else {
          if (kDebugMode) {
            print("User not authenticated. FCM token not saved.");
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error saving FCM token: $e");
        }
      }
    }

    // iOS: Wait for APNS token before getting FCM token
    if (Platform.isIOS) {
      FirebaseMessaging.instance.getAPNSToken().then((apnsToken) async {
        if (apnsToken != null) {
          await saveFcmToken();
        } else {
          // Optionally, retry or listen for token refresh
          FirebaseMessaging.instance.onTokenRefresh.listen((_) {
            saveFcmToken();
          });
        }
      });
    } else {
      // Android/web: get token directly
      saveFcmToken();
    }

    // Wenn die App im Vordergrund ist, Notifications als lokale Notifications anzeigen
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      // AndroidNotification? android = message.notification?.android;

      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'friend_request_channel',
              'Friend Request Notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });

  }
  late Locale _appLocale;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      /// -- README(Docs[3]) -- Bindings
      initialBinding: InitialBinding(),
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      locale: _appLocale,
      fallbackLocale: Locale('en'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'),
        Locale('de'),
      ],

      /// -- README(Docs[4]) -- To use Screen Transitions here
      /// -- README(Docs[5]) -- Home Screen or Progress Indicator
      home: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
