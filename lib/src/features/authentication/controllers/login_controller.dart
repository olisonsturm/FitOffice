import 'package:fit_office/src/utils/services/fcm_token_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/l10n/app_localizations.dart';

import '../../../repository/authentication_repository/authentication_repository.dart';
import '../../../utils/helper/helper_controller.dart';

/// LoginController is responsible for managing the login process.
/// It handles user input, form validation, and authentication using email and password.
class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  // TextField Controllers to get data from TextFields
  final showPassword = false.obs;
  final email = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  // Loader
  final isLoading = false.obs;

  /// EmailAndPasswordLogin
  /// This method validates the form, checks if the user exists,
  /// and logs in the user with Firebase Authentication.
  /// @param context The BuildContext for localization and UI updates.
  /// It sets the initial screen based on the user's authentication status.
  Future<void> login(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    try {
      isLoading.value = true;
      if (!loginFormKey.currentState!.validate()) {
        isLoading.value = false;
        return;
      }
      final auth = AuthenticationRepository.instance;
      await auth.loginWithEmailAndPassword(email.text.trim(), password.text.trim());
      auth.setInitialScreen(auth.firebaseUser);

      // Save FCM token after login
      await FCMTokenService.initializeFCM();
    } catch (e) {
      isLoading.value = false;
      Helper.errorSnackBar(title: localizations.tOhSnap, message: e.toString());
    }
  }
}
