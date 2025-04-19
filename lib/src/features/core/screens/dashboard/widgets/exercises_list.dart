import 'package:flutter/material.dart';

class AllExercisesList extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;
  final List<String> favorites;
  final void Function(String exerciseName) onToggleFavorite;
  final String query;

  const AllExercisesList({
    super.key,
    required this.exercises,
    required this.favorites,
    required this.onToggleFavorite,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final lowerQuery = query.toLowerCase();
    final filteredExercises = exercises.where((exercise) {
      final name = (exercise['name'] ?? '').toString().toLowerCase();
      final description = (exercise['description'] ?? '').toString().toLowerCase();
      return name.contains(lowerQuery) || description.contains(lowerQuery);
    }).toList();

    if (filteredExercises.isEmpty) {
      return const Text("Keine passenden Übungen gefunden.");
    }

    return Column(
      children: filteredExercises.map((exercise) {
        final exerciseName = exercise['name'];
        final isFavorite = favorites.contains(exerciseName);

        return Column(
          children: [
            Card(
              child: ListTile(
                onTap: () => {},
                title: Text(
                  exerciseName ?? 'Unknown',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Category: ${exercise['category'] ?? 'No category.'}\n'
                  'Description: ${exercise['description'] ?? 'No description.'}\n'
                  'Video: ${exercise['video'] ?? 'No video.'}\n',
                ),
                trailing: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () => onToggleFavorite(exerciseName),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
      }).toList(),
    );
  }
}
