import 'package:fit_office/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/src/utils/theme/widget_themes/appbar_theme.dart';
import 'package:fit_office/src/utils/theme/widget_themes/dialog_theme.dart';
import 'package:fit_office/src/utils/theme/widget_themes/elevated_button_theme.dart';
import 'package:fit_office/src/utils/theme/widget_themes/outlined_button_theme.dart';
import 'package:fit_office/src/utils/theme/widget_themes/text_field_theme.dart';
import 'package:fit_office/src/utils/theme/widget_themes/text_theme.dart';

/// A class that defines the app's themes, including light and dark themes.
class TAppTheme {
  TAppTheme._();

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    textTheme: TTextTheme.lightTextTheme,
    appBarTheme: TAppBarTheme.lightAppBarTheme,
    scaffoldBackgroundColor: tWhiteColor,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: tWhiteColor,
      selectedItemColor: tPrimaryColor,
      unselectedItemColor: tGreyColor,
      type: BottomNavigationBarType.fixed,
    ),
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationTheme,
    dialogTheme: TDialogTheme.lightDialogTheme,
    primaryColor: tPrimaryColor,
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: tPrimaryColor,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: tPrimaryColor,
      selectionColor: tPrimaryColor.withValues(alpha: .3),
      selectionHandleColor: tPrimaryColor,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    textTheme: TTextTheme.darkTextTheme,
    appBarTheme: TAppBarTheme.darkAppBarTheme,
    scaffoldBackgroundColor: tBlackColor,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: tBlackColor,
      selectedItemColor: tPrimaryColor,
      unselectedItemColor: tGreyColor,
      type: BottomNavigationBarType.fixed,
    ),
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.darkInputDecorationTheme,
    dialogTheme: TDialogTheme.darkDialogTheme,
    primaryColor: tPrimaryColor,
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: tPrimaryColor,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: tPrimaryColor,
      selectionColor: tPrimaryColor.withValues(alpha: .3),
      selectionHandleColor: tPrimaryColor,
    ),
  );
}
