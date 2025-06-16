import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/colors.dart';

class TDialogTheme {
  TDialogTheme._();

  // Button styles for dialogs
  static final ButtonStyle _lightCancelButtonStyle = TextButton.styleFrom(
    foregroundColor: tDarkGreyColor,
    backgroundColor: Colors.transparent,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static final ButtonStyle _lightDeleteButtonStyle = TextButton.styleFrom(
    foregroundColor: tWhiteColor,
    backgroundColor: tRedColor,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static final ButtonStyle _lightConfirmButtonStyle = TextButton.styleFrom(
    foregroundColor: tWhiteColor,
    backgroundColor: tPrimaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static final ButtonStyle _darkCancelButtonStyle = TextButton.styleFrom(
    foregroundColor: tLightGreyColor,
    backgroundColor: Colors.transparent,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static final ButtonStyle _darkDeleteButtonStyle = TextButton.styleFrom(
    foregroundColor: tWhiteColor,
    backgroundColor: tRedColor,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static final ButtonStyle _darkConfirmButtonStyle = TextButton.styleFrom(
    foregroundColor: tDarkColor,
    backgroundColor: tPrimaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  // Light Dialog Theme
  static DialogThemeData lightDialogTheme = DialogThemeData(
    backgroundColor: tWhiteColor,
    elevation: 5,
    titleTextStyle: const TextStyle(
      color: tDarkColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: const TextStyle(
      color: tDarkGreyColor,
      fontSize: 16,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  );

  // Dark Dialog Theme
  static DialogThemeData darkDialogTheme = DialogThemeData(
    backgroundColor: tDarkColor,
    elevation: 5,
    titleTextStyle: const TextStyle(
      color: tWhiteColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: const TextStyle(
      color: tPaleWhiteColor,
      fontSize: 16,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  );

  // Helper method to get button styles for light theme
  static ButtonStyle getLightCancelButtonStyle() => _lightCancelButtonStyle;
  static ButtonStyle getLightDeleteButtonStyle() => _lightDeleteButtonStyle;
  static ButtonStyle getLightConfirmButtonStyle() => _lightConfirmButtonStyle;

  // Helper method to get button styles for dark theme
  static ButtonStyle getDarkCancelButtonStyle() => _darkCancelButtonStyle;
  static ButtonStyle getDarkDeleteButtonStyle() => _darkDeleteButtonStyle;
  static ButtonStyle getDarkConfirmButtonStyle() => _darkConfirmButtonStyle;
}
