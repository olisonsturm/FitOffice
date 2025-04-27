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

  Future<String?> _getFriendshipStatus(String friendUsername) async {
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

        final friendshipRef =
            FirebaseFirestore.instance.collection('friendships');

        final existingQuery = await friendshipRef.where('sender', whereIn: [
          currentUserRef,
          friendDoc.reference
        ]).where('receiver',
            whereIn: [currentUserRef, friendDoc.reference]).get();

        if (existingQuery.docs.isNotEmpty) {
          final friendshipDoc = existingQuery.docs.first;
          final status = friendshipDoc['status'];
          return status;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
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

        final friendshipRef =
            FirebaseFirestore.instance.collection('friendships');

        final existingQuery = await friendshipRef
            .where('status', isEqualTo: 'accepted')
            .where('sender',
                whereIn: [currentUserRef, friendDoc.reference]).get();

        final alreadyExists = existingQuery.docs.any((doc) {
          final u1 = doc['sender'] as DocumentReference;
          final u2 = doc['receiver'] as DocumentReference;
          return (u1.id == currentUserRef.id && u2.id == friendDoc.id) ||
              (u1.id == friendDoc.id && u2.id == currentUserRef.id);
        });

        if (alreadyExists && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$friendUsername$tIsAlreadyYourFriend')),
          );
          return;
        }

        await friendshipRef.add({
          'sender': currentUserRef,
          'receiver': friendDoc.reference,
          'since': FieldValue.serverTimestamp(),
          'status': 'pending',
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$friendUsername$tFriendNow')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tExceptionAddingFriend)),
        );
      }
    }
  }

  void _removeFriend(String friendUsername) async {
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

        final friendshipRef =
            FirebaseFirestore.instance.collection('friendships');

        final existingQuery = await friendshipRef
            .where('status', isEqualTo: 'accepted')
            .where('sender',
                whereIn: [currentUserRef, friendDoc.reference]).get();

        final existingFriendship = existingQuery.docs.firstWhere((doc) {
          final u1 = doc['sender'] as DocumentReference;
          final u2 = doc['receiver'] as DocumentReference;
          return (u1.id == currentUserRef.id && u2.id == friendDoc.id) ||
              (u1.id == friendDoc.id && u2.id == currentUserRef.id);
        });

        await existingFriendship.reference.delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$friendUsername$tRemoved')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tExceptionRemoveFriend)),
        );
      }
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
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
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
                      return FutureBuilder<String?>(
                        future: _getFriendshipStatus(username),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const ListTile(
                              title: Text("Loading..."),
                            );
                          }
                          if (snapshot.hasData) {
                            final status = snapshot.data;
                            if (status == 'accepted') {
                              return ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(username),
                                trailing: IconButton(
                                  icon: const Icon(Icons.person_remove,
                                      color: Colors.red),
                                  onPressed: () => _removeFriend(username),
                                ),
                              );
                            } else if (status == 'pending') {
                              return ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(username),
                                trailing: const Icon(Icons.access_time,
                                    color: Colors.grey),
                              );
                            } else if (status == "denied") {
                              return ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(username),
                                trailing:
                                    Icon(Icons.person_add, color: Colors.grey),
                              );
                            }
                          }
                          return ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(username),
                            trailing: IconButton(
                              icon: const Icon(Icons.person_add,
                                  color: Colors.blue),
                              onPressed: () => _addFriend(username),
                            ),
                          );
                        },
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
