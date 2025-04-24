import 'package:fit_office/src/features/core/screens/dashboard/widgets/view_exercise.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/core/controllers/exercise_timer.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/start_exercise.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/active_dialog.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:fit_office/src/constants/colors.dart';

class FullWidthDivider extends StatelessWidget {
  const FullWidthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: MediaQuery.of(context).size.width,
      height: 1.8,
      color: const Color.fromARGB(255, 200, 200, 200),
    );
  }
}

class AllExercisesList extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;
  final List<String> favorites;
  final void Function(String exerciseName) onToggleFavorite;
  final String query;
  final bool showGroupedAlphabetically;

  const AllExercisesList({
    super.key,
    required this.exercises,
    required this.favorites,
    required this.onToggleFavorite,
    required this.query,
    this.showGroupedAlphabetically = true,
  });

  @override
  Widget build(BuildContext context) {
    final lowerQuery = query.toLowerCase().trim();
    final isFiltered = lowerQuery.isNotEmpty;

    // Bei Filter/Suche: einfach alphabetisch sortieren (aber ohne Gruppierung!)
    final List<Map<String, dynamic>> sortedList =
        List<Map<String, dynamic>>.from(isFiltered || !showGroupedAlphabetically
            ? _filtered(exercises, lowerQuery)
            : exercises);

    sortedList.sort((a, b) =>
        (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));

    final List<Widget> listWidgets = [];

    if (sortedList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(tDashboardExerciseNotFound),
      );
    }

    if (isFiltered || !showGroupedAlphabetically) {
      // Keine Buchstabenüberschrift – einfach sortieren und soft-dividern
      for (int i = 0; i < sortedList.length; i++) {
        listWidgets.add(_buildExerciseCard(context, sortedList[i]));
        if (i < sortedList.length - 1) listWidgets.add(_buildSoftDivider());
      }
    } else {
      // Gruppierung nach Buchstaben mit fetten Dividern
      String lastLetter = '';
      List<Map<String, dynamic>> buffer = [];

      void flush(String tag) {
        listWidgets.add(const SizedBox(height: 16));
        listWidgets.add(_buildHeader(tag));
        listWidgets.add(_buildFullDivider());

        for (int i = 0; i < buffer.length; i++) {
          listWidgets.add(_buildExerciseCard(context, buffer[i]));
          listWidgets.add(i == buffer.length - 1
              ? _buildFullDivider()
              : _buildSoftDivider());
        }
        buffer.clear();
      }

      for (final exercise in sortedList) {
        final name = (exercise['name'] ?? '').toString();
        if (name.isEmpty) continue;
        final firstLetter = name[0].toUpperCase();

        if (firstLetter != lastLetter) {
          if (buffer.isNotEmpty) flush(lastLetter);
          lastLetter = firstLetter;
        }

        buffer.add(exercise);
      }

      if (buffer.isNotEmpty) flush(lastLetter);
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: listWidgets,
    );
  }

  List<Map<String, dynamic>> _filtered(
      List<Map<String, dynamic>> list, String query) {
    return list.where((exercise) {
      final name = (exercise['name'] ?? '').toString().toLowerCase();
      final desc = (exercise['description'] ?? '').toString().toLowerCase();
      return name.contains(query) ||
          desc.contains(query) ||
          name.similarityTo(query) > 0.4 ||
          desc.similarityTo(query) > 0.4;
    }).toList();
  }

  Widget _buildHeader(String letter) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(letter,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      );

  Widget _buildFullDivider() => const FullWidthDivider();

  Widget _buildSoftDivider() => const Divider(
        thickness: 0.6,
        color: Color.fromARGB(255, 200, 200, 200),
        indent: 12,
        endIndent: 12,
      );

  Widget _buildExerciseCard(
      BuildContext context, Map<String, dynamic> exercise) {
    final exerciseName = exercise['name'];
    final exerciseCategory = exercise['category'];
    final isFavorite = favorites.contains(exerciseName);
    final timerController = Get.find<ExerciseTimerController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Material(
        color: tWhiteColor,
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          highlightColor: Colors.grey.shade300,
          splashColor: Colors.grey.shade300,
          onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExerciseDetailScreen(exerciseData: exercise),
            ),
          );
        },
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            title: Text(exerciseName ?? 'Unknown',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            subtitle: Text(exerciseCategory ?? 'No category',
                style: const TextStyle(fontSize: 13, color: Color(0xFF777777))),
            trailing: IntrinsicWidth(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    color: Colors.grey[800],
                    onPressed: () async {
                      if (timerController.isRunning.value ||
                          timerController.isPaused.value) {
                        await showDialog(
                          context: Get.context!,
                          barrierDismissible: false,
                          builder: (_) => const ActiveTimerDialog(),
                        );
                        return;
                      }
                      final confirmed = await showDialog<bool>(
                        context: Get.context!,
                        barrierDismissible: false,
                        builder: (_) => StartExerciseDialog(
                            exerciseName: exerciseName ?? 'Unknown'),
                      );
                      if (confirmed == true) {
                        timerController.start(exerciseName, exerciseCategory);
                        Navigator.of(Get.context!)
                            .popUntil((route) => route.isFirst);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => onToggleFavorite(exerciseName),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
