import 'package:flutter/material.dart';

/// A customizable save button widget that visually indicates whether there are unsaved changes.
///
/// The button is enabled only when [hasChanges] is true. When enabled, it calls the provided
/// [onPressed] callback when tapped. When disabled, it appears greyed out and is not tappable.
///
/// The button displays an icon and a label side by side, and has a subtle container styling
/// with rounded corners and shadow to make it stand out.
///
/// Example usage:
/// ```dart
/// SaveButton(
///   hasChanges: _formHasChanges,
///   onPressed: _saveData,
///   label: 'Save Changes',
/// )
class SaveButton extends StatelessWidget {
  final bool hasChanges;
  final VoidCallback? onPressed;
  final String label;

  const SaveButton({
    super.key,
    required this.hasChanges,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          foregroundColor: hasChanges ? Colors.blue : Colors.grey,
        ),
        onPressed: hasChanges ? onPressed : null,
        icon: Icon(
          Icons.save,
          color: hasChanges ? Colors.blue : Colors.grey,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: hasChanges ? Colors.blue : Colors.grey,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
