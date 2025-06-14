import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/utils/helper/helper_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fit_office/src/features/core/screens/profile/friend_profile.dart';
import 'package:flutter/material.dart';

import '../../widgets/avatar.dart';

class FriendsBoxWidget extends StatefulWidget {
  final String currentUserId;

  const FriendsBoxWidget({super.key, required this.currentUserId});

  @override
  State<FriendsBoxWidget> createState() => _FriendsBoxWidgetState();
}

class _FriendsBoxWidgetState extends State<FriendsBoxWidget> {
  bool showAll = false;
  List<Map<String, dynamic>> _cachedFriends = [];
  bool _isLoading = true;

  Future<void> _fetchFriends() async {
    setState(() => _isLoading = true);

    try {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId);
      final friendshipsRef =
      FirebaseFirestore.instance.collection('friendships');

      final acceptedSnapshot1 = await friendshipsRef
          .where('sender', isEqualTo: userRef)
          .where('status', isEqualTo: 'accepted')
          .get();

      final acceptedSnapshot2 = await friendshipsRef
          .where('receiver', isEqualTo: userRef)
          .where('status', isEqualTo: 'accepted')
          .get();

      final pendingSnapshot = await friendshipsRef
          .where('sender', isEqualTo: userRef)
          .where('status', isEqualTo: 'pending')
          .get();

      final allDocs = [
        ...acceptedSnapshot1.docs,
        ...acceptedSnapshot2.docs,
        ...pendingSnapshot.docs
      ];

      List<Map<String, dynamic>> friendsData = [];

      for (var doc in allDocs) {
        final data = doc.data();
        final DocumentReference otherUserRef;

        if ((data['sender'] as DocumentReference).id == widget.currentUserId) {
          otherUserRef = data['receiver'] as DocumentReference;
        } else {
          otherUserRef = data['sender'] as DocumentReference;
        }

        final otherUserSnap = await otherUserRef.get();
        if (otherUserSnap.exists) {
          final userData = otherUserSnap.data() as Map<String, dynamic>;
          userData['friendshipDocId'] = doc.id;
          userData['status'] = data['status'];
          friendsData.add(userData);
        }
      }

      setState(() {
        _cachedFriends = friendsData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> deleteFriendship(
      String docId, String userName, bool isPending) async {
    try {
      await FirebaseFirestore.instance
          .collection('friendships')
          .doc(docId)
          .delete();
      setState(() {
        _cachedFriends.removeWhere((f) => f['friendshipDocId'] == docId);
      });
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Helper.successSnackBar(title: isPending
              ? '${AppLocalizations.of(context)!.tFriendshipRequestWithdraw}$userName'
              : '$userName${AppLocalizations.of(context)!.tFriendDeleted}',);
        });
      }
    } catch (e) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Helper.errorSnackBar(title: AppLocalizations.of(context)!.tFriendDeleteException);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  @override
  Widget build(BuildContext context) {
    final displayedFriends = showAll ? _cachedFriends : _cachedFriends.take(3).toList();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Berechne die optimale Höhe basierend auf der Anzahl der angezeigten Freunde
    double? containerHeight;
    if (!showAll && _cachedFriends.isNotEmpty) {
      final itemsToShow = _cachedFriends.length > 3 ? 3 : _cachedFriends.length;
      containerHeight = itemsToShow * 56.0; // 56 ist die Standard-ListTile Höhe
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.tFriends,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87),
            ),
            const Spacer(),
            if (_cachedFriends.length > 3)
              TextButton(
                onPressed: () => setState(() => showAll = !showAll),
                child: Text(
                  showAll
                      ? AppLocalizations.of(context)!.tShowLess
                      : AppLocalizations.of(context)!.tShowAll,
                  style: const TextStyle(color: tPrimaryColor),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.refresh, color: tPrimaryColor),
              onPressed: _fetchFriends,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          const Center(child: CircularProgressIndicator(color: tPrimaryColor,))
        else if (_cachedFriends.isEmpty)
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.tNoFriendsYet,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                width: 1.5,
              ),
            ),
            height: containerHeight,
            child: ListView.builder(
              shrinkWrap: true,
              physics: showAll ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
              itemCount: displayedFriends.length,
              itemBuilder: (context, index) {
                final friend = displayedFriends[index];
                final name = friend['username'] ??
                    AppLocalizations.of(context)!.tUnknown;
                final status = friend['status'];
                final isPending = status == 'pending';

                return ListTile(
                  leading: SizedBox(
                    width: 30,
                    height: 30,
                    child: Avatar(
                      userEmail: friend['email'],
                    ),
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPending)
                        const Icon(Icons.access_time, color: Colors.grey),
                      const SizedBox(width: 8),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          isPending ? Icons.cancel : Icons.person_remove,
                          color: isPending ? Colors.orange : Colors.red,
                        ),
                        onPressed: () async {
                          final docId = friend['friendshipDocId'];
                          if (docId != null) {
                            await deleteFriendship(docId, name, isPending);
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    final userName = friend['username'];
                    bool isFriend = friend['status'] == "accepted";
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendProfile(
                            userName: userName,
                            isFriend: isFriend,
                            isPending: isPending),
                      ),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}