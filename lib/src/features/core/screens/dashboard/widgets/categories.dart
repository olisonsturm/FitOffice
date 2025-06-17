import 'package:fit_office/l10n/app_localizations.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/sections/favorites_filter.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/sections/mental_filter.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/sections/physicals_filter.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/src/features/core/controllers/db_controller.dart';
import 'package:get/get.dart';
import 'package:string_similarity/string_similarity.dart';

import '../../../../../constants/text_strings.dart';
import '../../../controllers/profile_controller.dart';
import '../../../models/dashboard/categories_model.dart';
import '../exercise_filter.dart';
import 'exercises_list.dart';

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
      upperBodyCount = "$countUpperBody ${AppLocalizations.of(context)!.tDashboardExerciseUnits}";
      lowerBodyCount = "$countLowerBody ${AppLocalizations.of(context)!.tDashboardExerciseUnits}";
      fullBodyCount = "$countFullBody ${AppLocalizations.of(context)!.tDashboardExerciseUnits}";
      psychologicalCount = "$countPsychological ${AppLocalizations.of(context)!.tDashboardExerciseUnits}";
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
      favoriteCount = "${favoriteNames.length} ${AppLocalizations.of(context)!.tDashboardExerciseUnits}";
    });
  }

  Future<void> _toggleFavorite(String exerciseName) async {
    final isFavorite = _userFavorites.contains(exerciseName);
    final user = await _profileController.getUserData();

    setState(() {
      if (isFavorite) {
        _userFavorites.remove(exerciseName);
      } else {
        _userFavorites.add(exerciseName);
      }
      favoriteCount = "${_userFavorites.length} ${AppLocalizations.of(context)!.tDashboardExerciseUnits}";
    });

    try {
      if (isFavorite) {
        await _dbController.removeFavorite(user.email, exerciseName);
      } else {
        await _dbController.addFavorite(user.email, exerciseName);
      }
    } catch (e) {
      setState(() {
        if (isFavorite) {
          _userFavorites.add(exerciseName);
        } else {
          _userFavorites.remove(exerciseName);
        }
        favoriteCount = "${_userFavorites.length} ${AppLocalizations.of(context)!.tDashboardExerciseUnits}";
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.tUpdateFavoriteException)),
        );
      }
    }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (shouldShowOnlyExercises) {
      return AllExercisesList(
        exercises: _filteredExercises,
        favorites: _userFavorites,
        onToggleFavorite: _toggleFavorite,
        query: _searchQuery,
        showGroupedAlphabetically: false,
      );
    }

    final list = [
      DashboardCategoriesModel(
        AppLocalizations.of(context)!.tAbbreviationUpperBody,
        AppLocalizations.of(context)!.tUpperBody,
        upperBodyCount,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseFilter(
              category: tUpperBody,
              heading: AppLocalizations.of(context)!.tUpperBody,
            ),
          ),
        ).then((_) {
          _loadUserFavorites();
          _loadAllExercises();
          widget.onReturnedFromFilter?.call();
        }),
      ),
      DashboardCategoriesModel(
        AppLocalizations.of(context)!.tAbbreviationLowerBody,
        AppLocalizations.of(context)!.tLowerBody,
        lowerBodyCount,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseFilter(
              category: tLowerBody,
              heading: AppLocalizations.of(context)!.tLowerBody,
            ),
          ),
        ).then((_) {
          _loadUserFavorites();
          _loadAllExercises();
          widget.onReturnedFromFilter?.call();
        }),
      ),
      DashboardCategoriesModel(
        AppLocalizations.of(context)!.tAbbreviationFullBody,
        AppLocalizations.of(context)!.tFullBody,
        fullBodyCount,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseFilter(
              category: tFullBody,
              heading: AppLocalizations.of(context)!.tFullBody,
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
      DashboardCategoriesModel(
        AppLocalizations.of(context)!.tAbbreviationMind,
        AppLocalizations.of(context)!.tMind,
        psychologicalCount,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseFilter(
              category: tMind,
              heading: AppLocalizations.of(context)!.tMind,
            ),
          ),
        ).then((_) {
          _loadUserFavorites();
          _loadAllExercises();
          widget.onReturnedFromFilter?.call();
        }),
      ),
    ];

    final listFavouriteExercises = [
      DashboardCategoriesModel(
        AppLocalizations.of(context)!.tAbbreviationFavorites,
        AppLocalizations.of(context)!.tFavorites,
        favoriteCount,
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseFilter(
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
        Text(
          AppLocalizations.of(context)!.tDashboardPhysicalExercisesTitle,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? widget.txtTheme.bodyLarge?.color : Colors.black),
        ),
        const SizedBox(height: 10),
        DashboardPhysicalSection(
          categories: list,
          txtTheme: widget.txtTheme,
        ),
        const SizedBox(height: 20),
        Text(
          AppLocalizations.of(context)!.tDashboardPsychologicalExercisesTitle,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? widget.txtTheme.bodyLarge?.color : Colors.black),
        ),
        const SizedBox(height: 10),
        DashboardMentalSection(
          categories: listPsychologicalExercises,
          txtTheme: widget.txtTheme,
        ),
        const SizedBox(height: 20),
        Text(
          AppLocalizations.of(context)!.tDashboardFavouriteExercises,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? widget.txtTheme.bodyLarge?.color : Colors.black),
        ),
        const SizedBox(height: 10),
        DashboardFavoritesSection(
          categories: listFavouriteExercises,
          txtTheme: widget.txtTheme,
        ),
        const SizedBox(height: 20),
        Text(
          AppLocalizations.of(context)!.tDashboardAllExercises,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? widget.txtTheme.bodyLarge?.color : Colors.black),
        ),
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
