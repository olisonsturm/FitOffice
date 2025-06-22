import 'dart:ui';

/// OnBoardingModel is a model class that represents the data for each onboarding page.
class OnBoardingModel {
  final String image;
  final String title;
  final String subTitle;
  final String counterText;
  final Color bgColorLight;
  final Color bgColorDark;

  OnBoardingModel({
    required this.image,
    required this.title,
    required this.subTitle,
    required this.counterText,
    required this.bgColorLight,
    required this.bgColorDark,
  });
}