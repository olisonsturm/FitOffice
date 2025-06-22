import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/features/authentication/models/user_model.dart';
import 'package:fit_office/src/repository/authentication_repository/authentication_repository.dart';
import 'package:fit_office/src/repository/user_repository/user_repository.dart';
import 'package:fit_office/l10n/app_localizations.dart';

import '../../../utils/helper/helper_controller.dart';

/// ProfileController class that manages user profile data and operations.
/// It handles fetching, updating, and deleting user profiles,
/// as well as notifying changes in profile picture updates.
class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  /// Repositories
  final _authRepo = AuthenticationRepository.instance;
  final _userRepo = UserRepository.instance;

  /// Reactive User Model for global state
  final user = Rx<UserModel?>(null);

  /// Reactive variable to notify when profile picture is updated
  final profilePictureUpdated = RxBool(false);

  /// Method to notify when profile picture is updated
  void notifyProfilePictureUpdated() {
    profilePictureUpdated.toggle();
  }

  /// Fetch user data using the authenticated user's ID
  Future<void> fetchUserData() async {
    try {
      final userId = _authRepo.getUserID;
      if (userId.isNotEmpty) {
        final userData = await _userRepo.getUserDetailsById(userId);
        user.value = userData;
      } else {
        Helper.warningSnackBar(title: 'Error', message: 'No user found!');
        throw Exception('No user found!');
      }
    } catch (e) {
      Helper.errorSnackBar(title: 'Error', message: e.toString());
      rethrow;
    }
  }

  /// This method ensures that the user data is fetched only once
  /// @returns the UserModel if it exists, otherwise fetches it
  Future<UserModel> getUserData() async {
    if (user.value == null) {
      await fetchUserData();
    }
    return user.value!;
  }

  /// Update user data and update the global state
  /// @param updatedUser The updated user model containing new data
  /// @param context The BuildContext to show snack bars
  Future<void> updateRecord(UserModel updatedUser, BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    try {
      // Fetch the current user data
      final currentUser = await getUserData();

      // Prepare the data to update only changed fields
      final updatedData = <String, dynamic>{};
      if (updatedUser.email != currentUser.email) {
        updatedData['email'] = updatedUser.email;
      }
      if (updatedUser.userName != currentUser.userName) {
        updatedData['username'] = updatedUser.userName;
      }
      if (updatedUser.fullName != currentUser.fullName) {
        updatedData['fullName'] = updatedUser.fullName;
      }
      updatedData['updatedAt'] = Timestamp.now();

      // Update the user record in the database
      await _userRepo.updateUserRecord(currentUser.id!, updatedData);

      // Update global state
      user.value = UserModel(
        id: currentUser.id,
        email: updatedData['email'] ?? currentUser.email,
        userName: updatedData['username'] ?? currentUser.userName,
        fullName: updatedData['fullName'] ?? currentUser.fullName,
        createdAt: currentUser.createdAt,
        updatedAt: Timestamp.now(),
        role: currentUser.role, // Preserve the role
        fitnessLevel: currentUser.fitnessLevel,
        completedExercises: currentUser.completedExercises,
        profilePicture: currentUser.profilePicture,
      );

      Helper.successSnackBar(
          title: localizations.tCongratulations, message: 'Profile Record has been updated!');
    } catch (e) {
      Helper.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Delete the authenticated user's account
  /// @param context The BuildContext to show snack bars
  /// Returns snack bar messages based on success or failure
  Future<void> deleteUser(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    try {
      final userId = _authRepo.getUserID;
      if (userId.isNotEmpty) {
        await _userRepo.deleteUser(userId);
        user.value = null; // Clear global state
        Helper.successSnackBar(
            title: localizations.tCongratulations, message: 'Account has been deleted!');
      } else {
        Helper.warningSnackBar(
            title: 'Error', message: 'User cannot be deleted!');
      }
    } catch (e) {
      Helper.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Fetch all users (for admin purposes)
  Future<List<UserModel>> getAllUsers() async => await _userRepo.allUsers();

  /// Fetch friends count for a given username
  /// @param username The username to search for friends
  /// @returns Amount of friends for the given username
  Future<int> getNumberOfFriends(String username) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return 0;
    }

    final documentRef = querySnapshot.docs.first.reference;
    final friendshipsRef = FirebaseFirestore.instance.collection('friendships');

    final acceptedSnapshot1 = await friendshipsRef
        .where('sender', isEqualTo: documentRef)
        .where('status', isEqualTo: 'accepted')
        .get();

    final acceptedSnapshot2 = await friendshipsRef
        .where('receiver', isEqualTo: documentRef)
        .where('status', isEqualTo: 'accepted')
        .get();

    final allDocs = [...acceptedSnapshot1.docs, ...acceptedSnapshot2.docs];

    return allDocs.length;
  }

}
