import 'package:flutter/material.dart';
import '../../../constants/colors.dart';

class TAppBarTheme {
  TAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: tWhiteColor,
    iconTheme: IconThemeData(color: tBlackColor, size: 18.0),
    actionsIconTheme: IconThemeData(color: tBlackColor, size: 18.0),
  );
  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: tBlackColor,
    iconTheme: IconThemeData(color: tWhiteColor, size: 18.0),
    actionsIconTheme: IconThemeData(color: tWhiteColor, size: 18.0),
  );
}