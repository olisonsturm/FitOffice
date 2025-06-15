import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../constants/sizes.dart';
import '../../../../constants/colors.dart';
import '../../models/model_on_boarding.dart';

class OnBoardingPageWidget extends StatelessWidget {
  const OnBoardingPageWidget({
    super.key,
    required this.model,
  });

  final OnBoardingModel model;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? model.bgColorDark : model.bgColorLight;

    return Container(
      padding: const EdgeInsets.all(tDefaultSpace),
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          RepaintBoundary(
            child: Lottie.asset(
              model.image,
              height: size.height * 0.45,
            ),
          ),
          Column(
            children: [
              Text(
                model.title,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: isDark ? tWhiteColor : tPrimaryColor,
                    ),
              ),
              Text(
                model.subTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? tPaleWhiteColor : tDarkColor,
                ),
              ),
            ],
          ),
          Text(
            model.counterText,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDark ? tWhiteColor : tPrimaryColor,
                ),
          ),
          const SizedBox(
            height: 80.0,
          )
        ],
      ),
    );
  }
}
