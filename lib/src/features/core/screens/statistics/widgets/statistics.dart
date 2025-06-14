import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fit_office/src/features/core/controllers/statistics_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../constants/colors.dart';
import '../../../../authentication/models/user_model.dart';
import '../../../controllers/db_controller.dart';
import '../../../controllers/profile_controller.dart';

class StatisticsWidget extends StatelessWidget {
  const StatisticsWidget(
      {super.key,
      required this.txtTheme,
      this.userEmail});

  final TextTheme txtTheme;
  final String? userEmail;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildStreakCard(controller, isDark),
        const SizedBox(height: 10),
        _buildLastExerciseCard(controller, isDark),
        const SizedBox(height: 10),
        _buildDurationCard(controller, isDark),
        const SizedBox(height: 10),
        buildTopExercisesCard(controller, isDark),
        const SizedBox(height: 10),
        buildLongestStreakCard(controller, isDark)
      ],
    );
  }

  /// Streak-Card
  Widget buildStreakCard(ProfileController controller, isDark) {
    return FutureBuilder(
      future: controller.getUserData(),
      builder: (context, userSnapshot) {
        final localizations = AppLocalizations.of(context)!;
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (userSnapshot.hasData) {
          final user = userSnapshot.data as UserModel;
          final statisticsController = StatisticsController();
          final email = userEmail ?? user.email;

          return FutureBuilder<List<dynamic>>(
            future: Future.wait([
              statisticsController.getStreakSteps(email),
              statisticsController.getDoneExercisesInSeconds(email),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                final streakSteps = snapshot.data![0] as int;
                final secondsToday = snapshot.data![1] as int;

                final progress = (secondsToday / 300).clamp(0.0, 1.0);
                final duration = Duration(seconds: secondsToday);
                final minutes = duration.inMinutes;
                final seconds = duration.inSeconds % 60;

                final isGoalReached = progress >= 1.0;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.local_fire_department,
                          color: streakSteps > 0 ? Colors.orange : Colors.grey,
                          size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(localizations.tActiveStreak,
                                style: txtTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold)),
                            Text(
                              streakSteps > 0
                                  ? '$streakSteps ${localizations.tDays}'
                                  : localizations.tNoActiveStreak,
                              style: txtTheme.bodyLarge,
                            ),
                            LinearProgressIndicator(
                              value: progress,
                              minHeight: 10,
                              color: isGoalReached ? Colors.green : Colors.orange,
                              backgroundColor:
                              isDark ? Colors.black26 : Colors.grey[300],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('$minutes min $seconds sec/5 min',
                                    style: txtTheme.bodySmall),
                                if (isGoalReached)
                                  const Icon(Icons.check_circle,
                                      color: Colors.green, size: 20),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return _styledCard(
                  icon: Icons.error,
                  iconColor: Colors.red,
                  title: localizations.tError,
                  content: localizations.tLoadingError,
                  isDark: isDark,
                );
              }
            },
          );
        } else {
          return _styledCard(
            icon: Icons.error,
            iconColor: Colors.red,
            title: localizations.tError,
            content: localizations.tLoadingError,
            isDark: isDark,
          );
        }
      },
    );
  }

  /// Last-Exercise-Card
  Widget _buildLastExerciseCard(ProfileController controller, isDark) {
    return FutureBuilder(
      future: controller.getUserData(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (userSnapshot.hasData) {
          final user = userSnapshot.data as UserModel;
          final dbController = DbController()..user = user;

          return FutureBuilder<String?>(
            future: dbController.lastExerciseOfUser(context),
            builder: (context, stepsSnapshot) {
              if (stepsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (stepsSnapshot.hasData && stepsSnapshot.data != null) {
                return _styledCard(
                  icon: Icons.schedule,
                  iconColor: Colors.white,
                  title: 'Zeitpunkt der letzten Übung',
                  content: stepsSnapshot.data!,
                  isDark: isDark,
                );
              } else {
                return _styledCard(
                  icon: Icons.schedule,
                  iconColor: Colors.white,
                  title: 'Zeitpunkt der letzten Übung',
                  content: 'Keine Übungen vorhanden.',
                  isDark: isDark,
                );
              }
            },
          );
        } else {
          return _styledCard(
            icon: Icons.error,
            iconColor: Colors.red,
            title: 'Fehler',
            content: 'Fehler beim Laden der Nutzerdaten.',
            isDark: isDark,
          );
        }
      },
    );
  }

  /// Duration-of-Last-Exercise-Card
  Widget _buildDurationCard(ProfileController controller, isDark) {
    return FutureBuilder(
      future: controller.getUserData(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (userSnapshot.hasData) {
          final user = userSnapshot.data as UserModel;
          final dbController = DbController()..user = user;

          return FutureBuilder<String?>(
            future: dbController.durationOfLastExercise(context),
            builder: (context, stepsSnapshot) {
              if (stepsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (stepsSnapshot.hasData && stepsSnapshot.data != null) {
                return _styledCard(
                  icon: Icons.run_circle,
                  iconColor: Colors.white,
                  title: 'Dauer der letzten Übung',
                  content: stepsSnapshot.data!,
                  isDark: isDark,
                );
              } else {
                return _styledCard(
                  icon: Icons.run_circle,
                  iconColor: Colors.white,
                  title: 'Dauer der letzten Übung',
                  content: 'Keine Übungen vorhanden.',
                  isDark: isDark,
                );
              }
            },
          );
        } else {
          return _styledCard(
            icon: Icons.error,
            iconColor: Colors.red,
            title: 'Fehler',
            content: 'Fehler beim Laden der Nutzerdaten.',
            isDark: isDark,
          );
        }
      },
    );
  }

  /// Top-3-Exercises-Card
  Widget buildTopExercisesCard(ProfileController controller, isDark) {
    return FutureBuilder(
      future: controller.getUserData(),
      builder: (context, userSnapshot) {
        final localizations = AppLocalizations.of(context)!;
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (userSnapshot.hasData) {
          final user = userSnapshot.data as UserModel;
          final statisticsController = StatisticsController();

          return FutureBuilder<List<String>>(
            future: statisticsController
                .getTop3Exercises(userEmail != null ? userEmail! : user.email),
            builder: (context, topExercisesSnapshot) {
              if (topExercisesSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (topExercisesSnapshot.hasData &&
                  topExercisesSnapshot.data!.isNotEmpty) {
                return _styledListCard(
                  icon: Icons.star,
                  iconColor: Colors.amber,
                  title: localizations.tTop3Exercises,
                  items: topExercisesSnapshot.data!,
                  isDark: isDark,
                );
              } else {
                return _styledTextBlockCard(
                    icon: Icons.star,
                    iconColor: Colors.grey,
                    title: localizations.tTop3Exercises,
                    lines: [localizations.tNoExercisesDone],
                    isDark: isDark,
                );
              }
            },
          );
        } else {
          return _styledCard(
            icon: Icons.error,
            iconColor: Colors.red,
            title: localizations.tError,
            content: localizations.tLoadingError,
            isDark: isDark,
          );
        }
      },
    );
  }

  Widget buildLongestStreakCard(ProfileController controller, isDark) {
    return FutureBuilder(
      future: controller.getUserData(),
      builder: (context, userSnapshot) {
        final localizations = AppLocalizations.of(context)!;
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (userSnapshot.hasData) {
          final user = userSnapshot.data as UserModel;
          final statisticsController = StatisticsController();

          return FutureBuilder<Map<String, dynamic>?>(
            future: statisticsController
                .getLongestStreak(userEmail == null ? user.email : userEmail!, context),
            builder: (context, streakSnapshot) {
              if (streakSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (streakSnapshot.hasData &&
                  streakSnapshot.data!.isNotEmpty) {
                final data = streakSnapshot.data!;

                return _styledTextBlockCard(
                  icon: Icons.auto_graph,
                  iconColor: Colors.amber,
                  title: localizations.tLongestStreak,
                  isDark: isDark,
                  lines: [
                    '${localizations.tStartDate}${data['startDate']}',
                    '${localizations.tEndDate}${data['endDate']}',
                    '${localizations.tDuration}${data['lengthInDays']}${localizations.tDays}',
                  ],
                );
              } else {
                return _styledTextBlockCard(
                  icon: Icons.auto_graph,
                  iconColor: Colors.grey,
                  title: localizations.tLongestStreak,
                  lines: [localizations.tNoStreak],
                  isDark: isDark,
                );
              }
            },
          );
        } else {
          return _styledCard(
            icon: Icons.error,
            iconColor: Colors.red,
            title: localizations.tError,
            content: localizations.tLoadingError,
            isDark: isDark,
          );
        }
      },
    );
  }

  /// Generic layout method
  Widget _styledCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.withAlpha((0.5 * 255).toInt()),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: txtTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(content, style: txtTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _styledListCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> items,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.withAlpha((0.5 * 255).toInt()),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: txtTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                ...items.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final item = entry.value;
                  return Text('$index. $item', style: txtTheme.bodyLarge);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _styledTextBlockCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> lines,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.withAlpha((0.5 * 255).toInt()),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: txtTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                ...lines.map((line) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(line, style: txtTheme.bodyLarge),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
