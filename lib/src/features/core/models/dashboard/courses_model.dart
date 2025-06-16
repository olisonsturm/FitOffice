import 'package:flutter/material.dart';

class DashboardTopCoursesModel{
  final String title;
  final String heading;
  final String subHeading;
  final VoidCallback? onPress;

  DashboardTopCoursesModel(this.title, this.heading, this.subHeading, this.onPress);

  static List<DashboardTopCoursesModel> list = [
    DashboardTopCoursesModel("Streak 🔥", "3 Sections", "Oberkörper", (){}),
    DashboardTopCoursesModel("Kinebeugen", "Eine Section", "Unterkörper", null),
    DashboardTopCoursesModel("Burpee", "4 Sections", "Ganzkörper", (){}),
  ];
}