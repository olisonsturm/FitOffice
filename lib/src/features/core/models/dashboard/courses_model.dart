import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/image_strings.dart';

class DashboardTopCoursesModel{
  final String title;
  final String heading;
  final String subHeading;
  final String image;
  final VoidCallback? onPress;

  DashboardTopCoursesModel(this.title, this.heading, this.subHeading, this.image, this.onPress);

  static List<DashboardTopCoursesModel> list = [
    DashboardTopCoursesModel("Streak 🔥", "3 Sections", "Oberkörper", tTopCourseImage1, (){}),
    DashboardTopCoursesModel("Kinebeugen", "Eine Section", "Unterkörper", tTopCourseImage2, null),
    DashboardTopCoursesModel("Burpee", "4 Sections", "Ganzkörper", tTopCourseImage1, (){}),
  ];
}