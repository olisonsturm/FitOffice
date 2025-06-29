import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/utils/helper/helper_controller.dart';
import 'package:flutter/material.dart';
import '../../../../common_widgets/form/form_header_widget.dart';
import '../../../../constants/sizes.dart';
import 'package:fit_office/l10n/app_localizations.dart';

/// ForgetPasswordScreen widget that displays a modal bottom sheet for password reset.
class ForgetPasswordScreen {
  static Future<dynamic> buildShowModalBottomSheet(BuildContext context, {required bool enableEdit, String? email}) {
return showModalBottomSheet(
  context: context,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(25.0),
      topRight: Radius.circular(25.0),
      bottomLeft: Radius.zero,
      bottomRight: Radius.zero,
    ),
  ),
  builder: (context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? tDarkColor
        : Colors.white;

    return Container(
      padding: const EdgeInsets.all(tDefaultSpace),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: tDefaultSpace),
          FormHeaderWidget(
            title: AppLocalizations.of(context)!.tForgotPassword,
            subTitle: AppLocalizations.of(context)!.tForgotPasswordSubTitle,
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
                    label: Text(AppLocalizations.of(context)!.tEmail),
                    hintText: AppLocalizations.of(context)!.tEmail,
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                    enabled: enableEdit,
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final localizations = AppLocalizations.of(context)!;
                      if (email != null && email.isNotEmpty) {
                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                          // TODO Is it working like this?
                          Helper.successSnackBar(title: 'Success', message: 'Password reset email sent');
                        } catch (e) {
                          // TODO Is it working like this?
                          Helper.errorSnackBar(title: localizations.tOhSnap, message: e.toString());
                        }
                      } else {
                        // TODO Is it working like this?
                        Helper.warningSnackBar(title: 'Warning', message: 'Please enter your email');
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.tYes),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  },
);
  }
}