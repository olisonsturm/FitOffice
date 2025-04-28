import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/colors.dart';

class ExerciseHistoryTab extends StatelessWidget {
  final String name;

  const ExerciseHistoryTab({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final historyEntries = [
      {"date": "08.04.2025", "reps": "3x12", "weight": "40kg"},
      {"date": "05.04.2025", "reps": "3x10", "weight": "37.5kg"},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: historyEntries.length,
      itemBuilder: (context, index) {
        final entry = historyEntries[index];
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: MediaQuery.of(context).size.width -
                32, // 16 px horizontal margin
            child: Card(
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
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text(
                  entry["date"]!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? tWhiteColor : tBlackColor,
                  ),
                ),
                subtitle: Text(
                  "Wiederholungen: ${entry["reps"]!}",
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.grey,
                  ),
                ),
                trailing: Text(
                  entry["weight"]!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? tWhiteColor : tBlackColor,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
