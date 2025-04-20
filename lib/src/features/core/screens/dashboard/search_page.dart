import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/core/controllers/db_controller.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/search.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/exercises_list.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/appbar.dart';

import '../../../authentication/models/user_model.dart';
import '../../controllers/profile_controller.dart';

class SearchPage extends StatefulWidget {
  final String query;
  const SearchPage({super.key, required this.query});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> _searchResults = [];
  final ProfileController _profileController = ProfileController();
  List<String> _userFavorites = [];
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _performSearch(widget.query);
    _loadUserAndSearch(widget.query);
  }

  void _performSearch(String query) async {
    final dbController = DbController();
    final results = await dbController.getExercises(query);
    setState(() {
      _searchResults = results;
    });
  }

  void _loadUserAndSearch(String query) async {
    _user = await _profileController.getUserData();
    final dbController = DbController();
    final results = await dbController.getExercises(query);
    final favorites = await dbController.getFavouriteExercises(_user!.email);

    setState(() {
      _searchResults = results;
      _userFavorites = favorites.map((e) => e['name'] as String).toList();
    });
  }

  void _toggleFavorite(String exerciseName) async {
    final dbController = DbController();
    if (_user == null) return;

    final isFavorite = _userFavorites.contains(exerciseName);

    if (isFavorite) {
      await dbController.removeFavorite(_user!.email, exerciseName);
    } else {
      await dbController.addFavorite(_user!.email, exerciseName);
    }

    final favorites = await dbController.getFavouriteExercises(_user!.email);
    setState(() {
      _userFavorites = favorites.map((e) => e['name'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TimerAwareAppBar(
        normalAppBar: AppBar(
          title: const Text(tDashboardSearch),  //den Text evtl anpassen was größe etc angeht...
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: _searchResults.isEmpty
                  ? const Text(tDashboardNoResultsFound)
                  : AllExercisesList(
                      exercises: _searchResults,
                      favorites: _userFavorites,
                      onToggleFavorite: _toggleFavorite,
                      query: widget.query,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
