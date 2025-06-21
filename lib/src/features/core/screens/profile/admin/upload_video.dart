import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Opens the device's gallery to pick a video file and uploads it to Firebase Storage.
///
/// Returns the download URL of the uploaded video if successful, or an empty string if
/// no video was selected.
///
/// Throws an error if the upload fails.
Future<String> uploadVideo() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

  if (pickedFile != null) {
    File videoFile = File(pickedFile.path);
      final storageRef = FirebaseStorage.instance.ref().child('videos/${DateTime.now()}.mp4');
      await storageRef.putFile(videoFile);

      String videoUrl = await storageRef.getDownloadURL();
      return videoUrl;
  }
  return "";
}

/// Saves an exercise document in Firestore with provided details and video URL.
///
/// [name] - The name of the exercise.
/// [description] - A textual description of the exercise.
/// [category] - The category this exercise belongs to (e.g., "Upper-Body").
/// [videoUrl] - URL of the uploaded exercise video.
///
/// This function adds a new document to the 'exercises' collection in Firestore.
Future<void> saveExerciseWithVideo(
    String name, String description, String category, String videoUrl) async {
  await FirebaseFirestore.instance.collection('exercises').add({
    'name': name,
    'description': description,
    'category': category,
    'video': videoUrl,
  });
}
