import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:fit_office/src/features/authentication/screens/mail_verification/mail_verification.dart';
import 'package:fit_office/src/features/authentication/screens/welcome/welcome_screen.dart';
import 'package:fit_office/src/features/core/screens/dashboard/dashboard.dart';
import '../../features/authentication/screens/on_boarding/on_boarding_screen.dart';
import 'exceptions/t_exceptions.dart';

/// AuthenticationRepository is responsible for managing user authentication
/// using Firebase Authentication.
/// It provides methods for email/password login and registration
class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  /// Variables
  late final Rx<User?> _firebaseUser;
  final _auth = FirebaseAuth.instance;
  final userStorage = GetStorage(); // Use this to store data locally (e.g. OnBoarding)

  /// Getters
  User? get firebaseUser => _firebaseUser.value;

  String get getUserID => firebaseUser?.uid ?? "";

  String get getUserEmail => firebaseUser?.email ?? "";

  String get getDisplayName => firebaseUser?.displayName ?? "";

  String get getPhoneNo => firebaseUser?.phoneNumber ?? "";

  /// Loads when app Launch from main.dart
  /// This method initializes the Firebase user stream and sets the initial screen based on the user's authentication status.
  @override
  void onReady() {
    _firebaseUser = Rx<User?>(_auth.currentUser);
    _firebaseUser.bindStream(_auth.userChanges());
    FlutterNativeSplash.remove();
    setInitialScreen(_firebaseUser.value);
    // ever(_firebaseUser, _setInitialScreen);
  }

  /// Setting initial screen
  /// This method checks if the user is authenticated and whether their email is verified.
  /// Parameter [user] is the current Firebase user.
  /// If the user is authenticated and their email is verified, it navigates to the Dashboard.
  Future<void> setInitialScreen(User? user) async {
    if (user != null) {

      user.emailVerified ? Get.offAll(() => const Dashboard(initialIndex: 1,)) : Get.offAll(() => const MailVerification());
    } else {
      // Check if it's the user's first time, then navigate accordingly
      userStorage.writeIfNull('isFirstTime', true);
      // Remove the splash screen
      userStorage.read('isFirstTime') != true
          ? Get.offAll(() => const WelcomeScreen())
          : Get.offAll(() => const OnBoardingScreen());
    }
  }

  /* ---------------------------- Email & Password sign-in ---------------------------------*/

  /// EmailAuthentication - LOGIN
  /// This method allows users to log in using their email and password.
  /// It handles FirebaseAuthException to provide custom error messages.
  /// @param email The user's email address.
  /// @param password The user's password.
  /// @throws String if the login fails due to an authentication error.
  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      final result = TExceptions.fromCode(e.code); // Throw custom [message] variable
      throw result.message;
    } catch (_) {
      const result = TExceptions();
      throw result.message;
    }
  }

/// EmailAuthentication - REGISTER
/// Allows users to register using their email and password.
/// Handles FirebaseAuthException to provide custom error messages.
/// Parameters: [email] (user's email address), [password] (user's password)
/// Throws a String if registration fails due to an authentication error.
  Future<void> registerWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password).then((userCredential) async {
        final user = userCredential.user;

        // Wait for 2 seconds to ensure the onCreate function is executed
        await Future.delayed(const Duration(seconds: 2));

        // Fetch the ID token with force refresh
        final idToken = await user?.getIdToken(true);

        // Log the new ID token with claims
        if (kDebugMode) {
          print("New ID Token with Claims: $idToken");
        }
      });
    } on FirebaseAuthException catch (e) {
      final ex = TExceptions.fromCode(e.code);
      throw ex.message;
    } catch (_) {
      const ex = TExceptions();
      throw ex.message;
    }
  }

  /// EmailVerification - MAIL VERIFICATION
  /// This method sends a verification email to the user's email address.
  /// It handles FirebaseAuthException to provide custom error messages.
  /// @throws String if the email verification fails due to an authentication error.
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      final ex = TExceptions.fromCode(e.code);
      throw ex.message;
    } catch (_) {
      const ex = TExceptions();
      throw ex.message;
    }
  }

  /* ---------------------------- ./end Federated identity & social sign-in ---------------------------------*/

  /// LogoutUser - Valid for any authentication.
  /// This method logs out the current user from Firebase Authentication.
  /// It handles FirebaseAuthException to provide custom error messages.
  /// @throws String if the logout fails due to an authentication error.
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const WelcomeScreen());
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    } on FormatException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Unable to logout. Try again.';
    }
  }

  /// DeleteUser - Valid for any authentication.
  /// This method deletes the current user from Firebase Authentication.
  /// It handles FirebaseAuthException to provide custom error messages.
  /// @throws String if the deletion fails due to an authentication error.
  Future<void> deleteUser() async {
    try {
      await _auth.currentUser?.delete();
      Get.offAll(() => const WelcomeScreen());
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    } on FormatException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Unable to delete user. Try again.';
    }
  }
}
