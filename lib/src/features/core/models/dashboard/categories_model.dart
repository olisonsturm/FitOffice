import 'package:flutter/material.dart';
import '../../controllers/db_controller.dart';

class DashboardCategoriesModel{
  final String title;
  final String heading;
  final String subHeading;
  final VoidCallback? onPress;

  DashboardCategoriesModel(this.title, this.heading, this.subHeading, this.onPress);

  static List<DashboardCategoriesModel> listFavouriteExercises = [
    DashboardCategoriesModel("❤", "Favoriten", "0 Lessons", null)
  ];
}