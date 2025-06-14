import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fit_office/src/features/authentication/models/user_model.dart';
import 'package:fit_office/src/features/core/controllers/friends_controller.dart';
import 'package:fit_office/src/features/core/screens/profile/widgets/custom_profile_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/features/core/controllers/profile_controller.dart';
import 'package:fit_office/src/features/core/screens/profile/widgets/avatar.dart';
import 'package:intl/intl.dart';
import 'package:fit_office/src/features/core/screens/profile/admin/widgets/confirmation_dialog.dart';

import '../statistics/widgets/statistics.dart';

class FriendProfile extends StatefulWidget {
  final String userName;
  final bool isFriend;
  final bool? isPending;

  const FriendProfile({
    super.key,
    required this.userName,
    required this.isFriend,
    this.isPending,
  });

  @override
  State<FriendProfile> createState() => _FriendProfileState();
}

class _FriendProfileState extends State<FriendProfile> {
  final controller = Get.put(ProfileController());
  bool isPendingLocal = false;

  @override
  void initState() {
    super.initState();
    isPendingLocal = widget.isPending ?? false;
  }

  Future<UserModel> getFriend(String userName) async {
    final localizations = AppLocalizations.of(context)!;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: userName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final userDoc = querySnapshot.docs.first;
      return UserModel.fromSnapshot(userDoc);
    } else {
        throw Exception(localizations.tNoUserFound);
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd.MM.yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;
    final currentEmail = ProfileController.instance.user.value?.email;
    final localisation = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localisation.tProfile),
        backgroundColor: Colors.grey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<UserModel>(
          future: getFriend(widget.userName),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text(localisation.tNoUserFound));
            } else {
              final friend = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Avatar(userEmail: friend.email)),
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
                      future: controller.getNumberOfFriends(widget.userName),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        return Text('${snapshot.data} ${localisation.tFriends}');
                      },
                    ),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: Text(
                      "${localisation.tJoined}: ${formatTimestamp(friend.createdAt!)}",
                      style:
                          txtTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CustomProfileButton(
                      isDark: Theme.of(context).brightness == Brightness.dark,
                      icon: widget.isFriend
                          ? Icons.person_remove
                          : (isPendingLocal
                              ? Icons.hourglass_bottom
                              : Icons.person_add),
                      iconColor: widget.isFriend
                          ? Colors.red
                          : (isPendingLocal ? Colors.grey : Colors.green),
                      label: widget.isFriend
                          ? localisation.tDeleteFriend
                          : (isPendingLocal ? localisation.tRequestPending : localisation.tSendRequest),
                      textColor: widget.isFriend
                          ? Colors.red
                          : (isPendingLocal ? Colors.grey : Colors.green),
                      onPress: () async {
                        if (widget.isFriend) {
                          showConfirmationDialogModel(
                            context: context,
                            title: localisation.tDeleteFriend,
                            content:
                                "Are you sure to end your friendship with ${widget.userName}?",
                            onConfirm: () async {
                              setState(() {
                                isPendingLocal = false;
                                Navigator.of(context).pop();
                              });
                              FriendsController controller =
                                  FriendsController();
                              await controller.removeFriendship(
                                  currentEmail!, widget.userName);

                              Get.snackbar(localisation.tFriendshipDeleted,
                                  "${widget.userName}${localisation.tFriendDeleted}");
                            },
                            cancel: localisation.tNo,
                            confirm: localisation.tYes,
                          );
                        } else if (isPendingLocal) {
                        } else {
                          setState(() {
                            isPendingLocal = true;
                          });
                          FriendsController controller = FriendsController();
                          await controller.sendFriendRequest(
                              currentEmail!, widget.userName);
                          Get.snackbar(localisation.tRequestSent,
                              "${localisation.tSentRequestToUser}${widget.userName}");
                        }
                      },
                    ),
                  ),
                  if (widget.isFriend == true) ...[
                    StatisticsWidget(
                      txtTheme: txtTheme,
                      isDark: Theme.of(context).brightness == Brightness.dark,
                      userEmail: friend.email,
                    ).buildStreakCard(controller),
                    const SizedBox(height: 12),
                    StatisticsWidget(
                            txtTheme: txtTheme,
                            isDark:
                                Theme.of(context).brightness == Brightness.dark,
                            userEmail: friend.email)
                        .buildTopExercisesCard(controller),
                    const SizedBox(height: 12),
                    StatisticsWidget(
                            txtTheme: txtTheme,
                            isDark:
                                Theme.of(context).brightness == Brightness.dark,
                            userEmail: friend.email)
                        .buildLongestStreakCard(controller)
                  ]
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
