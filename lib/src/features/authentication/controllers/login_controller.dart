import 'package:fit_office/src/utils/services/FCMTokenService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/l10n/app_localizations.dart';

import '../../../repository/authentication_repository/authentication_repository.dart';
import '../../../utils/helper/helper_controller.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  /// TextField Controllers to get data from TextFields
  final showPassword = false.obs;
  final email = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  /// Loader
  final isLoading = false.obs;

  /// [EmailAndPasswordLogin]
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
