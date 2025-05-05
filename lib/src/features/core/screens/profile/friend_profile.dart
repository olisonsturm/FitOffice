import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/authentication/models/user_model.dart';
import 'package:fit_office/src/features/core/controllers/db_controller.dart';
import 'package:fit_office/src/features/core/screens/profile/widgets/custom_profile_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/features/core/controllers/profile_controller.dart';
import 'package:fit_office/src/features/core/screens/profile/widgets/avatar.dart';
import 'package:intl/intl.dart';
import 'package:fit_office/src/features/core/screens/profile/admin/widgets/confirmation_dialog.dart';

class FriendProfile extends StatelessWidget {
  final String userName;
  final bool isFriend;

  FriendProfile({super.key, required this.userName, required this.isFriend});

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

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd.MM.yyyy').format(dateTime);
  }

  Future<void> sendFriendRequest(
      String senderEmail, String receiverUserName) async {
    final usersRef = FirebaseFirestore.instance.collection('users');

    final senderQuery =
        await usersRef.where('email', isEqualTo: senderEmail).get();
    final receiverQuery =
        await usersRef.where('username', isEqualTo: receiverUserName).get();

    if (senderQuery.docs.isEmpty || receiverQuery.docs.isEmpty) return;

    final senderRef = senderQuery.docs.first.reference;
    final receiverRef = receiverQuery.docs.first.reference;

    final existing = await FirebaseFirestore.instance
        .collection('friendships')
        .where('sender', isEqualTo: senderRef)
        .where('receiver', isEqualTo: receiverRef)
        .get();

    if (existing.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('friendships').add({
        'sender': senderRef,
        'receiver': receiverRef,
        'status': 'pending',
        'since': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> removeFriendship(String userEmail, String otherUserName) async {
    final usersRef = FirebaseFirestore.instance.collection('users');

    final userQuery = await usersRef.where('email', isEqualTo: userEmail).get();
    final otherUserQuery =
        await usersRef.where('username', isEqualTo: otherUserName).get();

    if (userQuery.docs.isEmpty || otherUserQuery.docs.isEmpty) return;

    final userRef = userQuery.docs.first.reference;
    final otherUserRef = otherUserQuery.docs.first.reference;

    final friendships = await FirebaseFirestore.instance
        .collection('friendships')
        .where('status', isEqualTo: 'accepted')
        .where(Filter.or(
          Filter.and(Filter('sender', isEqualTo: userRef),
              Filter('receiver', isEqualTo: otherUserRef)),
          Filter.and(Filter('sender', isEqualTo: otherUserRef),
              Filter('receiver', isEqualTo: userRef)),
        ))
        .get();

    for (var doc in friendships.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(tProfile),
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
                  const SizedBox(height: 5),
                  Center(
                    child: FutureBuilder<int>(
                      future: ProfileController.instance
                          .getNumberOfFriends(userName),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox.shrink();
                        }
                        return Text('${snapshot.data} $tFriends');
                      },
                    ),
                  ),
                  const SizedBox(height: 5),
                  Center(
                      child: Text(
                          "$tJoined: ${formatTimestamp(friend.createdAt!)}",
                          style: txtTheme.bodyLarge
                              ?.copyWith(color: Colors.grey[500]))),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CustomProfileButton(
                        isDark: Theme.of(context).brightness == Brightness.dark,
                        icon: isFriend ? Icons.person_remove : Icons.person_add,
                        iconColor: isFriend ? Colors.red : Colors.green,
                        label: isFriend ? tDeleteFriend : tSendRequest,
                        textColor: isFriend ? Colors.red : Colors.green,
                        onPress: () async {
                          final db = DbController();
                          final currentEmail =
                              ProfileController.instance.user.value?.email;

                          if (isFriend) {
                            showConfirmationDialog(
                              context: context,
                              title: tDeleteFriend,
                              content:
                                  "Are you sure to end your friendship with $userName?",
                              onConfirm: () async {
                                await removeFriendship(currentEmail!, userName);
                                Get.snackbar(tFriendshipDeleted,
                                    "$userName$tFriendDeleted");
                                Get.back();
                                Get.back();
                              },
                            );
                          } else {
                            await sendFriendRequest(currentEmail!, userName);
                            Get.snackbar(
                                tRequestSent, "$tSentRequestToUser$userName");
                            Get.back();
                          }
                        }),
                  ),
                  if (isFriend)
                    // TODO: Statistics, Streak and favourite exercises need to be added here
                    Center(child: Text("STATISTICS AND STREAK ETC. HERE"))
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
