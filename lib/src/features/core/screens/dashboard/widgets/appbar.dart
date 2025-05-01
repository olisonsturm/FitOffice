import 'package:fit_office/global_overlay.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/features/core/controllers/exercise_timer.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/active_dialog.dart';
import 'package:fit_office/src/features/core/screens/profile/admin/delete_exercise.dart';
import 'package:fit_office/src/features/core/screens/profile/admin/edit_exercise.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/utils/helper/dialog_helper.dart';

class SliderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final bool showFavoriteIcon;
  final bool showDarkModeToggle;
  final bool showStreak;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onBack;
  final Map<String, dynamic>? exercise;
  final bool isAdmin;

  const SliderAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.showFavoriteIcon = false,
    this.showDarkModeToggle = false,
    this.showStreak = false,
    this.isFavorite = false,
    this.onToggleFavorite,
    this.onBack,
    this.exercise,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final themeController = Get.put(_ThemeController());

    final Widget centerTitle = subtitle == null
        ? Text(
            title,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? tWhiteColor : tBlackColor),
            textAlign: TextAlign.center,
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? tWhiteColor : tBlackColor),
              ),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white70 : Colors.black45,
                ),
              ),
            ],
          );

    return AppBar(
      backgroundColor: isDarkMode ? tBlackColor : tWhiteColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Stack(
        alignment: Alignment.center,
        children: [
          centerTitle,

          // ← LINKS: Back-Button wenn showBackButton == true
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showBackButton)
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDarkMode ? tWhiteColor : tDarkColor,
                    ),
                    onPressed: onBack ?? () => Navigator.of(context).pop(),
                  ),
                if (isAdmin && showFavoriteIcon)
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? Colors.red
                          : (isDarkMode ? tPaleWhiteColor : tPaleBlackColor),
                    ),
                    onPressed: onToggleFavorite,
                  ),
                if (showStreak)
                  Builder(
                    builder: (context) {
                      int todaysExerciseMinutes = 4;
                      bool hasStreak = todaysExerciseMinutes >= 5;

                      return Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: hasStreak
                                ? Colors.orange
                                : (isDarkMode ? tWhiteColor : tPaleBlackColor),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$todaysExerciseMinutes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? tWhiteColor : tDarkColor,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),

          // → RECHTS: Favoriten-Icon + DarkMode-Toggle
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isAdmin && showFavoriteIcon)
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? Colors.red
                          : (isDarkMode ? tPaleWhiteColor : tPaleBlackColor),
                    ),
                    onPressed: onToggleFavorite,
                  ),
                if (isAdmin && exercise != null) ...[
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: isDarkMode ? tWhiteColor : tPaleBlackColor,
                    ),
                    onPressed: () async {
                      final timerController =
                          Get.find<ExerciseTimerController>();
                      if (timerController.isRunning.value ||
                          timerController.isPaused.value) {
                        await showUnifiedDialog(
                          context: context,
                          builder: (_) => ActiveTimerDialog.forAction('edit'),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditExercise(
                            exercise: exercise!,
                            exerciseName: exercise!['name'],
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final timerController =
                          Get.find<ExerciseTimerController>();
                      if (timerController.isRunning.value ||
                          timerController.isPaused.value) {
                        await showUnifiedDialog<void>(
                          context: context,
                          builder: (_) => ActiveTimerDialog.forAction('start'),
                        );

                        return;
                      }

                      await showUnifiedDialog<void>(
                        context: context,
                        builder: (ctx) => DeleteExerciseDialog(
                          exercise: exercise!,
                          exerciseName: exercise!['name'],
                          onSuccess: () => Navigator.of(context).pop(),
                        ),
                      );
                    },
                  ),
                ],
                if (showDarkModeToggle)
                  IconButton(
                    icon: Icon(
                      Icons.dark_mode,
                      color: isDarkMode ? tWhiteColor : tDarkColor,
                    ),
                    onPressed: () => themeController.toggleTheme(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ThemeController extends GetxController {
  void toggleTheme() {
    final isDarkMode = Get.context!.theme.brightness == Brightness.dark;
    Get.changeThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
  }
}
