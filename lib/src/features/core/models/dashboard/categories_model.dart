import 'package:fit_office/src/constants/text_strings.dart';
import 'package:flutter/material.dart';

class DashboardCategoriesModel{
  final String title;
  final String heading;
  final String subHeading;
  final VoidCallback? onPress;

  DashboardCategoriesModel(this.title, this.heading, this.subHeading, this.onPress);

  static List<DashboardCategoriesModel> listFavouriteExercises = [
    DashboardCategoriesModel("❤", tDashboardFavourites, "Favourites", null)
  ];
}