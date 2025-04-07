import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../authentication/models/user_model.dart';

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
}