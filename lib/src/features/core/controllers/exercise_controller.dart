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
    required String description,
    required String category,
    required String videoUrl,
  }) async {
    await FirebaseFirestore.instance.collection('exercises').add({
      'name': name,
      'description': description,
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
}
