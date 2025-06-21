import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/features/core/controllers/friends_controller.dart';
import 'package:fit_office/src/utils/theme/widget_themes/dialog_theme.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import 'package:fit_office/src/features/core/screens/profile/friend_profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/avatar.dart';

/// A widget that displays the current user's friends list in a card-like box,
/// supporting both a preview (up to 3 friends) and an expanded view.
///
/// This widget reacts to changes from the [FriendsController] (using GetX),
/// and supports deleting friends or canceling pending requests with a confirmation dialog.
///
/// Friends are displayed in a list with their avatar, name, and an action icon:
/// - If the friendship is accepted: shows a remove icon.
/// - If the request is pending: shows a cancel icon.
///
/// ### Parameters:
/// - [currentUserId] – The ID of the current user to fetch and manage friends.
///
/// ### Example:
/// ```dart
/// FriendsBoxWidget(currentUserId: userId)
/// ```
///
/// This widget should be placed inside a scrollable container or column.
///
/// ### Features:
/// - Localized text using [AppLocalizations].
/// - Responsive dark/light theme.
/// - Dynamic display of friends list (preview or full).
/// - Actionable friend management (remove/cancel request).
class FriendsBoxWidget extends StatefulWidget {
  final String currentUserId;

  const FriendsBoxWidget({super.key, required this.currentUserId});

  @override
  State<FriendsBoxWidget> createState() => _FriendsBoxWidgetState();
}

class _FriendsBoxWidgetState extends State<FriendsBoxWidget> {
  bool showAll = false;
  final FriendsController _friendsController = Get.put(FriendsController());

  @override
  void initState() {
    super.initState();
    _friendsController.initStreamsForUser(widget.currentUserId);
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
              AppLocalizations.of(context)!.tFriends,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87),
            ),
            const Spacer(),
            Obx(() {
              if (_friendsController.friends.length > 3) {
                return TextButton(
                  onPressed: () => setState(() => showAll = !showAll),
                  child: Text(
                    showAll
                        ? AppLocalizations.of(context)!.tShowLess
                        : AppLocalizations.of(context)!.tShowAll,
                    style: const TextStyle(color: tPrimaryColor),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
        const SizedBox(height: 8),

        Obx(() {
          if (_friendsController.isLoadingFriends.value) {
            return const Center(child: CircularProgressIndicator(color: tPrimaryColor));
          } else if (_friendsController.friends.isEmpty) {
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
                  AppLocalizations.of(context)!.tNoFriendsYet,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            );
          } else {
            final displayedFriends = showAll
                ? _friendsController.friends
                : _friendsController.friends.take(3).toList();

            double? containerHeight;
            if (!showAll && _friendsController.friends.isNotEmpty) {
              final itemsToShow = _friendsController.friends.length > 3
                  ? 3
                  : _friendsController.friends.length;
              containerHeight = itemsToShow * 56.0;
            }

            return Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                  width: 1.5,
                ),
              ),
              height: containerHeight,
              child: ListView.builder(
                shrinkWrap: true,
                physics: showAll
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                itemCount: displayedFriends.length,
                itemBuilder: (context, index) {
                  final friend = displayedFriends[index];
                  final name = friend['username'] ??
                      AppLocalizations.of(context)!.tUnknown;
                  final status = friend['status'];
                  final isPending = status == 'pending';

                  return ListTile(
                    leading: SizedBox(
                      width: 30,
                      height: 30,
                      child: Avatar(
                        userEmail: friend['email'],
                      ),
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPending)
                          const Icon(Icons.access_time, color: Colors.grey),
                        const SizedBox(width: 8),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            isPending ? Icons.cancel : Icons.person_remove,
                            color: isPending ? Colors.orange : Colors.red,
                          ),
                          onPressed: () async {
                            final docId = friend['friendshipDocId'];
                            if (docId != null) {
                              _showDeleteConfirmationDialog(name, isPending);
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      final userName = friend['username'];
                      bool isFriend = friend['status'] == "accepted";
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FriendProfile(
                              userName: userName,
                              isFriend: isFriend,
                              isPending: isPending),
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

  /// Displays a confirmation dialog for removing a friend or canceling a pending request.
  void _showDeleteConfirmationDialog(String userName, bool isPending) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final localization = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isPending
              ? localization.tCancelRequest
              : localization.tRemoveFriend,
        ),
        content: Text(
          isPending
              ? '${localization.tCancelRequestConfirm} $userName?'
              : '${localization.tRemoveFriendConfirm} $userName?',
        ),
        actions: [
          TextButton(
            style: isDark
                ? TDialogTheme.getDarkCancelButtonStyle()
                : TDialogTheme.getLightCancelButtonStyle(),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localization.tCancel),
          ),
          TextButton(
            style: isDark
                ? TDialogTheme.getDarkDeleteButtonStyle()
                : TDialogTheme.getLightDeleteButtonStyle(),
            onPressed: () async {
              Navigator.of(context).pop();
              final userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.currentUserId)
                  .get();

              if (userDoc.exists) {
                final userData = userDoc.data() as Map<String, dynamic>;
                final userEmail = userData['email'] as String;

                await _friendsController.removeFriendship(userEmail, userName, context);
              }
            },
            child: Text(
              isPending
                  ? localization.tCancel
                  : localization.tRemove,
            ),
          ),
        ],
      ),
    );
  }
}