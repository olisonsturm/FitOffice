import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:fit_office/firebase_options.dart';
import 'package:fit_office/src/repository/authentication_repository/authentication_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

/// ------ For Docs & Updates Check ------
/// ------------- README.md --------------

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  /// -- README(Update[]) -- GetX Local Storage
  await GetStorage.init();

  /// -- README(Docs[1]) -- Await Splash until other items Load
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  /// -- README(Docs[2]) -- Initialize Firebase & Authentication Repository
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((_) => Get.put(AuthenticationRepository()));

  /// -- README(Docs[3]) -- Initialize Firebase Storage
  if (defaultTargetPlatform != TargetPlatform.windows) {
    // window currently don't support storage emulator
    final emulatorHost =
    (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
        ? '10.0.2.2'
        : 'localhost';

    await FirebaseStorage.instance.useStorageEmulator(emulatorHost, 9199);
  }


  /// -- Main App Starts here (app.dart) ...
  runApp(const App());

}

