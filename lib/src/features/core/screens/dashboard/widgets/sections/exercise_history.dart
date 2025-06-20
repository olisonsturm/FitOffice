import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:get/get.dart';
import '../../../../controllers/profile_controller.dart';
import 'package:fit_office/l10n/app_localizations.dart';

class ExerciseHistoryTab extends StatelessWidget {
  final String name;
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
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];

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

            return ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;

                final timestamp = (data['endTime'] as Timestamp?)?.toDate();
                final durationSeconds = data['duration'] is int
                    ? data['duration']
                    : int.tryParse(data['duration'].toString()) ?? 0;

                if (timestamp == null) return const SizedBox();

                final minutes = durationSeconds ~/ 60;
                final seconds = durationSeconds % 60;

                final formattedDate =
                    "${timestamp.day.toString().padLeft(2, '0')}.${timestamp.month.toString().padLeft(2, '0')}.${timestamp.year} – ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";

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
