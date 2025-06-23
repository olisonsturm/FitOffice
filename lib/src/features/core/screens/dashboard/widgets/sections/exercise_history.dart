import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:get/get.dart';
import '../../../../controllers/profile_controller.dart';
import 'package:fit_office/l10n/app_localizations.dart';

/// Displays a history list of all past executions for a specific exercise.
///
/// Data is retrieved from Firestore under:
/// `users/{userId}/exerciseLogs`
/// where `exerciseName` matches the given [name].
class ExerciseHistoryTab extends StatelessWidget {
  /// Name of the exercise (used to filter history entries)
  final String name;

  /// Shared scroll controller (e.g., for global overlays or scroll-to-bottom)
  final ScrollController scrollController;

  const ExerciseHistoryTab(
      {super.key, required this.name, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final profileController = Get.find<ProfileController>();

    return FutureBuilder(
      future: profileController.getUserData(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!userSnapshot.hasData) {
          return Center(
            child: Text(
              localizations.tHistoryNoUserData,
              style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54),
            ),
          );
        }

        final user = userSnapshot.data!;
        final userId = user.id;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('exerciseLogs')
              .where('exerciseName', isEqualTo: name.trim())
              //.orderBy('endTime', descending: true)  --> Index dafür notwendig?! dass man das einstellen kann
              .snapshots(),
          builder: (context, snapshot) {
            // Show loading spinner while listening to the stream
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];
            // If there is no history for this exercise
            if (docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "${localizations.tHistoryNoExercise1} $name${localizations.tHistoryNoExercise2}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              );
            }
            // Build the list of history entries
            return ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                // Extract timestamp and duration
                final timestamp = (data['endTime'] as Timestamp?)?.toDate();
                final durationSeconds = data['duration'] is int
                    ? data['duration']
                    : int.tryParse(data['duration'].toString()) ?? 0;

                if (timestamp == null) return const SizedBox();

                final minutes = durationSeconds ~/ 60;
                final seconds = durationSeconds % 60;

                final formattedDate =
                    "${timestamp.day.toString().padLeft(2, '0')}.${timestamp.month.toString().padLeft(2, '0')}.${timestamp.year} – ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
                // Build visual card
                return Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: MediaQuery.of(context).size.width - 32,
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
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        title: Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? tWhiteColor : tBlackColor,
                          ),
                        ),
                        subtitle: Text(
                          "${localizations.tDuration}: $minutes ${localizations.tMinutes} $seconds ${localizations.tSeconds}",
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
