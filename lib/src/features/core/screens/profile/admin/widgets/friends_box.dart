import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fit_office/src/features/core/screens/profile/friend_profile.dart';
import 'package:flutter/material.dart';

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isPending
                    ? '${AppLocalizations.of(context)!.tFriendshipRequestWithdraw}$userName'
                    : '$userName${AppLocalizations.of(context)!.tFriendDeleted}',
              ),
            ),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(AppLocalizations.of(context)!.tFriendDeleteException)),
          );
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
    final displayedFriends = showAll ? _cachedFriends : _cachedFriends.toList();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

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
                  color: isDarkMode ? Colors.white : Colors.black87),
            ),
            const Spacer(),
            if (_cachedFriends.length > 3)
              TextButton(
                onPressed: () => setState(() => showAll = !showAll),
                child: Text(
                  showAll
                      ? AppLocalizations.of(context)!.tShowLess
                      : AppLocalizations.of(context)!.tShowAll,
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.blue),
              onPressed: _fetchFriends,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : Colors.white,
              border: Border.all(
                  color: isDarkMode ? Colors.white24 : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode ? Colors.black54 : Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SizedBox(
              height: showAll ? null : 168,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: displayedFriends.length,
                itemBuilder: (context, index) {
                  final friend = displayedFriends[index];
                  final name = friend['username'] ??
                      AppLocalizations.of(context)!.tUnknown;
                  final status = friend['status'];
                  final isPending = status == 'pending';

                  return ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: Text(
                      name,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
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
          ),
      ],
    );
  }
}
