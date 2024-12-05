# FitOffice

The original FitOffice@DHBW App. Made with ❤️ at DHBW Ravensburg.
 
## ERROR
  1. If you are facing [The current Flutter SDK version is 3.10.6. Because login_flutter_app depends on get >=4.6.6 <5.0.0-beta.1 which requires Flutter SDK version >=3.13.0, version solving failed.].
     [Solution]: run flutter upgrade to upgrade your flutter sdk to the latest. Make sure to have an active internet connection.

## Docs
     1. Show Splash Screen till data loads & when loaded call FlutterNativeSplash.remove(); 
        In this case I'm removing it inside AuthenticationRepository() -> onReady() method.
     2. Before running App - Initialize Firebase and after initialization, Call Authentication Repository so that It can check which screen to show.
     3. Solves the issues of Get.lazyPut and Get.Put() by defining all Controllers in InitialBinding
     4. Screen Transitions: Use these 2 properties in GetMaterialApp
            - defaultTransition: Transition.leftToRightWithFade,
            - transitionDuration: const Duration(milliseconds: 500),
     5. HOME SCREEN:
            - Show Progress Indicator OR SPLASH SCREEN until Screen Loads all its data from cloud.
            - Let the AuthenticationRepository decide which screen to appear as first.
     6. Authentication Repository:
            - Used for user authentication and screen redirects.
            - Called from main.dart on app launch.
            - onReady() sets firebaseUser state, removes Splash Screen, and redirects to relevant screen.
            - To use in other classes: [final auth = AuthenticationRepository.instance;]
