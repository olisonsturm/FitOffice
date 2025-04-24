import 'package:fit_office/src/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/sections/exercise_info.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/sections/exercise_history.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/appbar.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/features/core/controllers/exercise_timer.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> exerciseData;

  const ExerciseDetailScreen({super.key, required this.exerciseData});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tWhiteColor,
      appBar: TimerAwareAppBar(
        showBackButton: true,
        hideIcons: selectedTab == 0, 
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
                style: const TextStyle(
                    color: tBottomNavBarUnselectedColor, fontSize: 14),
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
                    onTap: () => setState(() => selectedTab = 0),
                  ),
                ),
                Expanded(
                  child: _TabButton(
                    text: tExerciseHistory,
                    isSelected: selectedTab == 1,
                    onTap: () => setState(() => selectedTab = 1),
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
