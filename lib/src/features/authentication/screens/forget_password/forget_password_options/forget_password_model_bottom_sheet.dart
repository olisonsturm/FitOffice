import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../../common_widgets/form/form_header_widget.dart';
import '../../../../../constants/sizes.dart';
import '../../../../../constants/text_strings.dart';

class ForgetPasswordScreen {
  static Future<dynamic> buildShowModalBottomSheet(BuildContext context, {required bool enableEdit, String? email}) {
return showModalBottomSheet(
  context: context,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
  builder: (context) => Container(
    padding: const EdgeInsets.all(tDefaultSpace),
    child: Column(
      children: [
        const SizedBox(height: tDefaultSpace * 4),
        const FormHeaderWidget(
          title: tForgotPassword,
          subTitle: tForgotPasswordSubTitle,
          crossAxisAlignment: CrossAxisAlignment.center,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: tFormHeight),
        Form(
          child: Column(
            children: [
              TextFormField(
                initialValue: email,
                decoration: InputDecoration(
                  label: const Text(tEmail),
                  hintText: tEmail,
                  prefixIcon: const Icon(Icons.mail_outline_rounded),
                  enabled: enableEdit,
                ),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (email != null && email.isNotEmpty) {
                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password reset email sent')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to send password reset email: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter your email')),
                      );
                    }
                  },
                  child: const Text(tYes),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);
  }
}