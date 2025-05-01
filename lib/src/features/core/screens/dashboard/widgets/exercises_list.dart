import 'package:fit_office/global_overlay.dart';
import 'package:fit_office/src/features/core/screens/dashboard/dashboard.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/view_exercise.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/core/controllers/exercise_timer.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/start_exercise.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/active_dialog.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:fit_office/src/constants/colors.dart';
import '../../../controllers/profile_controller.dart';
import '../../profile/admin/delete_exercise.dart';
import 'package:fit_office/src/features/authentication/models/user_model.dart';
import 'package:fit_office/src/utils/helper/dialog_helper.dart';

class FullWidthDivider extends StatelessWidget {
  const FullWidthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: MediaQuery.of(context).size.width,
      height: 1.8,
      color: const Color.fromARGB(255, 200, 200, 200),
    );
  }
}

class AllExercisesList extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;
  final List<String> favorites;
  final void Function(String exerciseName) onToggleFavorite;
  final String query;
  final bool showGroupedAlphabetically;

  const AllExercisesList({
    super.key,
    required this.exercises,
    required this.favorites,
    required this.onToggleFavorite,
    required this.query,
    this.showGroupedAlphabetically = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final lowerQuery = query.toLowerCase().trim();
    final isFiltered = lowerQuery.isNotEmpty;

    final List<Map<String, dynamic>> sortedList =
        List<Map<String, dynamic>>.from(isFiltered || !showGroupedAlphabetically
            ? _filtered(exercises, lowerQuery)
            : exercises);

    sortedList.sort((a, b) =>
        (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));

    return FutureBuilder<UserModel?>(
      future: ProfileController().getUserData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;
        final isAdmin = user?.role == 'admin';

        final List<Widget> listWidgets = [];

        if (sortedList.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(tDashboardExerciseNotFound),
          );
        }

        if (isFiltered || !showGroupedAlphabetically) {
          for (int i = 0; i < sortedList.length; i++) {
            listWidgets.add(_buildExerciseCard(
                context, sortedList[i], isAdmin, isDarkMode));
            if (i < sortedList.length - 1)
              listWidgets.add(_buildSoftDivider(isDarkMode));
          }
        } else {
          String lastLetter = '';
          List<Map<String, dynamic>> buffer = [];

          void flush(String tag) {
            listWidgets.add(const SizedBox(height: 16));
            listWidgets.add(_buildHeader(tag, isDarkMode));
            listWidgets.add(_buildFullDivider());

            for (int i = 0; i < buffer.length; i++) {
              listWidgets.add(
                  _buildExerciseCard(context, buffer[i], isAdmin, isDarkMode));
              listWidgets.add(i == buffer.length - 1
                  ? _buildFullDivider()
                  : _buildSoftDivider(isDarkMode));
            }
            buffer.clear();
          }

          for (final exercise in sortedList) {
            final name = (exercise['name'] ?? '').toString();
            if (name.isEmpty) continue;
            final firstLetter = name[0].toUpperCase();

            if (firstLetter != lastLetter) {
              if (buffer.isNotEmpty) flush(lastLetter);
              lastLetter = firstLetter;
            }

            buffer.add(exercise);
          }

          if (buffer.isNotEmpty) flush(lastLetter);
        }

        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: listWidgets,
        );
      },
    );
  }

  List<Map<String, dynamic>> _filtered(
      List<Map<String, dynamic>> list, String query) {
    return list.where((exercise) {
      final name = (exercise['name'] ?? '').toString().toLowerCase();
      final desc = (exercise['description'] ?? '').toString().toLowerCase();
      return name.contains(query) ||
          desc.contains(query) ||
          name.similarityTo(query) > 0.4 ||
          desc.similarityTo(query) > 0.4;
    }).toList();
  }

  Widget _buildHeader(String letter, bool isDarkMode) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(letter,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? tWhiteColor : tBlackColor,
            )),
      );

  Widget _buildFullDivider() => const FullWidthDivider();

  Widget _buildSoftDivider(bool isDarkMode) => Divider(
        thickness: 0.6,
        color: isDarkMode ? tDarkGreyColor : tExerciseDivider,
        indent: 12,
        endIndent: 12,
      );

  Widget _buildExerciseCard(BuildContext context, Map<String, dynamic> exercise,
      bool isAdmin, bool isDarkMode) {
    final exerciseName = exercise['name'];
    final exerciseCategory = exercise['category'];
    final timerController = Get.find<ExerciseTimerController>();
    final isFavorite = favorites.contains(exerciseName);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Material(
        color: isDarkMode ? tDarkGreyColor : tWhiteColor,
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          highlightColor: isDarkMode ? tDarkGreyColor : Colors.grey.shade300,
          splashColor: isDarkMode ? tDarkGreyColor : Colors.grey.shade300,
          onTap: () async {
            final dashboardState =
                context.findAncestorStateOfType<DashboardState>();
            dashboardState?.wasSearchFocusedBeforeNavigation =
                dashboardState.searchHasFocus;
            //dashboardState?.removeSearchFocus(); // Fokus ggf. bewusst entfernen
            dashboardState?.wasSearchFocusedBeforeNavigation =
                dashboardState.searchHasFocus;

            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExerciseDetailScreen(exerciseData: exercise),
              ),
            );
            if (result == true) {
              onToggleFavorite(exerciseName);
            }
            dashboardState
                ?.handleReturnedFromExercise(); // Zustand wiederherstellen
          },
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            title: Text(exerciseName ?? 'Unknown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black,
                )),
            subtitle: Text(exerciseCategory ?? 'No category',
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode ? tPaleWhiteColor : const Color(0xFF777777),
                )),
            trailing: IntrinsicWidth(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    color: isDarkMode ? tWhiteColor : tDarkGreyColor,
                    onPressed: () async {
                      if (timerController.isRunning.value ||
                          timerController.isPaused.value) {
                        await showUnifiedDialog<void>(
                          context: context,
                          builder: (ctx) =>
                              ActiveTimerDialog.forAction('start'),
                        );

                        return;
                      }
                      final confirmed = await showUnifiedDialog<bool>(
                        context: context,
                        builder: (ctx) => StartExerciseDialog(
                          exerciseName: exerciseName ?? 'Unknown',
                        ),
                      );

                      if (confirmed == true) {
                        timerController.start(exerciseName, exerciseCategory);
                        if (context.mounted) {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? Colors.red
                          : (isDarkMode
                              ? tPaleWhiteColor
                              : tBottomNavBarUnselectedColor),
                    ),
                    onPressed: () => onToggleFavorite(exerciseName),
                  ),
                  if (isAdmin) ...[
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final timerController =
                            Get.find<ExerciseTimerController>();
                        if (timerController.isRunning.value ||
                            timerController.isPaused.value) {
                          await showUnifiedDialog<void>(
                            context: context,
                            builder: (ctx) =>
                                ActiveTimerDialog.forAction('delete'),
                          );

                          return;
                        }

                        await showUnifiedDialog<bool>(
                          context: context,
                          builder: (ctx) => DeleteExerciseDialog(
                            exercise: exercise,
                            exerciseName: exerciseName ?? 'Unknown',
                          ),
                        );
                      },
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
