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
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

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
  final GlobalKey _progressTabKey = GlobalKey();
  final GlobalKey _libraryTabKey = GlobalKey();
  final GlobalKey _statisticsTabKey = GlobalKey();
  final GlobalKey _profileTabKey = GlobalKey();
  List<TargetFocus> targets = [];

  int _selectedIndex = 0;
  String favoriteCount = '';

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return AppLocalizations.of(context)!.tProgress;
      case 1:
        return AppLocalizations.of(context)!.tLibrary;
      case 2:
        return AppLocalizations.of(context)!.tStatistics;
      case 3:
        return AppLocalizations.of(context)!.tProfile;
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

  void checkAndStartTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial = prefs.getBool('seenTutorial') ?? false;

    if (!hasSeenTutorial) {
      _initTargets();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        TutorialCoachMark(
          targets: targets,
          alignSkip: Alignment.bottomRight,
          onFinish: () {
            prefs.setBool('seenTutorial', true);
          },
          onClickTarget: (target) {},
          onSkip: () {
            prefs.setBool('seenTutorial', true);
            return true;
          },
          onClickOverlay: (target) {},
        ).show(context: context);
      });
    }
  }

  void _initTargets() {
    targets.clear();
    targets.addAll([
      TargetFocus(
        keyTarget: _progressTabKey,
        enableOverlayTab: false,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Lottie.asset('assets/lottie/FittyFuchsOffice.json'),
                ),
                Text(
                  AppLocalizations.of(context)!.tProgressTutorial,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildNavigationButtons(0),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        keyTarget: _libraryTabKey,
        enableOverlayTab: false,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Lottie.asset('assets/lottie/FittyFuchsOffice.json'),
                ),
                Text(
                  AppLocalizations.of(context)!.tLibraryTutorial,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildNavigationButtons(1),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        keyTarget: _progressTabKey,
        enableOverlayTab: false,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Lottie.asset('assets/lottie/FittyFuchsOffice.json'),
                ),
                Text(
                  AppLocalizations.of(context)!.tStatisticsTutorial,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildNavigationButtons(0),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        keyTarget: _progressTabKey,
        enableOverlayTab: false,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Lottie.asset('assets/lottie/FittyFuchsOffice.json'),
                ),
                Text(
                  AppLocalizations.of(context)!.tProfileTutorial,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildNavigationButtons(0),
              ],
            ),
          ),
        ],
      ),
    ]);
  }

  late TutorialCoachMark tutorialCoachMark;

  Widget _buildNavigationButtons(int step) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (step > 0)
          TextButton(
            onPressed: () {
              tutorialCoachMark.previous();
            },
            child: Text(AppLocalizations.of(context)!.tBack),
          ),
        if (step < targets.length - 1)
          TextButton(
            onPressed: () {
              tutorialCoachMark.next();
            },
            child: Text(AppLocalizations.of(context)!.tContinue),
          ),
        if (step == targets.length - 1)
          ElevatedButton(
            onPressed: () {
              tutorialCoachMark.finish();
            },
            child: Text(AppLocalizations.of(context)!.tGotIt),
          ),
      ],
    );
  }

  final StreakController _streakController = Get.put(StreakController());

  @override
  void initState() {
    super.initState();
    _streakController.loadStreakData();
    _loadUserFavorites();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAndStartTutorial();
    });
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
          FocusScope.of(context).unfocus();
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: tBottomNavBarSelectedColor,
        unselectedItemColor: tBottomNavBarUnselectedColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.route, key: _progressTabKey),
            label: AppLocalizations.of(context)!.tProgress,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book, key: _libraryTabKey),
            label: AppLocalizations.of(context)!.tLibrary,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart, key: _statisticsTabKey),
            label: AppLocalizations.of(context)!.tStatistics,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, key: _profileTabKey),
            label: AppLocalizations.of(context)!.tProfile,
          ),
        ],
      ),
    );
  }
}
