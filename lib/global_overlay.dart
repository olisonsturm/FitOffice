import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/features/core/controllers/db_controller.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/cancel_exercise.dart';
import 'package:fit_office/src/features/core/screens/libary/library_screen.dart';
import 'package:fit_office/src/utils/helper/dialog_helper.dart';
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
  final RxBool _dialogIsOpen = false.obs;

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

        return IgnorePointer(
          ignoring: _dialogIsOpen.value,
          child: AnimatedOpacity(
            opacity: _dialogIsOpen.value ? 0.85 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: isDashboard
                      ? MediaQuery.of(context).padding.bottom + 58
                      : MediaQuery.of(context).padding.bottom,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 6),
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
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          /// Text- & Icon-Bereich links
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final dbController =
                                    Get.put(DbController(), permanent: true);

                                final exerciseData =
                                    await dbController.getExerciseByName(
                                        timerController.exerciseName.value);

                                if (exerciseData != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ExerciseDetailScreen(
                                          exerciseData: exerciseData),
                                    ),
                                  );
                                }
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.fitness_center,
                                      color: tWhiteColor),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          timerController.exerciseName.value,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            color: tWhiteColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          timerController
                                              .exerciseCategory.value,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            color: tPaleWhiteColor,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          /// Timer
                          Text(
                            timerController.formattedTime.value,
                            style: const TextStyle(
                              color: tWhiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(width: 12),

                          /// Steuer-Buttons
                          SizedBox(
                            height: 48,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
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
                                    icon: const Icon(Icons.check_circle,
                                        color: tWhiteColor),
                                    onPressed: () async {
                                      final libraryState =
                                          context.findAncestorStateOfType<
                                              LibraryScreenState>();
                                      final confirmed =
                                          await showUnifiedDialog<bool>(
                                        barrierDismissible: false,
                                        context: context,
                                        libraryState: libraryState,
                                        builder: (_) => EndExerciseDialog(
                                          exerciseName: timerController
                                              .exerciseName.value,
                                        ),
                                      );
                                      if (confirmed == true) {
                                        timerController.stopAndSave(
                                            shouldSave: true);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel,
                                        color: tWhiteColor),
                                    onPressed: () async {
                                      final libraryState =
                                          context.findAncestorStateOfType<
                                              LibraryScreenState>();
                                      final confirmed =
                                          await showUnifiedDialog<bool>(
                                        barrierDismissible: false,
                                        context: context,
                                        libraryState: libraryState,
                                        builder: (_) => CancelExerciseDialog(
                                          exerciseName: timerController
                                              .exerciseName.value,
                                        ),
                                      );
                                      if (confirmed == true) {
                                        timerController.stopAndSave(
                                            shouldSave: false);
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
                ),
              ],
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

  bool get isDialogOpen => _dialogIsOpen.value;

  void setDialogOpen(bool isOpen) {
    _dialogIsOpen.value = isOpen;
  }

  static const double overlayHeight = 86;

}
