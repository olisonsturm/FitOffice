import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
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
    }on SocketException catch (e) {
      // Network error occurred, handle accordingly
      return "Keine Internetverbindung.";  // You can return a custom message
    } on FirebaseException catch (e) {
      // Handle other Firestore specific exceptions
      return "Datenbankfehler.";
    } catch (e) {
      // Catch all other errors
      return "Unerwarteter Fehler.";
    }

    return "0";
  }

  String timestampToString(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
    return formattedDate;
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
          return "Zeitpunkt: " + startedAtString;
        } else {
          return "Kein gültiges Datum verfügbar.";
        }
      } else {
        return "Keine Übungen absolviert.";
      }
    } catch (e) {
      return "Fehler beim Abrufen der letzten Übung.";
    }
  }

}