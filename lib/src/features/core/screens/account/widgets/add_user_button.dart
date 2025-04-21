import 'package:fit_office/src/constants/text_strings.dart';
import 'package:flutter/material.dart';
import '../edit_user_page.dart';

class CreateUserButton extends StatelessWidget {
  const CreateUserButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
                    builder: (_) => const EditUserPage(),
                  ),
                );
              },
              icon: const Icon(Icons.person_add, color: Colors.blue),
              label: const Text(
                tAddUser,
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
      ],
    );
  }
}
