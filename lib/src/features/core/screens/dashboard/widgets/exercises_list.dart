import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/authentication/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/features/core/controllers/exercise_timer.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/start_exercise.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/active_dialog.dart';

import '../../../controllers/profile_controller.dart';
import '../../profile/admin/delete_exercise.dart';
import '../../profile/admin/edit_exercise.dart';

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
      final description = (exercise['description'] ?? '')
          .toString()
          .toLowerCase();
      final nameSimilarity = name.similarityTo(lowerQuery);
      final descriptionSimilarity = description.similarityTo(lowerQuery);

      return name.contains(lowerQuery) ||
          description.contains(lowerQuery) ||
          nameSimilarity > 0.4 ||
          descriptionSimilarity > 0.4;
    }).toList();

    if (filteredExercises.isEmpty) {
      return const Text(tDashboardExerciseNotFound);
    }

    final timerController = Get.find<ExerciseTimerController>();

    return FutureBuilder<UserModel?>(
      future: ProfileController().getUserData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;
        final isAdmin = user?.role == 'admin';

        return Column(
          children: filteredExercises.map((exercise) {
            final exerciseName = exercise['name'];
            final exerciseCategory = exercise['category'];
            final isFavorite = favorites.contains(exerciseName);

            return Column(
              children: [
                Card(
                  child: ListTile(
                    title: Text(
                      exerciseName ?? 'Unknown',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Category: ${exercise['category'] ??
                        'No category.'}'),
                    trailing: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: IntrinsicWidth(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.play_arrow),
                              color: Colors.grey,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () async {
                                if (timerController.isRunning.value ||
                                    timerController.isPaused.value) {
                                  await showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) => const ActiveTimerDialog(),
                                  );
                                  return;
                                }

                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) =>
                                      StartExerciseDialog(
                                        exerciseName: exerciseName ??
                                            'Unknown exercise',
                                      ),
                                );

                                if (confirmed == true) {
                                  timerController.start(
                                      exerciseName, exerciseCategory);
                                  Navigator.of(context).popUntil((
                                      route) => route.isFirst);
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons
                                    .favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => onToggleFavorite(exerciseName),
                            ),
                            if (isAdmin) ...[
                              IconButton(
                                icon: const Icon(
                                    Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditExercise(
                                            exercise: exercise,
                                            exerciseName: exercise['name'],
                                          ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.delete, color: Colors.red),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DeleteExercise(
                                            exercise: exercise,
                                            exerciseName: exercise['name'],
                                          ),
                                    ),
                                  );
                                },
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
