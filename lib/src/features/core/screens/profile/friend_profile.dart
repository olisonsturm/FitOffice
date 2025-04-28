import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/authentication/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/features/core/controllers/profile_controller.dart';
import 'package:fit_office/src/features/core/screens/profile/widgets/avatar.dart';

class FriendProfile extends StatelessWidget {
  final String userName;

  FriendProfile({super.key, required this.userName});

  final controller = Get.put(ProfileController());

  Future<UserModel> getFriend(String userName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: userName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final userDoc = querySnapshot.docs.first;
      return UserModel.fromSnapshot(userDoc);
    } else {
      throw Exception(tNoUserFound);
    }
  }

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(tFriendProfile),
        backgroundColor: Colors.grey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<UserModel>(
          future: getFriend(userName),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text(tNoUserFound));
            } else {
              final friend = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: Avatar()),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      '@${friend.userName}',
                      style: txtTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      friend.fullName,
                      style: txtTheme.headlineSmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: Text(
                      friend.email,
                      style:
                          txtTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
