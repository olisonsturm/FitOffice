import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../../constants/sizes.dart';
import '../../../../constants/text_strings.dart';
import '../../../../repository/authentication_repository/authentication_repository.dart';
import '../../../../repository/user_repository/user_repository.dart';
import '../../../../utils/helper/helper_controller.dart';
import '../../../authentication/models/user_model.dart';
import '../../../authentication/screens/forget_password/forget_password_mail/forget_password_mail.dart';
import '../../controllers/profile_controller.dart';

// TODO: Add all the form fields, show the right timestamps not a hardcoded value, check if the username is already taken, and add a confirm popup before deleting the account.
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
            validator: Helper.validateUsername,
            decoration: const InputDecoration(label: Text(tUserName), prefixIcon: Icon(LineAwesomeIcons.user)),
            enabled: false,
          ),
          const SizedBox(height: tFormHeight - 20),
          TextFormField(
            controller: fullName,
            validator: Helper.validateFullName,
            decoration: const InputDecoration(label: Text(tFullName), prefixIcon: Icon(LineAwesomeIcons.user_tag)),
          ),
          const SizedBox(height: tFormHeight - 20),
          TextFormField(
            controller: email,
            validator: Helper.validateEmail,
            decoration: const InputDecoration(label: Text(tEmail), prefixIcon: Icon(LineAwesomeIcons.envelope_1)),
            enabled: false,
          ),
          const SizedBox(height: tFormHeight - 20),

          /// -- FORGET PASSWORD BTN
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.to(() => ForgetPasswordMailScreen(email: email.text.trim(),));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.withOpacity(0.3),
                elevation: 0,
                foregroundColor: Colors.black,
                side: BorderSide.none,
              ),
              child: const Text(tResetPassword),
            ),
          ),
          const SizedBox(height: tFormHeight - 20),

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
                  updatedAt: Timestamp.now(),
                );

                await controller.updateRecord(userData);
              },
              child: const Text(tSaveProfile),
            ),
          ),
          const SizedBox(height: tFormHeight),

          /// -- Created Date and Delete Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FutureBuilder(
                future: controller.getUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      UserModel user = snapshot.data as UserModel;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: tJoined,
                              style: const TextStyle(fontSize: 12),
                              children: [
                                TextSpan(
                                  text: ' ${DateFormat('dd MMMM yyyy').format(user.createdAt!.toDate())}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              text: 'Last Updated ',
                              style: const TextStyle(fontSize: 12),
                              children: [
                                TextSpan(
                                  text: ' ${DateFormat('dd MMMM yyyy').format(user.updatedAt!.toDate())}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: tJoined,
                              style: TextStyle(fontSize: 12),
                              children: [
                                TextSpan(
                                  text: ' #error',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              text: 'Last Updated ',
                              style: TextStyle(fontSize: 12),
                              children: [
                                TextSpan(
                                  text: ' #error',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  } else {
                    return const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: tJoined,
                            style: TextStyle(fontSize: 12),
                            children: [
                              TextSpan(
                                text: ' ...',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            text: 'Last Updated ',
                            style: TextStyle(fontSize: 12),
                            children: [
                              TextSpan(
                                text: ' ...',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
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
                    if (kDebugMode) {
                      print('FirebaseAuthException: ${e.code} - ${e.message}');
                    }
                    Helper.errorSnackBar(title: tOhSnap, message: 'Failed to delete account: ${e.message}');
                  } catch (e) {
                    // Log any other errors
                    if (kDebugMode) {
                      print('Exception: $e');
                    }
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
          ),
        ],
      ),
    );
  }
}