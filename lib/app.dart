import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fit_office/src/utils/services/fcm_token_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/utils/app_bindings.dart';
import 'package:fit_office/src/utils/theme/theme.dart';

import 'main.dart';

/// Main application widget that initializes the app with the given locale
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

    FCMTokenService.initializeFCM();

    // Wenn die App im Vordergrund ist, Notifications als lokale Notifications anzeigen
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
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
              channelDescription: 'Channel for friend request notifications',
              icon: '@mipmap/launcher_icon',
            ),
          ),
          payload: message.data['type'],
        );
      }
    });

  }
  late Locale _appLocale;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      /// Initial binding for the application
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

      /// Initial route of the application
      /// GetX will handle the further navigation/routing
      home: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
