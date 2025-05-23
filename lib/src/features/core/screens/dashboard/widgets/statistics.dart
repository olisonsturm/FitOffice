import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/core/controllers/statistics_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../constants/colors.dart';
import '../../../../authentication/models/user_model.dart';
import '../../../controllers/db_controller.dart';
import '../../../controllers/profile_controller.dart';

class StatisticsWidget extends StatelessWidget {
  const StatisticsWidget({
    super.key,
    required this.txtTheme,
    required this.isDark,
  });

  final TextTheme txtTheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStreakCard(controller),
        const SizedBox(height: 10),
        _buildLastExerciseCard(controller),
        const SizedBox(height: 10),
        _buildDurationCard(controller),
        const SizedBox(height: 10),
        _buildTopExercisesCard(controller)
      ],
    );
  }

  /// Streak-Card
  Widget _buildStreakCard(ProfileController controller) {
    return FutureBuilder(
      future: controller.getUserData(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (userSnapshot.hasData) {
          final user = userSnapshot.data as UserModel;
          final dbController = DbController()..user = user;

          return FutureBuilder<String?>(
            future: dbController.fetchActiveStreakSteps(),
            builder: (context, stepsSnapshot) {
              if (stepsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (stepsSnapshot.hasData && stepsSnapshot.data != null) {
                return _styledCard(
                  icon: Icons.local_fire_department,
                  iconColor: Colors.orange,
                  title: 'Aktiver Streak',
                  content: stepsSnapshot.data!,
                );
              } else {
                return _styledCard(
                  icon: Icons.local_fire_department,
                  iconColor: Colors.grey,
                  title: 'Aktiver Streak',
                  content: 'Kein aktiver Streak gefunden.',
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
          );
        }
      },
    );
  }

  /// Last-Exercise-Card
  Widget _buildLastExerciseCard(ProfileController controller) {
    return FutureBuilder(
      future: controller.getUserData(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (userSnapshot.hasData) {
          final user = userSnapshot.data as UserModel;
          final dbController = DbController()..user = user;

          return FutureBuilder<String?>(
            future: dbController.lastExerciseOfUser(),
            builder: (context, stepsSnapshot) {
              if (stepsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (stepsSnapshot.hasData && stepsSnapshot.data != null) {
                return _styledCard(
                  icon: Icons.schedule,
                  iconColor: Colors.white,
                  title: 'Zeitpunkt der letzten Übung',
                  content: stepsSnapshot.data!,
                );
              } else {
                return _styledCard(
                  icon: Icons.schedule,
                  iconColor: Colors.white,
                  title: 'Zeitpunkt der letzten Übung',
                  content: 'Keine Übungen vorhanden.',
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
          );
        }
      },
    );
  }

  /// Duration-of-Last-Exercise-Card
  Widget _buildDurationCard(ProfileController controller) {
    return FutureBuilder(
      future: controller.getUserData(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (userSnapshot.hasData) {
          final user = userSnapshot.data as UserModel;
          final dbController = DbController()..user = user;

          return FutureBuilder<String?>(
            future: dbController.durationOfLastExercise(),
            builder: (context, stepsSnapshot) {
              if (stepsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (stepsSnapshot.hasData && stepsSnapshot.data != null) {
                return _styledCard(
                  icon: Icons.run_circle,
                  iconColor: Colors.white,
                  title: 'Dauer der letzten Übung',
                  content: stepsSnapshot.data!,
                );
              } else {
                return _styledCard(
                  icon: Icons.run_circle,
                  iconColor: Colors.white,
                  title: 'Dauer der letzten Übung',
                  content: 'Keine Übungen vorhanden.',
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
          );
        }
      },
    );
  }

  /// Top-3-Exercises-Card
  Widget _buildTopExercisesCard(ProfileController controller) {
    return FutureBuilder(
      future: controller.getUserData(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (userSnapshot.hasData) {
          final user = userSnapshot.data as UserModel;
          final statisticsController = StatisticsController();

          return FutureBuilder<List<String>>(
            future: statisticsController.getTop3Exercises(user.email),
            builder: (context, topExercisesSnapshot) {
              if (topExercisesSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (topExercisesSnapshot.hasData &&
                  topExercisesSnapshot.data!.isNotEmpty) {
                return _styledListCard(
                  icon: Icons.star,
                  iconColor: Colors.amber,
                  title: tTop3Exercises,
                  items: topExercisesSnapshot.data!,
                );
              } else {
                return _styledListCard(
                  icon: Icons.star,
                  iconColor: Colors.grey,
                  title: tTop3Exercises,
                  items: [tNoExercisesDone],
                );
              }
            },
          );
        } else {
          return _styledCard(
            icon: Icons.error,
            iconColor: Colors.red,
            title: tError,
            content: tLoadingError,
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
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? tSecondaryColor : tCardBgColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
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
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? tSecondaryColor : tCardBgColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
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
                const SizedBox(height: 8),
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
}
