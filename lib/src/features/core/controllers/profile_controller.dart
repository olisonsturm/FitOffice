import 'package:get/get.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/authentication/models/user_model.dart';
import 'package:fit_office/src/repository/authentication_repository/authentication_repository.dart';
import 'package:fit_office/src/repository/user_repository/user_repository.dart';

import '../../../utils/helper/helper_controller.dart';

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  /// Repositories
  final _authRepo = AuthenticationRepository.instance;
  final _userRepo = UserRepository.instance;

  /// Get User Email and pass to UserRepository to fetch user record.
  Future<UserModel> getUserData() async {
    try {
      final currentUserEmail = _authRepo.getUserEmail;
      if (currentUserEmail.isNotEmpty) {
        return await _userRepo.getUserDetails(currentUserEmail);
      } else {
        Helper.warningSnackBar(title: 'Error', message: 'No user found!');
        throw Exception('No user found!');
    }
  } catch (e) {
    Helper.errorSnackBar(title: 'Error', message: e.toString());
    rethrow;
  }
}

  /// Fetch List of user records.
  Future<List<UserModel>> getAllUsers() async => await _userRepo.allUsers();

  /// Update User Data
  updateRecord(UserModel user) async {
    try {
      await _userRepo.updateUserRecord(user);
      //Show some message or redirect to other screen here...
      Helper.successSnackBar(title: tCongratulations, message: 'Profile Record has been updated!');
    } catch (e) {
      Helper.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> deleteUser() async {
    try {
      String uID = _authRepo.getUserID;
      if (uID.isNotEmpty) {
        await _userRepo.deleteUser(uID);
        // You can Logout() or move to other screen here...
        Helper.successSnackBar(title: tCongratulations, message: 'Account has been deleted!');
      } else {
        Helper.successSnackBar(title: 'Error', message: 'User cannot be deleted!');
      }
    } catch (e) {
      Helper.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
