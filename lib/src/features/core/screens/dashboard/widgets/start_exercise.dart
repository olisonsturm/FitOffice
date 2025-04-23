import 'package:fit_office/src/constants/text_strings.dart';
import 'package:flutter/material.dart';

class StartExerciseDialog extends StatelessWidget {
  final String exerciseName;

  const StartExerciseDialog({super.key, required this.exerciseName});

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        title: const Text(tStartExercisePopUp),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(tStartExerciseConfirmation),
            const SizedBox(height: 12),
            Text(
              exerciseName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text(tStartExerciseNegative),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text(tStartExercisePositive),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}
