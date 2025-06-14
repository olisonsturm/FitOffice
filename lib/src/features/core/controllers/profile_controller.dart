import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/features/authentication/models/user_model.dart';
import 'package:fit_office/src/repository/authentication_repository/authentication_repository.dart';
import 'package:fit_office/src/repository/user_repository/user_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/helper/helper_controller.dart';

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  /// Repositories
  final _authRepo = AuthenticationRepository.instance;
  final _userRepo = UserRepository.instance;

  /// Reactive User Model for global state
  final user = Rx<UserModel?>(null);

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

  Future<UserModel> getUserData() async {
    if (user.value == null) {
      await fetchUserData();
    }
    return user.value!;
  }

  /// Update user data and update the global state
  Future<void> updateRecord(UserModel updatedUser, BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    try {
      await _userRepo.updateUserRecord(updatedUser.id!, updatedUser.toJson());
      user.value = updatedUser; // Update global state
      Helper.successSnackBar(
          title: localizations.tCongratulations, message: 'Profile Record has been updated!');
    } catch (e) {
      Helper.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Delete the authenticated user's account
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
