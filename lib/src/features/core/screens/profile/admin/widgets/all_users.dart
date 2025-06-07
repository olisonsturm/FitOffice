import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/features/authentication/models/user_model.dart';
import 'package:fit_office/src/features/core/controllers/profile_controller.dart';

import '../../../dashboard/widgets/categories.dart';
import '../../../dashboard/widgets/search.dart';
import '../edit_user_page.dart';

class AllUsersPage extends StatefulWidget {
  final bool showOnlyFriends;
  final String? currentUserId;

  const AllUsersPage(
      {super.key, this.showOnlyFriends = false, this.currentUserId});

  @override
  State<AllUsersPage> createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {
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

    List<UserModel> users = [];

    if (widget.showOnlyFriends && widget.currentUserId != null) {
      final friendshipsSnapshot = await FirebaseFirestore.instance
          .collection('friendships')
          .where('sender', isEqualTo: widget.currentUserId)
          .get();

      final receiverFriendshipsSnapshot = await FirebaseFirestore.instance
          .collection('friendships')
          .where('receiver', isEqualTo: widget.currentUserId)
          .get();

      final friendIds = <dynamic>{
        ...friendshipsSnapshot.docs.map((doc) => doc['receiver']),
        ...receiverFriendshipsSnapshot.docs.map((doc) => doc['sender']),
      }.toList();

      if (friendIds.isNotEmpty) {
        final usersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: friendIds)
            .get();

        users = usersSnapshot.docs
            .map((doc) => UserModel.fromSnapshot(doc))
            .toList();
      }
    } else {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      users =
          usersSnapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
    }

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
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.tAllUsers),
          backgroundColor: Colors.grey),
      body: isUserLoaded
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DashboardSearchBox(
                    txtTheme: Theme.of(context).textTheme,
                    onSearchSubmitted: _searchUsers,
                    onTextChanged: (query) {
                      _categoriesKey.currentState?.updateSearchQuery(query);
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
                      ? Text(AppLocalizations.of(context)!.tNoUsersFound)
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
                                                        EditUserPage(
                                                            user: user),
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
                                                    title: Text(AppLocalizations
                                                            .of(context)!
                                                        .tDeleteEditUserHeading),
                                                    content: Text(
                                                        '${AppLocalizations.of(context)!.tAskDeleteUser}${user.fullName}${AppLocalizations.of(context)!.tDeleteUserConsequence}'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .tCancel),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          Navigator.of(context)
                                                              .pop();
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'users')
                                                              .doc(user.id)
                                                              .delete();
                                                          _loadData();
                                                        },
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .tDelete,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
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
