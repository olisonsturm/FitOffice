import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:flutter/material.dart';

class DeleteExercise extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final String exerciseName;

  const DeleteExercise({
    super.key,
    required this.exercise,
    required this.exerciseName,
  });

  @override
  State<DeleteExercise> createState() => _DeleteExerciseState();
}

class _DeleteExerciseState extends State<DeleteExercise> {
  bool isLoading = false;

  Future<void> _deleteExercise() async {
    setState(() => isLoading = true);

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
        await FirebaseFirestore.instance.collection('exercises').doc(docId).delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(tGotDeleted)),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }

    setState(() => isLoading = false);
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(tDeleteExercise),
        content: Text('Do you want to delete "${widget.exerciseName}"? The exercise cannot be restored and will be deleted for every user!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(tCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteExercise();
            },
            child: const Text(
              tDelete,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(tDeleteExercise),
        backgroundColor: tCardBgColor,
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
          onPressed: _showDeleteDialog,
          icon: const Icon(Icons.delete, color: Colors.white),
          label: const Text(
            tDeleteExercise,
            style: TextStyle(fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
