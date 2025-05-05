import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/video_player.dart';
import 'package:fit_office/src/features/core/screens/profile/admin/upload_video.dart';
import 'package:fit_office/src/features/core/screens/profile/admin/widgets/delete_video.dart';
import 'package:fit_office/src/features/core/screens/profile/admin/widgets/replace_video.dart';
import 'package:fit_office/src/features/core/screens/profile/admin/widgets/save_button.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'add_exercises.dart';

class EditExercise extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final String exerciseName;

  const EditExercise(
      {super.key, required this.exercise, required this.exerciseName});

  @override
  State<EditExercise> createState() => _EditExerciseState();
}

class _EditExerciseState extends State<EditExercise> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late String originalName;
  late String originalDescription;
  late String originalVideo;
  late String originalCategory;

  final List<String> _categories = [tUpperBody, tLowerBody, tMental];
  String? _selectedCategory;
  String? uploadedVideoUrl;
  VideoPlayerController? _videoPlayerController;

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

  bool isLoading = false;
  bool hasChanged = false;

  Future<void> initVideoPlayer(String? url) async {
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
      setState(() {});
    } catch (e) {
      debugPrint('Fehler beim Laden des Videos: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise['name']);
    _descriptionController =
        TextEditingController(text: widget.exercise['description']);
    _selectedCategory =
        reverseCategoryMap[widget.exercise['category']] ?? tUpperBody;
    originalName = widget.exercise['name'];
    originalDescription = widget.exercise['description'];
    originalVideo = widget.exercise['video'];
    originalCategory = _selectedCategory!;

    _nameController.addListener(_checkIfChanged);
    _descriptionController.addListener(_checkIfChanged);

    initVideoPlayer(widget.exercise['video']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _showSaveConfirmationDialog() {
    showConfirmationDialog(
      context: context,
      title: tSaveChanges,
      content: tSaveChangesQuestion,
      onConfirm: _saveExercise,
    );
  }

  void _saveExercise() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final category = categoryMap[_selectedCategory];

    String videoUrl = uploadedVideoUrl ?? originalVideo;

    if (name.isEmpty || description.isEmpty || category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(tFillOutAllFields)),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final updatedData = {
        'name': name,
        'description': description,
        'category': category,
        'video': videoUrl,
      };

      await editExercise(widget.exerciseName, updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(tChangesSaved)),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }

    setState(() => isLoading = false);
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

  void _checkIfChanged() {
    final hasAnyChanged = _nameController.text.trim() != originalName.trim() ||
        _descriptionController.text.trim() != originalDescription.trim() ||
        _selectedCategory != originalCategory ||
        (uploadedVideoUrl != null && uploadedVideoUrl != originalVideo);

    if (hasAnyChanged != hasChanged) {
      setState(() {
        hasChanged = hasAnyChanged;
      });
    }
  }

  // Future<void> initVideoPlayer(String url) async {
  //   _videoPlayerController?.dispose();
  //   _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
  //   await _videoPlayerController!.initialize();
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(tEditExerciseHeading),
        backgroundColor: isDarkMode ? tDarkGreyColor : tCardBgColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                style:
                    TextStyle(color: isDarkMode ? tWhiteColor : tBlackColor),
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
                style:
                    TextStyle(color: isDarkMode ? tWhiteColor : tBlackColor),
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
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: tCategory,
                  labelStyle: TextStyle(color: tBottomNavBarSelectedColor),
                  floatingLabelStyle:
                      TextStyle(color: tBottomNavBarSelectedColor),
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
              isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        Builder(
                          builder: (context) {
                            final videoUrl = uploadedVideoUrl ?? originalVideo;

                            final hasVideo = videoUrl.isNotEmpty &&
                                Uri.tryParse(videoUrl)?.hasAbsolutePath ==
                                    true &&
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
                                            videoUrl: videoUrl),
                                      ),
                                      Positioned(
                                        top: 30,
                                        right: 4,
                                        child: IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () async {
                                            final confirm =
                                                await showDialog<bool>(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (context) =>
                                                  const ConfirmVideoDeleteDialog(),
                                            );

                                            if (confirm != true) return;

                                            try {
                                              final storageRef = FirebaseStorage
                                                  .instance
                                                  .refFromURL(videoUrl);
                                              await storageRef.delete();

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        tVideoDeleteSuccess)),
                                              );

                                              setState(() {
                                                uploadedVideoUrl = null;
                                                originalVideo = '';
                                              });

                                              _checkIfChanged();
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(content: Text("$e")),
                                              );
                                            }
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
                                              : tGreyColor,
                                        ),
                                      ),
                                    ),
                                  );
                          },
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: tWhiteColor,
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
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
                              final hasExistingVideo =
                                  (uploadedVideoUrl ?? originalVideo)
                                      .isNotEmpty;
                              bool proceed = true;

                              if (hasExistingVideo) {
                                proceed = await showDialog<bool>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) =>
                                          const ReplaceVideoDialog(),
                                    ) ??
                                    false;

                                if (!proceed) return;
                              }

                              final videoUrl = await uploadVideo();

                              if (videoUrl.isNotEmpty) {
                                if (hasExistingVideo) {
                                  try {
                                    final storageRef = FirebaseStorage.instance
                                        .refFromURL(
                                            uploadedVideoUrl ?? originalVideo);
                                    await storageRef.delete();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('$tDeleteVideoFailed: $e')),
                                    );
                                  }
                                }

                                await initVideoPlayer(videoUrl);
                                setState(() {
                                  uploadedVideoUrl = videoUrl;
                                  originalVideo = '';
                                });

                                _checkIfChanged();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(tUploadVideoSuccess)),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(tNoVideoSelected)),
                                );
                              }
                            },
                            icon: Icon(
                              Icons.video_call,
                              color: tBlackColor,
                            ),
                            label: Text(
                              (uploadedVideoUrl == null &&
                                      originalVideo.isEmpty)
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
                            color: hasChanged
                                ? (tWhiteColor)
                                : (isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.grey.shade300),
                            border: Border.all(
                              color: hasChanged
                                  ? (tWhiteColor)
                                  : (isDarkMode
                                      ? Colors.grey[700]!
                                      : Colors.grey.shade400),
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
                              Icons.save,
                              color: hasChanged
                                  ? ( tBlackColor)
                                  : Colors.grey.shade600,
                            ),
                            onPressed:
                                hasChanged ? _showSaveConfirmationDialog : null,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            label: Text(
                              tSave,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: hasChanged
                                    ? (tBlackColor)
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
