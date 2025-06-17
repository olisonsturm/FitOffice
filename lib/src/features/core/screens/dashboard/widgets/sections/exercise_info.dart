import 'package:fit_office/src/features/core/screens/dashboard/widgets/cancel_exercise.dart';
import 'package:fit_office/src/utils/helper/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/features/core/controllers/exercise_timer.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/start_exercise.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/active_dialog.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/video_player.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../end_exercise.dart';

class ExerciseInfoTab extends StatefulWidget {
  final Map<String, dynamic> exerciseData;
  final ScrollController scrollController;

  const ExerciseInfoTab(
      {super.key, required this.exerciseData, required this.scrollController});

  @override
  State<ExerciseInfoTab> createState() => _ExerciseInfoTabState();
}

class _ExerciseInfoTabState extends State<ExerciseInfoTab> {
  final timerController = Get.find<ExerciseTimerController>();
  String? _locale;

  bool get isRunningThisExercise =>
      timerController.exerciseName.value == widget.exerciseData['name'];

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _locale = prefs.getString('locale') ?? 'de';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }


  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String description;
    if (_locale == 'de') {
      description =
          widget.exerciseData['description'] ??
              localizations.tExerciseNoDescription;
    } else {
      description =
          widget.exerciseData['description_en'] ??
              localizations.tExerciseNoDescription;
    }

    final videoUrl = widget.exerciseData['video'];
    final hasVideo = videoUrl != null &&
        videoUrl is String &&
        videoUrl.isNotEmpty &&
        Uri.tryParse(videoUrl)?.hasAbsolutePath == true &&
        (videoUrl.startsWith('http://') || videoUrl.startsWith('https://'));

    Widget videoContent = hasVideo
        ? SizedBox(
            height: 200,
            width: double.infinity,
            child: VideoPlayerWidget(videoUrl: videoUrl),
          )
        : Container(
            height: 200,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            child: Center(
              child: Text(
                localizations.tNoVideoAvailable,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : tDarkGreyColor,
                ),
              ),
            ),
          );

    return Obx(() {
      final isRunning = timerController.isRunning.value;
      final isPaused = timerController.isPaused.value;
      final isThisExerciseRunning = isRunning &&
          timerController.exerciseName.value == widget.exerciseData['name'];

      return ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Card(
            color: isDarkMode ? tBlackColor : tWhiteColor,
            elevation: isDarkMode ? 0 : 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDarkMode
                    ? Colors.grey.shade700
                    : tBottomNavBarUnselectedColor,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localizations.tExerciseVideo,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? tWhiteColor : tBlackColor,
                      )),
                  const SizedBox(height: 12),
                  videoContent,
                  const SizedBox(height: 20),
                  Text(localizations.tExerciseDescription,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? tWhiteColor : tBlackColor,
                      )),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  isThisExerciseRunning
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          tBottomNavBarUnselectedColor,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                      side: BorderSide.none,
                                    ),
                                    icon: Icon(
                                      isPaused ? Icons.play_arrow : Icons.pause,
                                      color: tWhiteColor,
                                    ),
                                    label: Text(
                                      isPaused
                                          ? localizations.tExerciseResume
                                          : localizations.tExercisePause,
                                      style:
                                          const TextStyle(color: tWhiteColor),
                                    ),
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
                                      backgroundColor: tFinishExerciseColor,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                      side: BorderSide.none,
                                    ),
                                    icon: const Icon(Icons.check_circle,
                                        color: tWhiteColor),
                                    label: Text(
                                      localizations.tExerciseFinish,
                                      style: TextStyle(color: tWhiteColor),
                                    ),
                                    onPressed: () async {
                                      final confirmed =
                                          await showUnifiedDialog<bool>(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (_) => EndExerciseDialog(
                                          exerciseName:
                                              widget.exerciseData['name'] ?? '',
                                        ),
                                      );
                                      if (confirmed == true) {
                                        timerController.stopAndSave(
                                            shouldSave: true);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: tRedColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                                side: BorderSide.none,
                              ),
                              icon:
                                  const Icon(Icons.cancel, color: tWhiteColor),
                              label: Text(
                                localizations.tCancelExercise,
                                style: TextStyle(color: tWhiteColor),
                              ),
                              onPressed: () async {
                                final confirmed = await showUnifiedDialog<bool>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => CancelExerciseDialog(
                                    exerciseName:
                                        widget.exerciseData['name'] ?? '',
                                  ),
                                );
                                if (confirmed == true) {
                                  timerController.stopAndSave(
                                      shouldSave: false);
                                }
                              },
                            ),
                          ],
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow,
                                color: tWhiteColor),
                            label: Text(
                              localizations.tExerciseStart,
                              style: TextStyle(color: tWhiteColor),
                            ),
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
                                await showUnifiedDialog(
                                  context: context,
                                  builder: (_) => ActiveTimerDialog.forAction(
                                      'start', context),
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
