import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

/// A custom button widget for profile actions, featuring an icon, label, and optional active state.
/// It supports both light and dark themes, with customizable colors for the icon and text.
/// The button can be tapped to trigger a callback function, and it visually indicates whether it is active by changing its background color and showing a check icon.
class CustomProfileButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPress;
  final Color iconColor;
  final Color textColor;
  final bool isActive;
  final bool isDark;

  const CustomProfileButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPress,
    this.iconColor = Colors.orangeAccent,
    this.textColor = Colors.black,
    this.isActive = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.withAlpha((0.1 * 255).toInt()) : (isDark ? Colors.grey[800] : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.grey.withAlpha((0.5 * 255).toInt()),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: AutoSizeText(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: textColor != Colors.black ? textColor : (isDark ? Colors.white : Colors.black),
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

class CustomProfileDropdownButton extends StatefulWidget {
  final IconData icon;
  final bool isDark;
  final List<DropdownMenuItem<String>> items;
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const CustomProfileDropdownButton({
    super.key,
    required this.icon,
    required this.isDark,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  CustomProfileDropdownButtonState createState() => CustomProfileDropdownButtonState();
}

class CustomProfileDropdownButtonState extends State<CustomProfileDropdownButton> {
  late String currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.withAlpha((0.5 * 255).toInt()),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(widget.icon, color: Colors.orangeAccent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentValue,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: isDark ? Colors.white : Colors.black,
                  size: 24,
                ),
                dropdownColor: isDark ? Colors.grey[850] : Colors.white,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 1.0,
                ),
                isDense: true,
                itemHeight: null,
                items: widget.items,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      currentValue = value;
                    });
                    widget.onChanged(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}