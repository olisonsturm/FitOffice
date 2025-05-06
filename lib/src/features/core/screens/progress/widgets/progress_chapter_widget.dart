import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/constants/sizes.dart';

class ProgressChapterWidget extends StatelessWidget {
  final String title;
  final int currentStep;
  final int startStep;
  final int stepCount;
  final double screenWidth;
  final double screenHeight;
  final int chapterIndex;
  final bool isLocked;

  const ProgressChapterWidget({
    super.key,
    required this.title,
    required this.currentStep,
    required this.startStep,
    required this.stepCount,
    required this.screenWidth,
    required this.screenHeight,
    required this.chapterIndex,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final List<Offset> pawPositions = List.generate(stepCount, (index) {
      final double x = (chapterIndex % 2 == 0) // Check if chapterIndex is even
          ? screenWidth * (0.33 * math.cos(index * math.pi / 4))
          : 1 - screenWidth * (0.33 * math.cos(index * math.pi / 4));
      final double y = screenHeight * (index * 0.125);
      return Offset(x, y);
    });

    final Color? inactiveColor = Colors.grey[500];
    final Color activeColor = tSecondaryColor;
    final Color completedColor = tPrimaryColor;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        const SizedBox(height: tDefaultSpace),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isLocked
                    ? inactiveColor
                    : isDark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            if (isLocked)
              const SizedBox(width: 8),
            if (isLocked)
              Icon(
                Icons.lock,
                color: inactiveColor,
                size: 28,
              ),
          ],
        ),
        const SizedBox(height: tDefaultSpace),
        Stack(
          children: [
            const SizedBox(height: kToolbarHeight),
            Container(
              width: screenWidth - tDefaultSpace * 2,
              height: pawPositions.last.dy + 100,
              color: Colors.transparent,
            ),
            ...pawPositions.asMap().entries.map((entry) {
              int index = entry.key;
              Offset position = entry.value;

              final bool isStepActive = (startStep + index) < currentStep;

              return Positioned(
                left: position.dx + (screenWidth - 100) / 2 - tDefaultSpace,
                top: position.dy,
                child: Icon(
                  Icons.pets,
                  size: 100,
                  color: isStepActive && !isLocked
                      ? completedColor
                      : isLocked ? inactiveColor : activeColor,
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: tDefaultSpace),
      ],
    );
  }
}
