import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  final Map<String, String> categoryMap = {
    tUpperBody: 'Upper-Body',
    tLowerBody: 'Lower-Body',
    tMental: 'Mind',
  };

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  Future<void> initVideoPlayer(String path, {bool isLocal = false}) async {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();

    _videoPlayerController = isLocal
        ? VideoPlayerController.file(File(path))
        : VideoPlayerController.networkUrl(Uri.parse(path));

    await _videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: false,
      looping: false,
      aspectRatio: _videoPlayerController!.value.aspectRatio,
    );

    setState(() {});
  }

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    _videoController.clear();

    _videoPlayerController?.dispose();
    _videoPlayerController = null;
    _selectedVideoFile = null;

    setState(() {
      _selectedCategory = null;
      uploadedVideoUrl = null;
    });
  }

  void _showConfirmationDialog() {
    showConfirmationDialog(
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

    if (_selectedVideoFile != null && videoUrl == null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('videos/${DateTime.now()}.mp4');

        await storageRef.putFile(_selectedVideoFile!);

        videoUrl = await storageRef.getDownloadURL();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e')),
          );
        }
        setState(() => isLoading = false);
        return;
      }
    }

    if ((name.isEmpty ||
            description.isEmpty ||
            category == null ||
            videoUrl == null) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(tFillOutAllFields)),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('exercises').add({
        'name': name,
        'description': description,
        'category': categoryMap[_selectedCategory],
        'video': videoUrl,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(tExerciseAdded)),
        );
      }
      _resetForm();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }

    setState(() => isLoading = false);
  }

  bool get _hasChanges {
    return _nameController.text.trim().isNotEmpty ||
        _descriptionController.text.trim().isNotEmpty ||
        _selectedCategory != null ||
        _selectedVideoFile != null ||
        uploadedVideoUrl != null;
  }

  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _selectedCategory != null &&
        (_selectedVideoFile != null || uploadedVideoUrl != null);
  }

  void showDiscardChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(tDiscardChangesQuestion),
        content: const Text(tDiscardChangesText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(tCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              tDiscardChanges,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(tAddExercisesHeader),
        backgroundColor: tCardBgColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_hasChanges) {
              showDiscardChangesDialog();
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
                        onPressed:
                            _isFormValid ? _showConfirmationDialog : null,
                        icon: Icon(Icons.add,
                            color: _isFormValid ? Colors.blue : Colors.grey),
                        label: Text(
                          tAdd,
                          style: TextStyle(
                            color: _isFormValid ? Colors.blue : Colors.grey,
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

void showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(tCancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text(
            tSave,
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    ),
  );
}
