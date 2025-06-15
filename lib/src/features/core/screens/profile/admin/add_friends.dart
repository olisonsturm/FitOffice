import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import 'package:fit_office/src/features/core/screens/profile/friend_profile.dart';
import 'package:fit_office/src/utils/helper/helper_controller.dart';
import 'package:fit_office/src/utils/theme/widget_themes/dialog_theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../controllers/friends_controller.dart';

class AddFriendsScreen extends StatefulWidget {
  final String currentUserId;

  const AddFriendsScreen({super.key, required this.currentUserId});

  @override
  State<AddFriendsScreen> createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends State<AddFriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<String> results = [];
  bool isSearching = false;
  Map<String, String?> friendshipStatus = {};
  final _controller = FriendsController();
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final query = _searchController.text.trim();
      _searchUsers(query);
    });
  }

  void _searchUsers(String query) async {
    if (query.length < 2) {
      if (mounted) {
        setState(() {
          results = [];
          isSearching = false;
          friendshipStatus.clear();
        });
      }
      return;
    }

    if (mounted) {
      setState(() => isSearching = true);
    }

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      final filtered = snapshot.docs
          .where((doc) =>
              doc.id != widget.currentUserId &&
              doc.data().containsKey('username') &&
              (doc['username'] as String)
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .map((doc) => doc['username'].toString())
          .toList();

      Map<String, String?> statusMap = {};
      for (final username in filtered) {
        final status =
            await _controller.getFriendshipStatus(currentUserEmail!, username);
        statusMap[username] = status;
      }

      if (mounted) {
        setState(() {
          results = filtered;
          friendshipStatus = statusMap;
          isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          results = [];
          friendshipStatus.clear();
          isSearching = false;
        });
      }
    }
  }

  Future<void> _withdrawFriendRequest(String username) async {
    if (!mounted) return;

    setState(() {
      friendshipStatus[username] = null;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final friendDoc = querySnapshot.docs.first;
        final currentUserRef = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.currentUserId);

        final friendshipRef =
            FirebaseFirestore.instance.collection('friendships');

        final pendingQuery = await friendshipRef
            .where('sender', isEqualTo: currentUserRef)
            .where('receiver', isEqualTo: friendDoc.reference)
            .where('status', isEqualTo: 'pending')
            .get();

        if (pendingQuery.docs.isNotEmpty) {
          await pendingQuery.docs.first.reference.delete();

          if (mounted) {
            Helper.warningSnackBar(title: AppLocalizations.of(context)!.tInfo,
              message: AppLocalizations.of(context)!.tFriendshipRequestWithdraw + username);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          friendshipStatus[username] = 'pending';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.tFriendDeleteException)),
        );
      }
    }
  }

  // New method to show confirmation dialog before removing friend or withdrawing request
  void _showDeleteConfirmationDialog(String userName, bool isPending) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final localization = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isPending
              ? localization.tCancelRequest
              : localization.tRemoveFriend,
        ),
        content: Text(
          isPending
              ? '${localization.tCancelRequestConfirm} $userName?'
              : '${localization.tRemoveFriendConfirm} $userName?',
        ),
        actions: [
          TextButton(
            style: isDark
                ? TDialogTheme.getDarkCancelButtonStyle()
                : TDialogTheme.getLightCancelButtonStyle(),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localization.tCancel),
          ),
          TextButton(
            style: isDark
                ? TDialogTheme.getDarkDeleteButtonStyle()
                : TDialogTheme.getLightDeleteButtonStyle(),
            onPressed: () async {
              Navigator.of(context).pop();

              if (isPending) {
                await _withdrawFriendRequest(userName);
              } else {
                if (!mounted) return;

                setState(() {
                  friendshipStatus[userName] = null;
                });

                try {
                  await _controller.removeFriendship(
                      currentUserEmail!, userName, context);
                } catch (e) {
                  if (mounted) {
                    setState(() {
                      friendshipStatus[userName] = 'accepted';
                    });
                  }
                }
              }
            },
            child: Text(
              isPending
                  ? localization.tCancel
                  : localization.tRemove,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.tAddFriendsHeader),
          backgroundColor: tPrimaryColor,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                decoration: InputDecoration(
                  hintText: localizations.tFriendsSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
              ),
              const SizedBox(height: 20),
              if (isSearching)
                const CircularProgressIndicator()
              else if (results.isEmpty && _searchController.text.length >= 2)
                Text(localizations.tNoResults)
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final username = results[index];
                      final status = friendshipStatus[username];

                      if (status == 'accepted') {
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(username),
                          trailing: IconButton(
                            icon: const Icon(Icons.person_remove,
                                color: Colors.red),
                            onPressed: () async {
                              _showDeleteConfirmationDialog(username, false);
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FriendProfile(
                                    userName: username, isFriend: true),
                              ),
                            );
                          },
                        );
                      } else if (status == 'pending') {
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(username),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time, color: Colors.grey),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.cancel,
                                    color: Colors.orange),
                                onPressed: () =>
                                    _showDeleteConfirmationDialog(username, true),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FriendProfile(
                                  userName: username,
                                  isFriend: false,
                                  isPending: true,
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(username),
                          trailing: IconButton(
                            icon: const Icon(Icons.person_add,
                                color: Colors.blue),
                            onPressed: () async {
                              if (!mounted) return;

                              setState(() {
                                friendshipStatus[username] = 'pending';
                              });

                              try {
                                await _controller.sendFriendRequest(
                                    currentUserEmail!, username, context);
                              } catch (e) {
                                if (mounted) {
                                  setState(() {
                                    friendshipStatus[username] = null;
                                  });

                                  Helper.errorSnackBar(title: localizations.tError,
                                    message: localizations.tExceptionAddingFriend);
                                }
                              }
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FriendProfile(
                                    userName: username, isFriend: false),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
