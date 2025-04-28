import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/cancel_exercise.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/features/core/controllers/exercise_timer.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/view_exercise.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/end_exercise.dart';

class GlobalExerciseOverlay {
  static final GlobalExerciseOverlay _instance =
      GlobalExerciseOverlay._internal();
  factory GlobalExerciseOverlay() => _instance;
  GlobalExerciseOverlay._internal();

  OverlayEntry? _overlayEntry;

  void init(BuildContext context) {
    final timerController = Get.find<ExerciseTimerController>();

    ever(timerController.isRunning, (_) {
      if (timerController.isRunning.value) {
        _showOverlay(context);
      } else {
        _removeOverlay();
      }
    });
  }

  void _showOverlay(BuildContext context) {
    if (_overlayEntry != null) return;

    final timerController = Get.find<ExerciseTimerController>();

    _overlayEntry = OverlayEntry(
      builder: (context) => Obx(() {
        final navigator = Navigator.of(context);
        final isDashboard = navigator.canPop() == false;

        final isRunning = timerController.isRunning.value;
        final isOnCorrectExercise =
            ExerciseDetailScreen.currentExerciseName.value != null &&
                ExerciseDetailScreen.currentExerciseName.value ==
                    timerController.exerciseName.value;
        final isOnAboutTab = ExerciseDetailScreen.currentTabIndex.value == 0;

        final hideControlButtons =
            isRunning && isOnCorrectExercise && isOnAboutTab;

        return AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          left: 0,
          right: 0,
          bottom: isDashboard
              ? MediaQuery.of(context).padding.bottom + 58
              : MediaQuery.of(context).padding.bottom,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: tBottomNavBarSelectedColor,
                borderRadius: isDashboard
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      )
                    : BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      final exerciseData = {
                        'name': timerController.exerciseName.value,
                        'category': timerController.exerciseCategory.value,
                      };
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExerciseDetailScreen(
                            exerciseData: exerciseData,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.fitness_center, color: tWhiteColor),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              timerController.exerciseName.value,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: tWhiteColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              timerController.exerciseCategory.value,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: tPaleWhiteColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    timerController.formattedTime.value,
                    style: const TextStyle(
                      color: tWhiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        if (!hideControlButtons) ...[
                          IconButton(
                            icon: Obx(() => Icon(
                                  timerController.isPaused.value
                                      ? Icons.play_arrow
                                      : Icons.pause,
                                  color: tWhiteColor,
                                )),
                            onPressed: () {
                              if (timerController.isPaused.value) {
                                timerController.resume();
                              } else {
                                timerController.pause();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: tWhiteColor),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const EndExerciseDialog(),
                              );
                              if (confirmed == true) {
                                timerController.stop();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: tWhiteColor),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const CancelExerciseDialog(),
                              );
                              if (confirmed == true) {
                                timerController.stop();
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );

    final overlay = Navigator.of(context, rootNavigator: true).overlay;
    overlay?.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
