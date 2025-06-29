import 'package:fit_office/global_overlay.dart';
import 'package:fit_office/src/features/core/screens/libary/library_screen.dart';
import 'package:fit_office/src/features/core/screens/progress/progress_screen.dart';
import 'package:fit_office/src/features/core/screens/statistics/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/l10n/app_localizations.dart';
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

/// The main dashboard screen of the app that allows navigation between
/// the Library, Progress, Statistics, and Profile sections.
///
/// This screen also initiates the onboarding tutorial for first-time users,
/// handles tutorial language selection, and tracks user preferences using
/// SharedPreferences.
class Dashboard extends StatefulWidget {
  final int initialIndex;
  const Dashboard({super.key, required this.initialIndex});

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

  int selectedIndex = 1; // Default to Library tab
  String favoriteCount = '';

  /// Gets the current tab title based on the selected index.
  String _getPageTitle() {
    switch (selectedIndex) {
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

  /// Loads the user's favorite exercises and updates the [favoriteCount].
  void _loadUserFavorites() async {
    final user = await _profileController.getUserData();
    final userFavorites = await _dbController.getFavouriteExercises(user.email);
    final favoriteNames =
        userFavorites.map((e) => e['name'] as String).toList();
    if (mounted) {
      setState(() {
        favoriteCount =
        "${favoriteNames.length} ${AppLocalizations.of(context)!
            .tDashboardExerciseUnits}";
      });
    }
  }

  /// Checks if the user has seen the tutorial before and starts it if not.
  void checkAndStartTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial =
        prefs.getBool('seenTutorial_${_currentUser.email}') ?? false;

    if (!hasSeenTutorial) {
      _showLanguageSelection();
    }
  }

  /// Displays a dialog to let the user choose their preferred tutorial language.
  void _showLanguageSelection() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Get.context?.theme.brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 130,
                width: 180,
                child: Lottie.asset('assets/lottie/FittyFuchsOffice.json'),
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.tTutorialLanguage,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Get.context?.theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
              const SizedBox(height: 32),
              Text(
                AppLocalizations.of(context)!.tLanguageChange,
                style: TextStyle(
                    color: Get.context?.theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Sets the tutorial language and starts the tutorial.
  Future<void> _selectLanguageAndContinue(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', languageCode);
    Get.updateLocale(Locale(languageCode));

    if (mounted) {
      Navigator.of(context).pop();
    }

    await Future.delayed(const Duration(milliseconds: 300));
    _initTargets();
    startTutorialStep(0);
  }

  int tutorialStep = 0;
  int counter = 0;

  /// Starts the tutorial from a specific step index.
  ///
  /// Automatically navigates to the tab associated with each tutorial target.
  void startTutorialStep(int step) async {
    if (_isShowingTutorial) return;
    _isShowingTutorial = true;

    if (step >= targets.length || step < 0) return;

    tutorialCoachMark?.finish();

    final user = await _profileController.getUserData();

    setState(() {
      tutorialStep = step;

      final currentTarget = targets[step];
      final key = currentTarget.keyTarget;

      if (key == _progressTabKey) {
        selectedIndex = 0;
      } else if (key == _libraryTabKey) {
        selectedIndex = 1;
      } else if (key == _statisticsTabKey) {
        selectedIndex = 2;
      } else if (key == _profileTabKey) {
        selectedIndex = 3;
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        tutorialCoachMark = TutorialCoachMark(
          initialFocus: step,
          targets: targets,
          pulseEnable: false,
          alignSkip: Alignment.topRight,
          colorShadow: Colors.black,
          opacityShadow: 0.8,
          skipWidget: Padding(
            padding: const EdgeInsets.only(top: 40.0, right: 16.0),
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  tutorialCoachMark?.skip();
                },
                child: Text(
                  AppLocalizations.of(context)!.tSkip,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          onFinish: () {
            SharedPreferences.getInstance().then((prefs) {
              prefs.setBool('seenTutorial_${user.email}', true);
            });
            _isShowingTutorial = false;
          },
          onClickTarget: (target) async {
            setState(() {
              switch (counter) {
                case 0:
                  selectedIndex = 0;
                case 1:
                  selectedIndex = 1;
                case 2:
                  selectedIndex = 2;
                case 3:
                  selectedIndex = 3;
                case 4:
                  selectedIndex = 3;
                default:
                  selectedIndex = 0;
              }
              counter++;
            });

            if (target.identify == "full_screen_step_profile_2") {
              SharedPreferences.getInstance().then((prefs) {
                prefs.setBool('seenTutorial_${user.email}', true);
              });
            }
          },
          onSkip: () {
            SharedPreferences.getInstance().then((prefs) {
              prefs.setBool('seenTutorial_${user.email}', true);
            });
            _isShowingTutorial = false;
            return true;
          },
          onClickOverlay: (_) {},
        );
      }

      if (mounted) {
        tutorialCoachMark!.show(context: context);
      }
    });
  }

  /// Changes the tutorial language and restarts the tutorial.
  Future<void> changeTutorialLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', languageCode);
    Get.updateLocale(Locale(languageCode));

    Future.delayed(const Duration(milliseconds: 300), () {
      _initTargets();
      startTutorialStep(0);
    });
  }

  /// Initializes all tutorial targets for guided onboarding using the `showcaseview` or `tutorial_coach_mark` package.
  ///
  /// This function defines visual focus areas (`TargetFocus`) over key UI elements
  /// like tabs or full-screen overlays, each displaying animations and localized
  /// instructional text via Lottie animations. The tutorial steps help users
  /// understand key features and UI elements of the app.
  ///
  /// Must be called inside a context-aware widget (e.g., in `initState()` or after build).
  void _initTargets() {
    final screenSize = MediaQuery.of(context).size;
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
                  height: 130,
                  width: 180,
                  child: Lottie.asset('assets/lottie/FittyFuchsOffice.json'),
                ),
                Text(
                  AppLocalizations.of(context)!.tProgressTutorial,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "full_screen_step",
        keyTarget: _fullscreenDummyKey,
        pulseVariation: ConstantTween(1.0),
        shape: ShapeLightFocus.RRect,
        color: Colors.black.withAlpha(204),
        enableOverlayTab: true,
        radius: 0,
        targetPosition: TargetPosition(Size(screenSize.width, screenSize.height),
    Offset.zero),
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 130,
                    width: 180,
                    child: Lottie.asset('assets/lottie/FittyFuchsOffice.json'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      AppLocalizations.of(context)!.tTutorialSteps,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
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
                  height: 130,
                  width: 180,
                  child: Lottie.asset('assets/lottie/FittyFuchsOffice.json'),
                ),
                Text(
                  AppLocalizations.of(context)!.tLibraryTutorial,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "mind_favorites_info",
        keyTarget: _fullscreenDummyKey,
        shape: ShapeLightFocus.RRect,
        color: Colors.black.withAlpha(204),
        enableOverlayTab: true,
        radius: 0,
        targetPosition: TargetPosition(Size.zero, Offset.zero),
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              top: 200,
              left: 0,
              right: 0,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 130,
                          width: 180,
                          child: Lottie.asset(
                            'assets/lottie/FittyFuchsOffice.json',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(
                          width: 180,
                          child: Text(
                            AppLocalizations.of(context)!.tTutorialCategories,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                  height: 130,
                  width: 180,
                  child: Lottie.asset('assets/lottie/FittyFuchsOffice.json'),
                ),
                Text(
                  AppLocalizations.of(context)!.tStatisticsTutorial,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "full_screen_step_statistics_1",
        keyTarget: _fullscreenDummyKey,
        shape: ShapeLightFocus.RRect,
        color: Colors.black.withAlpha(204),
        enableOverlayTab: true,
        radius: 0,
        targetPosition: TargetPosition(Size.zero, Offset.zero),
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 130,
                      width: 180,
                      child:
                          Lottie.asset('assets/lottie/FittyFuchsOffice.json'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        AppLocalizations.of(context)!.tTutorialStatistics1,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "full_screen_step_statistics_2",
        keyTarget: _fullscreenDummyKey,
        shape: ShapeLightFocus.RRect,
        color: Colors.black.withAlpha(204),
        enableOverlayTab: true,
        radius: 0,
        targetPosition: TargetPosition(Size.zero, Offset.zero),
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 130,
                      width: 180,
                      child:
                          Lottie.asset('assets/lottie/FittyFuchsOffice.json'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        AppLocalizations.of(context)!.tTutorialStatistics2,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "full_screen_step_statistics_3",
        keyTarget: _fullscreenDummyKey,
        shape: ShapeLightFocus.RRect,
        color: Colors.black.withAlpha(204),
        enableOverlayTab: true,
        radius: 0,
        targetPosition: TargetPosition(Size.zero, Offset.zero),
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 130,
                      width: 180,
                      child:
                          Lottie.asset('assets/lottie/FittyFuchsOffice.json'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        AppLocalizations.of(context)!.tTutorialStatistics3,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
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
                  height: 130,
                  width: 180,
                  child: Lottie.asset('assets/lottie/FittyFuchsOffice.json'),
                ),
                Text(
                  AppLocalizations.of(context)!.tProfileTutorial,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "full_screen_step_profile",
        keyTarget: _fullscreenDummyKey,
        shape: ShapeLightFocus.RRect,
        color: Colors.black.withAlpha(204),
        enableOverlayTab: true,
        radius: 0,
        targetPosition: TargetPosition(Size.zero, Offset.zero),
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 130,
                      width: 180,
                      child:
                          Lottie.asset('assets/lottie/FittyFuchsOffice.json'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        AppLocalizations.of(context)!.tTutorialProfile,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "full_screen_step_profile_2",
        keyTarget: _fullscreenDummyKey,
        shape: ShapeLightFocus.RRect,
        color: Colors.black.withAlpha(204),
        enableOverlayTab: true,
        radius: 0,
        targetPosition: TargetPosition(Size.zero, Offset.zero),
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 130,
                      width: 180,
                      child:
                          Lottie.asset('assets/lottie/FittyFuchsOffice.json'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        AppLocalizations.of(context)!.tTutorialProfile2,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ]);
  }

  TutorialCoachMark? tutorialCoachMark;

  final StreakController _streakController = Get.put(StreakController());
  late UserModel _currentUser;
  bool _isShowingTutorial = false;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    _initializeDashboard();

    WidgetsBinding.instance.addPostFrameCallback((_) {
    GlobalExerciseOverlay().init(context);
  });
  }

  /// Initializes dashboard-related user data and triggers the tutorial if applicable.
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
  final GlobalKey _fullscreenDummyKey = GlobalKey();

  /// Builds the main dashboard UI with navigation tabs and conditional tutorial overlays.
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
          /// Displays one of the four main screens based on [selectedIndex].
          IndexedStack(
            index: selectedIndex,
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
          /// Conditionally renders the full-screen tutorial overlay.
          if (_isShowingTutorial)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                key: _fullscreenDummyKey,
                width: 0,
                height: 0,
                decoration: BoxDecoration(
                  color: Get.context?.theme.brightness == Brightness.dark
                      ? const Color.fromARGB(204, 0, 0, 0)
                      : const Color(0xFF333333),
                ),
              ),
            ),
        ],
      ),
      /// Bottom navigation bar for switching between tabs.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          FocusScope.of(context).unfocus();
          setState(() {
            selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: tBottomNavBarSelectedColor,
        unselectedItemColor: tBottomNavBarUnselectedColor,
        items: [
          BottomNavigationBarItem(
            icon: Container(key: _progressTabKey, child: Icon(Icons.route)),
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

  void updateSelectedIndex(int index) {
    if (mounted && selectedIndex != index) {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  @override
  void dispose() {
    tutorialCoachMark?.finish();
    super.dispose();
  }
}
