import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import '../../authentication/models/user_model.dart';
import 'package:intl/intl.dart';

class DbController {
  late UserModel user;
  Future<String?> fetchActiveStreakSteps() async {
    final userId = user.id;
    //This query must be edited when database structure is defined
    final streaksRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('streaks');

    try {
      final querySnapshot = await streaksRef
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final steps = doc.data()['steps'];
        if (steps is String) {
          return steps;
        }
      }
    }on SocketException {
      // Network error occurred, handle accordingly
      return tDashboardNoInternetConnection;
    } on FirebaseException {
      // Handle other Firestore specific exceptions
      return tDashboardDatabaseException;
    } catch (e) {
      // Catch all other errors
      return tDashboardUnexpectedError;
    }

    return "0";
  }

  String timestampToString(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
    return formattedDate;
  }

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  Future<String?> lastExerciseOfUser() async {
    try {
      final userId = user.id;

      //Query needs to be edited if database structure changes
      final exerciseHistoryRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('exerciseHistory');

      final querySnapshot = await exerciseHistoryRef
          .orderBy('completedAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;

        final startedAt = doc.data()['startedAt'];

        if (startedAt != null && startedAt is Timestamp) {
          String startedAtString = timestampToString(startedAt);
          return startedAtString;
        } else {
          return tDashboardNoValidDate;
        }
      } else {
        return tDashboardNoExercisesDone;
      }
    } catch (e) {
      return tDashboardExceptionLoadingExercise;
    }
  }

  Future<String?> durationOfLastExercise() async {
    final userId = user.id;

    //Query needs to be edited if database structure changes
    final exerciseHistoryRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('exerciseHistory');

    final querySnapshot = await exerciseHistoryRef
        .orderBy('completedAt', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final data = doc.data();

      final Timestamp? startedAt = data['startedAt'];
      final Timestamp? completedAt = data['completedAt'];

      if (startedAt != null && completedAt != null) {
        final DateTime start = startedAt.toDate();
        final DateTime end = completedAt.toDate();

        final Duration duration = end.difference(start);
        String formattedDuration = _formatDuration(duration);

        return formattedDuration;
      } else {
        return tDashboardTimestampsMissing;
      }
    }
    return null;
  }

  Future<String> getNumberOfExercisesUpperBody() async {
    final numberOfExercisesUpperBody = await FirebaseFirestore.instance
        .collection('exercises')
        .where('category', isEqualTo: 'upper-body')
        .count()
        .get();
    return numberOfExercisesUpperBody.count.toString();
  }

  Future<String> getNumberOfExercisesLowerBody() async {
    final numberOfExercisesLowerBody = await FirebaseFirestore.instance
        .collection('exercises')
        .where('category', isEqualTo: 'lower-body')
        .count()
        .get();
    return numberOfExercisesLowerBody.count.toString();
  }

  Future<String> getNumberOfExercisesFullBody() async {
    final numberOfExercisesLowerBody = await FirebaseFirestore.instance
        .collection('exercises')
        .where('category', isEqualTo: 'full-body')
        .count()
        .get();
    return numberOfExercisesLowerBody.count.toString();
  }

  Future<String> getNumberOfPsychologicalExercises() async {
    final numberOfExercisesLowerBody = await FirebaseFirestore.instance
        .collection('exercises')
        .where('category', isEqualTo: 'mental')
        .count()
        .get();
    return numberOfExercisesLowerBody.count.toString();
  }
}