import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/text_strings.dart';

class ActiveTimerDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;

  const ActiveTimerDialog({
    super.key,
    required this.title,
    required this.message,
    required this.buttonText,
  });

  factory ActiveTimerDialog.forAction(String actionType) {
    switch (actionType) {
      case 'delete':
        return const ActiveTimerDialog(
          title: tActiveExercise,
          message: tActiveExerciseDialogMessageDelete,
          buttonText: tActiveExerciseAnswer,
        );
      case 'edit':
        return const ActiveTimerDialog(
          title: tActiveExercise,
          message: tActiveExerciseDialogMessageEdit,
          buttonText: tActiveExerciseAnswer,
        );
      case 'start':
        return const ActiveTimerDialog(
          title: tActiveExercise,
          message: tActiveExerciseDialogMessageStart,
          buttonText: tActiveExerciseAnswer,
        );
      default:
        return const ActiveTimerDialog(
          title: tActiveExercise,
          message: tActiveExerciseDialogMessageDefault,
          buttonText: tActiveExerciseAnswer,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(buttonText),
        ),
      ],
    );
  }
}
