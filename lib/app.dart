import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/utils/app_bindings.dart';
import 'package:fit_office/src/utils/theme/theme.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/exercise_pop_up.dart'; 


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      /// -- README(Docs[3]) -- Bindings
      initialBinding: InitialBinding(),
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      /// -- README(Docs[4]) -- To use Screen Transitions here
      /// -- README(Docs[5]) -- Home Screen or Progress Indicator
      home: Stack(
        children: [
          /// -- Dein bisheriger Startscreen (z.B. Progress Indicator oder später Splash/Login)
          const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),

          /// -- Das neue globale Popup für die laufende Übung
          const ExerciseMiniPopup(),
        ],
      ),
    );
  }
}