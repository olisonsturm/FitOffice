import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/statistics_controller.dart';

class SliderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final bool showFavoriteIcon;
  final bool showDarkModeToggle;
  final bool showStreak;
  final bool isFavorite;
  final bool isProcessing;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onBack;
  final Map<String, dynamic>? exercise;
  final bool isAdmin;
  final VoidCallback? onEdit;

  const SliderAppBar(
      {super.key,
      required this.title,
      this.subtitle,
      this.showBackButton = false,
      this.showFavoriteIcon = false,
      this.showDarkModeToggle = false,
      this.showStreak = false,
      this.isFavorite = false,
      this.isProcessing = false,
      this.onToggleFavorite,
      this.onBack,
      this.exercise,
      this.isAdmin = false,
      this.onEdit});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeController = Get.put(_ThemeController());

    final Widget centerTitle = subtitle == null
        ? Text(
            title,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? tWhiteColor : tBlackColor),
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
                    color: isDark ? tWhiteColor : tBlackColor),
              ),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black45,
                ),
              ),
            ],
          );

    return AppBar(
      backgroundColor: isDark ? tBlackColor : tWhiteColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Stack(
        alignment: Alignment.center,
        children: [
          centerTitle,
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showBackButton)
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDark ? tWhiteColor : tDarkColor,
                    ),
                    onPressed: onBack ?? () => Navigator.of(context).pop(),
                  ),
                if (isAdmin && showFavoriteIcon)
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? Colors.red
                          : (isDark ? tPaleWhiteColor : tPaleBlackColor),
                    ),
                    onPressed: isProcessing ? null : onToggleFavorite,
                  ),
                if (showStreak)
                  Obx(() {
                    final streakCtrl = Get.find<StreakController>();
                    if (streakCtrl.isLoading.value) {
                      return const Text(tLoading);
                    } else if (streakCtrl.isError.value) {
                      return const Text(tError);
                    }

                    final bool hasStreak = streakCtrl.hasStreak.value;
                    final int doneSecs = streakCtrl.doneSeconds.value;
                    final int streakCount = streakCtrl.streakSteps.value;
                    final Color flameColor = doneSecs >= 300
                        ? Colors.orange
                        : (isDark ? tWhiteColor : tPaleBlackColor);

                    return Row(
                      children: [
                        Icon(Icons.local_fire_department, color: flameColor),
                        const SizedBox(width: 4),
                        Text(
                          hasStreak ? streakCount.toString() : '0',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? tWhiteColor : tDarkColor,
                          ),
                        ),
                      ],
                    );
                  }),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isAdmin && showFavoriteIcon && exercise != null)
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? Colors.red
                          : (isDark ? tWhiteColor : tBlackColor),
                    ),
                    onPressed: isProcessing ? null : onToggleFavorite,
                  ),
                if (isAdmin && exercise != null) ...[
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: isDark ? tWhiteColor : tPaleBlackColor,
                    ),
                    onPressed: onEdit,
                  ),
                ],
                if (showDarkModeToggle)
                  IconButton(
                    icon: Icon(
                      Icons.dark_mode,
                      color: isDark ? tWhiteColor : tDarkColor,
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
