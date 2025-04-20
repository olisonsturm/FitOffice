import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/core/controllers/db_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/appbar.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/exercises_list.dart';

import '../../../authentication/models/user_model.dart';
import '../../controllers/profile_controller.dart';

class FavoritesPage extends StatefulWidget {
  final String category;
  final String heading;

  const FavoritesPage({
    super.key,
    required this.category,
    required this.heading,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPage();
}

class _FavoritesPage extends State<FavoritesPage> {
  List<Map<String, dynamic>> _searchResults = [];
  List<String> _userFavorites = [];
  final ProfileController _profileController = Get.put(ProfileController());
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUserAndFavorites();
  }

  void _loadUserAndFavorites() async {
    final user = await _profileController.getUserData();
    final dbController = DbController();

    final favorites = await dbController.getFavouriteExercises(user.email);
    final favoriteNames = favorites.map((e) => e['name'] as String).toList();

    setState(() {
      _user = user;
      _searchResults = favorites;
      _userFavorites = favoriteNames;
    });
  }

  void _toggleFavorite(String exerciseName) async {
    if (_user == null) return;

    final dbController = DbController();
    final isFavorite = _userFavorites.contains(exerciseName);

    if (isFavorite) {
      await dbController.removeFavorite(_user!.email, exerciseName);
    } else {
      await dbController.addFavorite(_user!.email, exerciseName);
    }

    _loadUserAndFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TimerAwareAppBar(
        normalAppBar: AppBar(
          title: const Text(tFavorites),
          backgroundColor: Colors.grey,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _searchResults.isEmpty
            ? const Text(tDashboardNoResultsFound)
            : AllExercisesList(
                exercises: _searchResults,
                favorites: _userFavorites,
                onToggleFavorite: _toggleFavorite,
                query: "", 
              ),
      ),
    );
  }
}
