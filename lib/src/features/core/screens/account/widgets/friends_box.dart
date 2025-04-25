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
      final friendsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .collection('friends')
          .orderBy('addedAt', descending: true)
          .get();

      List<Map<String, dynamic>> friendsData = [];

      for (var doc in friendsSnapshot.docs) {
        final userRef = doc['user'] as DocumentReference;
        final userSnap = await userRef.get();
        if (userSnap.exists) {
          friendsData.add(userSnap.data() as Map<String, dynamic>);
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
    final displayedFriends = showAll ? _cachedFriends : _cachedFriends.take(3).toList();

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
              onPressed: _fetchFriends
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
            constraints: showAll
                ? const BoxConstraints()
                : const BoxConstraints(maxHeight: 168),
            child: ListView.builder(
              shrinkWrap: showAll,
              physics: showAll ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
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
                );
              },
            ),
          ),
      ],
    );
  }
}
