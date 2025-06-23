import 'package:fit_office/l10n/app_localizations.dart';
import 'package:fit_office/src/features/core/controllers/db_controller.dart';
import 'package:fit_office/src/features/core/controllers/profile_controller.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/appbar.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/exercises_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../authentication/models/user_model.dart';

/// A page that displays a filtered list of exercises.
/// Either shows exercises from a specific category **or** only the user's favorites.
/// Users can directly toggle the favorite status from the list.
class ExerciseFilter extends StatefulWidget {
  final String heading;
  final String? category; // z. B. 'Upper Body'
  final bool showOnlyFavorites;

  const ExerciseFilter({
    super.key,
    required this.heading,
    this.category,
    this.showOnlyFavorites = false,
  });

  @override
  State<ExerciseFilter> createState() => _ExerciseFilterState();
}

class _ExerciseFilterState extends State<ExerciseFilter> {
  final ProfileController _profileController = Get.put(ProfileController());
  final DbController _dbController = DbController();
  List<Map<String, dynamic>> _exercises = [];
  List<String> _userFavorites = [];
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    /// Validation: A category must NOT be provided when showing only favorites.
    assert(
      !(widget.showOnlyFavorites && widget.category != null),
      'Do not provide a category when showOnlyFavorites is true.',
    );

    _loadUserAndExercises();
  }

  /// Loads current user data and fetches filtered exercises from the database.
  Future<void> _loadUserAndExercises() async {
    setState(() => _isLoading = true);

    final user = await _profileController.getUserData();
    _user = user;

    final result = await _dbController.getFilteredExercises(
      email: user.email,
      category: widget.category,
      onlyFavorites: widget.showOnlyFavorites,
    );

    if (!mounted) return; 

    setState(() {
      _exercises = List<Map<String, dynamic>>.from(result['exercises']);
      _userFavorites = List<String>.from(result['favorites']);
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite(String exerciseName) async {
    if (_user == null) return;

    final isFavorite = _userFavorites.contains(exerciseName);

    await _dbController.toggleFavorite(
      email: _user!.email,
      exerciseName: exerciseName,
      isCurrentlyFavorite: isFavorite,
    );

    await _loadUserAndExercises(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SliderAppBar(
        title: widget.heading,
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            // 1. Übungen (sichtbar, sobald geladen)
            Visibility(
              visible: !_isLoading && _exercises.isNotEmpty,
              child: AllExercisesList(
                exercises: _exercises,
                favorites: _userFavorites,
                onToggleFavorite: _toggleFavorite,
                query: "",
                showGroupedAlphabetically: false,
              ),
            ),

            // 2. Hinweis, wenn nichts gefunden wurde
            Visibility(
              visible: !_isLoading && _exercises.isEmpty,
              child: Center(
                child: Text(AppLocalizations.of(context)!.tDashboardNoResultsFound),
              ),
            ),

            // 3. Optionale Ladeanzeige (nicht notwendig, aber falls du willst)
            // Sichtbar NUR während des Ladens – sonst unsichtbar
            if (_isLoading)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SizedBox.shrink(), // oder: kleine Loader-Leiste
              ),
          ],
        ),
      ),
    );
  }
}