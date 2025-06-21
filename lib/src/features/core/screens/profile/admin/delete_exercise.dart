import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fit_office/src/features/core/controllers/db_controller.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/l10n/app_localizations.dart';

/// A dialog widget that provides UI and functionality to delete a specific exercise.
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
  final dbController = DbController();

  /// Deletes the exercise document and associated video (if any) from Firestore and Firebase Storage.
  /// Also deletes related exercise logs.
  /// Shows a success message on completion or error message on failure.
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

        dbController.deleteExciseLogsOfExercise(widget.exerciseName);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.tGotDeleted)),
        );
        widget.onSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 365, minWidth: 300),
        child: Material(
          borderRadius: BorderRadius.circular(20),
          color: isDarkMode ? tDarkGreyColor : tWhiteColor,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Stack(
              children: [
                if (isDeleting)
                  const SizedBox(
                    height: 150,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!.tDeleteExercise,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : tBlackColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppLocalizations.of(context)!.tDeleteExerciseMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode ? tPaleWhiteColor : tPaleBlackColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.exerciseName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: isDarkMode ? tWhiteColor : tBlackColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _deleteExercise,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade500,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide.none,
                              ),
                              icon:
                                  const Icon(Icons.delete, color: tWhiteColor),
                              label: Text(
                                AppLocalizations.of(context)!.tDelete,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: tWhiteColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isDarkMode ? tGreyColor : tPaleBlackColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide.none,
                              ),
                              icon: const Icon(Icons.undo_sharp,
                                  color: Colors.white),
                              label: Text(
                                AppLocalizations.of(context)!.tCancel,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                Positioned(
                  right: -12,
                  top: -12,
                  child: IconButton(
                    icon: Icon(
                      Icons.cancel_outlined,
                      color: isDarkMode ? tPaleWhiteColor : tPaleBlackColor,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    iconSize: 28,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
