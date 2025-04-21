import 'package:fit_office/src/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/features/authentication/models/user_model.dart';
import 'package:fit_office/src/features/core/controllers/db_controller.dart';
import 'package:fit_office/src/features/core/controllers/profile_controller.dart';

class AllUsersPage extends StatefulWidget {
  const AllUsersPage({super.key});

  @override
  State<AllUsersPage> createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {
  final DbController _dbController = DbController();
  final ProfileController _profileController = Get.put(ProfileController());

  late UserModel _currentUser;
  bool isUserLoaded = false;
  List<UserModel> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final currentUser = await _profileController.getUserData();
    final users = await _dbController.getAllUsers();

    setState(() {
      _currentUser = currentUser;
      _allUsers = users;
      isUserLoaded = true;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(tAllUsers), backgroundColor: Colors.grey),
      body: isUserLoaded
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: _allUsers.isEmpty
            ? const Text(tNoUsersFound)
            : ListView.builder(
          itemCount: _allUsers.length,
          itemBuilder: (context, index) {
            final user = _allUsers[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('Email: ${user.email}\nRole: ${user.role ?? 'No role'}'),
                trailing: _currentUser.role == 'admin'
                    ? IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(tDeleteUserHeading),
                        content: Text('Do you like to delete "${user.fullName}"? The user cannot be restored and will be deleted globally!'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(tCancel),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await _dbController.deleteUser(user.email);
                              _loadData();
                            },
                            child: const Text(tDelete, style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                )
                    : null,
              ),
            );
          },
        ),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
