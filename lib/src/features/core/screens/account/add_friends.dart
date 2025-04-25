import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      setState(() {
        results = [];
        isSearching = false;
      });
      return;
    }

    setState(() => isSearching = true);

    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();

      final filtered = snapshot.docs
          .where((doc) =>
              doc.id != widget.currentUserId &&
              doc.data().containsKey('username') &&
              (doc['username'] as String)
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .map((doc) => doc['username'].toString())
          .toList();

      setState(() {
        results = filtered;
        isSearching = false;
      });
    } catch (e) {
      setState(() {
        results = [];
        isSearching = false;
      });
    }
  }

  void _addFriend(String friendUsername) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: friendUsername)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final friendDoc = querySnapshot.docs.first;
        final currentUserRef = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.currentUserId);

        final friendshipRef = FirebaseFirestore.instance.collection('friendships');

        // Prüfen, ob diese Freundschaft schon existiert (egal in welcher Reihenfolge)
        final existingQuery = await friendshipRef
            .where('status', isEqualTo: 'accepted')
            .where('user1', whereIn: [currentUserRef, friendDoc.reference])
            .get();

        final alreadyExists = existingQuery.docs.any((doc) {
          final u1 = doc['user1'] as DocumentReference;
          final u2 = doc['user2'] as DocumentReference;
          return (u1.id == currentUserRef.id && u2.id == friendDoc.id) ||
              (u1.id == friendDoc.id && u2.id == currentUserRef.id);
        });

        if (alreadyExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$friendUsername ist bereits dein Freund.')),
          );
          return;
        }

        await friendshipRef.add({
          'user1': currentUserRef,
          'user2': friendDoc.reference,
          'since': FieldValue.serverTimestamp(),
          'status': 'accepted',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$friendUsername$tFriendNow')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tExceptionAddingFriend)),
      );
    }
  }



  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), 
      child: Scaffold(
        appBar: AppBar(
          title: const Text(tAddFriendsHeader),
          backgroundColor: tCardBgColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                decoration: InputDecoration(
                  hintText: tFriendsSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
              ),
              const SizedBox(height: 20),
              if (isSearching)
                const CircularProgressIndicator()
              else if (results.isEmpty && _searchController.text.length >= 2)
                const Text(tNoResults),
              if (results.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final username = results[index];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(username),
                        trailing: IconButton(
                          icon: const Icon(Icons.person_add),
                          onPressed: () => _addFriend(username),
                        ),
                      );
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
