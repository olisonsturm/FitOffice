import 'package:fit_office/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/src/utils/theme/widget_themes/appbar_theme.dart';
import 'package:fit_office/src/utils/theme/widget_themes/elevated_button_theme.dart';
import 'package:fit_office/src/utils/theme/widget_themes/outlined_button_theme.dart';
import 'package:fit_office/src/utils/theme/widget_themes/text_field_theme.dart';
import 'package:fit_office/src/utils/theme/widget_themes/text_theme.dart';

class TAppTheme {
  TAppTheme._();

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    textTheme: TTextTheme.lightTextTheme,
    appBarTheme: TAppBarTheme.lightAppBarTheme,
    scaffoldBackgroundColor: tWhiteColor,
    primaryColor: tPrimaryColor,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: tWhiteColor,
      selectedItemColor: tPrimaryColor,
      unselectedItemColor: tGreyColor,
      type: BottomNavigationBarType.fixed,
    ),
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationTheme,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    textTheme: TTextTheme.darkTextTheme,
    appBarTheme: TAppBarTheme.darkAppBarTheme,
    scaffoldBackgroundColor: tBlackColor,
    primaryColor: tPrimaryColor,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: tBlackColor,
      selectedItemColor: tPrimaryColor,
      unselectedItemColor: tGreyColor,
      type: BottomNavigationBarType.fixed,
    ),
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.darkInputDecorationTheme,
  );
}
