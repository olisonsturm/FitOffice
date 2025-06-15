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

    // Check if this chapter is currently being animated
    bool isCurrentChapter;

    // Korrigierte Logik für aktives Kapitel
    if (currentStep % stepsPerChapter == 0 && isAnimating) {
      // Wenn wir genau am Ende eines Kapitels sind, dann ist das
      // ABGESCHLOSSENE Kapitel das aktive (nicht das nächste)
      final int completedChapterIndex = (currentStep / stepsPerChapter).floor() - 1;
      isCurrentChapter = chapterIndex == completedChapterIndex;
    } else {
      // Normale Berechnung innerhalb eines Kapitels
      isCurrentChapter = currentStep >= startStep && currentStep < startStep + stepCount;
    }

    // Check if chapter is completed
    final bool isCompleted = currentStep >= startStep + stepCount;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isCurrentChapter && isAnimating
            ? LinearGradient(
          colors: [
            tPrimaryColor.withValues(alpha: 0.1),
            tSecondaryColor.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        boxShadow: isCurrentChapter && isAnimating
            ? [
          BoxShadow(
            color: tPrimaryColor.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ]
            : null,
      ),
      child: Column(
        children: [
          const SizedBox(height: tDefaultSpace),

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
              ],
            ),
          ),

          const SizedBox(height: tDefaultSpace),
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
        // Determine icon color (keine Größenänderung mehr für einzelne Schritte)
        double size = 100.0; // Original size, jetzt konstant für alle
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

        // WICHTIG: KEIN extra Space für den Container selbst, sondern Shadow-Effekt innerhalb der festen Größe
        return Container(
          width: 100.0, // Feste Größe ohne Extraplatz
          height: 100.0, // Feste Größe ohne Extraplatz
          clipBehavior: Clip.none,
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow-Effekt als separates Element (unter der Pfote)
              if (isCompleted)
                Container(
                  width: 100.0,
                  height: 100.0,
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

              // TODO: AUSRICHTEN der Pfotenabdrücke
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationZ(
                  (chapterIndex % 2 == 0
                      ? -1
                      : 1) *
                    (stepIndex == 0
                        ? 2
                        : 2 + (stepIndex - 1) * 0.1 + (isCurrent ? 0.1 : 0.0)),
                )..scale(chapterIndex % 2 == 0 ? -1.0 : 1.0, 1.0),
                child: Icon(
                  Icons.pets,
                  size: size,
                  color: iconColor,
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
