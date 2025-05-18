import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:fit_office/src/features/core/controllers/exercise_controller.dart';
import 'package:fit_office/src/features/core/screens/profile/admin/widgets/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../../../../../constants/colors.dart';
import '../../dashboard/widgets/video_player.dart';

class AddExercises extends StatefulWidget {
  final String currentUserId;

  const AddExercises({super.key, required this.currentUserId});

  @override
  State<AddExercises> createState() => _AddExercisesScreenState();
}

class _AddExercisesScreenState extends State<AddExercises> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _videoController = TextEditingController();

  final List<String> _categories = [tUpperBody, tLowerBody, tMental];
  String? _selectedCategory;
  String? uploadedVideoUrl;
  File? _selectedVideoFile;
  bool isLoading = false;

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  ExerciseController exerciseController = ExerciseController();

  Future<void> initVideoPlayer(String path, {bool isLocal = false}) async {
    final (videoCtrl, chewieCtrl) =
        await exerciseController.initializeControllers(path, isLocal: true);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();

    setState(() {
      _videoPlayerController = videoCtrl;
      _chewieController = chewieCtrl;
    });
  }

  void _resetForm() {
    exerciseController.resetForm(
        nameController: _nameController,
        descriptionController: _descriptionController,
        videoController: _videoController);

    _videoPlayerController?.dispose();
    _videoPlayerController = null;
    _selectedVideoFile = null;

    setState(() {
      _selectedCategory = null;
      uploadedVideoUrl = null;
    });
  }

  void _showConfirmationDialog() {
    showConfirmationDialogModel(
      context: context,
      title: tSaveChanges,
      content: tSaveExerciseConfirmation,
      onConfirm: _addExercise,
    );
  }

  Future<void> _addExercise() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final category = _selectedCategory;
    String? videoUrl = uploadedVideoUrl;

    if ((name.isEmpty || description.isEmpty || category == null) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(tFillOutAllFields)),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (_selectedVideoFile != null && videoUrl == null) {
        videoUrl = await exerciseController.uploadVideo(_selectedVideoFile!);
      }

      if (videoUrl == null) {
        throw Exception(tNoVideoSelected);
      }

      await exerciseController.saveExercise(
        name: name,
        description: description,
        category: category!,
        videoUrl: videoUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(tExerciseAdded)),
        );
      }

      _resetForm();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }

    if (mounted) setState(() => isLoading = false);
  }

  void _onFormChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _videoController.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isValid = exerciseController.isFormValid(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        videoFile: _selectedVideoFile,
        uploadedUrl: uploadedVideoUrl);
    return Scaffold(
      appBar: AppBar(
        title: const Text(tAddExercisesHeader),
        backgroundColor: tCardBgColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (exerciseController.hasChanges(
                nameController: _nameController,
                descriptionController: _descriptionController,
                selectedCategory: _selectedCategory,
                selectedVideoFile: _selectedVideoFile,
                uploadedVideoUrl: uploadedVideoUrl)) {
              showConfirmationDialogModel(
                context: context,
                title: tDiscardChangesQuestion,
                content: tDiscardChangesText,
                confirm: tDiscardChanges,
                cancel: tCancel,
                onConfirm: () {
                  Navigator.pop(context);
                },
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: tName,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: tDescription,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: tCategory,
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                items: _categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
              const SizedBox(height: 12),
              if (_selectedVideoFile != null || uploadedVideoUrl != null) ...[
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: uploadedVideoUrl != null
                          ? VideoPlayerWidget(videoUrl: uploadedVideoUrl!)
                          : _videoPlayerController != null
                              ? Chewie(controller: _chewieController!)
                              : const Center(
                                  child: CircularProgressIndicator()),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.white70,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            if (uploadedVideoUrl != null) {
                              try {
                                final ref = FirebaseStorage.instance
                                    .refFromURL(uploadedVideoUrl!);
                                await ref.delete();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(tVideoDeleteSuccess)),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("$e")),
                                );
                              }
                              uploadedVideoUrl = null;
                            }
                            setState(() {
                              _selectedVideoFile = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 12),
              if (uploadedVideoUrl == null)
                TextButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.pickVideo(source: ImageSource.gallery);

                    if (pickedFile != null) {
                      _selectedVideoFile = File(pickedFile.path);
                      await initVideoPlayer(_selectedVideoFile!.path,
                          isLocal: true);
                      setState(() {
                        uploadedVideoUrl = null;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(tNoVideoSelected)),
                      );
                    }
                  },
                  icon: const Icon(Icons.video_call, color: Colors.blue),
                  label: const Text(
                    tUploadVideo,
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.white),
                        onPressed: isValid ? _showConfirmationDialog : null,
                        icon: Icon(Icons.add,
                            color: isValid ? Colors.blue : Colors.grey),
                        label: Text(
                          tAdd,
                          style: TextStyle(
                            color: isValid ? Colors.blue : Colors.grey,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
