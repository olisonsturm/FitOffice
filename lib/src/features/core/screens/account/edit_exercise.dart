import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/core/screens/account/widgets/confirmation_dialog.dart';
import 'package:fit_office/src/features/core/screens/account/widgets/save_button.dart';
import 'package:flutter/material.dart';

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
  late final TextEditingController _videoController;
  late String originalName;
  late String originalDescription;
  late String originalVideo;
  late String originalCategory;

  final List<String> _categories = [tUpperBody, tLowerBody, tMental];
  String? _selectedCategory;

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise['name']);
    _descriptionController =
        TextEditingController(text: widget.exercise['description']);
    _videoController = TextEditingController(text: widget.exercise['video']);
    _selectedCategory =
        reverseCategoryMap[widget.exercise['category']] ?? tUpperBody;
    originalName = widget.exercise['name'];
    originalDescription = widget.exercise['description'];
    originalVideo = widget.exercise['video'];
    originalCategory = _selectedCategory!;

    _nameController.addListener(_checkIfChanged);
    _descriptionController.addListener(_checkIfChanged);
    _videoController.addListener(_checkIfChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _videoController.dispose();
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
    final video = _videoController.text.trim();
    final category = categoryMap[_selectedCategory];

    if (name.isEmpty || description.isEmpty || category == null || video.isEmpty) {
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
        'video': video,
        'category': category,
      };

      await editExercise(widget.exerciseName, updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(tChangesSaved)),
      );

      Navigator.pop(context);  // Go back after saving
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
        _videoController.text.trim() != originalVideo.trim() ||
        _selectedCategory != originalCategory;

    if (hasAnyChanged != hasChanged) {
      setState(() {
        hasChanged = hasAnyChanged;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(tEditExerciseHeading),
        backgroundColor: tCardBgColor,
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
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                  _checkIfChanged();
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _videoController,
                decoration: const InputDecoration(
                  labelText: tVideoURL,
                  border: OutlineInputBorder(),
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
                      child: SaveButton(
                        hasChanges: hasChanged,
                        onPressed: _showSaveConfirmationDialog,
                        label: tSave,
                      )
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
