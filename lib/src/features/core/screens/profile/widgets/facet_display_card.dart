import 'package:flutter/material.dart';

class FactDisplayCard extends StatelessWidget {
  final IconData icon;
  final String title; // Bold text
  final String subtitle; // Normal text
  final Color iconColor;
  final Color backgroundColor;

  const FactDisplayCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor = Colors.blue,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 40),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
