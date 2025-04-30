import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/text_strings.dart';

Future<void> showDeleteExerciseDialog({
  required BuildContext context,
  required Map<String, dynamic> exercise,
  required String exerciseName,
  VoidCallback? onSuccess,
}) async {
  bool isDeleting = false;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(tDeleteExercise),
          content: isDeleting
              ? const SizedBox(
                  height: 60,
                  child: Center(child: CircularProgressIndicator()),
                )
              : Text(
                  'Möchtest du "${exerciseName}" wirklich löschen?\n\nDiese Übung wird unwiderruflich für alle Benutzer entfernt.'),
          actions: isDeleting
              ? []
              : [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(tCancel),
                  ),
                  TextButton(
                    onPressed: () async {
                      setState(() => isDeleting = true);

                      try {
                        final querySnapshot = await FirebaseFirestore.instance
                            .collection('exercises')
                            .where('name', isEqualTo: exerciseName)
                            .get();

                        if (querySnapshot.docs.isNotEmpty) {
                          final docId = querySnapshot.docs.first.id;
                          final videoUrl = exercise['video'];

                          if (videoUrl != null && videoUrl.isNotEmpty) {
                            final ref =
                                FirebaseStorage.instance.refFromURL(videoUrl);
                            await ref.delete();
                          }

                          await FirebaseFirestore.instance
                              .collection('exercises')
                              .doc(docId)
                              .delete();
                        }

                        Navigator.of(context).pop(); // Dialog schließen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text(tGotDeleted)),
                        );

                        if (onSuccess != null) {
                          onSuccess();
                        }
                      } catch (e) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Fehler: $e')),
                        );
                      }
                    },
                    child: const Text(
                      tDelete,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
        ),
      );
    },
  );
}
