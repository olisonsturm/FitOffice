import 'package:fit_office/src/features/authentication/controllers/signup_controller.dart';
import 'package:fit_office/src/features/core/screens/profile/admin/widgets/confirmation_dialog.dart';
import 'package:fit_office/src/features/core/screens/profile/admin/widgets/save_button.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import 'package:fit_office/src/features/authentication/models/user_model.dart';
import 'package:fit_office/src/features/core/controllers/db_controller.dart';

/// A page that allows creating a new user or editing an existing user's details.
class EditUserPage extends StatefulWidget {
  final UserModel? user;

  const EditUserPage({super.key, this.user});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = SignUpController.instance.signupFormKey;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _fitnessLevelController;
  late TextEditingController _userNameController;
  late TextEditingController _passwordController;

  final DbController _dbController = DbController();
  final SignUpController _signUpController = SignUpController.instance;

  bool isLoading = false;
  bool hasChanged = false;

  final List<String> _roles = ['user', 'admin'];
  String? _selectedRole;

  bool get isEditMode => widget.user != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.fullName ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _userNameController =
        TextEditingController(text: widget.user?.userName ?? '');
    _fitnessLevelController =
        TextEditingController(text: widget.user?.fitnessLevel ?? '');
    _passwordController = TextEditingController();
    _selectedRole = widget.user?.role ?? 'user';

    _nameController.addListener(_checkChanges);
    _userNameController.addListener(_checkChanges);
    _emailController.addListener(_checkChanges);
    _fitnessLevelController.addListener(_checkChanges);
    _passwordController.addListener(_checkChanges);

    _checkChanges();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _userNameController.dispose();
    _fitnessLevelController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Checks if any form field value has changed from the original user data.
  /// Updates [hasChanged] accordingly to enable/disable the save button.
  void _checkChanges() {
    final hasAnyChanged = _nameController.text != widget.user?.fullName ||
        _userNameController.text != widget.user?.userName ||
        _emailController.text != widget.user?.email ||
        _fitnessLevelController.text != widget.user?.fitnessLevel ||
        _passwordController.text.isNotEmpty ||
        _selectedRole != widget.user?.role;

    setState(() {
      hasChanged = hasAnyChanged;
    });
  }

  /// Validates and attempts to save changes to the user.
  ///
  /// If editing, updates the user data in the database.
  /// If creating, uses the sign-up controller to create a new user.
  /// Shows appropriate SnackBars on success or failure.
  Future<void> _saveChanges() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final localisations = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      final userData = UserModel(
        id: widget.user?.id,
        userName: _userNameController.text.trim(),
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: _selectedRole,
        fitnessLevel: _fitnessLevelController.text.trim(),
      );

      try {
        if (isEditMode) {
          await _dbController.updateUser(userData);
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text(localisations.tUserUpdated)),
          );
        } else {
          _signUpController.userName.text = _userNameController.text.trim();
          _signUpController.email.text = _emailController.text.trim();
          _signUpController.password.text = _passwordController.text.trim();
          _signUpController.fullName.text = _nameController.text.trim();

          await _signUpController.createUser();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(AppLocalizations.of(context)!.tUserCreated)),
            );
          }
        }
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e')),
          );
        }
      }

      setState(() => isLoading = false);
    }
  }

  /// Displays a confirmation dialog before saving changes.
  void _showSaveConfirmationDialog() {
    showConfirmationDialogModel(
      context: context,
      title: AppLocalizations.of(context)!.tSaveChanges,
      content: AppLocalizations.of(context)!.tSaveChangesQuestion,
      onConfirm: _saveChanges,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localisations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            isEditMode ? localisations.tEditUser : localisations.tCreateUser),
        backgroundColor: tPrimaryColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: localisations.tFullName,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? localisations.tRequired
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _userNameController,
                  decoration: InputDecoration(
                    labelText: localisations.tUserName,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? localisations.tRequired
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  readOnly: isEditMode,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.tEmail,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? localisations.tRequired
                      : null,
                ),
                const SizedBox(height: 12),
                if (!isEditMode)
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: localisations.tPassword,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localisations.tPasswordRequired;
                      }
                      if (value.length < 6) {
                        return localisations.tPasswordLength;
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: _roles
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                    _checkChanges();
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? localisations.tRequired
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _fitnessLevelController,
                  decoration: const InputDecoration(
                    labelText: 'Fitness Level',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? localisations.tRequired
                      : null,
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator()
                    : Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: SaveButton(
                          hasChanges: hasChanged,
                          onPressed: _showSaveConfirmationDialog,
                          label: localisations.tSave,
                        )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
