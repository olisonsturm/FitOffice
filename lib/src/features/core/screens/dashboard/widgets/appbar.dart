import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/features/core/screens/profile/admin/edit_exercise.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SliderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final bool showFavoriteIcon;
  final bool showDarkModeToggle;
  final bool showEditOption;
  final bool showStreak;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onBack;
  final Map<String, dynamic>? exercise;

  const SliderAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.showFavoriteIcon = false,
    this.showDarkModeToggle = false,
    this.showEditOption = false,
    this.showStreak = false,
    this.isFavorite = false,
    this.onToggleFavorite,
    this.onBack,
    this.exercise,
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
                if (showStreak)
                  Builder(
                    builder: (context) {
                      // Hardcodierte Übungszeit in Minuten (später aus der DB holen!)
                      int todaysExerciseMinutes = 4;

                      // Überprüfen, ob 5 Minuten erreicht sind
                      bool hasStreak = todaysExerciseMinutes >= 5;

                      return Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: hasStreak
                                ? Colors.orange
                                : (isDarkMode
                                    ? tWhiteColor
                                    : tPaleBlackColor),
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
                if (showEditOption && exercise != null)
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: isDarkMode ? tWhiteColor : tPaleBlackColor,
                    ),
                    onPressed: () {
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
                if (showFavoriteIcon)
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? Colors.red
                          : (isDarkMode ? tPaleWhiteColor : tPaleBlackColor),
                    ),
                    onPressed: onToggleFavorite,
                  ),
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
