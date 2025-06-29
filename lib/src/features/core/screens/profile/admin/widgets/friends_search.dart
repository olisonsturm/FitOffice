import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/l10n/app_localizations.dart';

/// A widget that provides a search interface for finding users by their usernames.
///
/// Displays a search input field and shows up to three matching usernames in a list
/// as the user types a query. If more than three results are available, the user
/// can view the full list in a dialog.
///
/// The search queries the 'users' collection in Firestore and filters usernames
/// that contain the search query, excluding the current user.
///
/// The search activates only when the query length is at least two characters.
class FriendSearchWidget extends StatefulWidget {
  final String? currentUserId;

  const FriendSearchWidget({super.key, required this.currentUserId});

  @override
  State<FriendSearchWidget> createState() => _FriendSearchWidgetState();
}

class _FriendSearchWidgetState extends State<FriendSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<String> userResults = [];
  List<String> fullResults = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final query = _searchController.text.trim();
      searchUsers(query);
    });
  }

  /// Performs a search query against Firestore 'users' collection filtering by username.
  ///
  /// Ignores queries shorter than 2 characters or when currentUserId is null.
  /// Updates [userResults] and [fullResults] with the filtered usernames.
  /// Sets [isSearching] to true while query is in progress.
  void searchUsers(String query) async {
    if (query.length < 2 || widget.currentUserId == null) {
      setState(() {
        userResults = [];
        fullResults = [];
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
        fullResults = filtered;
        userResults = filtered.take(3).toList();
        isSearching = false;
      });
    } catch (e) {
      setState(() {
        userResults = [];
        fullResults = [];
        isSearching = false;
      });
    }
  }

  /// Displays a dialog showing the full list of search results.
  ///
  /// If no results are available, displays a localized "No user found" message.
  void _showFullResultDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.tAllResults),
        content: SizedBox(
          width: double.maxFinite,
          child: fullResults.isEmpty
              ? Text(AppLocalizations.of(context)!.tNoUserFound)
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: fullResults.length,
                  itemBuilder: (context, index) {
                    final username = fullResults[index];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(username),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.tClose),
          )
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.tFriendsSearchHint,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (_) {
            if (fullResults.isNotEmpty) _showFullResultDialog();
          },
        ),
        const SizedBox(height: 20),
        if (isSearching)
          const Center(child: CircularProgressIndicator()),
        if (!isSearching && _searchController.text.length >= 2)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: userResults.length,
            itemBuilder: (context, index) {
              final username = userResults[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(username),
              );
            },
          ),
      ],
    );
  }
}
