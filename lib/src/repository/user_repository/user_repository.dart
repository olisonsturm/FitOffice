import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/features/authentication/models/user_model.dart';
import '../authentication_repository/exceptions/t_exceptions.dart';

/// UserRepository is responsible for managing user data in Firestore.
/// It provides methods to create, read, update, and delete user records,
/// as well as checking for user existence by email.
/// Uses FirebaseAuth for authentication and FirebaseFirestore for database operations.
class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  /// This method creates a new user record in Firestore using the current authenticated user's UID.
  /// @param user The UserModel object containing user details to be stored.
  Future<void> createUser(UserModel user) async {
    try {
      // Get the current authenticated user's UID
      final auth = FirebaseAuth.instance;
      final userId = auth.currentUser?.uid;

      if (userId == null) {
        throw Exception('User is not authenticated');
      }

      // Use the UID as the document ID in Firestore
      await _db.collection("users").doc(userId).set(user.toJson());
    } on FirebaseAuthException catch (e) {
      final result = TExceptions.fromCode(e.code);
      throw result.message;
    } on FirebaseException catch (e) {
      throw e.message.toString();
    } catch (e) {
      throw e
          .toString()
          .isEmpty ? 'Something went wrong. Please Try Again' : e.toString();
    }
  }

  /// This method retrieves the details of the currently authenticated user from Firestore.
  /// @return A Future that resolves to a UserModel object containing user details.
  /// @throws Exception if the user is not authenticated or if there is an error fetching the user details.
  /// @throws String if the user record does not exist.
  /// @throws String if there is an error fetching the user details.
  Future<UserModel> getUserDetails() async {
    try {
      final auth = FirebaseAuth.instance;
      final userId = auth.currentUser?.uid;

      if (userId == null) {
        throw Exception('User is not authenticated');
      }

      final snapshot = await _db.collection("users").doc(userId).get();
      if (!snapshot.exists) throw 'No such user found';

      return UserModel.fromSnapshot(snapshot);
    } catch (e) {
      throw e
          .toString()
          .isEmpty ? 'Something went wrong. Please Try Again' : e.toString();
    }
  }

  /// This method retrieves all user records from Firestore.
  /// @return A Future that resolves to a list of UserModel objects containing user details.
  /// @throws String if there is an error fetching the user records.
  /// @throws String if there are no user records found.
  /// @throws String if there is an error fetching the user records.
  Future<List<UserModel>> allUsers() async {
    try {
      final snapshot = await _db.collection("users").get();
      final users = snapshot.docs.map((e) => UserModel.fromSnapshot(e))
          .toList();
      return users;
    } on FirebaseAuthException catch (e) {
      final result = TExceptions.fromCode(e.code);
      throw result.message;
    } on FirebaseException catch (e) {
      throw e.message.toString();
    } catch (e) {
      debugPrint('Error: $e');
      throw 'Something went wrong. Please Try Again. Details: $e';
    }
  }

  /// This method updates an existing user record in Firestore.
  /// @param userId The ID of the user whose record is to be updated.
  /// @param data A map containing the fields to be updated in the user record.
  /// @throws String if the user record does not exist.
  /// @throws String if there is an error updating the user record.
  Future<void> updateUserRecord(String userId,
      Map<String, dynamic> data) async {
    try {
      await _db.collection("users").doc(userId).set(data, SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      final result = TExceptions.fromCode(e.code);
      throw result.message;
    } on FirebaseException catch (e) {
      throw e.message.toString();
    } catch (_) {
      throw 'Something went wrong. Please Try Again';
    }
  }

  /// This method deletes a user record from Firestore.
  /// @param id The ID of the user whose record is to be deleted.
  /// @throws String if the user record does not exist.
  /// @throws String if there is an error deleting the user record.
  Future<void> deleteUser(String id) async {
    try {
      await _db.collection("users").doc(id).delete();
    } on FirebaseAuthException catch (e) {
      final result = TExceptions.fromCode(e.code);
      throw result.message;
    } on FirebaseException catch (e) {
      throw e.message.toString();
    } catch (_) {
      throw 'Something went wrong. Please Try Again';
    }
  }

  /// Check if user exists with email
  /// @param email The email address to check for user existence.
  /// @return A Future that resolves to a boolean indicating whether a user with the given email exists.
  /// @throws String if there is an error fetching the record.
  Future<bool> recordExist(String email) async {
    try {
      final snapshot = await _db.collection("users").where(
          "email", isEqualTo: email).get();
      return snapshot.docs.isEmpty ? false : true;
    } catch (e) {
      throw "Error fetching record.";
    }
  }

  /// This method retrieves user details by their ID.
  /// @param userId The ID of the user whose details are to be retrieved.
  /// @return A Future that resolves to a UserModel object containing user details.
  /// @throws String if the user record does not exist.
  /// @throws String if there is an error fetching the user details.
  Future<UserModel> getUserDetailsById(String userId) async {
    try {
      final snapshot = await _db.collection("users").doc(userId).get();
      if (!snapshot.exists) {
        throw Exception('No user found with the given ID');
      }
      return UserModel.fromSnapshot(snapshot);
    } on FirebaseException catch (e) {
      throw e.message.toString();
    } catch (e) {
      throw 'Something went wrong. Please try again. Details: $e';
    }
  }
}
