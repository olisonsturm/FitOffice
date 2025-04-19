import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/core/controllers/db_controller.dart';
import 'package:fit_office/src/features/core/screens/dashboard/search_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../authentication/models/user_model.dart';
import '../../controllers/profile_controller.dart';

class FavoritesPage extends StatefulWidget {
  final String category;
  final String heading;
  const FavoritesPage({super.key, required this.category, required this.heading});

  @override
  State<FavoritesPage> createState() => _FavoritesPage();
}

class _FavoritesPage extends State<FavoritesPage> {
  List<Map<String, dynamic>> _searchResults = [];
  final ProfileController _profileController = Get.put(ProfileController());
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _performSearch();
  }

  void _performSearch() async {
    final dbController = DbController();
    final user = await _profileController.getUserData();

    setState(() {
      _user = user;
    });

    final results = await dbController.getFavouriteExercises(user.email);
    setState(() {
      _searchResults = results;
    });
  }

  void _loadUser() async {
    final user = await _profileController.getUserData();
    setState(() {
      _user = user;
    });
  }

  void _toggleFavorite(String exerciseName) async {
    final dbController = DbController();
    final user = _user;
    if (user == null) return;

    await dbController.removeFavorite(user.email, exerciseName);

    setState(() {
      _searchResults.removeWhere((element) => element['name'] == exerciseName);
    });
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
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () => _toggleFavorite(exercise['name']),
                      ),
                    ),
                  );
                },
              ),
            ),
            /* SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchPage(query: widget.category),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.grey, width: 2)
                ),
                child: const Text("Add favorites"),
              ),
            ), */
          ],
        ),
      ),
    );
  }
}
