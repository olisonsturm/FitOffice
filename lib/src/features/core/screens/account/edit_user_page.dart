import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fit_office/src/features/authentication/controllers/signup_controller.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/authentication/models/user_model.dart';
import 'package:fit_office/src/features/core/controllers/db_controller.dart';

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

  final List<String> _roles = ['user', 'admin'];
  String? _selectedRole;

  bool get isEditMode => widget.user != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.fullName ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _userNameController = TextEditingController(text: widget.user?.userName ?? '');
    _fitnessLevelController = TextEditingController(text: widget.user?.fitnessLevel ?? '');
    _passwordController = TextEditingController();
    _selectedRole = widget.user?.role ?? 'user';
  }

  Future<void> createUserAsAdmin({
    required String email,
    required String password,
  }) async {
    final FirebaseApp tempApp = await Firebase.initializeApp(
      name: 'tempApp',
      options: Firebase.app().options,
    );

    final FirebaseAuth tempAuth = FirebaseAuth.instanceFor(app: tempApp);

    try {
      await tempAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } finally {
      await tempAuth.signOut();
      await tempApp.delete();
    }
  }

  Future<void> _saveChanges() async {
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User updated')),
          );
        } else {
          _signUpController.userName.text = _userNameController.text.trim();
          _signUpController.email.text = _emailController.text.trim();
          _signUpController.password.text = _passwordController.text.trim();
          _signUpController.fullName.text = _nameController.text.trim();

          await _signUpController.createUser();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User created')),
          );
          await createUserAsAdmin(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }

      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit User" : "Create User"),
        backgroundColor: tCardBgColor,
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
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _userNameController,
                  decoration: const InputDecoration(
                    labelText: tUserName,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  readOnly: isEditMode,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                if (!isEditMode)
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
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
                  onChanged: (value) => setState(() => _selectedRole = value),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _fitnessLevelController,
                  decoration: const InputDecoration(
                    labelText: 'Fitness Level',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
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
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.save, color: Colors.blue),
                    label: Text(
                      isEditMode ? tSaveChanges : tCreateUser,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
