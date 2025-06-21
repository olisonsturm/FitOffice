import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/utils/theme/widget_themes/dialog_theme.dart';

/// Displays a customizable confirmation dialog with `confirm` and `cancel` actions.
///
/// This function shows a [AlertDialog] with a title, message content,
/// and two action buttons:
/// - A cancel button that simply dismisses the dialog.
/// - A confirm button that dismisses the dialog and then executes [onConfirm].
///
/// The appearance of the dialog buttons adapts to the current [Brightness] (light or dark mode).
///
/// ### Parameters:
/// - [context]: The build context used to show the dialog.
/// - [title]: The title text displayed at the top of the dialog.
/// - [content]: The body text displayed below the title.
/// - [onConfirm]: A callback function executed after the dialog is confirmed.
/// - [confirm]: The label for the confirm button (defaults to [tSave]).
/// - [cancel]: The label for the cancel button (defaults to [tCancel]).
///
/// ### Example:
/// ```dart
/// showConfirmationDialogModel(
///   context: context,
///   title: 'Save Changes?',
///   content: 'Are you sure you want to save these changes?',
///   onConfirm: () {
///     saveUserProfile();
///   },
/// );
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
