import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticsController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<DocumentReference> _getUserDocRef(String email) async {
    final snapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('User not found');
    }

    return snapshot.docs.first.reference;
  }

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

  Future<bool> isStreakActive(String userEmail) async {
    final userRef = await _getUserDocRef(userEmail);
    final streaks = await userRef
        .collection('streaks')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    return streaks.docs.isNotEmpty;
  }

  Future<int> getDoneExercisesInSeconds(String userEmail) async {
    final userRef = await _getUserDocRef(userEmail);
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(Duration(days: 1));

    final logs = await userRef
        .collection('exerciseLogs')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .where('startTime', isLessThan: Timestamp.fromDate(tomorrowStart))
        .get();

    int total = 0;

    for (final doc in logs.docs) {
      final data = doc.data();
      final start = (data['startTime'] as Timestamp?)?.toDate();
      final end = (data['endTime'] as Timestamp?)?.toDate();

      if (start != null && end != null) {
        total += end.difference(start).inSeconds;
      }
    }

    return total;
  }

  Future<int> getStreakSteps(String userEmail) async {
    final userRef = await _getUserDocRef(userEmail);
    final streaks = await userRef
        .collection('streaks')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (streaks.docs.isEmpty) return 0;

    final startedAt = (streaks.docs.first['startedAt'] as Timestamp).toDate();
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startedAt.year, startedAt.month, startedAt.day);

    return today.difference(start).inDays + 1;
  }

}
