import 'package:fit_office/src/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/features/core/controllers/exercise_timer.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/start_exercise.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/end_exercise.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/active_dialog.dart';

class ExerciseInfoTab extends StatefulWidget {
  final Map<String, dynamic> exerciseData;

  const ExerciseInfoTab({super.key, required this.exerciseData});

  @override
  State<ExerciseInfoTab> createState() => _ExerciseInfoTabState();
}

class _ExerciseInfoTabState extends State<ExerciseInfoTab> {
  final timerController = Get.find<ExerciseTimerController>();

  bool get isRunningThisExercise =>
      timerController.isRunning.value &&
      timerController.exerciseName.value == widget.exerciseData['name'];

  @override
  Widget build(BuildContext context) {
    final description =
        widget.exerciseData['description'] ?? tExerciseNoDescription;

    return Obx(() {
      final isRunning = timerController.isRunning.value;
      final isPaused = timerController.isPaused.value;
      final isThisExerciseRunning = isRunning &&
          timerController.exerciseName.value == widget.exerciseData['name'];

      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Card(
            color: tWhiteColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: tBottomNavBarUnselectedColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(tExerciseVideo,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Center(
                      child: Text(
                        'Video aktuell deaktiviert',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(tExerciseDescription,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  isThisExerciseRunning
                      ? Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: tBottomNavBarUnselectedColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                  side: BorderSide.none,
                                ),
                                icon: Icon(
                                    isPaused ? Icons.play_arrow : Icons.pause),
                                label: Text(isPaused
                                    ? tExerciseResume
                                    : tExercisePause),
                                onPressed: () {
                                  isPaused
                                      ? timerController.resume()
                                      : timerController.pause();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: tPrimaryColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                  side: BorderSide.none,
                                ),
                                icon: const Icon(Icons.stop),
                                label: const Text(tExerciseStop),
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
                            ),
                          ],
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow),
                            label: const Text(tExerciseStart),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: tBottomNavBarSelectedColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                              side: BorderSide.none,
                            ),
                            onPressed: () async {
                              if (timerController.isRunning.value &&
                                  !isThisExerciseRunning) {
                                await showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => const ActiveTimerDialog(),
                                );
                                return;
                              }

                              final confirmed = await showDialog<bool>(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => StartExerciseDialog(
                                  exerciseName:
                                      widget.exerciseData['name'] ?? '',
                                ),
                              );
                              if (confirmed == true) {
                                timerController.start(
                                  widget.exerciseData['name'] ?? '',
                                  widget.exerciseData['category'] ?? '',
                                );
                              }
                            },
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}