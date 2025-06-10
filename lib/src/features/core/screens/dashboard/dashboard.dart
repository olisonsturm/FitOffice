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

import '../../../authentication/models/user_model.dart';
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
  TutorialCoachMark? _languageSelectionCoachMark;

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
      favoriteCount =
          "${favoriteNames.length} ${AppLocalizations.of(context)!.tDashboardExerciseUnits}";
    });
  }

  void checkAndStartTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial =
        prefs.getBool('seenTutorial_${_currentUser.email}') ?? false;

    if (!hasSeenTutorial) {
      _showLanguageSelection();
    }
  }

  void _showLanguageSelection() {
    final languageTarget = TargetFocus(
      identify: "language_select",
      shape: ShapeLightFocus.RRect,
      enableOverlayTab: false,
      radius: 10,
      targetPosition: TargetPosition(Size.zero, Offset.zero),
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: Column(
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: Lottie.asset('assets/lottie/FittyFuchsOffice.json'),
              ),
              Text(
                AppLocalizations.of(context)!.tTutorialLanguage,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _selectLanguageAndContinue('en'),
                        child: const Text('English 🇬🇧'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _selectLanguageAndContinue('de'),
                        child: const Text('Deutsch 🇩🇪'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.tLanguageChange,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );

    _languageSelectionCoachMark = TutorialCoachMark(
      targets: [languageTarget],
      alignSkip: Alignment.bottomRight,
      onFinish: () {},
      onClickTarget: (_) {},
      onSkip: () {
        return true;
      },
      onClickOverlay: (_) {},
      colorShadow: Colors.red,
    );

    if (mounted) {
      _languageSelectionCoachMark!.show(context: context);
    }
  }

  Future<void> _selectLanguageAndContinue(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', languageCode);
    Get.updateLocale(Locale(languageCode));

    Future.delayed(const Duration(milliseconds: 200), () {
      _languageSelectionCoachMark?.finish();
    });

    await Future.delayed(const Duration(milliseconds: 300));

    _initTargets();
    startTutorialStep(0);
  }

  int tutorialStep = 0;

  void startTutorialStep(int step) async {
    if (step >= targets.length || step < 0) {
      return;
    }
    tutorialCoachMark?.finish();

    final user = await _profileController.getUserData();
    setState(() {
      tutorialStep = step;
      if (step == 1) {
      } else if (step > 1) {
        _selectedIndex = step - 1;
      } else {
        _selectedIndex = step;
      }
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      tutorialCoachMark = TutorialCoachMark(
        initialFocus: step,
        targets: targets,
        alignSkip: Alignment.bottomRight,
        onFinish: () {
          if (step == targets.length - 1) {
            SharedPreferences.getInstance().then((prefs) {
              prefs.setBool('seenTutorial_${user.email}', true);
            });
          }
        },
        onClickTarget: (_) {

        },
        onSkip: () {
          SharedPreferences.getInstance().then((prefs) {
            prefs.setBool('seenTutorial_${user.email}', true);
          });
          return true;
        },
        onClickOverlay: (_) {},
      );

      if (mounted) {
        tutorialCoachMark!.show(context: context);
      }
    });
  }

  Future<void> changeTutorialLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', languageCode);
    Get.updateLocale(Locale(languageCode));

    Future.delayed(const Duration(milliseconds: 300), () {
      _initTargets();
      startTutorialStep(0);
    });
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
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                _buildNavigationButtons(0),
              ],
              ),
            ),
        ],
      ),
      TargetFocus(
        identify: "full_screen_step",
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        radius: 0,
        targetPosition: TargetPosition(Size.zero, Offset.zero),
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Lottie.asset('assets/lottie/FittyFuchsOffice.json'),
                ),
                Text(
                  "Hier siehst du die einzelnen Schritte",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildNavigationButtons(1),
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
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                _buildNavigationButtons(2),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        keyTarget: _statisticsTabKey,
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
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                _buildNavigationButtons(3),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        keyTarget: _profileTabKey,
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
                _buildNavigationButtons(4),
              ],
            ),
          ),
        ],
      ),
    ]);
  }

  TutorialCoachMark? tutorialCoachMark;

  Widget _buildNavigationButtons(int step) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (step > 0)
          TextButton(
            onPressed: () {
              startTutorialStep(step - 1);
            },
            child: Text(AppLocalizations.of(context)!.tBack),
          ),
        if (step < targets.length - 1)
          TextButton(
            onPressed: () {
              startTutorialStep(step + 1);
            },
            child: Text(AppLocalizations.of(context)!.tContinue),
          ),
        if (step == targets.length - 1)
          ElevatedButton(
            onPressed: () {
              tutorialCoachMark!.finish();
              SharedPreferences.getInstance().then((prefs) {
                prefs.setBool('seenTutorial_${_currentUser.email}', true);
              });
            },
            child: Text(AppLocalizations.of(context)!.tGotIt),
          ),
      ],
    );
  }

  final StreakController _streakController = Get.put(StreakController());
  late UserModel _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  void _initializeDashboard() async {
    _currentUser = await _profileController.getUserData();
    _streakController.loadStreakData();
    _loadUserFavorites();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        checkAndStartTutorial();
      });
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
