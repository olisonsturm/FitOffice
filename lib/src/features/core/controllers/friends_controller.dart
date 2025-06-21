import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import 'package:fit_office/src/utils/helper/helper_controller.dart';
import 'package:get/get.dart';

import '../../authentication/models/user_model.dart';

/// A controller for managing friendships and friend requests.
///
/// Handles listening to Firestore updates, maintains the list of friends
/// and friend requests, and provides methods for sending, accepting,
/// denying, and removing friendships.
class FriendsController extends GetxController {
  static FriendsController get instance => Get.find();

  final friends = <Map<String, dynamic>>[].obs;
  final friendRequests = <DocumentSnapshot>[].obs;
  final isLoadingFriends = true.obs;
  final isLoadingRequests = true.obs;

  StreamSubscription<QuerySnapshot>? _friendsSubscription;
  StreamSubscription<QuerySnapshot>? _requestsSubscription;

  /// Cancels active stream subscriptions when the controller is disposed.
  @override
  void onClose() {
    _friendsSubscription?.cancel();
    _requestsSubscription?.cancel();
    super.onClose();
  }

  /// Initializes Firestore listeners for the given [userId].
  void initStreamsForUser(String userId) {
    listenToFriendships(userId);
    listenToFriendRequests(userId);
  }

  /// Listens for changes to friendship documents where [userId] is involved.
  ///
  /// Updates the [friends] list with accepted or pending friends.
  void listenToFriendships(String userId) {
    isLoadingFriends.value = true;
    friends.clear();

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId);
    final friendshipsRef = FirebaseFirestore.instance.collection('friendships');

    final senderQuery = friendshipsRef
        .where('sender', isEqualTo: userRef)
        .where('status', whereIn: ['accepted', 'pending'])
        .snapshots();

    final receiverQuery = friendshipsRef
        .where('receiver', isEqualTo: userRef)
        .where('status', isEqualTo: 'accepted')
        .snapshots();

    _friendsSubscription?.cancel();

    _friendsSubscription = senderQuery.listen((senderSnapshot) async {
      List<DocumentSnapshot> allDocs = List.from(senderSnapshot.docs);

      final receiverDocs = await friendshipsRef
          .where('receiver', isEqualTo: userRef)
          .where('status', isEqualTo: 'accepted')
          .get();

      allDocs.addAll(receiverDocs.docs);

      await _processNewFriendData(userId, allDocs);

      receiverQuery.listen((receiverSnapshot) async {
        List<DocumentSnapshot> combinedDocs = List.from(senderSnapshot.docs);
        combinedDocs.addAll(receiverSnapshot.docs);
        await _processNewFriendData(userId, combinedDocs);
      });
    });
  }

  /// Listens for incoming friend requests directed at [userId].
  ///
  /// Populates the [friendRequests] list with pending requests.
  void listenToFriendRequests(String userId) {
    isLoadingRequests.value = true;
    friendRequests.clear();

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId);
    final friendshipsRef = FirebaseFirestore.instance.collection('friendships');

    final requestsQuery = friendshipsRef
        .where('receiver', isEqualTo: userRef)
        .where('status', isEqualTo: 'pending')
        .snapshots();

    _requestsSubscription?.cancel();

    _requestsSubscription = requestsQuery.listen((snapshot) {
      friendRequests.value = snapshot.docs;
      isLoadingRequests.value = false;
    });
  }

  /// Processes friendship documents and updates the [friends] list.
  ///
  /// [userId] is the current user; [docs] are Firestore friendship documents.
  Future<void> _processNewFriendData(String userId, List<DocumentSnapshot> docs) async {
    final List<Map<String, dynamic>> updatedFriends = [];

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final DocumentReference otherUserRef;

      if ((data['sender'] as DocumentReference).id == userId) {
        otherUserRef = data['receiver'] as DocumentReference;
      } else {
        otherUserRef = data['sender'] as DocumentReference;
      }

      final otherUserSnap = await otherUserRef.get();
      if (otherUserSnap.exists) {
        final userData = otherUserSnap.data() as Map<String, dynamic>;
        userData['friendshipDocId'] = doc.id;
        userData['status'] = data['status'];

        updatedFriends.add(userData);
      }
    }

    friends.value = updatedFriends;
    isLoadingFriends.value = false;
  }

  /// Sends a friend request from [senderEmail] to [receiverUserName].
  ///
  /// Displays a success, error, or warning snackbar depending on the outcome.
  Future<void> sendFriendRequest(
      String senderEmail, String receiverUserName, BuildContext context) async {
    final usersRef = FirebaseFirestore.instance.collection('users');
    final localizations = AppLocalizations.of(context)!;

    final senderQuery =
    await usersRef.where('email', isEqualTo: senderEmail).get();
    final receiverQuery =
    await usersRef.where('username', isEqualTo: receiverUserName).get();

    if (senderQuery.docs.isEmpty || receiverQuery.docs.isEmpty) {
      Helper.errorSnackBar(
        title: localizations.tError,
        message: localizations.tNoUserFound,
      );
      return;
    }

    final senderRef = senderQuery.docs.first.reference;
    final receiverRef = receiverQuery.docs.first.reference;

    final existing = await FirebaseFirestore.instance
        .collection('friendships')
        .where(Filter.or(
          Filter.and(
            Filter('sender', isEqualTo: senderRef),
            Filter('receiver', isEqualTo: receiverRef)
          ),
          Filter.and(
            Filter('sender', isEqualTo: receiverRef),
            Filter('receiver', isEqualTo: senderRef)
          ),
        ))
        .get();

    if (existing.docs.isEmpty) {
      final docRef = await FirebaseFirestore.instance.collection('friendships').add({
        'sender': senderRef,
        'receiver': receiverRef,
        'status': 'pending',
        'since': FieldValue.serverTimestamp(),
      });

      final senderData = senderQuery.docs.first.data();

      friends.add({
        'username': senderData['username'],
        'email': senderData['email'],
        'fullName': senderData['fullName'],
        'friendshipDocId': docRef.id,
        'status': 'pending',
      });

      Helper.successSnackBar(
        title: localizations.tSuccess,
        message: '${localizations.tFriendRequestSentTo} $receiverUserName',
      );
    } else {
      Helper.warningSnackBar(
        title: localizations.tInfo,
        message: localizations.tFriendshipAlreadyExists,
      );
    }
  }

  /// Removes a friendship or cancels a friend request.
  ///
  /// Displays appropriate success or error messages.
  Future<void> removeFriendship(String userEmail, String otherUserName, BuildContext context) async {
    final errorTitle = AppLocalizations.of(context)?.tError ?? "Error";
    final noUserFoundMessage = AppLocalizations.of(context)?.tNoUserFound ?? "User not found";
    final successTitle = AppLocalizations.of(context)?.tSuccess ?? "Success";
    final infoTitle = AppLocalizations.of(context)?.tInfo ?? "Info";
    final friendDeletedMessage = AppLocalizations.of(context)?.tFriendDeleted ?? "was removed from your friends";
    final friendshipRequestWithdraw = AppLocalizations.of(context)?.tFriendshipRequestWithdraw ?? "Friend request withdrawn from";
    final friendDeleteException = AppLocalizations.of(context)?.tFriendDeleteException ?? "Error removing friend";

    final usersRef = FirebaseFirestore.instance.collection('users');

    final userQuery = await usersRef.where('email', isEqualTo: userEmail).get();
    final otherUserQuery =
    await usersRef.where('username', isEqualTo: otherUserName).get();

    if (userQuery.docs.isEmpty || otherUserQuery.docs.isEmpty) {
      Helper.errorSnackBar(
        title: errorTitle,
        message: noUserFoundMessage,
      );
      return;
    }

    final userRef = userQuery.docs.first.reference;
    final otherUserRef = otherUserQuery.docs.first.reference;

    try {
      final friendships = await FirebaseFirestore.instance
          .collection('friendships')
          .where(Filter.or(
            Filter.and(Filter('sender', isEqualTo: userRef),
                Filter('receiver', isEqualTo: otherUserRef)),
            Filter.and(Filter('sender', isEqualTo: otherUserRef),
                Filter('receiver', isEqualTo: userRef)),
          ))
          .get();

      if (friendships.docs.isEmpty) {
        throw Exception("No friendship found");
      }

      bool isPending = false;
      for (var doc in friendships.docs) {
        final status = doc.get('status');
        if (status == 'pending') {
          isPending = true;
          break;
        }
      }

      for (var doc in friendships.docs) {
        await doc.reference.delete();
      }

      friends.removeWhere((friend) =>
        friend['username'] == otherUserName ||
        (friend['email'] != null && friend['email'] == otherUserName)
      );

      if (isPending) {
        Helper.warningSnackBar(
          title: infoTitle,
          message: friendshipRequestWithdraw + otherUserName,
        );
      } else {
        Helper.successSnackBar(
          title: successTitle,
          message: '$otherUserName $friendDeletedMessage',
        );
      }
    } catch (e) {
      Helper.errorSnackBar(
        title: errorTitle,
        message: friendDeleteException,
      );
      rethrow;
    }
  }

  /// Accepts or denies a friend request.
  ///
  /// [doc] is the friend request document, [newStatus] must be `'accepted'` or `'denied'`.
  Future<void> respondToFriendRequest(DocumentSnapshot doc, String newStatus, BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    if (newStatus == 'denied') {
      await doc.reference.delete();
      friendRequests.removeWhere((request) => request.id == doc.id);

      Helper.successSnackBar(
        title: localizations.tInfo,
        message: localizations.tFriendRequestDenied,
      );
    } else {
      await doc.reference.update({
        'status': newStatus,
      });

      Helper.successSnackBar(
        title: localizations.tSuccess,
        message: localizations.tFriendRequestAccepted,
      );
    }
  }

  /// Retrieves the current friendship status between two users.
  ///
  /// Returns `null` if no friendship exists.
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

  /// Fetches the [UserModel] for a given [userName].
  ///
  /// Throws an exception if no user is found.
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
