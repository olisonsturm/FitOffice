import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/features/core/controllers/exercise_timer.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/end_exercise.dart';

class TimerAwareAppBar extends StatelessWidget implements PreferredSizeWidget {
  final PreferredSizeWidget normalAppBar;
  final bool showBackButton;
    final bool hideIcons; 

  const TimerAwareAppBar({
    super.key,
    required this.normalAppBar,
    this.hideIcons = false,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final timerController = Get.find<ExerciseTimerController>();

    return Obx(() {
      final isRunning = timerController.isRunning.value;
      final isInfoTab =
          ModalRoute.of(context)?.settings.name == '/exercise_info';

      if (!isRunning) return normalAppBar;

      return AppBar(
        elevation: 0,
        backgroundColor: Colors.orange,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Stack(
          alignment: Alignment.center,
          children: [
            /// CENTER: Übungsname + Kategorie (immer zentriert)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timerController.exerciseName.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  timerController.exerciseCategory.value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            /// LEFT: zurück-Button (optional) + Timer
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showBackButton)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2, right: 12),
                    child: Text(
                      timerController.formattedTime.value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// RIGHT: Pause + Stop
            Align(
              alignment: Alignment.centerRight,
              child: hideIcons
                  ? const SizedBox.shrink()
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            timerController.isPaused.value
                                ? Icons.play_arrow
                                : Icons.pause,
                            size: 28,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            timerController.isPaused.value
                                ? timerController.resume()
                                : timerController.pause();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.stop,
                              size: 28, color: Colors.white),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const EndExerciseDialog(),
                            );
                            if (confirmed == true) timerController.stop();
                          },
                        ),
                      ],
                    ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
