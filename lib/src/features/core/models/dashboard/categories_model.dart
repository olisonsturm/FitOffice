import 'package:flutter/material.dart';

class DashboardCategoriesModel{
  final String title;
  final String heading;
  final String subHeading;
  final VoidCallback? onPress;

  DashboardCategoriesModel(this.title, this.heading, this.subHeading, this.onPress);

  static List<DashboardCategoriesModel> list = [
    DashboardCategoriesModel("OK", "Oberkörper", "10 Lessons", null),
    DashboardCategoriesModel("UK", "Unterkörper", "11 Lessons", null),
    DashboardCategoriesModel("GK", "Ganzkörper", "8 Lessons", null),
  ];

  static List<DashboardCategoriesModel> listPsychologicalExercises = [
    DashboardCategoriesModel("🧠", "Geist", "0 Lessons", null),
  ];

  static List<DashboardCategoriesModel> listFavouriteExercises = [
    DashboardCategoriesModel("❤", "Favoriten", "0 Lessons", null)
  ];
}