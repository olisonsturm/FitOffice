import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_office/src/utils/helper/helper_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../../constants/sizes.dart';
import '../../../../constants/text_strings.dart';
import '../../../../repository/authentication_repository/authentication_repository.dart';
import '../../../../repository/user_repository/user_repository.dart';
import '../../../authentication/models/user_model.dart';
import '../../controllers/profile_controller.dart';

// TODO: Add all the form fields, check if the username is already taken, and add a confirm popup before deleting the account.
class ProfileFormScreen extends StatelessWidget {
  const ProfileFormScreen({
    super.key,
    required this.user,
    required this.email,
    required this.fullName,
    required this.userName,
    required this.password,
  });

  final UserModel user;
  final TextEditingController email;
  final TextEditingController fullName;
  final TextEditingController userName;
  final TextEditingController password;

  @override
  Widget build(BuildContext context) {

    final _db = FirebaseFirestore.instance;
    final controller = Get.put(ProfileController());

    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: userName,
            decoration: const InputDecoration(label: Text(tUserName), prefixIcon: Icon(LineAwesomeIcons.user)),
          ),
          const SizedBox(height: tFormHeight - 20),
          TextFormField(
            controller: email,
            decoration: const InputDecoration(label: Text(tEmail), prefixIcon: Icon(LineAwesomeIcons.envelope_1)),
          ),
          const SizedBox(height: tFormHeight - 20),
          TextFormField(
            controller: fullName,
            decoration: const InputDecoration(label: Text(tFullName), prefixIcon: Icon(LineAwesomeIcons.user_friends)),
          ),
          const SizedBox(height: tFormHeight),

          /// -- Form Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final userData = UserModel(
                  id: user.id,
                  email: email.text.trim(),
                  userName: userName.text.trim(),
                  fullName: fullName.text.trim(),
                );

                await controller.updateRecord(userData);
              },
              child: const Text(tEditProfile),
            ),
          ),
          const SizedBox(height: tFormHeight),

          /// -- Created Date and Delete Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text.rich(
                TextSpan(
                  text: tJoined,
                  style: TextStyle(fontSize: 12),
                  //TODO: Replace the hardcoded date with the actual date from Firestore
                  children: [TextSpan(text: tJoinedAt, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Delete Firebase Auth account
                    await FirebaseFirestore.instance.runTransaction((transaction) async {
                      // Delete Firestore document
                      await UserRepository.instance.deleteUser(user.id!);
                      // Delete Firebase Auth account
                      await AuthenticationRepository.instance.deleteUser();
                    });

                    // Show success message
                    Helper.successSnackBar(title: tSuccess, message: 'Account deleted successfully');
                  } on FirebaseAuthException catch (e) {
                    // Log the error code and message
                    print('FirebaseAuthException: ${e.code} - ${e.message}');
                    Helper.errorSnackBar(title: tOhSnap, message: 'Failed to delete account: ${e.message}');
                  } catch (e) {
                    // Log any other errors
                    print('Exception: $e');
                    Helper.errorSnackBar(title: tOhSnap, message: 'Failed to delete account: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    elevation: 0,
                    foregroundColor: Colors.red,
                    side: BorderSide.none),
                child: const Text(tDelete),
              ),
            ],
          )
        ],
      ),
    );
  }
}