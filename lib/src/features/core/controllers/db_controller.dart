import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../authentication/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:fit_office/l10n/app_localizations.dart';

class DbController {
  late UserModel user;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String?> fetchActiveStreakSteps(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final userId = user.id;
    //This query must be edited when database structure is defined
    final streaksRef =
        firestore.collection('users').doc(userId).collection('streaks');

    try {
      final querySnapshot =
          await streaksRef.where('active', isEqualTo: true).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final steps = doc.data()['steps'];
        if (steps is String) {
          return steps;
        }
      }
    } on SocketException {
      // Network error occurred, handle accordingly
      return localizations.tDashboardNoInternetConnection;
    } on FirebaseException {
      // Handle other Firestore specific exceptions
      return localizations.tDashboardDatabaseException;
    } catch (e) {
      // Catch all other errors
      return localizations.tDashboardUnexpectedError;
    }

    return "0";
  }

  String timestampToString(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
    return formattedDate;
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
    final snapshot = await firestore.collection('exercises').get();
    final prefs = await SharedPreferences.getInstance();
    final locale = prefs.getString('locale');

    final results = snapshot.docs
        .where((doc) {
      String name;
      String description;
          if (locale == 'de') {
            name = doc['name'] as String;
            description = doc['description'] as String;
          } else {
            name = doc['name_en'] as String;
            description = doc['description_en'] as String;
          }
          final nameSimilarity = StringSimilarity.compareTwoStrings(
            name.toLowerCase(),
            exerciseName.toLowerCase(),
          );
          final descriptionSimilarity = StringSimilarity.compareTwoStrings(
            description.toLowerCase(),
            exerciseName.toLowerCase(),
          );
          return nameSimilarity > 0.4 || descriptionSimilarity > 0.4;
        })
        .map((doc) => doc.data())
        .toList();

    return results;
  }

  Future<List<Map<String, dynamic>>> getAllExercisesOfCategory(
      String categoryName) async {
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

    final favoritesSnapshot =
        await userDoc.reference.collection('favorites').get();

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
    if (exerciseQuery.docs.isEmpty) return;

    final exerciseDoc = exerciseQuery.docs.first;
    final exerciseRef = exerciseDoc.reference;

    final userQuery = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (userQuery.docs.isEmpty) return;

    final userDoc = userQuery.docs.first;

    // ➔ Jetzt prüfen, ob die Favorit bereits existiert!
    final favoriteQuery = await userDoc.reference
        .collection('favorites')
        .where('exercise', isEqualTo: exerciseRef)
        .get();

    if (favoriteQuery.docs.isEmpty) {
      // Nur wenn noch nicht vorhanden, hinzufügen!
      await userDoc.reference.collection('favorites').add(
          {'exercise': exerciseRef, 'addedAt': FieldValue.serverTimestamp()});
    }
  }

  Future<void> removeFavorite(String email, String exerciseName) async {
    final exerciseQuery = await firestore
        .collection('exercises')
        .where('name', isEqualTo: exerciseName)
        .get();

    if (exerciseQuery.docs.isEmpty) return;

    final exerciseDoc = exerciseQuery.docs.first;
    final exerciseRef = exerciseDoc.reference;

    final userQuery = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (userQuery.docs.isEmpty) return;

    final userDoc = userQuery.docs.first;

    final favoriteQuery = await userDoc.reference
        .collection('favorites')
        .where('exercise', isEqualTo: exerciseRef)
        .get();

    if (favoriteQuery.docs.isEmpty) return;

    await favoriteQuery.docs.first.reference.delete();
  }

  Future<void> deleteUser(String userEmail) async {
    final snapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .get();
    final userDoc = snapshot.docs.first;
    final userRef = userDoc.reference;
    await userRef.delete();
  }

  Future<void> updateUser(UserModel user) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();

    if (query.docs.isNotEmpty) {
      final docId = query.docs.first.id;
      await FirebaseFirestore.instance.collection('users').doc(docId).update({
        'fullName': user.fullName,
        'role': user.role,
      });
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await firestore.collection('users').get();
    return snapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
  }

  Future<List<Map<String, dynamic>>> getAllExercises() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('exercises').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getFilteredExercises({
    required String email,
    String? category,
    bool onlyFavorites = false,
  }) async {
    final allExercises = await getAllExercises();
    final favoritesRaw = await getFavouriteExercises(email);
    final favoriteNames = favoritesRaw.map((e) => e['name'] as String).toList();

    List<Map<String, dynamic>> filtered;

    if (onlyFavorites) {
      filtered = allExercises.where((exercise) {
        return favoriteNames.contains(exercise['name']);
      }).toList();
    } else if (category != null) {
      filtered = allExercises.where((exercise) {
        return exercise['category'] == category;
      }).toList();
    } else {
      filtered = allExercises;
    }

    return {
      'exercises': filtered,
      'favorites': favoriteNames,
    };
  }

  Future<void> toggleFavorite({
    required String email,
    required String exerciseName,
    required bool isCurrentlyFavorite,
  }) async {
    if (isCurrentlyFavorite) {
      await removeFavorite(email, exerciseName);
    } else {
      await addFavorite(email, exerciseName);
    }
  }

  Future<void> deleteExciseLogsOfExercise(String exerciseName) async {
    final usersSnapshot = await firestore.collection('users').get();

    for (final userDoc in usersSnapshot.docs) {
      final userRef = userDoc.reference;

      final logsSnapshot = await userRef
          .collection('exerciseLogs')
          .where('exerciseName', isEqualTo: exerciseName)
          .get();

      for (final logDoc in logsSnapshot.docs) {
        await logDoc.reference.delete();
      }
    }
  }
}
