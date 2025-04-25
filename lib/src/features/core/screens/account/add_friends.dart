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
