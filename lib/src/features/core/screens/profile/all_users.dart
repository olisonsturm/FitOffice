import 'package:fit_office/src/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/features/authentication/models/user_model.dart';
import 'package:fit_office/src/features/core/controllers/db_controller.dart';
import 'package:fit_office/src/features/core/controllers/profile_controller.dart';

import '../dashboard/widgets/categories.dart';
import '../dashboard/widgets/search.dart';
import 'admin/edit_user_page.dart';

class AllUsersPage extends StatefulWidget {
  const AllUsersPage({super.key});

  @override
  State<AllUsersPage> createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {
  final DbController _dbController = DbController();
  final ProfileController _profileController = Get.put(ProfileController());
  final GlobalKey<DashboardCategoriesState> _categoriesKey =
  GlobalKey<DashboardCategoriesState>();

  late UserModel _currentUser;
  bool isUserLoaded = false;
  bool _searchHasFocus = false;
  String _searchText = '';

  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];

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
      _filteredUsers = users;
      isUserLoaded = true;
    });
  }

  void _searchUsers(String query) {
    final normalizedQuery = query.toLowerCase().trim();

    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final nameMatch = user.fullName.toLowerCase().contains(normalizedQuery);
        final emailMatch = user.email.toLowerCase().contains(normalizedQuery);
        return nameMatch || emailMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text(tAllUsers), backgroundColor: Colors.grey),
      body: isUserLoaded
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DashboardSearchBox(
              txtTheme: Theme.of(context).textTheme,
              onSearchSubmitted: _searchUsers,
              onTextChanged: (query) {
                _categoriesKey.currentState
                    ?.updateSearchQuery(query);
                setState(() {
                  _searchText = query;
                });
              },
              onFocusChanged: (hasFocus) {
                setState(() {
                  _searchHasFocus = hasFocus;
                });
              },
            ),
            const SizedBox(height: 16),
            _filteredUsers.isEmpty
                ? const Text(tNoUsersFound)
                : Expanded(
              child: ListView.builder(
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
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
                      subtitle: Text(
                          'Email: ${user.email}\nRole: ${user.role ?? 'No role'}'),
                      trailing: _currentUser.role == 'admin'
                          ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditUserPage(user: user),
                                ),
                              ).then((_) => _loadData());
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    AlertDialog(
                                      title: const Text(
                                          tDeleteEditUserHeading),
                                      content: Text(
                                          'Do you like to delete "${user.fullName}"? The user cannot be restored and will be deleted globally!'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop();
                                          },
                                          child:
                                          const Text(tCancel),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(context)
                                                .pop();
                                            await _dbController
                                                .deleteUser(
                                                user.email);
                                            _loadData();
                                          },
                                          child: const Text(
                                            tDelete,
                                            style: TextStyle(
                                                color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                            },
                          )
                        ],
                      )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}