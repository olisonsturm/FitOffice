import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_office/src/features/core/screens/profile/widgets/custom_profile_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../../../constants/sizes.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import '../../../../../repository/authentication_repository/authentication_repository.dart';
import '../../../../../repository/user_repository/user_repository.dart';
import '../../../../../utils/helper/helper_controller.dart';
import '../../../../../utils/theme/widget_themes/dialog_theme.dart';
import '../../../../authentication/models/user_model.dart';
import '../../../../authentication/screens/forget_password/forget_password_model_bottom_sheet.dart';
import '../../../controllers/profile_controller.dart';

// TODO: Add all the form fields, show the right timestamps not a hardcoded value, check if the username is already taken, and add a confirm popup before deleting the account.
class ProfileFormScreen extends StatefulWidget {
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
  ProfileFormScreenState createState() => ProfileFormScreenState();
}

class ProfileFormScreenState extends State<ProfileFormScreen> {
  late String initialEmail;
  late String initialFullName;
  late String initialUserName;
  bool isEdited = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initialEmail = widget.email.text;
    initialFullName = widget.fullName.text;
    initialUserName = widget.userName.text;

    // Add listeners to check for changes in the form fields
    widget.email.addListener(_checkForChanges);
    widget.fullName.addListener(_checkForChanges);
    widget.userName.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    setState(() {
      // Check if any of the fields have changed
      isEdited = widget.email.text != initialEmail ||
          widget.fullName.text != initialFullName ||
          widget.userName.text != initialUserName;
    });
  }

  @override
  void dispose() {
    widget.email.removeListener(_checkForChanges);
    widget.fullName.removeListener(_checkForChanges);
    widget.userName.removeListener(_checkForChanges);
    _passwordController.dispose();
    super.dispose();
  }

  // Show reauthentication dialog to confirm user's identity before sensitive operations
  Future<String?> _getPasswordFromUser(BuildContext context) async {
    final localisation = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    _passwordController.clear();
    String? password;

    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(localisation.tAuthentication),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localisation.tReauthenticationRequired),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: localisation.tPassword,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            style: isDarkMode
                ? TDialogTheme.getDarkCancelButtonStyle()
                : TDialogTheme.getLightCancelButtonStyle(),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(localisation.tCancel),
          ),
          TextButton(
            style: isDarkMode
                ? TDialogTheme.getDarkConfirmButtonStyle()
                : TDialogTheme.getLightConfirmButtonStyle(),
            onPressed: () {
              if (_passwordController.text.isEmpty) {
                Helper.warningSnackBar(
                  title: localisation.tWarning,
                  message: localisation.tEnterPassword,
                );
                return;
              }
              password = _passwordController.text;
              Navigator.of(context).pop();
            },
            child: Text(localisation.tConfirm),
          ),
        ],
      ),
    );

    return password;
  }

  // Method to handle account deletion with proper error handling
  Future<void> _handleAccountDeletion(BuildContext context) async {
    final localisation = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localisation.tRemoveAccount),
        content: Text(localisation.tRemoveAccountConfirm),
        actions: [
          TextButton(
            style: isDarkMode
                ? TDialogTheme.getDarkCancelButtonStyle()
                : TDialogTheme.getLightCancelButtonStyle(),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(localisation.tCancel),
          ),
          TextButton(
            style: isDarkMode
                ? TDialogTheme.getDarkDeleteButtonStyle()
                : TDialogTheme.getLightDeleteButtonStyle(),
            onPressed: () async {
              // Close the confirmation dialog first
              Navigator.of(dialogContext).pop();

              // First reauthenticate the user
              final password = await _getPasswordFromUser(context);

              if (password != null && context.mounted) {
                // Create a separate variable to track the deletion dialog
                BuildContext? loadingDialogContext;

                try {
                  // Show loading indicator and store its context
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) {
                      loadingDialogContext = ctx;
                      return AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(localisation.tDeletingAccount),
                          ],
                        ),
                      );
                    },
                  );

                  // Perform account deletion
                  final email = AuthenticationRepository.instance.getUserEmail;
                  if (email.isEmpty) {
                    throw 'Could not find user email. Please log in again.';
                  }
                  await AuthenticationRepository.instance.deleteUserWithData(email, password);

                  // Dismiss loading dialog if it's showing
                  if (loadingDialogContext != null && Navigator.of(loadingDialogContext!, rootNavigator: true).canPop()) {
                    Navigator.of(loadingDialogContext!, rootNavigator: true).pop();
                  }

                  // Show success message if context is still valid
                  if (context.mounted) {
                    Helper.successSnackBar(
                      title: localisation.tSuccess,
                      message: localisation.tAccountDeleted
                    );
                  }
                } catch (e) {
                  // Dismiss loading dialog if it's showing
                  if (loadingDialogContext != null && Navigator.of(loadingDialogContext!, rootNavigator: true).canPop()) {
                    Navigator.of(loadingDialogContext!, rootNavigator: true).pop();
                  }

                  if (kDebugMode) {
                    print('Account deletion error: $e');
                  }

                  // Show error message if context is still valid
                  if (context.mounted) {
                    Helper.errorSnackBar(
                      title: localisation.tOhSnap,
                      message: 'Failed to delete account: ${e.toString()}'
                    );
                  }
                }
              }
            },
            child: Text(localisation.tRemove),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localisation = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: widget.userName,
            validator: (value) => Helper.validateUsername(value, context),
            decoration: InputDecoration(label: Text(localisation.tUserName), prefixIcon: Icon(LineAwesomeIcons.user)),
            enabled: false,
          ),
          const SizedBox(height: tFormHeight - 20),
          TextFormField(
            controller: widget.fullName,
            validator: (value) => Helper.validateFullName(value, context),
            decoration: InputDecoration(label: Text(localisation.tFullName), prefixIcon: Icon(LineAwesomeIcons.user_tag_solid)),
          ),
          const SizedBox(height: tFormHeight - 20),
          TextFormField(
            controller: widget.email,
            validator: (value) => Helper.validateEmail(value, context),
            decoration: InputDecoration(label: Text(localisation.tEmail), prefixIcon: Icon(LineAwesomeIcons.envelope)),
            enabled: false,
          ),
          const SizedBox(height: tFormHeight - 20),

          /// -- FORGET PASSWORD BTN
          CustomProfileButton(
            isDark: isDark,
            icon: LineAwesomeIcons.key_solid,
            label: localisation.tResetPassword,
            onPress: () {
              ForgetPasswordScreen.buildShowModalBottomSheet(
                context,
                email: widget.email.text,
                enableEdit: false,
              );
            },
            iconColor: Colors.grey,
            textColor: Colors.black,
          ),

          /// -- Form Submit Button
          CustomProfileButton(
            isDark: isDark,
            icon: LineAwesomeIcons.save_solid,
            label: localisation.tSaveProfile,
            onPress: isEdited
                ? () {
                final userData = UserModel(
                  id: widget.user.id,
                  email: widget.email.text.trim(),
                  userName: widget.userName.text.trim(),
                  fullName: widget.fullName.text.trim(),
                  createdAt: widget.user.createdAt,
                  updatedAt: Timestamp.now(),
                  role: widget.user.role, // Ensure role is preserved
                  fitnessLevel: widget.user.fitnessLevel,
                  completedExercises: widget.user.completedExercises,
                  profilePicture: widget.user.profilePicture,
                );

                // Update the user record and global state
                controller.updateRecord(userData, context);

                // Close the modal after saving
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
                : () {}, // Disable the button if no changes were made
            iconColor: Colors.green,
            textColor: Colors.green,
            isActive: isEdited,
          ),
          Divider(),

          /// -- Delete Account Button
          CustomProfileButton(
            isDark: isDark,
            icon: LineAwesomeIcons.trash_solid,
            label: localisation.tDelete,
            onPress: () => _handleAccountDeletion(context),
            iconColor: Colors.red,
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
