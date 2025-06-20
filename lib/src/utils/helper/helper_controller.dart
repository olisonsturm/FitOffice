import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class Helper extends GetxController {


  /* -- ============= VALIDATIONS ================ -- */
  static String? validateUsername(String? value, BuildContext context) {
    if (value!.isEmpty) return AppLocalizations.of(context)!.tUserNameCannotEmpty;
    if (!RegExp(r'^[a-z0-9._]+$').hasMatch(value)) return AppLocalizations.of(context)!.tInvalidUserName;
    if (value.length < 4) return AppLocalizations.of(context)!.tUserNameLength;
    return null;
  }

  static Future<bool> isUsernameTaken(String username) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  static String? validateFullName(String? value, BuildContext context) {
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value!)) return AppLocalizations.of(context)!.tInvalidFullName;
    return null;
  }

  /**
      student@stud.dhbw-ravensburg.de
      john.doe@dhbw.de
      jane_doe@stud.dhbw.de
      user123@dhbw-karlsruhe.de
      example.user@stud.dhbw-mannheim.de
      firstname.lastname@dhbw-stuttgart.de
      test.email@stud.dhbw-heilbronn.de
      user.name@dhbw-loerrach.de
      sample_user@stud.dhbw-villingen-schwenningen.de
      another.example@dhbw-mosbach.de
   *////
  static String? validateEmail(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return AppLocalizations.of(context)!.tEmailCannotEmpty;
    if (!GetUtils.isEmail(value)) return AppLocalizations.of(context)!.tInvalidEmailFormat;
    // TODO: Uncomment this line to restrict email domains after development phase
    //if (!RegExp(r'^[\w\.-]+@[\w\.-]*dhbw[\w\.-]*\.de$').hasMatch(value)) return tOnlyDHBWEmailAllowed;
    return null;
  }

  static String? validatePassword(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return AppLocalizations.of(context)!.tPasswordEmptyException;

    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return AppLocalizations.of(context)!.tPasswordRequirements;
    }
    return null;
  }

  static String? repeatPassword(String value, controller, BuildContext context) {
    if (value.isEmpty) {
      return AppLocalizations.of(context)!.tPleaseRepeatPassword;
    }
    if (value != controller.password.text) {
      return AppLocalizations.of(context)!.tPasswordsDoNotMatch;
    }
    return null;
  }


  /* -- ============= SNACK-BARS ================ -- */

  static void successSnackBar({required String title, message}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: tWhiteColor,
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 6),
      margin: const EdgeInsets.all(tDefaultSpace - 10),
      icon: const Icon(LineAwesomeIcons.check_circle, color: tWhiteColor),
    );
  }

  static void warningSnackBar({required String title, message}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: tWhiteColor,
      backgroundColor: Colors.orange,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 6),
      margin: const EdgeInsets.all(tDefaultSpace - 10),
      icon: Icon(LineAwesomeIcons.exclamation_circle_solid, color: tWhiteColor),
    );
  }

  static void errorSnackBar({required String title, message}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: tWhiteColor,
      backgroundColor: Colors.red.shade600,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 6),
      margin: const EdgeInsets.all(tDefaultSpace - 10),
      icon: const Icon(LineAwesomeIcons.times_circle, color: tWhiteColor),
    );
  }

  static void modernSnackBar({required String title, message}) {
    Get.snackbar(title, message,
        isDismissible: true,
        colorText: tWhiteColor,
        backgroundColor: tGreyColor,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(tDefaultSpace - 10),
    );
  }
}
