import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticsController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<String>> getTop3Exercises(String userEmail) async {
    final userSnapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .get();

    if (userSnapshot.docs.isEmpty) return [];

    final userDocId = userSnapshot.docs.first.id;

    final exerciseLogsSnapshot = await firestore
        .collection('users')
        .doc(userDocId)
        .collection('exerciseLogs')
        .get();

    final exerciseCounts = <String, int>{};
    final exerciseDurations = <String, int>{};

    for (final doc in exerciseLogsSnapshot.docs) {
      final exerciseName = doc['exerciseName'] as String?;
      final duration = doc['duration'] as int?;

      if (exerciseName != null && duration != null) {
        exerciseCounts[exerciseName] = (exerciseCounts[exerciseName] ?? 0) + 1;
        exerciseDurations[exerciseName] =
            (exerciseDurations[exerciseName] ?? 0) + duration;
      }
    }

    final sortedExercises = exerciseDurations.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedExercises.take(3).map((entry) {
      final name = entry.key;
      final totalDuration = exerciseDurations[name] ?? 0;
      final formattedDuration = _formatDuration(totalDuration);
      return '$name ($formattedDuration)';
    }).toList();
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
