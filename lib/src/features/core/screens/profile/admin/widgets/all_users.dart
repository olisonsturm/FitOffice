import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/features/authentication/models/user_model.dart';
import 'package:fit_office/src/features/core/controllers/profile_controller.dart';
import 'package:fit_office/src/utils/theme/widget_themes/dialog_theme.dart';

import '../../../../../../constants/colors.dart';
import '../../../dashboard/widgets/categories.dart';
import '../../../dashboard/widgets/search.dart';
import '../../widgets/avatar.dart';
import '../edit_user_page.dart';

/// A page that displays a list of all users or only friends of the current user,
/// with search functionality and admin controls.
///
/// This widget is used in an administrative or social context where the current
/// user can view other user accounts. If `showOnlyFriends` is true and
/// `currentUserId` is provided, it filters the list to only show friends.
///
/// Admins can also edit or delete users from this list.
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

  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Loads user data from Firebase and optionally filters to only friends
  /// depending on [widget.showOnlyFriends].
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

  /// Filters the list of users based on a search query.
  void _searchUsers(String query) {
    final normalizedQuery = query.toLowerCase().trim();

    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final usernameMatch =
            user.userName.toLowerCase().contains(normalizedQuery);
        final emailMatch = user.email.toLowerCase().contains(normalizedQuery);
        return usernameMatch || emailMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.tMenu3),
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: tPrimaryColor),
      body: isUserLoaded
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  /// Search bar to filter users
                  DashboardSearchBox(
                    txtTheme: Theme.of(context).textTheme,
                    onSearchSubmitted: _searchUsers,
                    onTextChanged: (query) {
                      _categoriesKey.currentState?.updateSearchQuery(query);
                      setState(() {});
                    },
                    onFocusChanged: (hasFocus) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),

                  /// Show message or filtered user list
                  _filteredUsers.isEmpty
                      ? Text(AppLocalizations.of(context)!.tNoUsersFound)
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              return Card(
                                color: isDark ? Colors.grey.shade800 : Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: isDark ? Colors.white24 : Colors.black12,
                                    width: 1.0,
                                  ),
                                ),
                                child: ListTile(
                                  leading: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: Avatar(
                                      userEmail: user.email,
                                    ),
                                  ),
                                  title: Text(
                                    user.userName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                      '${user.email}\nRole: ${user.role ?? 'No role'}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark ? Colors.white70 : Colors.black54,
                                      )),

                                  /// Admin controls: Edit/Delete
                                  trailing: _currentUser.role == 'admin'
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit,
                                                  color: isDark ? Colors.white : Colors.black),
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
                                                        '${AppLocalizations.of(context)!.tAskDeleteUser}${user.userName}${AppLocalizations.of(context)!.tDeleteUserConsequence}'),
                                                    actions: [
                                                      TextButton(
                                                        style: Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.dark
                                                            ? TDialogTheme
                                                                .getDarkCancelButtonStyle()
                                                            : TDialogTheme
                                                                .getLightCancelButtonStyle(),
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
                                                        style: Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.dark
                                                            ? TDialogTheme
                                                                .getDarkDeleteButtonStyle()
                                                            : TDialogTheme
                                                                .getLightDeleteButtonStyle(),
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
