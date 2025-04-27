import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_office/src/constants/text_strings.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  @override
  Widget build(BuildContext context) {
    final displayedFriends = showAll ? _cachedFriends : _cachedFriends.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              tFriends,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (_cachedFriends.length > 3)
              TextButton(
                onPressed: () => setState(() => showAll = !showAll),
                child: Text(
                  showAll ? tShowLess : tShowAll,
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
            child: showAll
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _cachedFriends.length,
                    itemBuilder: (context, index) {
                      final friend = _cachedFriends[index];
                      final name = friend['username'] ?? tUnknown;
                      final status = friend['status'];
                      final isPending = status == 'pending';

                      return ListTile(
                        leading: const Icon(Icons.person, color: Colors.blue),
                        title: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: isPending
                            ? const Icon(Icons.access_time, color: Colors.grey)
                            : IconButton(
                                icon: const Icon(Icons.person_remove,
                                    color: Colors.red),
                                onPressed: () async {
                                  final docId = friend['friendshipDocId'];
                                  if (docId != null) {
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('friendships')
                                          .doc(docId)
                                          .delete();
                                      setState(() {
                                        _cachedFriends.removeWhere((f) =>
                                            f['friendshipDocId'] == docId);
                                      });
                                      if (mounted) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    '$name$tFriendDeleted')),
                                          );
                                        });
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    tFriendDeleteException)),
                                          );
                                        });
                                      }
                                    }
                                  }
                                },
                              ),
                      );
                    },
                  )
                : SizedBox(
                    height: 168,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: displayedFriends.length,
                      itemBuilder: (context, index) {
                        final friend = displayedFriends[index];
                        final name = friend['username'] ?? tUnknown;
                        final status = friend['status'];
                        final isPending = status == 'pending';

                        return ListTile(
                          leading: const Icon(Icons.person, color: Colors.blue),
                          title: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: isPending
                              ? const Icon(Icons.access_time,
                                  color: Colors.grey)
                              : IconButton(
                                  icon: const Icon(Icons.person_remove,
                                      color: Colors.red),
                                  onPressed: () async {
                                    final docId = friend['friendshipDocId'];
                                    if (docId != null) {
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('friendships')
                                            .doc(docId)
                                            .delete();

                                        setState(() {
                                          _cachedFriends.removeWhere((f) =>
                                              f['friendshipDocId'] == docId);
                                        });
                                        if (mounted) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      '$name$tFriendDeleted')),
                                            );
                                          });
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      tFriendDeleteException)),
                                            );
                                          });
                                        }
                                      }
                                    }
                                  },
                                ),
                        );
                      },
                    ),
                  ),
          ),
      ],
    );
  }
}
