import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/text_strings.dart';

class ActiveTimerDialog extends StatelessWidget {
  const ActiveTimerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(tActiveExercise),
      content: const Text(tActiveExerciseErrorMsg),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(tActiveExerciseAnswer),
        ),
      ],
    );
  }
}
