import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/core/controllers/db_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../authentication/models/user_model.dart';
import '../../controllers/profile_controller.dart';

class CategoriesPage extends StatefulWidget {
  final String category;
  final String heading;
  const CategoriesPage({super.key, required this.category, required this.heading});

  @override
  State<CategoriesPage> createState() => _CategoriesPage();
}

class _CategoriesPage extends State<CategoriesPage> {
  List<Map<String, dynamic>> _searchResults = [];
  List<String> _userFavorites = [];
  final ProfileController _profileController = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    _performSearch(widget.category);
  }

  void _performSearch(String query) async {
    final dbController = DbController();
    final results = await dbController.getAllExercisesOfCategory(query);
    setState(() {
      _searchResults = results;
    });
    _loadUserFavorites();
  }

  void _loadUserFavorites() async {
    final user = await _getUserData();
    DbController dbController = DbController();
    final userFavorites = await dbController.getFavouriteExercises(user.email);

    setState(() {
      _userFavorites = userFavorites.map((e) => e['name'] as String).toList();
    });
  }

  Future<UserModel> _getUserData() async {
    return await _profileController.getUserData();
  }

  void _toggleFavorite(String exerciseName) async {
    final dbController = DbController();
    final user = await _getUserData();
    final isFavorite = _userFavorites.contains(exerciseName);

    if (isFavorite) {
      await dbController.removeFavorite(user.email, exerciseName);
    } else {
      await dbController.addFavorite(user.email, exerciseName);
    }

    _loadUserFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.heading),
        backgroundColor: Colors.grey,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: _searchResults.isEmpty
                  ? const Text(tDashboardNoResultsFound)
                  : ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final exercise = _searchResults[index];
                  final exerciseName = exercise['name'];
                  final isFavorite = _userFavorites.contains(exerciseName);
                  return Card(
                    child: ListTile(
                      onTap: () => {
                        // TODO: Add link to exercise here
                      },
                      title: Text(exercise['name'] ?? 'Unknown',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          'Category: ${exercise['category'] ?? 'No category.'}\n'
                              'Description: ${exercise['description'] ?? 'No description.'}\n'
                              'Video: ${exercise['video'] ?? 'No video.'}\n'
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => _toggleFavorite(exerciseName),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
