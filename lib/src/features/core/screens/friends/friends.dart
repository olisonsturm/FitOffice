import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/constants/sizes.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/constants/colors.dart';

import '../../../authentication/models/user_model.dart';
import '../../controllers/profile_controller.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final controller = Get.put(ProfileController());
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<String> userResults = [];
  bool isSearching = false;
  String? currentUserId;
  late Future<UserModel> _userFuture;

  @override
  void initState() {
    super.initState();

    // Einmal User laden und ID setzen
    _userFuture = controller.getUserData().then((user) {
      currentUserId = user.id;
      return user;
    });
  }

  void searchUsers(String query) async {
    if (query.length < 3 || currentUserId == null) {
      setState(() {
        userResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() => isSearching = true);

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    final results = snapshot.docs
        .where((doc) => doc.id != currentUserId)
        .map((doc) => doc['username'].toString())
        .toList();

    setState(() {
      userResults = results;
      isSearching = false;
    });
  }

  // Logik um Freunde hinzuzufügen, aber auch nötig, dass diese erst die Anfrage annehmen müssen etc --> entsprechend auch die Anpassung der DB nötig... --> wann gesendet, wann angenommen etc
  /*
  void addFriend(String friendUsername) async {
    if (currentUserId == null) return;

    try {
      final friendSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: friendUsername)
          .limit(1)
          .get();

      if (friendSnapshot.docs.isEmpty) {
        Get.snackbar('Fehler', 'Benutzer nicht gefunden.');
        return;
      }

      final friendId = friendSnapshot.docs.first.id;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('friends')
          .doc(friendId)
          .set({'addedAt': Timestamp.now()});

      Get.snackbar('Erfolg', '$friendUsername wurde hinzugefügt!');
    } catch (e) {
      Get.snackbar('Fehler', 'Freund konnte nicht hinzugefügt werden.');
    }
  }
  */

  @override
  void dispose() {
    searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => _searchFocus.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Freunde'),
          backgroundColor: tPrimaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(tDefaultSize),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<UserModel>(
                future: _userFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    final user = snapshot.data!;
                    return Text('Hallo ${user.fullName} 👋',
                        style: txtTheme.headlineSmall);
                  } else {
                    return const Text('Hallo ...');
                  }
                },
              ),
              const SizedBox(height: tDefaultSize),
              TextField(
                controller: searchController,
                focusNode: _searchFocus,
                decoration: InputDecoration(
                  hintText: 'Freunde suchen',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: searchUsers,
              ),
              const SizedBox(height: 20),

              if (isSearching) const Center(child: CircularProgressIndicator()),

              if (!isSearching && searchController.text.length >= 3)
                Expanded(
                  child: ListView.builder(
                    itemCount: userResults.length,
                    itemBuilder: (context, index) {
                      final username = userResults[index];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(username),
                        // trailing: ElevatedButton(
                        //   onPressed: () => addFriend(username),
                        //   child: const Text('Hinzufügen'),
                        // ),
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
