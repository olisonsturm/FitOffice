import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';

import '../../../constants/text_strings.dart';

class ExerciseController {
  final Map<String, String> categoryMap = {
    tUpperBody: 'Upper-Body',
    tLowerBody: 'Lower-Body',
    tMental: 'Mind',
  };

  void resetForm(
      {required TextEditingController nameController,
      required TextEditingController descriptionController,
      required TextEditingController videoController}) {
    nameController.clear();
    descriptionController.clear();
    videoController.clear();
  }

  Future<String?> uploadVideo(File videoFile) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('videos/${DateTime.now()}.mp4');

      await storageRef.putFile(videoFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      throw Exception('Video upload failed: $e');
    }
  }

  Future<void> saveExercise({
    required String name,
    required String nameEn,
    required String description,
    required String descriptionEn,
    required String category,
    required String videoUrl,
  }) async {
    await FirebaseFirestore.instance.collection('exercises').add({
      'name': name,
      'name_en': nameEn,
      'description': description,
      'description_en': descriptionEn,
      'category': ExerciseController().categoryMap[category],
      'video': videoUrl,
    });
  }

  Future<(VideoPlayerController, ChewieController)> initializeControllers(
      String path,
      {bool isLocal = false}) async {
    final videoPlayerController = isLocal
        ? VideoPlayerController.file(File(path))
        : VideoPlayerController.networkUrl(Uri.parse(path));

    await videoPlayerController.initialize();

    final chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: false,
      looping: false,
      aspectRatio: videoPlayerController.value.aspectRatio,
    );

    return (videoPlayerController, chewieController);
  }

  bool isFormValid({
    required String name,
    required String description,
    required String? category,
    required File? videoFile,
    required String? uploadedUrl,
  }) {
    return name.trim().isNotEmpty &&
        description.trim().isNotEmpty &&
        category != null &&
        (videoFile != null || uploadedUrl != null);
  }

  bool hasChanges(
      {required TextEditingController nameController,
      required TextEditingController descriptionController,
      required String? selectedCategory,
      required File? selectedVideoFile,
      required String? uploadedVideoUrl}) {
    return nameController.text.trim().isNotEmpty ||
        descriptionController.text.trim().isNotEmpty ||
        selectedCategory != null ||
        selectedVideoFile != null ||
        uploadedVideoUrl != null;
  }

  Future<void> editExercise(
      String exerciseName, Map<String, dynamic> updatedData) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('exercises')
        .where('name', isEqualTo: exerciseName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;

      await FirebaseFirestore.instance
          .collection('exercises')
          .doc(docId)
          .update(updatedData);
    }
  }

  bool checkIfExerciseChanged({
    required String newName,
    required String newNameEn,
    required String newDescription,
    required String newDescriptionEn,
    required String newCategory,
    required String originalName,
    required String originalNameEn,
    required String originalDescription,
    required String originalDescriptionEn,
    required String originalCategory,
    required bool isVideoMarkedForDeletion,
    required File? pickedVideoFile,
    required String? uploadedVideoUrl,
    required String originalVideo,
  }) {
    final hasVideo = !isVideoMarkedForDeletion &&
        (pickedVideoFile != null ||
            uploadedVideoUrl != null ||
            originalVideo.isNotEmpty);

    final isValid = newName.isNotEmpty &&
        newNameEn.isNotEmpty &&
        newDescriptionEn.isNotEmpty &&
        newDescription.isNotEmpty &&
        newCategory.isNotEmpty &&
        hasVideo;

    final hasAnyChanged = newName.trim() != originalName.trim() ||
        newNameEn.trim() != originalNameEn.trim() ||
        newDescription.trim() != originalDescription.trim() ||
        newDescriptionEn.trim() != originalDescriptionEn ||
        newCategory != originalCategory ||
        pickedVideoFile != null ||
        (uploadedVideoUrl != null && uploadedVideoUrl != originalVideo) ||
        isVideoMarkedForDeletion;

    return hasAnyChanged && isValid;
  }

  Future<void> deleteVideoByUrl(String url) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('$e');
    }
  }
}
