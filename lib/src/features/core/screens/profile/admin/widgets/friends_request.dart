import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_office/src/constants/colors.dart';
  import 'package:fit_office/src/features/core/controllers/friends_controller.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/avatar.dart';

/// A widget that displays a list of incoming friend requests for the current user.
///
/// Shows a loading indicator while requests are being fetched.
/// If there are no requests, displays a placeholder message.
/// Otherwise, shows a scrollable list of friend requests with sender info and
/// buttons to accept or deny each request.
///
/// Uses the [FriendsController] to access friend request data and respond to requests.
///
/// The widget automatically rebuilds when the friend requests or loading status changes,
/// thanks to the use of `Obx` from GetX for reactive state management.
class FriendRequestsWidget extends StatefulWidget {
  final String currentUserId;

  const FriendRequestsWidget({super.key, required this.currentUserId});

  @override
  State<FriendRequestsWidget> createState() => _FriendRequestsWidgetState();
}

class _FriendRequestsWidgetState extends State<FriendRequestsWidget> {
  final FriendsController _friendsController = Get.find<FriendsController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.tFriendshipRequests,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 8),

        Obx(() {
          if (_friendsController.isLoadingRequests.value) {
            return const Center(child: CircularProgressIndicator(color: tPrimaryColor));
          } else if (_friendsController.friendRequests.isEmpty) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.tNoRequests,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            );
          } else {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                  width: 1.5,
                ),
              ),
              constraints: const BoxConstraints(maxHeight: 168),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _friendsController.friendRequests.length,
                itemBuilder: (context, index) {
                  final doc = _friendsController.friendRequests[index];
                  final senderRef = doc['sender'] as DocumentReference;

                  return FutureBuilder<DocumentSnapshot>(
                    future: senderRef.get(),
                    builder: (context, senderSnap) {
                      if (!senderSnap.hasData) return const SizedBox.shrink();

                      final senderData =
                      senderSnap.data!.data() as Map<String, dynamic>;
                      final senderName = senderData['username'] ??
                          AppLocalizations.of(context)!.tUnknown;

                      final Timestamp sinceTimestamp = doc['since'] as Timestamp;
                      final DateTime sinceDate = sinceTimestamp.toDate();
                      final Duration difference =
                      DateTime.now().difference(sinceDate);

                      String timeAgo;
                      if (difference.inDays >= 1) {
                        timeAgo = '${difference.inDays}d ago';
                      } else if (difference.inHours >= 1) {
                        timeAgo = '${difference.inHours}h ago';
                      } else {
                        timeAgo = '${difference.inMinutes}min ago';
                      }

                      return ListTile(
                        leading: SizedBox(
                          width: 30,
                          height: 30,
                          child: Avatar(
                            userEmail: senderData['email'],
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              senderName,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '($timeAgo)',
                              style: TextStyle(
                                color:
                                isDark ? Colors.white54 : Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _respondToRequest(doc, 'accepted'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _respondToRequest(doc, 'denied'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }
        }),
      ],
    );
  }

  /// Handles the response to a friend request by updating its status.
  ///
  /// Calls the [FriendsController] to process the response (accept or deny)
  /// and passes the current [BuildContext] for UI-related operations.
  Future<void> _respondToRequest(DocumentSnapshot doc, String newStatus) async {
    await _friendsController.respondToFriendRequest(doc, newStatus, context);
  }
}