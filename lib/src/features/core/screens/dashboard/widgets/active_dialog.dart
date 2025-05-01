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
          message:
              'Bitte beende die laufende Übung, bevor du eine Übung löschen kannst.',
          buttonText: 'Verstanden',
        );
      case 'edit':
        return const ActiveTimerDialog(
          title: tActiveExercise,
          message:
              'Bitte beende die laufende Übung, bevor du eine Übung bearbeiten kannst.',
          buttonText: 'Verstanden',
        );
      case 'start':
        return const ActiveTimerDialog(
          title: tActiveExercise,
          message:
              'Bitte beende zuerst die aktuelle Übung, bevor du eine neue starten kannst.',
          buttonText: 'Verstanden',
        );
      default:
        return const ActiveTimerDialog(
          title: tActiveExercise,
          message: tActiveExerciseErrorMsg,
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
