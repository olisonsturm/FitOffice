import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../../constants/text_strings.dart';

class Helper extends GetxController {

  /* -- ============= VALIDATIONS ================ -- */

  // TODO: Add validation to only allow stud.dhbw-ravensburg.de email addresses
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
   */
  static String? validateEmail(value) {
    if (value == null || value.isEmpty) return tEmailCannotEmpty;
    if (!GetUtils.isEmail(value)) return tInvalidEmailFormat;
    if (!RegExp(r'^[\w\.-]+@[\w\.-]*dhbw[\w\.-]*\.de$').hasMatch(value)) {
      return tOnlyDHBWEmailAllowed;
    }
    return null;
  }

  static String? validatePassword(value) {
    if (value == null || value.isEmpty) return 'Password cannot be empty';

    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return tPasswordRequirements;
    }
    return null;
  }


  /* -- ============= SNACK-BARS ================ -- */

  static successSnackBar({required title, message}) {
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

  static warningSnackBar({required title, message}) {
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
      icon: const Icon(LineAwesomeIcons.exclamation_circle, color: tWhiteColor),
    );
  }

  static errorSnackBar({required title, message}) {
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

  static modernSnackBar({required title, message}) {
    Get.snackbar(title, message,
        isDismissible: true,
        colorText: tWhiteColor,
        backgroundColor: Colors.blueGrey,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(tDefaultSpace - 10),
    );
  }
}
