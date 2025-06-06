import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:fit_office/firebase_options.dart';
import 'package:fit_office/src/repository/authentication_repository/authentication_repository.dart';
import 'package:fit_office/global_overlay.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  /// -- README(Update[]) -- GetX Local Storage
  await GetStorage.init();

  /// -- README(Docs[1]) -- Await Splash until other items Load
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  /// -- README(Docs[2]) -- Initialize Firebase & Authentication Repository
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((_) {
    Get.put(AuthenticationRepository());
  });

  /// -- Main App Starts here (app.dart) ...
  runApp(const App());

  //TODO: Ist das der richtige Zeitpunkt? Da es ja erst nach dem Build kommt? Somit auch nach dem Splash Loading.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    GlobalExerciseOverlay().init(Get.context!);
  });
}
