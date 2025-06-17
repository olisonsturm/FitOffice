import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import 'package:fit_office/src/utils/helper/helper_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../authentication/models/user_model.dart';

class FriendsController extends GetxController {
  static FriendsController get instance => Get.find();

  // Reaktive Variablen für Freunde und Anfragen
  final friends = <Map<String, dynamic>>[].obs;
  final friendRequests = <DocumentSnapshot>[].obs;
  final isLoadingFriends = true.obs;
  final isLoadingRequests = true.obs;

  // Stream-Subscriptions für automatische Updates
  StreamSubscription<QuerySnapshot>? _friendsSubscription;
  StreamSubscription<QuerySnapshot>? _requestsSubscription;

  @override
  void onClose() {
    _friendsSubscription?.cancel();
    _requestsSubscription?.cancel();
    super.onClose();
  }

  // Methode zum Initialisieren der Streams für einen bestimmten Benutzer
  void initStreamsForUser(String userId) {
    listenToFriendships(userId);
    listenToFriendRequests(userId);
  }

  // Stream für Freundschaften eines Benutzers
  void listenToFriendships(String userId) {
    isLoadingFriends.value = true;
    friends.clear(); // Liste leeren, bevor wir sie neu befüllen

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId);
    final friendshipsRef = FirebaseFirestore.instance.collection('friendships');

    // Als Sender: akzeptierte Freundschaften und ausstehende Anfragen (die ich gesendet habe)
    final senderQuery = friendshipsRef
        .where('sender', isEqualTo: userRef)
        .where('status', whereIn: ['accepted', 'pending'])
        .snapshots();

    // Als Empfänger: NUR akzeptierte Freundschaften (keine ausstehenden Anfragen)
    final receiverQuery = friendshipsRef
        .where('receiver', isEqualTo: userRef)
        .where('status', isEqualTo: 'accepted')
        .snapshots();

    // Verarbeite beide Streams
    _friendsSubscription?.cancel(); // Alte Subscription beenden

    // Verwende einen kombinierten Ansatz für beide Streams
    _friendsSubscription = senderQuery.listen((senderSnapshot) async {
      // Zuerst Sender-Daten verarbeiten
      List<DocumentSnapshot> allDocs = List.from(senderSnapshot.docs);

      // Jetzt auch den zweiten Stream manuell abfragen und hinzufügen
      final receiverDocs = await friendshipsRef
          .where('receiver', isEqualTo: userRef)
          .where('status', isEqualTo: 'accepted')
          .get();

      allDocs.addAll(receiverDocs.docs);

      // Alle Daten auf einmal verarbeiten
      await _processNewFriendData(userId, allDocs);

      // Dann auf Änderungen hören
      receiverQuery.listen((receiverSnapshot) async {
        List<DocumentSnapshot> combinedDocs = List.from(senderSnapshot.docs);
        combinedDocs.addAll(receiverSnapshot.docs);
        await _processNewFriendData(userId, combinedDocs);
      });
    });
  }

  // Stream für Freundschaftsanfragen eines Benutzers
  void listenToFriendRequests(String userId) {
    isLoadingRequests.value = true;
    friendRequests.clear(); // Liste leeren, bevor wir sie neu befüllen

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId);
    final friendshipsRef = FirebaseFirestore.instance.collection('friendships');

    // Stream für eingehende Anfragen
    final requestsQuery = friendshipsRef
        .where('receiver', isEqualTo: userRef)
        .where('status', isEqualTo: 'pending')
        .snapshots();

    _requestsSubscription?.cancel(); // Alte Subscription beenden

    _requestsSubscription = requestsQuery.listen((snapshot) {
      friendRequests.value = snapshot.docs;
      isLoadingRequests.value = false;
    });
  }

  // Verarbeitung neuer Freundschaftsdaten
  Future<void> _processNewFriendData(String userId, List<DocumentSnapshot> docs) async {
    // Erstelle eine neue Liste für aktualisierte Freunde
    final List<Map<String, dynamic>> updatedFriends = [];

    // Sammle zunächst alle gültigen Dokumente
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final DocumentReference otherUserRef;

      // Bestimme, wer der andere Benutzer ist
      if ((data['sender'] as DocumentReference).id == userId) {
        otherUserRef = data['receiver'] as DocumentReference;
      } else {
        otherUserRef = data['sender'] as DocumentReference;
      }

      // Lade Daten des anderen Benutzers
      final otherUserSnap = await otherUserRef.get();
      if (otherUserSnap.exists) {
        final userData = otherUserSnap.data() as Map<String, dynamic>;
        userData['friendshipDocId'] = doc.id;
        userData['status'] = data['status'];

        // Füge zu unserer aktualisierten Liste hinzu
        updatedFriends.add(userData);
      }
    }

    // Ersetze die gesamte Liste mit der aktualisierten Liste
    friends.value = updatedFriends;
    isLoadingFriends.value = false;
  }

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

    // Prüfe, ob bereits eine Freundschaftsanfrage existiert
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
      // Erstelle eine neue Freundschaftsanfrage
      final docRef = await FirebaseFirestore.instance.collection('friendships').add({
        'sender': senderRef,
        'receiver': receiverRef,
        'status': 'pending',
        'since': FieldValue.serverTimestamp(),
      });

      // Hole Sender-Daten für die lokale UI-Aktualisierung
      final senderData = senderQuery.docs.first.data();

      // Manuelles Hinzufügen zur friends-Liste für sofortige UI-Aktualisierung
      friends.add({
        'username': senderData['username'],
        'email': senderData['email'],
        'fullName': senderData['fullName'],
        'friendshipDocId': docRef.id,
        'status': 'pending',
      });

      // Erfolgsmeldung anzeigen
      Helper.successSnackBar(
        title: localizations.tSuccess,
        message: '${localizations.tFriendRequestSentTo} $receiverUserName',
      );
    } else {
      // Es existiert bereits eine Freundschaftsanfrage
      Helper.warningSnackBar(
        title: localizations.tInfo,
        message: localizations.tFriendshipAlreadyExists,
      );
    }
  }

  Future<void> removeFriendship(String userEmail, String otherUserName, BuildContext context) async {
    // Lokale Variablen für Texte speichern, bevor asynchrone Operationen beginnen
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
      // Finde alle Freundschaftseinträge zwischen den beiden Benutzern
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

      // Überprüfe, ob es sich um eine ausstehende Anfrage oder eine akzeptierte Freundschaft handelt
      bool isPending = false;
      for (var doc in friendships.docs) {
        final status = doc.get('status');
        if (status == 'pending') {
          isPending = true;
          break;
        }
      }

      // Lösche alle Freundschaftseinträge
      for (var doc in friendships.docs) {
        await doc.reference.delete();
      }

      // Entferne den Freund auch aus der lokalen Liste, damit die UI sofort aktualisiert wird
      friends.removeWhere((friend) =>
        friend['username'] == otherUserName ||
        (friend['email'] != null && friend['email'] == otherUserName)
      );

      // Zeige je nach Status der Freundschaft die entsprechende Erfolgsnachricht an
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

  Future<void> respondToFriendRequest(DocumentSnapshot doc, String newStatus, BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    if (newStatus == 'denied') {
      await doc.reference.delete();
      // Entferne die Anfrage aus unserer Liste
      friendRequests.removeWhere((request) => request.id == doc.id);

      // Benachrichtigung anzeigen
      Helper.successSnackBar(
        title: localizations.tInfo,
        message: localizations.tFriendRequestDenied,
      );
    } else {
      await doc.reference.update({
        'status': newStatus,
      });
      // Die Streams werden die Änderung automatisch erkennen

      // Benachrichtigung anzeigen
      Helper.successSnackBar(
        title: localizations.tSuccess,
        message: localizations.tFriendRequestAccepted,
      );
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

  Future<String?> getUserEmailById(String userId) async {
    try {
      // Get the document reference using the userId
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // Extract the email from the document data
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['email'] as String?;
      } else {
        return null; // User not found
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user email: $e');
      }
      return null;
    }
  }
  Future<String?> getUserNameById(String userId) async {
    try {
      // Get the document reference using the userId
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // Extract the username from the document data
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['username'] as String?;
      } else {
        return null; // User not found
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching username: $e');
      }
      return null;
    }
  }
}
