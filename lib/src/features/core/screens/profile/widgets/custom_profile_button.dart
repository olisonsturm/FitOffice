import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class CustomProfileButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPress;
  final Color iconColor;
  final Color textColor;
  final bool isActive;

  const CustomProfileButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPress,
    this.iconColor = Colors.blue,
    this.textColor = Colors.black,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.grey.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            if (isActive)
              Icon(
                LineAwesomeIcons.check_circle,
                color: Colors.blue,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
