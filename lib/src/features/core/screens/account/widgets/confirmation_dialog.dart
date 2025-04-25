import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/text_strings.dart'; // Nur falls du tSave etc. brauchst

void showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(tCancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text(
            tSave,
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    ),
  );
}
