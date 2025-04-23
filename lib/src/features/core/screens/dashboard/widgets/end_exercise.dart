// ignore_for_file: deprecated_member_use

import 'package:fit_office/src/constants/text_strings.dart';
import 'package:flutter/material.dart';

class EndExerciseDialog extends StatelessWidget {
  const EndExerciseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, 
      child: AlertDialog(
        title: const Text(tEndExercisePopUp),
        content: const Text(tEndExerciseConfirmation),
        actions: [
          TextButton(
            child: const Text(tEndExerciseNegative),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text(tEndExercisePositive),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}
