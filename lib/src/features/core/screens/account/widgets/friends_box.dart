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

      final snapshot1 = await friendshipsRef
          .where('user1', isEqualTo: userRef)
          .where('status', isEqualTo: 'accepted')
          .get();

      final snapshot2 = await friendshipsRef
          .where('user2', isEqualTo: userRef)
          .where('status', isEqualTo: 'accepted')
          .get();

      final allDocs = [...snapshot1.docs, ...snapshot2.docs];

      List<Map<String, dynamic>> friendsData = [];

      for (var doc in allDocs) {
        final data = doc.data();
        final DocumentReference otherUserRef;

        if ((data['user1'] as DocumentReference).id == widget.currentUserId) {
          otherUserRef = data['user2'] as DocumentReference;
        } else {
          otherUserRef = data['user1'] as DocumentReference;
        }

        final otherUserSnap = await otherUserRef.get();
        if (otherUserSnap.exists) {
          final userData = otherUserSnap.data() as Map<String, dynamic>;
          userData['friendshipDocId'] = doc.id;
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
    final displayedFriends =
        showAll ? _cachedFriends : _cachedFriends.take(3).toList();

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
                onPressed: _fetchFriends),
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
            constraints: showAll
                ? const BoxConstraints()
                : const BoxConstraints(maxHeight: 168),
            child: ListView.builder(
              shrinkWrap: showAll,
              physics: showAll
                  ? const NeverScrollableScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
              itemCount: _cachedFriends.length,
              itemBuilder: (context, index) {
                final friend = _cachedFriends[index];
                final name = friend['username'] ?? tUnknown;

                return ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.person_remove, color: Colors.red),
                    onPressed: () async {
                      final docId = friend['friendshipDocId'];
                      if (docId != null) {
                        try {
                          await FirebaseFirestore.instance
                              .collection('friendships')
                              .doc(docId)
                              .delete();

                          setState(() {
                            _cachedFriends.removeAt(index);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$name$tFriendDeleted')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text(tFriendDeleteException)),
                          );
                        }
                      }
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
