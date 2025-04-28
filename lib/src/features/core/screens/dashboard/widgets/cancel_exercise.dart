import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/text_strings.dart';


class CancelExerciseDialog extends StatelessWidget {
  const CancelExerciseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {},
      child: AlertDialog(
        title: const Text(tCancelExercise),
        content: const Text(
          tCancelExerciseMessage,
        ),
        actions: [
          TextButton(
            child: const Text(tCancelExerciseNegative),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text(tCancelExercisePositive),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}
