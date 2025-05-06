import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class FactDisplayCard extends StatelessWidget {
  final IconData icon;
  final String title; // Bold text
  final String subtitle; // Normal text
  final Color iconColor;
  final Color backgroundColor;
  final bool isDark;

  const FactDisplayCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor = Colors.blue,
    this.backgroundColor = Colors.white,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.withAlpha((0.5 * 255).toInt()),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 40),
          AutoSizeText(
            title,
            maxLines: 1,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          AutoSizeText(
            subtitle,
            maxLines: 1,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
