import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/core/screens/dashboard/categories_page.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/features/core/controllers/db_controller.dart';
import 'package:get/get.dart';

import '../../../../authentication/models/user_model.dart';
import '../../../controllers/db_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../models/dashboard/categories_model.dart';
import '../favorites_page.dart';
import 'exercises_list.dart';

class DashboardCategories extends StatefulWidget {
  const DashboardCategories({
    super.key,
    required this.txtTheme,
    required this.onSearchChanged, // NEU
  });

  final TextTheme txtTheme;
  final void Function(String) onSearchChanged; // NEU

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
        await _dbController.getNumberOfExercisesByCategory('upper-body');
    String countLowerBody =
        await _dbController.getNumberOfExercisesByCategory('lower-body');
    String countFullBody =
        await _dbController.getNumberOfExercisesByCategory('full-body');
    String countPsychological =
        await _dbController.getNumberOfExercisesByCategory('mental');

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
      _filteredExercises = _filterExercises(_searchQuery, all);
    });
  }

  void _loadUserFavorites() async {
    final user = await _profileController.getUserData();
    final userFavorites = await _dbController.getFavouriteExercises(user.email);

    setState(() {
      _userFavorites = userFavorites.map((e) => e['name'] as String).toList();
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
      return name.contains(lower) || desc.contains(lower);
    }).toList();
  }

  void updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      _filteredExercises = _filterExercises(query, _allExercises);
    });

    widget.onSearchChanged(
        query); // Optional, falls man es wieder zurückreichen möchte
  }

  @override
  Widget build(BuildContext context) {
    final list = [
      DashboardCategoriesModel(
        "UB",
        tDasboardUpperBody,
        upperBodyCount,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CategoriesPage(
              category: "upper-body",
              heading: "Oberkörper",
            ),
          ),
        ).then((_) {
          _loadUserFavorites();
          _loadAllExercises();
        }),
      ),
      DashboardCategoriesModel(
        "LB",
        tDashboardLowerBody,
        lowerBodyCount,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CategoriesPage(
              category: "lower-body",
              heading: "Unterkörper",
            ),
          ),
        ).then((_) {
          _loadUserFavorites();
          _loadAllExercises();
        }),
      ),
      DashboardCategoriesModel(
        "CB",
        tDashboardCompleteBody,
        fullBodyCount,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CategoriesPage(
              category: "complete-body",
              heading: "Ganzkörper",
            ),
          ),
        ).then((_) {
          _loadUserFavorites();
          _loadAllExercises();
        }),
      ),
    ];

    final listPsychologicalExercises = [
      DashboardCategoriesModel(
        "🧠",
        tDashboardMind,
        psychologicalCount,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CategoriesPage(
              category: "mental",
              heading: "Geist",
            ),
          ),
        ).then((_) {
          _loadUserFavorites();
          _loadAllExercises();
        }),
      ),
    ];

    final listFavouriteExercises =
        DashboardCategoriesModel.listFavouriteExercises;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          tDashboardPhysicalExercisesTitle,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // Körperliche Übungen (horizontal)
        SizedBox(
          height: 45,
          child: ListView.builder(
            itemCount: list.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => GestureDetector(
              onTap: list[index].onPress,
              child: SizedBox(
                width: 170,
                height: 45,
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: tDarkColor,
                      ),
                      child: Center(
                        child: Text(
                          list[index].title,
                          style: widget.txtTheme.titleLarge
                              ?.apply(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            list[index].heading,
                            style: widget.txtTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            list[index].subHeading,
                            style: widget.txtTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          tDashboardPsychologicalExercisesTitle,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 45,
          child: ListView.builder(
            itemCount: listPsychologicalExercises.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => GestureDetector(
              onTap: listPsychologicalExercises[index].onPress,
              child: SizedBox(
                width: 170,
                height: 45,
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: tDarkColor,
                      ),
                      child: Center(
                        child: Text(
                          listPsychologicalExercises[index].title,
                          style: widget.txtTheme.titleLarge
                              ?.apply(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            listPsychologicalExercises[index].heading,
                            style: widget.txtTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            listPsychologicalExercises[index].subHeading,
                            style: widget.txtTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          tDashboardFavouriteExercises,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 45,
          child: ListView.builder(
            itemCount: listFavouriteExercises.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesPage(
                      category: "favorites",
                      heading: "Favorites",
                    ),
                  ),
                ).then((_) {
                  _loadUserFavorites();
                  _loadAllExercises();
                });
              },
              child: SizedBox(
                width: 170,
                height: 45,
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: tDarkColor,
                      ),
                      child: Center(
                        child: Text(
                          listFavouriteExercises[index].title,
                          style: widget.txtTheme.titleLarge
                              ?.apply(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            listFavouriteExercises[index].heading,
                            style: widget.txtTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            listFavouriteExercises[index].subHeading,
                            style: widget.txtTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          tDashboardAllExercises,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        AllExercisesList(
          exercises: _allExercises,
          favorites: _userFavorites,
          onToggleFavorite: _toggleFavorite,
          query: _searchQuery,
        ),
      ],
    );
  }
}
