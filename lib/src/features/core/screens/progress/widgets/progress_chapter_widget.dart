import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/constants/sizes.dart';
import 'package:lottie/lottie.dart';

class ProgressChapterWidget extends StatelessWidget {
  final String title;
  final int currentStep;
  final int startStep;
  final int stepCount;
  final double screenWidth;
  final double screenHeight;
  final int chapterIndex;
  final bool isLocked;
  final Animation<double>? stepAnimation;
  final Animation<double>? chapterAnimation;
  final bool isAnimating;
  final int stepsPerChapter; // Neu hinzugefügter Parameter

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
    this.stepAnimation,
    this.chapterAnimation,
    this.isAnimating = false,
    required this.stepsPerChapter, // Neu hinzugefügter Parameter
  });

  @override
  Widget build(BuildContext context) {
    // Position-Berechnung zurück zum Original, ohne extra Padding
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

    // Check if chapter is completed
    final bool isCompleted = currentStep >= startStep + stepCount;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Chapter Title with Animation
          AnimatedBuilder(
            animation: chapterAnimation ?? const AlwaysStoppedAnimation(0.0),
            builder: (context, child) {
              final animationValue = chapterAnimation?.value ?? 0.0;

              return Transform.scale(
                scale: isCompleted ? 1.0 + (animationValue * 0.1) : 1.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Chapter completion indicator
                    if (isCompleted)
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: tPrimaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: tPrimaryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),

                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isLocked
                            ? inactiveColor
                            : isCompleted
                            ? tPrimaryColor
                            : isDark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),

                    if (isLocked) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.lock,
                        color: inactiveColor,
                        size: 28,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: tDefaultSpace),

          // Progress Path with Paw Prints only (no path lines)
          Container(
            width: screenWidth,
            clipBehavior: Clip.none, // Verhindert Abschneiden
            child: Stack(
              clipBehavior: Clip.none, // Verhindert Abschneiden
              children: [
                // Background container
                Container(
                  width: screenWidth,
                  height: pawPositions.last.dy + 100,
                  color: Colors.transparent,
                ),

                // Step indicators (paw prints) - Originale Positionen wiederhergestellt
                ...pawPositions.asMap().entries.map((entry) {
                  int index = entry.key;
                  Offset position = entry.value;

                  final int stepNumber = startStep + index;
                  final bool isStepCompleted = stepNumber < currentStep;
                  final bool isCurrentStep = stepNumber == currentStep - 1;

                  return Positioned(
                    left: position.dx + (screenWidth - 100) / 2 - tDefaultSize,
                    top: position.dy,
                    child: _buildStepIndicator(
                      isCompleted: isStepCompleted && !isLocked,
                      isCurrent: isCurrentStep && !isLocked,
                      isLocked: isLocked,
                      completedColor: completedColor,
                      inactiveColor: inactiveColor,
                      activeColor: activeColor,
                      stepIndex: index,
                    ),
                  );
                }),

                // Fox animation jumping between steps
                if (currentStep >= startStep && currentStep < startStep + stepCount)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    left: pawPositions[(currentStep - startStep)].dx + (screenWidth) / 2 - 90,
                    top: pawPositions[(currentStep - startStep)].dy - 65,
                    child: Lottie.asset(
                      'assets/lottie/FittyFuchsWaving.json',
                      width: 150,
                      height: 150,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8), // vorher tDefaultSpace
        ],
      ),
    );
  }

  Widget _buildStepIndicator({
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
    required Color completedColor,
    required Color? inactiveColor,
    required Color activeColor,
    required int stepIndex,
  }) {
    return AnimatedBuilder(
      animation: stepAnimation ?? const AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        // Bestimme die Farbe des Icons (keine dynamische Größenänderung mehr hier)
        Color iconColor;
        if (isLocked) {
          iconColor = inactiveColor ?? Colors.grey;
        } else if (isCompleted) {
          iconColor = completedColor;
        } else if (isCurrent) {
          iconColor = activeColor;
        } else {
          iconColor = activeColor;
        }

        // Größenkonstanten
        const double containerSize = 100.0;
        const double iconSize = 100.0;

        // WICHTIG: KEIN extra Space für den Container selbst, sondern Shadow-Effekt innerhalb der festen Größe
        return Container(
          width: containerSize,
          height: containerSize,
          clipBehavior: Clip.none,
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.center, // Zentriert alles im Stack
            children: [
              // Glow-Effekt als separates Element (unter der Pfote)
              if (isCompleted)
                Container(
                  width: containerSize,
                  height: containerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: completedColor.withValues(alpha: 0.4),
                        blurRadius: 20.0,
                        spreadRadius: 4.0,
                      ),
                    ],
                  ),
                ),

              // Zusätzlicher Glow-Effekt für aktuelle Pfote - subtiler
              if (isCurrent && isAnimating)
                AnimatedBuilder(
                  animation: stepAnimation ?? const AlwaysStoppedAnimation(0.0),
                  builder: (context, _) {
                    final animValue = stepAnimation?.value ?? 0.0;
                    return Container(
                      width: containerSize,
                      height: containerSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.2 + (animValue * 0.2)),
                            blurRadius: 12.0 + (animValue * 6.0), // Reduzierter Blur-Effekt
                            spreadRadius: 2.0 + (animValue * 0.5), // Minimaler Spread
                          ),
                        ],
                      ),
                    );
                  },
                ),

              // Pfotensymbol - jetzt mit ScaleTransition für korrekte Zentrierung
              Center(
                child: ScaleTransition(
                  scale: isCurrent && isAnimating
                      ? Tween<double>(begin: 1.0, end: 1.08).animate(stepAnimation!) // Nur 8% vergrößern statt 12%
                      : const AlwaysStoppedAnimation(1.0),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationZ(
                      (chapterIndex % 2 == 0 ? -1 : 1) *
                        (stepIndex == 0
                            ? 2
                            : 2 + (stepIndex - 1) * 0.1 + (isCurrent ? 0.1 : 0.0)),
                    ),
                    child: Icon(
                      Icons.pets,
                      size: iconSize,
                      color: iconColor,
                    ),
                  ),
                ),
              ),

              // Completion indicator (Häkchen)
              if (isCompleted && !isLocked)
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: completedColor, width: 2),
                    ),
                    child: Icon(
                      Icons.check,
                      color: completedColor,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
