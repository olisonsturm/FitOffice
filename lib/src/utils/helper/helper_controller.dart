import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';

/// Helper class for common functionalities like validations and snack bars
/// This class extends GetxController to leverage GetX's reactive state management.
/// It provides static methods for validating user inputs such as usernames, emails, and passwords,
/// as well as methods for displaying various types of snack bars (success, warning, error, modern).
class Helper extends GetxController {

  /* -- ============= VALIDATIONS ================ -- */
  /// Validates a username based on specific criteria:
  /// - Must not be empty
  /// - Must match the regex pattern for valid usernames (lowercase letters, digits, dots, and underscores)
  /// - Must be at least 4 characters long
  /// @param value The username string to validate.
  /// @param context The BuildContext for localization.
  /// @return A string error message if validation fails, or null if it passes.
  static String? validateUsername(String? value, BuildContext context) {
    if (value!.isEmpty) return AppLocalizations.of(context)!.tUserNameCannotEmpty;
    if (!RegExp(r'^[a-z0-9._]+$').hasMatch(value)) return AppLocalizations.of(context)!.tInvalidUserName;
    if (value.length < 4) return AppLocalizations.of(context)!.tUserNameLength;
    return null;
  }

  /// Checks if a username is already taken in the Firestore database.
  /// @param username The username string to check.
  /// @return A Future that resolves to true if the username is taken, false otherwise.
  static Future<bool> isUsernameTaken(String username) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  /// Validates a full name to ensure it contains only letters and spaces.
  /// @param value The full name string to validate.
  /// @param context The BuildContext for localization.
  /// @return A string error message if validation fails, or null if it passes.
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
  /// Validates an email address to ensure it is not empty, has a valid format, and DHBW domain.
  /// @param value The email string to validate.
  /// @param context The BuildContext for localization.
  /// @return A string error message if validation fails, or null if it passes.
  static String? validateEmail(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return AppLocalizations.of(context)!.tEmailCannotEmpty;
    if (!GetUtils.isEmail(value)) return AppLocalizations.of(context)!.tInvalidEmailFormat;
    if (!RegExp(r'^[\w\.-]+@[\w\.-]*dhbw[\w\.-]*\.de$').hasMatch(value)) return AppLocalizations.of(context)!.tOnlyDHBWEmailAllowed;
    return null;
  }

  /// Validates a password to ensure it meets specific criteria:
  /// - At least 8 characters long
  /// - Contains at least one uppercase letter, one lowercase letter, one digit, and one special character.
  /// @param value The password string to validate.
  /// @param context The BuildContext for localization.
  /// @return A string error message if validation fails, or null if it passes.
  static String? validatePassword(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return AppLocalizations.of(context)!.tPasswordEmptyException;

    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return AppLocalizations.of(context)!.tPasswordRequirements;
    }
    return null;
  }

  /// Validates a password confirmation to ensure it matches the original password.
  /// @param value The confirmation password string to validate.
  /// @param controller The controller containing the original password.
  /// @param context The BuildContext for localization.
  /// @return A string error message if validation fails, or null if it passes.
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
  /// Displays a success snack bar with a title and message.
  /// @param title The title of the snack bar.
  /// @param message The message to display in the snack bar.
  /// @return void
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

  /// Displays a warning snack bar with a title and message.
  /// @param title The title of the snack bar.
  /// @param message The message to display in the snack bar.
  /// @return void
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

  /// Displays an error snack bar with a title and message.
  /// @param title The title of the snack bar.
  /// @param message The message to display in the snack bar.
  /// @return void
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

  /// Displays a modern snack bar with a title and message.
  /// @param title The title of the snack bar.
  /// @param message The message to display in the snack bar.
  /// @return void
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
