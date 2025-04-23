import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/core/screens/dashboard/categories_page.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:fit_office/src/features/core/controllers/db_controller.dart';
import 'package:get/get.dart';
import 'package:string_similarity/string_similarity.dart';

import '../../../../authentication/models/user_model.dart';
import '../../../controllers/profile_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../models/dashboard/categories_model.dart';
import '../exercise_filter.dart';
import 'exercises_list.dart';
import 'sections/physicals_filter.dart';
import 'sections/mental_filter.dart';
import 'sections/favorites_filter.dart';

class DashboardCategories extends StatefulWidget {
  const DashboardCategories({
    super.key,
    required this.txtTheme,
    required this.onSearchChanged,
    this.forceShowExercisesOnly = false,
    this.onReturnedFromFilter,
  });

  final VoidCallback? onReturnedFromFilter;
  final TextTheme txtTheme;
  final void Function(String) onSearchChanged;
  final bool forceShowExercisesOnly;

  @override
  State<DashboardCategories> createState() => DashboardCategoriesState();
}

class DashboardCategoriesState extends State<DashboardCategories> {
  final DbController _dbController = DbController();
  final ProfileController _profileController = Get.put(ProfileController());

  String upperBodyCount = '';
  String lowerBodyCount = '';
  String fullBodyCount = '';
  String psychologicalCount = '';
  String favoriteCount = '';

  List<Map<String, dynamic>> _allExercises = [];
  List<Map<String, dynamic>> _filteredExercises = [];
  List<String> _userFavorites = [];

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadExerciseCount();
    _loadAllExercises();
    _loadUserFavorites();
  }

  void _loadExerciseCount() async {
    String countUpperBody =
        await _dbController.getNumberOfExercisesByCategory(tUpperBody);
    String countLowerBody =
        await _dbController.getNumberOfExercisesByCategory(tLowerBody);
    String countFullBody =
        await _dbController.getNumberOfExercisesByCategory(tFullBody);
    String countPsychological =
        await _dbController.getNumberOfExercisesByCategory(tMind);

    setState(() {
      upperBodyCount = "$countUpperBody $tDashboardExerciseUnits";
      lowerBodyCount = "$countLowerBody $tDashboardExerciseUnits";
      fullBodyCount = "$countFullBody $tDashboardExerciseUnits";
      psychologicalCount = "$countPsychological $tDashboardExerciseUnits";
    });
  }

  void _loadAllExercises() async {
    final all = await _dbController.getAllExercises();
    setState(() {
      _allExercises = all;
      _filteredExercises = _filterExercises(_searchQuery, all); // <- wichtig!
    });
  }

  void _loadUserFavorites() async {
    final user = await _profileController.getUserData();
    final userFavorites = await _dbController.getFavouriteExercises(user.email);
    final favoriteNames =
        userFavorites.map((e) => e['name'] as String).toList();

    setState(() {
      _userFavorites = favoriteNames;
      favoriteCount = "${favoriteNames.length} $tDashboardExerciseUnits";
    });
  }

  void _toggleFavorite(String exerciseName) async {
    final user = await _profileController.getUserData();
    final isFavorite = _userFavorites.contains(exerciseName);

    if (isFavorite) {
      await _dbController.removeFavorite(user.email, exerciseName);
    } else {
      await _dbController.addFavorite(user.email, exerciseName);
    }

    _loadUserFavorites();
  }

  List<Map<String, dynamic>> _filterExercises(
      String query, List<Map<String, dynamic>> exercises) {
    if (query.trim().isEmpty) return exercises;
    final lower = query.toLowerCase();

    return exercises.where((exercise) {
      final name = (exercise['name'] ?? '').toString().toLowerCase();
      final desc = (exercise['description'] ?? '').toString().toLowerCase();

      if (query.length == 1) {
        return name.startsWith(lower) || desc.startsWith(lower);
      }

      final nameSimilarity = name.similarityTo(lower);
      final descSimilarity = desc.similarityTo(lower);

      return name.startsWith(lower) ||
          desc.startsWith(lower) ||
          name.contains(lower) ||
          desc.contains(lower) ||
          nameSimilarity > 0.4 ||
          descSimilarity > 0.4;
    }).toList();
  }

  void updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      _filteredExercises = _filterExercises(query, _allExercises);
    });

    widget.onSearchChanged(query);
  }

  void refreshData() {
    _loadUserFavorites();
    _loadAllExercises();
  }

  @override
  Widget build(BuildContext context) {
    bool shouldShowOnlyExercises =
        _searchQuery.trim().isNotEmpty || widget.forceShowExercisesOnly;

    if (shouldShowOnlyExercises) {
      return AllExercisesList(
        exercises: _filteredExercises,
        favorites: _userFavorites,
        onToggleFavorite: _toggleFavorite,
        query: _searchQuery,
      );
    }

    final list = [
      DashboardCategoriesModel(
        tAbbreviationUpperBody,
        tUpperBody,
        upperBodyCount,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ExerciseFilter(
              category: tUpperBody,
              heading: tUpperBody,
            ),
          ),
        ).then((_) {
          _loadUserFavorites();
          _loadAllExercises();
          widget.onReturnedFromFilter?.call();
        }),
      ),
      DashboardCategoriesModel(
        tAbbreviationLowerBody,
        tLowerBody,
        lowerBodyCount,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ExerciseFilter(
              category: tLowerBody,
              heading: tLowerBody,
            ),
          ),
        ).then((_) {
          _loadUserFavorites();
          _loadAllExercises();
          widget.onReturnedFromFilter?.call();
        }),
      ),
      DashboardCategoriesModel(
        tAbbreviationFullBody,
        tFullBody,
        fullBodyCount,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ExerciseFilter(
              category: tFullBody,
              heading: tFullBody,
            ),
          ),
        ).then((_) {
          _loadUserFavorites();
          _loadAllExercises();
          widget.onReturnedFromFilter?.call();
        }),
      ),
    ];

    final listPsychologicalExercises = [
      DashboardCategoriesModel("🧠", tAbbreviationMind, psychologicalCount, () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CategoriesPage(category: "mental", heading: "Geist"),
        ),
      ),),
    ];

    final listFavouriteExercises = [
      DashboardCategoriesModel(
        tAbbreviationFavorites,
        tFavorites,
        favoriteCount,
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ExerciseFilter(
                heading: tFavorites,
                showOnlyFavorites: true,
              ),
            ),
          ).then((_) {
            _loadUserFavorites();
            _loadAllExercises();
            widget.onReturnedFromFilter?.call();
          });
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          tDashboardPhysicalExercisesTitle,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        DashboardPhysicalSection(
          categories: list,
          txtTheme: widget.txtTheme,
        ),
        const SizedBox(height: 20),
        const Text(
          tDashboardPsychologicalExercisesTitle,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        DashboardMentalSection(
          categories: listPsychologicalExercises,
          txtTheme: widget.txtTheme,
        ),
        const SizedBox(height: 20),
        const Text(
          tDashboardFavouriteExercises,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        DashboardFavoritesSection(
          categories: listFavouriteExercises,
          txtTheme: widget.txtTheme,
        ),
        const SizedBox(height: 20),
        const Text(
          tDashboardAllExercises,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        AllExercisesList(
          exercises: _filteredExercises,
          favorites: _userFavorites,
          onToggleFavorite: _toggleFavorite,
          query: _searchQuery,
        ),
      ],
    );
  }
}