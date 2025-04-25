import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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


Future<void> saveExerciseWithVideo(
    String name, String description, String category, String videoUrl) async {
  await FirebaseFirestore.instance.collection('exercises').add({
    'name': name,
    'description': description,
    'category': category,
    'video': videoUrl,
  });
}
