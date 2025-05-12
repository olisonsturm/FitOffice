import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticsController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;


  Future<List<String>> getTop3Exercises(String userEmail) async {
    final userSnapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .get();

    if (userSnapshot.docs.isEmpty) {
      return [];
    }

    final userDocId = userSnapshot.docs.first.id;

    final exerciseLogsSnapshot = await firestore
        .collection('users')
        .doc(userDocId)
        .collection('exerciseLogs')
        .get();

    final exerciseCounts = <String, int>{};

    for (final doc in exerciseLogsSnapshot.docs) {
      final exerciseName = doc['exerciseName'] as String?;
      if (exerciseName != null) {
        exerciseCounts[exerciseName] = (exerciseCounts[exerciseName] ?? 0) + 1;
      }
    }

    final sortedExercises = exerciseCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedExercises.take(3).map((entry) => entry.key).toList();
  }
}
