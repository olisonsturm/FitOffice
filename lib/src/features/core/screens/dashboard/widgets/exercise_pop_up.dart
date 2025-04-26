import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/features/core/controllers/exercise_timer.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/view_exercise.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/end_exercise.dart'; 

class ExerciseMiniPopup extends StatelessWidget {
  const ExerciseMiniPopup({super.key});

  bool get isDashboard {
    final currentRoute = Get.currentRoute;
    return currentRoute == '/dashboard' || currentRoute == '/';
  }

  @override
  Widget build(BuildContext context) {
    final timerController = Get.find<ExerciseTimerController>();

    return Obx(() {
      if (!timerController.isRunning.value) return const SizedBox.shrink();

      final bool dashboard = isDashboard;

      return Positioned(
        left: 0,
        right: 0,
        bottom: dashboard ? 64 : 20,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.orange.shade700,
            borderRadius: dashboard
                ? const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  )
                : BorderRadius.circular(24),
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
              // Icon links
              GestureDetector(
                onTap: () {
                  final exerciseData = {
                    'name': timerController.exerciseName.value,
                    'category': timerController.exerciseCategory.value,
                  };
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ExerciseDetailScreen(exerciseData: exerciseData),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.fitness_center, color: Colors.white),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timerController.exerciseName.value,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          timerController.exerciseCategory.value,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Timer-Anzeige
              Text(
                timerController.formattedTime.value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),

              const SizedBox(width: 12),

              // PAUSE / RESUME Button
              IconButton(
                icon: Obx(() => Icon(
                      timerController.isPaused.value
                          ? Icons.play_arrow
                          : Icons.pause,
                      color: Colors.white,
                    )),
                onPressed: () {
                  if (timerController.isPaused.value) {
                    timerController.resume();
                  } else {
                    timerController.pause();
                  }
                },
              ),

              // STOP Button
              IconButton(
                icon: const Icon(Icons.stop, color: Colors.white),
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
            ],
          ),
        ),
      );
    });
  }
}
