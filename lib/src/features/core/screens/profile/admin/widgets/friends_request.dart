import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:flutter/material.dart';

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
    await doc.reference.update({'status': newStatus});
    setState(() {
      _requests.removeWhere((d) => d.id == doc.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              tFriendshipRequests,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.blue),
              onPressed: _loadRequests,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_requests.isEmpty)
          Text(
            tNoRequests,
            style:
                TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : Colors.white,
              border: Border.all(
                color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode ? Colors.black54 : Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
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
                    final senderName = senderData['username'] ?? tUnknown;

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
                      leading: const Icon(Icons.person, color: Colors.blue),
                      title: Row(
                        children: [
                          Text(
                            senderName,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '($timeAgo)',
                            style: TextStyle(
                              color:
                                  isDarkMode ? Colors.white54 : Colors.black54,
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
