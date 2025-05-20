import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/appbar.dart';
import 'package:fit_office/src/features/core/screens/profile/admin/widgets/confirmation_dialog.dart';
import 'package:fit_office/src/features/core/screens/profile/admin/widgets/delete_video.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../../../../constants/colors.dart';
import '../../../../../constants/text_strings.dart';
import '../../../controllers/exercise_controller.dart';
import '../../dashboard/widgets/video_player.dart';

class ExerciseForm extends StatefulWidget {
  final Map<String, dynamic>? exercise;
  final String? exerciseName;
  final bool isEdit;

  const ExerciseForm(
      {super.key, this.exercise, this.exerciseName, required this.isEdit});

  @override
  State<ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<ExerciseForm> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _videoController = TextEditingController();

  final List<String> _categories = [tUpperBody, tLowerBody, tMental];
  String? _selectedCategory;
  String? uploadedVideoUrl;
  String? _videoToDelete;
  File? _selectedVideoFile;
  bool isLoading = false;
  bool isVideoMarkedForDeletion = false;
  bool hasChanged = false;

  late String originalName;
  late String originalDescription;
  late String originalVideo;
  late String originalCategory;

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  ExerciseController exerciseController = ExerciseController();

  final Map<String, String> categoryMap = {
    tUpperBody: 'Upper-Body',
    tLowerBody: 'Lower-Body',
    tMental: 'Mind',
  };

  final Map<String, String> reverseCategoryMap = {
    'Upper-Body': tUpperBody,
    'Lower-Body': tLowerBody,
    'Mind': tMental,
  };

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

  Future<void> initVideoPlayerEditVideo(String? url) async {
    if (url == null || url.isEmpty) return;

    final uri = Uri.tryParse(url);
    final isValidUrl = uri != null &&
        uri.hasAbsolutePath &&
        (url.startsWith('http://') || url.startsWith('https://'));

    if (!isValidUrl) return;

    try {
      _videoPlayerController?.dispose();
      _videoPlayerController = VideoPlayerController.networkUrl(uri);
      await _videoPlayerController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
      );
      setState(() {});
    } catch (e) {
      debugPrint('$e');
    }
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

  void _showConfirmationDialog(bool isEdit) {
    showConfirmationDialogModel(
      context: context,
      title: tSaveChanges,
      content: tSaveExerciseConfirmation,
      onConfirm: isEdit ? _saveExercise : _addExercise,
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

  void _saveExercise() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final category = categoryMap[_selectedCategory];

    final hasVideo = !isVideoMarkedForDeletion &&
        (_selectedVideoFile != null ||
            uploadedVideoUrl != null ||
            originalVideo.isNotEmpty);

    if (name.isEmpty || description.isEmpty || category == null || !hasVideo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(tFillOutAllFields)),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (_videoToDelete != null && _videoToDelete!.isNotEmpty) {
        try {
          exerciseController.deleteVideoByUrl(_videoToDelete!);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$tDeleteVideoFailed: $e')),
            );
          }
        }
      }

      String? finalVideoUrl = uploadedVideoUrl;

      if (_selectedVideoFile != null) {
        finalVideoUrl =
            await exerciseController.uploadVideo(_selectedVideoFile!);
      }

      final videoUrl = finalVideoUrl ?? originalVideo;

      final updatedData = {
        'name': name,
        'description': description,
        'category': category,
        'video': videoUrl,
      };

      await exerciseController.editExercise(widget.exerciseName!, updatedData);
      _videoToDelete = null;
      _selectedVideoFile = null;
      uploadedVideoUrl = finalVideoUrl;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(tChangesSaved)),
        );
        Navigator.pop(context, updatedData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }

    setState(() => isLoading = false);
  }

  void _onFormChanged() {
    setState(() {});
  }

  void _checkIfChanged() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final category = _selectedCategory ?? '';
    final result = exerciseController.checkIfExerciseChanged(
      newName: name,
      newDescription: description,
      newCategory: category,
      originalName: originalName,
      originalDescription: originalDescription,
      originalCategory: originalCategory,
      isVideoMarkedForDeletion: isVideoMarkedForDeletion,
      pickedVideoFile: _selectedVideoFile,
      uploadedVideoUrl: uploadedVideoUrl,
      originalVideo: originalVideo,
    );

    if (result != hasChanged) {
      setState(() => hasChanged = result);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.exercise != null) {
      _nameController = TextEditingController(text: widget.exercise!['name']);
      _descriptionController =
          TextEditingController(text: widget.exercise!['description']);
      _selectedCategory =
          reverseCategoryMap[widget.exercise!['category']] ?? tUpperBody;
      originalName = widget.exercise!['name'];
      originalDescription = widget.exercise!['description'];
      originalVideo = widget.exercise!['video'];
      originalCategory = _selectedCategory!;

      _nameController.addListener(_checkIfChanged);
      _descriptionController.addListener(_checkIfChanged);

      initVideoPlayerEditVideo(widget.exercise!['video']);
    } else {
      _nameController.addListener(_onFormChanged);
      _descriptionController.addListener(_onFormChanged);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _videoPlayerController?.dispose();
    if (!(widget.isEdit && widget.exercise != null)) {
      _videoController.dispose();
      _chewieController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isValid = exerciseController.isFormValid(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        videoFile: _selectedVideoFile,
        uploadedUrl: uploadedVideoUrl);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? tEditExerciseHeading : tAddExercisesHeader),
        backgroundColor: tCardBgColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (widget.isEdit) {
              if (hasChanged) {
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
            } else if (widget.isEdit == false) {
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
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
            child: Column(children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: tName,
              labelStyle: TextStyle(color: tBottomNavBarSelectedColor),
              floatingLabelStyle: TextStyle(
                  color: tBottomNavBarSelectedColor,
                  fontWeight: FontWeight.bold),
              filled: true,
              fillColor: isDarkMode ? Colors.grey[850] : tWhiteColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isDarkMode ? Colors.white24 : Colors.black12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    BorderSide(color: tBottomNavBarSelectedColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
              controller: _descriptionController,
              maxLines: 5,
              style: TextStyle(color: isDarkMode ? tWhiteColor : tBlackColor),
              decoration: InputDecoration(
                labelText: tDescription,
                labelStyle: TextStyle(color: tBottomNavBarSelectedColor),
                floatingLabelStyle: TextStyle(
                    color: tBottomNavBarSelectedColor,
                    fontWeight: FontWeight.bold),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[850] : tWhiteColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: isDarkMode ? Colors.white24 : Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      BorderSide(color: tBottomNavBarSelectedColor, width: 2),
                ),
              )),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: tCategory,
              labelStyle: TextStyle(color: tBottomNavBarSelectedColor),
              floatingLabelStyle: TextStyle(color: tBottomNavBarSelectedColor),
              filled: true,
              fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.white24 : Colors.black12,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: tBottomNavBarSelectedColor,
                  width: 2,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            dropdownColor: isDarkMode ? Colors.grey[850] : Colors.white,
            iconEnabledColor: tBottomNavBarSelectedColor,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
            ),
            items: _categories.map((String cat) {
              return DropdownMenuItem<String>(
                value: cat,
                child: Text(cat),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue!;
              });
              _checkIfChanged();
            },
          ),
          const SizedBox(height: 24),
          if (isLoading && widget.isEdit)
            const CircularProgressIndicator()
          else if (widget.isEdit == false) ...[
            if (_selectedVideoFile != null || uploadedVideoUrl != null) ...[
              Stack(
                alignment: Alignment.topRight,
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: uploadedVideoUrl != null
                        ? VideoPlayerWidget(videoUrl: uploadedVideoUrl!)
                        : _chewieController != null
                            ? Chewie(controller: _chewieController!)
                            : const Center(child: CircularProgressIndicator()),
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
            ]
          ] else
            Column(
              children: [
                Builder(
                  builder: (context) {
                    final videoUrl = isVideoMarkedForDeletion
                        ? ''
                        : (uploadedVideoUrl ?? originalVideo);

                    final hasVideo = videoUrl.isNotEmpty &&
                        Uri.tryParse(videoUrl)?.hasAbsolutePath == true &&
                        (videoUrl.startsWith('http://') ||
                            videoUrl.startsWith('https://'));

                    return hasVideo
                        ? Stack(
                            alignment: Alignment.topRight,
                            children: [
                              SizedBox(
                                height: 200,
                                width: double.infinity,
                                child: VideoPlayerWidget(
                                  file: _selectedVideoFile,
                                  videoUrl: _selectedVideoFile == null
                                      ? videoUrl
                                      : null,
                                ),
                              ),
                              Positioned(
                                top: 30,
                                right: 4,
                                child: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) =>
                                          const ConfirmVideoDeleteDialog(),
                                    );

                                    if (confirm != true) return;

                                    setState(() {
                                      _videoToDelete =
                                          uploadedVideoUrl ?? originalVideo;
                                      uploadedVideoUrl = null;
                                      _selectedVideoFile = null;
                                      isVideoMarkedForDeletion = true;

                                      _videoPlayerController?.dispose();
                                      _videoPlayerController = null;
                                    });

                                    _checkIfChanged();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(tVideoDeleteSuccess)),
                                    );
                                  },
                                  iconSize: 28,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ],
                          )
                        : Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                tNoVideoAvailable,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white70
                                      : tDarkGreyColor,
                                ),
                              ),
                            ),
                          );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: tWhiteColor,
              border: Border.all(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isDarkMode
                  ? []
                  : const [
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
              ),
              onPressed: () async {
                final picker = ImagePicker();
                final pickedFile =
                    await picker.pickVideo(source: ImageSource.gallery);

                if (pickedFile != null) {
                  final file = File(pickedFile.path);
                  _videoPlayerController?.dispose();
                  _videoPlayerController = VideoPlayerController.file(file);
                  await _videoPlayerController!.initialize();
                  _chewieController = ChewieController(
                    videoPlayerController: _videoPlayerController!,
                    autoPlay: false,
                    looping: false,
                  );

                  setState(() {
                    _selectedVideoFile = file;
                    uploadedVideoUrl = null;
                    isVideoMarkedForDeletion = false;
                  });

                  _checkIfChanged();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(tVideoSelected)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(tNoVideoSelected)),
                  );
                }
              },
              icon: Icon(
                Icons.video_call,
                color: tBlackColor,
              ),
              label: Text(
                (isVideoMarkedForDeletion || (uploadedVideoUrl == null))
                    ? tUploadVideo
                    : tReplaceVideo,
                style: TextStyle(
                  color: tBlackColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.isEdit ? (hasChanged
                    ? (tWhiteColor)
                    : (isDarkMode ? Colors.grey[800] : Colors.grey.shade300)) : Colors.white,
                border: Border.all(
                  color: hasChanged
                      ? (tWhiteColor)
                      : (isDarkMode ? Colors.grey[700]! : Colors.grey.shade400),
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isDarkMode
                    ? []
                    : const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
              ),
              child: TextButton.icon(
                icon: Icon(
                  widget.isEdit ? Icons.save : Icons.add,
                  color: widget.isEdit
                      ? (hasChanged ? (tBlackColor) : Colors.grey.shade600)
                      : (isValid ? Colors.blue : Colors.grey),
                ),
                onPressed: hasChanged && widget.isEdit
                    ? () => _showConfirmationDialog(widget.isEdit)
                    : widget.isEdit == false && isValid
                        ? () => _showConfirmationDialog(widget.isEdit)
                        : null,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                label: Text(
                  widget.isEdit ? tSave : tAdd,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.isEdit
                        ? (hasChanged ? (tBlackColor) : Colors.grey.shade600)
                        : (isValid ? Colors.blue : Colors.grey),
                  ),
                ),
              )),
        ])),
      ),
    );
  }
}
