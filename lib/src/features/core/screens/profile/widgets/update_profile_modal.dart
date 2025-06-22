import 'package:flutter/material.dart';
import 'package:fit_office/src/features/authentication/models/user_model.dart';
import 'package:fit_office/src/features/core/screens/profile/widgets/profile_form.dart';
import 'package:fit_office/src/features/core/screens/profile/widgets/avatar_with_edit.dart';
import '../../../../../constants/sizes.dart';

/// A modal dialog for updating user profile information.
class UpdateProfileModal {
  static void show(BuildContext context, UserModel user) {
    final email = TextEditingController(text: user.email);
    final password = TextEditingController(text: user.password);
    final userName = TextEditingController(text: user.userName);
    final fullName = TextEditingController(text: user.fullName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: tDefaultSize,
            right: tDefaultSize,
            top: tDefaultSize,
            bottom: MediaQuery.of(context).viewInsets.bottom + tDefaultSize,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Center(child: AvatarWithEdit()),
                const SizedBox(height: 25),
                ProfileFormScreen(
                  user: user,
                  email: email,
                  fullName: fullName,
                  userName: userName,
                  password: password,
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        );
      },
    );
  }
}