import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import 'package:fit_office/src/features/core/controllers/statistics_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../authentication/models/user_model.dart';
import '../../../controllers/profile_controller.dart';

/// A widget that displays various fitness statistics related to a user.
///
/// The widget fetches user data and displays multiple statistic cards,
/// including streak information, last exercise time/duration, top exercises,
/// and longest streak. It can show statistics for the currently logged-in user
/// or for a specified user email.
class StatisticsWidget extends StatelessWidget {
  const StatisticsWidget({
    super.key,
    required this.txtTheme,
    this.userEmail,
  });

  final TextTheme txtTheme;
  final String? userEmail;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<UserModel>(
      future: controller.getUserData(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: tPrimaryColor),
          );
        }

        if (!userSnapshot.hasData) {
          return _buildErrorCard(context, isDark);
        }

        final user = userSnapshot.data!;
        final email = userEmail ?? user.email;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildStreakCard(email, isDark, context),
            const SizedBox(height: 10),
            buildLastExerciseCard(user, isDark, context),
            const SizedBox(height: 10),
            buildDurationCard(user, isDark, context),
            const SizedBox(height: 10),
            buildTopExercisesCard(email, isDark, context),
            const SizedBox(height: 10),
            buildLongestStreakCard(email, isDark, context),
          ],
        );
      },
    );
  }

  /// Consolidated Streak Card with better error handling
  Widget buildStreakCard(String email, bool isDark, BuildContext context) {
    final statisticsController = StatisticsController();
    final localizations = AppLocalizations.of(context)!;

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        statisticsController.getStreakSteps(email),
        statisticsController.getDoneExercisesInSeconds(email),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard(icon: Icons.local_fire_department_outlined);
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorCard(context, isDark);
        }

        final streakSteps = snapshot.data![0] as int;
        final secondsToday = snapshot.data![1] as int;

        return _buildStreakCardContent(
          streakSteps: streakSteps,
          secondsToday: secondsToday,
          isDark: isDark,
          localizations: localizations,
        );
      },
    );
  }

  Widget _buildStreakCardContent({
    required int streakSteps,
    required int secondsToday,
    required bool isDark,
    required AppLocalizations localizations,
  }) {
    const goalSeconds = 300; // 5 minutes
    final progress = (secondsToday / goalSeconds).clamp(0.0, 1.0);
    final duration = Duration(seconds: secondsToday);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final isGoalReached = progress >= 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(isDark),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.local_fire_department_outlined,
            color: streakSteps > 0 ? tPrimaryColor : Colors.grey,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.tActiveStreak,
                  style: txtTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  streakSteps > 0
                      ? '$streakSteps ${localizations.tDays}'
                      : localizations.tNoActiveStreak,
                  style: txtTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  color: isGoalReached ? Colors.green : Colors.orange,
                  backgroundColor: isDark ? Colors.black26 : Colors.grey[300],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$minutes min $seconds sec/5 min',
                      style: txtTheme.bodySmall,
                    ),
                    if (isGoalReached)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Last Exercise Card
  Widget buildLastExerciseCard(UserModel user, bool isDark, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final statisticsController = StatisticsController();

    return FutureBuilder<String?>(
      future: statisticsController.getTimeOfLastExercise(user.email, context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard(icon: Icons.schedule);
        }

        return _styledCard(
          icon: Icons.schedule,
          iconColor: snapshot.hasData && snapshot.data != null
              ? tPrimaryColor
              : Colors.grey,
          title: localizations.tLastExerciseTime,
          content: snapshot.data ?? localizations.tNoExercisesAvailable,
          isDark: isDark,
        );
      },
    );
  }

  /// Duration Card
  Widget buildDurationCard(UserModel user, bool isDark, BuildContext context) {
    final statisticsController = StatisticsController();
    final localizations = AppLocalizations.of(context)!;

    return FutureBuilder<String?>(
      future: statisticsController.getDurationOfLastExercise(user.email, context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard(icon: Icons.run_circle_outlined);
        }

        return _styledCard(
          icon: Icons.run_circle_outlined,
          iconColor: snapshot.hasData && snapshot.data != null
              ? tPrimaryColor
              : Colors.grey,
          title: localizations.tLastExerciseDuration,
          content: snapshot.data ?? localizations.tNoExercisesAvailable,
          isDark: isDark,
        );
      },
    );
  }

  /// Top Exercises Card
  Widget buildTopExercisesCard(String email, bool isDark, BuildContext context) {
    final statisticsController = StatisticsController();
    final localizations = AppLocalizations.of(context)!;

    return FutureBuilder<List<String>>(
      future: statisticsController.getTop3Exercises(email),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard(icon: Icons.star_border_outlined);
        }

        if (snapshot.hasError) {
          return _buildErrorCard(context, isDark);
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return _styledListCard(
            icon: Icons.star_border_outlined,
            iconColor: tPrimaryColor,
            title: localizations.tTop3Exercises,
            items: snapshot.data!,
            isDark: isDark,
          );
        }

        return _styledTextBlockCard(
          icon: Icons.star_border_outlined,
          iconColor: Colors.grey,
          title: localizations.tTop3Exercises,
          lines: [localizations.tNoExercisesDone],
          isDark: isDark,
        );
      },
    );
  }

  /// Longest Streak Card
  Widget buildLongestStreakCard(String email, bool isDark, BuildContext context) {
    final statisticsController = StatisticsController();
    final localizations = AppLocalizations.of(context)!;

    return FutureBuilder<Map<String, dynamic>?>(
      future: statisticsController.getLongestStreak(email, context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard(icon: Icons.auto_graph_outlined);
        }

        if (snapshot.hasError) {
          return _buildErrorCard(context, isDark);
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final data = snapshot.data!;
          return _styledTextBlockCard(
            icon: Icons.auto_graph_outlined,
            iconColor: tPrimaryColor,
            title: localizations.tLongestStreak,
            isDark: isDark,
            lines: [
              '${localizations.tStartDate}${data['startDate']}',
              '${localizations.tEndDate}${data['endDate']}',
              '${localizations.tDuration}${data['lengthInDays']}${localizations.tDays}',
            ],
          );
        }

        return _styledTextBlockCard(
          icon: Icons.auto_graph_outlined,
          iconColor: Colors.grey,
          title: localizations.tLongestStreak,
          lines: [localizations.tNoStreak],
          isDark: isDark,
        );
      },
    );
  }

  // Helper methods for common UI patterns
  Widget _buildLoadingCard({IconData? icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(Theme.of(Get.context!).brightness == Brightness.dark),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon ?? Icons.hourglass_empty,
            color: Colors.grey,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Platzhalter für Titel
                Container(
                  height: 20,
                  width: double.infinity * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                // Platzhalter für Content
                Container(
                  height: 16,
                  width: double.infinity * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, bool isDark) {
    final localizations = AppLocalizations.of(context)!;
    return _styledCard(
      icon: Icons.error_outline,
      iconColor: Colors.red,
      title: localizations.tError,
      content: localizations.tLoadingError,
      isDark: isDark,
    );
  }

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? Colors.grey[800] : Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: Colors.grey.withAlpha((0.5 * 255).toInt()),
        width: 1.5,
      ),
    );
  }

  /// Generic styled card layouts
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
      decoration: _cardDecoration(isDark),
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
                  style: txtTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
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
      decoration: _cardDecoration(isDark),
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
                  style: txtTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...items.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text('$index. $item', style: txtTheme.bodyLarge),
                  );
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
      decoration: _cardDecoration(isDark),
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
                  style: txtTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
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