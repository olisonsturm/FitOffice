import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../authentication/models/user_model.dart';

class FriendsController {
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

  Future<String?> getFriendshipStatus(
      String currentEmail, String otherUserName) async {
    final usersRef = FirebaseFirestore.instance.collection('users');

    final userQuery =
    await usersRef.where('email', isEqualTo: currentEmail).get();
    final otherUserQuery =
    await usersRef.where('username', isEqualTo: otherUserName).get();

    if (userQuery.docs.isEmpty || otherUserQuery.docs.isEmpty) return null;

    final userRef = userQuery.docs.first.reference;
    final otherUserRef = otherUserQuery.docs.first.reference;

    final friendshipQuery = await FirebaseFirestore.instance
        .collection('friendships')
        .where(Filter.or(
      Filter.and(Filter('sender', isEqualTo: userRef),
          Filter('receiver', isEqualTo: otherUserRef)),
      Filter.and(Filter('sender', isEqualTo: otherUserRef),
          Filter('receiver', isEqualTo: userRef)),
    ))
        .get();

    if (friendshipQuery.docs.isNotEmpty) {
      return friendshipQuery.docs.first.get('status');
    }

    return null;
  }

  Future<UserModel> getFriend(String userName, BuildContext context) async {
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


}