import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import '../../authentication/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:string_similarity/string_similarity.dart';

class DbController {
  late UserModel user;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<String?> fetchActiveStreakSteps() async {
    final userId = user.id;
    //This query must be edited when database structure is defined
    final streaksRef = firestore
        .collection('users')
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
      final exerciseHistoryRef = firestore
          .collection('users')
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
    final exerciseHistoryRef = firestore
        .collection('users')
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
  
  Future<String> getNumberOfExercisesByCategory(String category) async {
    final numberOfExercisesByCategory = await firestore
        .collection('exercises')
        .where('category', isEqualTo: category)
        .count()
        .get();
    return numberOfExercisesByCategory.count.toString();
  }

  Future<List<Map<String, dynamic>>> getExercises(String exerciseName) async {
    final snapshot = await firestore
        .collection('exercises')
        .get();

    final results = snapshot.docs.where((doc) {
      final name = doc['name'] as String;
      final description = doc['description'] as String;
      final nameSimilarity = StringSimilarity.compareTwoStrings(
        name.toLowerCase(),
        exerciseName.toLowerCase(),
      );
      final descriptionSimilarity = StringSimilarity.compareTwoStrings(
        description.toLowerCase(),
        exerciseName.toLowerCase(),
      );
      return nameSimilarity > 0.2 || descriptionSimilarity > 0.4;
    }).map((doc) => doc.data()).toList();

    return results;
  }

  Future<List<Map<String, dynamic>>> getAllExercisesOfCategory(String categoryName) async {
    final snapshot = await firestore
        .collection('exercises')
        .where('category', isEqualTo: categoryName)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getFavouriteExercises(String email) async {
    final userQuery = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (userQuery.docs.isEmpty) return [];

    final userDoc = userQuery.docs.first;

    final favoritesSnapshot = await userDoc.reference
        .collection('favorites')
        .get();

    List<Map<String, dynamic>> exerciseList = [];

    for (var favDoc in favoritesSnapshot.docs) {
      final exerciseRef = favDoc.data()['exercise'];

      if (exerciseRef is DocumentReference) {
        final exerciseSnap = await exerciseRef.get();
        if (exerciseSnap.exists) {
          exerciseList.add(exerciseSnap.data() as Map<String, dynamic>);
        }
      }
    }
    return exerciseList;
  }

  Future<void> addFavorite(String email, String exerciseName) async {
    final exerciseQuery = await firestore
        .collection('exercises')
        .where('name', isEqualTo: exerciseName)
        .get();
    final exerciseDoc = exerciseQuery.docs.first;
    final exerciseId = exerciseDoc.id;
    
    final userQuery = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    final userDoc = userQuery.docs.first;
    await userDoc.reference
        .collection('favorites')
        .add({'exercise': FirebaseFirestore.instance.doc('exercises/$exerciseId'), 'addedAt': FieldValue.serverTimestamp()});
  }

  Future<void> removeFavorite(String email, String exerciseName) async {
    final exerciseQuery = await firestore
        .collection('exercises')
        .where('name', isEqualTo: exerciseName)
        .get();

    final exerciseDoc = exerciseQuery.docs.first;
    final exerciseRef = exerciseDoc.reference;

    final userQuery = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    final userDoc = userQuery.docs.first;

    final favoriteQuery = await userDoc.reference
        .collection('favorites')
        .where('exercise', isEqualTo: exerciseRef).get();

    await favoriteQuery.docs.first.reference.delete();
  }

  Future<List<Map<String, dynamic>>> getAllExercises() async {
  try {
    final snapshot = await FirebaseFirestore.instance.collection('exercises').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  } catch (e) {
    print('Fehler beim Abrufen aller Übungen: $e');
    return [];
  }
}

}