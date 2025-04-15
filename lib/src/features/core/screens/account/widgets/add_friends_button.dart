//TODO: Add functionality to the share button and add colors to constants
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import '../add_friends.dart';

class AddFriendsButton extends StatelessWidget {
  final String currentUserId;

  const AddFriendsButton({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ADD FRIENDS BUTTON
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddFriendsScreen(currentUserId: currentUserId),
                  ),
                );
              },
              icon: const Icon(Icons.person_add_alt_1, color: Colors.blue),
              label: const Text(
                tAddFriendsButton,
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // SHARE BUTTON (noch ohne Funktionalität)
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {}, 
            icon: const Icon(CupertinoIcons.share, color: Colors.blue),
          ),
        ),
      ],
    );
  }
}
