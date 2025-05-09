// ... deine bestehenden Imports ...
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:fit_office/src/constants/colors.dart';
import '../../../../../utils/helper/dialog_helper.dart';
import '../../../controllers/profile_controller.dart';
import '../../profile/admin/delete_exercise.dart';
import '../../profile/admin/edit_exercise.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/view_exercise.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/start_exercise.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/active_dialog.dart';
import 'package:fit_office/src/features/authentication/models/user_model.dart';
import '../../../controllers/exercise_timer.dart';
import 'package:fit_office/src/constants/text_strings.dart';

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

class FavoriteIcon extends StatelessWidget {
  final bool isInitiallyFavorite;
  final bool isProcessing;
  final VoidCallback onToggle;

  const FavoriteIcon({
    super.key,
    required this.isInitiallyFavorite,
    required this.isProcessing,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isInitiallyFavorite ? Icons.favorite : Icons.favorite_border,
        color: isInitiallyFavorite ? Colors.red : Colors.grey,
      ),
      onPressed: isProcessing ? null : onToggle,
    );
  }
}

class AllExercisesList extends StatefulWidget {
  final List<Map<String, dynamic>> exercises;
  final List<String> favorites;
  final Future<void> Function(String exerciseName) onToggleFavorite;
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
  State<AllExercisesList> createState() => _AllExercisesListState();
}

class _AllExercisesListState extends State<AllExercisesList> {
  final Map<String, bool> _isProcessingFavorite = {};

  Future<void> _toggleFavorite(String exerciseName) async {
    if (_isProcessingFavorite[exerciseName] == true) return;

    setState(() {
      _isProcessingFavorite[exerciseName] = true;
    });

    try {
      await widget.onToggleFavorite(exerciseName);
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(tUpdateFavoriteException)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingFavorite[exerciseName] = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lowerQuery = widget.query.toLowerCase().trim();
    final isFiltered = lowerQuery.isNotEmpty;

    final List<Map<String, dynamic>> sortedList =
    List<Map<String, dynamic>>.from(isFiltered || !widget.showGroupedAlphabetically
        ? _filtered(widget.exercises, lowerQuery)
        : widget.exercises);

    sortedList.sort((a, b) =>
        (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));

    return FutureBuilder<UserModel?>(
      future: ProfileController().getUserData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;
        final isAdmin = user?.role == 'admin';

        final List<Widget> listWidgets = [];

        if (sortedList.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(tDashboardExerciseNotFound),
          );
        }

        if (isFiltered || !widget.showGroupedAlphabetically) {
          for (int i = 0; i < sortedList.length; i++) {
            listWidgets.add(_buildExerciseCard(context, sortedList[i], isAdmin));
            if (i < sortedList.length - 1) listWidgets.add(const Divider());
          }
        } else {
          String lastLetter = '';
          List<Map<String, dynamic>> buffer = [];

          void flush(String tag) {
            listWidgets.add(const SizedBox(height: 16));
            listWidgets.add(_buildHeader(tag));
            listWidgets.add(const Divider());

            for (int i = 0; i < buffer.length; i++) {
              listWidgets.add(_buildExerciseCard(context, buffer[i], isAdmin));
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
      },
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

  Widget _buildExerciseCard(
      BuildContext context, Map<String, dynamic> exercise, bool isAdmin) {
    final exerciseName = exercise['name'];
    final exerciseCategory = exercise['category'];
    final timerController = Get.find<ExerciseTimerController>();
    final isFavorite = widget.favorites.contains(exerciseName);
    final isProcessing = _isProcessingFavorite[exerciseName] ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Material(
        color: isDark ? Colors.grey[800] : tWhiteColor,
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          highlightColor: Colors.grey.shade300,
          splashColor: Colors.grey.shade300,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExerciseDetailScreen(exerciseData: exercise, isFavorite: isFavorite),
              ),
            );

            if (result == true) {
              _toggleFavorite(exerciseName);
            }
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
                        await showUnifiedDialog<void>(
                          context: context,
                          builder: (ctx) =>
                              ActiveTimerDialog.forAction('start'),
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
                  FavoriteIcon(
                    isInitiallyFavorite: isFavorite,
                    isProcessing: isProcessing,
                    onToggle: () => _toggleFavorite(exerciseName),
                  ),
                  if (isAdmin) ...[
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditExercise(
                              exercise: exercise,
                              exerciseName: exercise['name'],
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DeleteExerciseDialog(
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
    );
  }
}
