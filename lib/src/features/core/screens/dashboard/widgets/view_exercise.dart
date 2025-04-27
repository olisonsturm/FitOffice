import 'package:fit_office/src/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/sections/exercise_info.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/sections/exercise_history.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/appbar.dart';
import 'package:get/get.dart';

import '../../../controllers/db_controller.dart';
import '../../../controllers/profile_controller.dart';

class ExerciseDetailScreen extends StatefulWidget {
  static RxnString currentExerciseName = RxnString(); // <<< korrekt!
  static RxInt currentTabIndex =
      0.obs; // <<< Aktiver Tab: 0 = About, 1 = History

  final Map<String, dynamic> exerciseData;

  const ExerciseDetailScreen({super.key, required this.exerciseData});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  int selectedTab = 0;
  bool isFavorite = false;
  bool favoriteChanged = false;

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
    _loadFavoriteStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ExerciseDetailScreen.currentExerciseName.value = '';
      ExerciseDetailScreen.currentTabIndex.value = -1;
    });
    super.dispose();
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
    final user = await _profileController.getUserData();
    final exerciseName = widget.exerciseData['name'];

    if (isFavorite) {
      await _dbController.removeFavorite(user.email, exerciseName);
    } else {
      await _dbController.addFavorite(user.email, exerciseName);
    }

    setState(() {
      isFavorite = !isFavorite;
      favoriteChanged = true;
    });
  }

  void _handleBack() {
    Navigator.pop(context, favoriteChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tWhiteColor,
      appBar: SliderAppBar(
        showBackButton: true,
        showFavoriteIcon: true,
        isFavorite: isFavorite,
        onToggleFavorite: toggleFavorite,
        onBack: _handleBack,
        normalAppBar: AppBar(
          backgroundColor: tWhiteColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          title: Column(
            children: [
              Text(
                widget.exerciseData['name'] ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.exerciseData['category'] ?? '',
                style: TextStyle(
                  color: tBottomNavBarUnselectedColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: tBottomNavBarUnselectedColor),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    text: tExerciseAbout,
                    isSelected: selectedTab == 0,
                    onTap: () {
                      setState(() => selectedTab = 0);
                      ExerciseDetailScreen.currentTabIndex.value = 0;
                    },
                  ),
                ),
                Expanded(
                  child: _TabButton(
                    text: tExerciseHistory,
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
                  : ExerciseHistoryTab(name: widget.exerciseData['name']),
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
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
