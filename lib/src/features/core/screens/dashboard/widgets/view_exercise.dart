import 'package:fit_office/l10n/app_localizations.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/sections/exercise_history.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/sections/exercise_info.dart';
import 'package:fit_office/src/features/core/screens/profile/admin/exercise_form.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/appbar.dart';
import 'package:get/get.dart';

import '../../../../../utils/helper/dialog_helper.dart';
import '../../../controllers/db_controller.dart';
import '../../../controllers/exercise_timer.dart';
import '../../../controllers/profile_controller.dart';
import 'active_dialog.dart';

class ExerciseDetailScreen extends StatefulWidget {
  static RxnString currentExerciseName = RxnString();
  static RxInt currentTabIndex = 0.obs;

  final Map<String, dynamic> exerciseData;
  final bool isFavorite;

  const ExerciseDetailScreen(
      {super.key, required this.exerciseData, this.isFavorite = false});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  int selectedTab = 0;
  bool isFavorite = false;
  bool favoriteChanged = false;
  bool isAdmin = false;
  bool isProcessing = false;

  final DbController _dbController = DbController();
  final ProfileController _profileController = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ExerciseDetailScreen.currentExerciseName.value =
          widget.exerciseData['name'];
      ExerciseDetailScreen.currentTabIndex.value = 0;
    });
    isFavorite = widget.isFavorite;
    _loadFavoriteStatus();
    _loadUserRole();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ExerciseDetailScreen.currentExerciseName.value = '';
      ExerciseDetailScreen.currentTabIndex.value = -1;
    });
    super.dispose();
  }

  void _loadUserRole() async {
    final user = await _profileController.getUserData();
    setState(() {
      isAdmin = user.role == 'admin';
    });
  }

  void _loadFavoriteStatus() async {
    final user = await _profileController.getUserData();
    final favorites = await _dbController.getFavouriteExercises(user.email);

    setState(() {
      isFavorite = favorites
          .map((e) => e['name'] as String)
          .contains(widget.exerciseData['name']);
    });
  }

  void toggleFavorite() async {
    if (isProcessing) return;
    setState(() {
      isProcessing = true;
      isFavorite = !isFavorite;
      favoriteChanged = true;
    });

    final user = await _profileController.getUserData();
    final exerciseName = widget.exerciseData['name'];

    try {
      await _dbController.toggleFavorite(
        email: user.email,
        exerciseName: exerciseName,
        isCurrentlyFavorite: !isFavorite,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          isFavorite = !isFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.tUpdateFavoriteException)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  void _handleBack() {
    Navigator.pop(context, favoriteChanged);
  }

  void _editExercise() async {
    final timerController = Get.find<ExerciseTimerController>();
    if (timerController.isRunning.value || timerController.isPaused.value) {
      await showUnifiedDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => ActiveTimerDialog.forAction('edit', context),
      );
      return;
    }

    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ExerciseForm(
                isEdit: true,
                exercise: widget.exerciseData,
                exerciseName: widget.exerciseData['name'],
              )),
    );

    if (updated != null && updated is Map<String, dynamic>) {
      setState(() {
        widget.exerciseData.clear();
        widget.exerciseData.addAll(updated);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : tWhiteColor,
      appBar: SliderAppBar(
        title: widget.exerciseData['name'] ?? '',
        subtitle: widget.exerciseData['category'] ?? '',
        showBackButton: true,
        showFavoriteIcon: true,
        isFavorite: isFavorite,
        isAdmin: isAdmin,
        exercise: widget.exerciseData,
        onToggleFavorite: toggleFavorite,
        onBack: _handleBack,
        onEdit: _editExercise,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode
                    ? Colors.grey.shade700
                    : tBottomNavBarUnselectedColor,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode ? Colors.transparent : Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    text: AppLocalizations.of(context)!.tExerciseAbout,
                    isSelected: selectedTab == 0,
                    onTap: () {
                      setState(() => selectedTab = 0);
                      ExerciseDetailScreen.currentTabIndex.value = 0;
                    },
                  ),
                ),
                Expanded(
                  child: _TabButton(
                    text: AppLocalizations.of(context)!.tExerciseHistory,
                    isSelected: selectedTab == 1,
                    onTap: () {
                      setState(() => selectedTab = 1);
                      ExerciseDetailScreen.currentTabIndex.value = 1;
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: selectedTab == 0
                  ? ExerciseInfoTab(exerciseData: widget.exerciseData)
                  : ExerciseHistoryTab(
                      name: (widget.exerciseData['name'] ?? '')
                          .toString()
                          .trim()),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? tBottomNavBarSelectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDarkMode ? Colors.white70 : Colors.black),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
