import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/text_strings.dart';

class DeleteExerciseDialog extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final String exerciseName;
  final VoidCallback? onSuccess;

  const DeleteExerciseDialog({
    super.key,
    required this.exercise,
    required this.exerciseName,
    this.onSuccess,
  });

  @override
  State<DeleteExerciseDialog> createState() => _DeleteExerciseDialogState();
}

class _DeleteExerciseDialogState extends State<DeleteExerciseDialog> {
  bool isDeleting = false;

  Future<void> _deleteExercise() async {
    setState(() => isDeleting = true);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('exercises')
          .where('name', isEqualTo: widget.exerciseName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        final videoUrl = widget.exercise['video'];

        if (videoUrl != null && videoUrl.isNotEmpty) {
          final ref = FirebaseStorage.instance.refFromURL(videoUrl);
          await ref.delete();
        }

        await FirebaseFirestore.instance
            .collection('exercises')
            .doc(docId)
            .delete();
      }

      if (mounted) {
        Navigator.of(context).pop(); // Dialog schließen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(tGotDeleted)),
        );
        widget.onSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Dialog schließen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(tDeleteExercise),
      content: isDeleting
          ? const SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            )
          : Text(
              'Möchtest du "${widget.exerciseName}" wirklich löschen?\n\nDiese Übung wird unwiderruflich für alle Benutzer entfernt.'),
      actions: isDeleting
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(tCancel),
              ),
              TextButton(
                onPressed: _deleteExercise,
                child: const Text(
                  tDelete,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
    );
  }
}
