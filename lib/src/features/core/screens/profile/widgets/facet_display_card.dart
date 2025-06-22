import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

/// A card widget that displays a fact with an icon, title, and subtitle.
/// The card is styled to look non-interactive, with a faded appearance.
/// It is used to present facts in a visually appealing way, suitable for both light and dark themes.
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
    return IgnorePointer(
      child: Opacity(
        opacity: 0.7, // Slightly faded to look non-interactive
        child: Container(
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
              Icon(icon, color: iconColor.withValues(alpha: .7), size: 40),
              AutoSizeText(
                title,
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: .7),
                ),
                textAlign: TextAlign.center,
              ),
              AutoSizeText(
                subtitle,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 14,
                  color: (isDark ? Colors.white70 : Colors.black54).withValues(alpha: .7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
