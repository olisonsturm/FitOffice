import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/colors.dart';

import '../../../constants/sizes.dart';

class TTextFormFieldTheme {
  TTextFormFieldTheme._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    prefixIconColor: tSecondaryColor,
    floatingLabelStyle: const TextStyle(color: tSecondaryColor),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(tBorderRadius),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(tBorderRadius),
      borderSide: const BorderSide(width: 2, color: tSecondaryColor),
    ),
  );

  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    prefixIconColor: tPrimaryColor,
    floatingLabelStyle: const TextStyle(color: tPrimaryColor),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(tBorderRadius),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(tBorderRadius),
      borderSide: const BorderSide(width: 2, color: tPrimaryColor),
    ),
  );
}
