import 'package:fit_office/src/features/core/screens/libary/library_screen.dart';
import 'package:fit_office/src/features/core/screens/progress/progress_screen.dart';
import 'package:fit_office/src/features/core/screens/statistics/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/appbar.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/categories.dart';
import 'package:fit_office/src/features/core/screens/profile/profile_screen.dart';

import '../../controllers/db_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/statistics_controller.dart';
import 'exercise_filter.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  final GlobalKey<DashboardCategoriesState> _categoriesKey =
      GlobalKey<DashboardCategoriesState>();
  final ProfileController _profileController = Get.put(ProfileController());
  final DbController _dbController = DbController();

  int _selectedIndex = 0;
  String favoriteCount = '';

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Progress';
      case 1:
        return 'Library';
      case 2:
        return 'Statistics';
      case 3:
        return 'Profile';
      default:
        return '';
    }
  }

  void _loadUserFavorites() async {
    final user = await _profileController.getUserData();
    final userFavorites = await _dbController.getFavouriteExercises(user.email);
    final favoriteNames =
        userFavorites.map((e) => e['name'] as String).toList();

    setState(() {
      favoriteCount = "${favoriteNames.length} ${AppLocalizations.of(context)!.tDashboardExerciseUnits}";
    });
  }

  final StreakController _streakController = Get.put(StreakController());

  @override
  void initState() {
    super.initState();
    _streakController.loadStreakData();
    _loadUserFavorites();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SliderAppBar(
        title: _getPageTitle(),
        showBackButton: false,
        showDarkModeToggle: true,
        showStreak: true,
        showFavoriteIcon: true,
        subtitle: 'FitOffice@DHBW',
        onToggleFavorite: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseFilter(
                heading: AppLocalizations.of(context)!.tFavorites,
                showOnlyFavorites: true,
              ),
            ),
          ).then((_) {
            _loadUserFavorites();
            _categoriesKey.currentState?.refreshData();
          });
        },
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              // 0: Progress Screen
              ProgressScreen(),

              // 1: Exercise Library TODO: Add Obx() support to update User Infos directly as Olison in ProfilScreen did.
              LibraryScreen(),

              // 2: Statistics Screen
              StatisticScreen(),

              // 3: Friends
              ProfileScreen(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          FocusScope.of(context)
              .unfocus(); // <-- Fokus entfernen bei Navigation
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: tBottomNavBarSelectedColor,
        unselectedItemColor: tBottomNavBarUnselectedColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.route),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
