import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/core/controllers/db_controller.dart';
import 'package:flutter/material.dart';

class CategoriesPage extends StatefulWidget {
  final String category;
  final String heading;
  const CategoriesPage({super.key, required this.category, required this.heading});

  @override
  State<CategoriesPage> createState() => _CategoriesPage();
}

class _CategoriesPage extends State<CategoriesPage> {
  List<Map<String, dynamic>> _searchResults = [];

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
