import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../widgets/avatar.dart';

class FriendRequestsWidget extends StatefulWidget {
  final String currentUserId;

  const FriendRequestsWidget({super.key, required this.currentUserId});

  @override
  State<FriendRequestsWidget> createState() => _FriendRequestsWidgetState();
}

class _FriendRequestsWidgetState extends State<FriendRequestsWidget> {
  List<DocumentSnapshot> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    final currentUserRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId);

    final snapshot = await FirebaseFirestore.instance
        .collection('friendships')
        .where('receiver', isEqualTo: currentUserRef)
        .where('status', isEqualTo: 'pending')
        .get();

    setState(() {
      _requests = snapshot.docs;
      _isLoading = false;
    });
  }

  Future<void> _respondToRequest(DocumentSnapshot doc, String newStatus) async {
    if (newStatus == 'denied') {
      await doc.reference.delete();
    } else {
      await doc.reference.update({
        'status': newStatus,
      });
    }

    setState(() {
      _requests.removeWhere((d) => d.id == doc.id);
    });
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
            IconButton(
              icon: const Icon(Icons.refresh, color: tPrimaryColor),
              onPressed: _loadRequests,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          const Center(child: CircularProgressIndicator(color: tPrimaryColor))
        else if (_requests.isEmpty)
          Container(
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
          )
        else
          Container(
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
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final doc = _requests[index];
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
          ),
      ],
    );
  }
}