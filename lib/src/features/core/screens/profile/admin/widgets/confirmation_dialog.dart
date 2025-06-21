import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/utils/theme/widget_themes/dialog_theme.dart';

/// Displays a customizable confirmation dialog with `confirm` and `cancel` actions.
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
          style: Theme.of(context).brightness == Brightness.dark
              ? TDialogTheme.getDarkCancelButtonStyle()
              : TDialogTheme.getLightCancelButtonStyle(),
          onPressed: () => Navigator.pop(context),
          child: Text(cancel),
        ),
        TextButton(
          style: Theme.of(context).brightness == Brightness.dark
              ? TDialogTheme.getDarkConfirmButtonStyle()
              : TDialogTheme.getLightConfirmButtonStyle(),
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: Text(confirm),
        ),
      ],
    ),
  );
}
