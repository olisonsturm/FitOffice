import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

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

  Future<int> getDoneExercisesInSeconds(String userEmail,
      {DateTime? day}) async {
    final userRef = await _getUserDocRef(userEmail);

    final DateTime targetDay = day ?? DateTime.now();
    final dayStart = DateTime(targetDay.year, targetDay.month, targetDay.day);
    final nextDayStart = dayStart.add(const Duration(days: 1));

    final logs = await userRef
        .collection('exerciseLogs')
        .where('startTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
        .where('startTime', isLessThan: Timestamp.fromDate(nextDayStart))
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

    if (await getDoneExercisesInSeconds(userEmail) < 300) {
      return today.difference(start).inDays;
    }
    return today.difference(start).inDays + 1;
  }

  Future<void> setStreakInvalid(String userEmail) async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final todayStart = DateTime.now().subtract(Duration(
      hours: DateTime.now().hour,
      minutes: DateTime.now().minute,
      seconds: DateTime.now().second,
      milliseconds: DateTime.now().millisecond,
      microseconds: DateTime.now().microsecond,
    ));
    if (await getDoneExercisesInSeconds(userEmail, day: yesterday) < 300) {
      final userRef = await _getUserDocRef(userEmail);
      final streaks = await userRef
          .collection('streaks')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      if (streaks.docs.isNotEmpty) {
        final docRef = streaks.docs.first;
        final startedAt = (docRef['startedAt'] as Timestamp).toDate();

        final exercises = await userRef
            .collection('exerciseLogs')
            .orderBy('startTime', descending: true)
            .get();

        DateTime failedAtTime = todayStart;

        if (exercises.docs.isNotEmpty) {
          final exerciseDoc = exercises.docs.first;
          final exerciseTime = (exerciseDoc['startTime'] as Timestamp).toDate();

          failedAtTime = DateTime(exerciseTime.year, exerciseTime.month,
              exerciseTime.day, 23, 59, 59);
        }

        if (startedAt.isBefore(todayStart)) {
          await docRef.reference.update({
            'isActive': false,
            'failedAt': Timestamp.fromDate(failedAtTime),
          });
        }
      }
    }
  }

  Future<Map<String, dynamic>?> getLongestStreak(
      String userEmail, BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final userRef = await _getUserDocRef(userEmail);

    final allStreaksSnapshot = await userRef.collection('streaks').get();

    if (allStreaksSnapshot.docs.isEmpty) return null;

    int maxDays = 0;
    DateTime? longestStart;
    DateTime? longestEnd;
    bool isActiveStreak = false;

    for (var doc in allStreaksSnapshot.docs) {
      final startedAt = (doc['startedAt'] as Timestamp).toDate();
      DateTime endDate;

      final bool isActive = doc['isActive'] == true;

      if (doc['isActive'] == true) {
        endDate = DateTime.now();
      } else {
        endDate = (doc['failedAt'] as Timestamp).toDate();
      }

      final duration = endDate.difference(startedAt).inDays + 1;

      if (duration > maxDays) {
        maxDays = duration;
        longestStart = startedAt;
        longestEnd = endDate;
        isActiveStreak = isActive;
      }
    }

    return {
      'lengthInDays': maxDays,
      'startDate': _formatDate(longestStart!),
      'endDate': isActiveStreak
          ? localizations.tStreakStillActive
          : _formatDate(longestEnd!),
    };
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day.$month.$year';
  }

  Future<String> getTimeOfLastExercise(
      String userEmail, BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final userRef = await _getUserDocRef(userEmail);
    final exercise = await userRef
        .collection('exerciseLogs')
        .orderBy('endTime', descending: true)
        .limit(1)
        .get();
    if (exercise.docs.isEmpty) return localizations.tNoExercisesDone;
    final doc = exercise.docs.first;
    final Timestamp timestamp = doc['endTime'];
    final DateTime dateTime = timestamp.toDate();
    final formatted = DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
    return formatted;
  }

  Future<String> getDurationOfLastExercise(
      String userEmail, BuildContext context) async {
    final localisations = AppLocalizations.of(context)!;
    final userRef = await _getUserDocRef(userEmail);
    final exercise = await userRef
        .collection('exerciseLogs')
        .orderBy('endTime', descending: true)
        .limit(1)
        .get();
    if (exercise.docs.isEmpty) return localisations.tNoExercisesDone;
    final doc = exercise.docs.first;
    final Timestamp start = doc['startTime'];
    final Timestamp end = doc['endTime'];
    final Duration duration = end.toDate().difference(start.toDate());
    final String formattedDuration =
        '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')} min';
    return formattedDuration;
  }
}

class StreakController extends GetxController {
  final StatisticsController _statisticsController = StatisticsController();

  var streakSteps = 0.obs;
  var doneSeconds = 0.obs;
  var hasStreak = false.obs;
  var isLoading = true.obs;
  var isError = false.obs;

  Future<void> loadStreakData() async {
    isLoading.value = true;
    isError.value = false;
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null) {
      isError.value = true;
      isLoading.value = false;
      return;
    }

    try {
      await _statisticsController.setStreakInvalid(userEmail);
      hasStreak.value = await _statisticsController.isStreakActive(userEmail);

      final results = await Future.wait([
        _statisticsController.getDoneExercisesInSeconds(userEmail),
        _statisticsController.getStreakSteps(userEmail),
      ]);

      doneSeconds.value = results[0];
      streakSteps.value = results[1];
    } catch (_) {
      isError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
