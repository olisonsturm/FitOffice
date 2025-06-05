import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/text_strings.dart';

void showConfirmationDialogModel(
    {required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
    String confirm = tSave,
    String cancel = tCancel}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: Text(
            confirm,
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    ),
  );
}
