import 'package:fit_office/src/features/core/screens/dashboard/widgets/statistics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/constants/sizes.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/appbar.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/categories.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/search.dart';
import 'package:fit_office/src/features/core/screens/profile/profile_screen.dart';

import '../../../authentication/models/user_model.dart';
import '../../controllers/db_controller.dart';
import '../../controllers/profile_controller.dart';
import '../progress/progress.dart';

final GlobalKey<DashboardState> dashboardKey = GlobalKey<DashboardState>();

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  final GlobalKey<DashboardCategoriesState> _categoriesKey =
      GlobalKey<DashboardCategoriesState>();
  final GlobalKey<DashboardSearchBoxState> _searchBoxKey =
      GlobalKey<DashboardSearchBoxState>();
  final ProfileController _profileController = Get.put(ProfileController());
  final DbController _dbController = DbController();

  bool wasSearchFocusedBeforeNavigation = false;
  bool get searchHasFocus => _searchHasFocus;

  bool _searchHasFocus = false;
  String _searchText = '';

  int _selectedIndex = 0;
  List<String> _userFavorites = [];
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

  void handleReturnedFromExercise() {
    if (!wasSearchFocusedBeforeNavigation) {
      removeSearchFocus();
    } else {
      _searchBoxKey.currentState?.requestFocus();
    }
  }

  void removeSearchFocus() {
    FocusScope.of(context).unfocus();
    _searchBoxKey.currentState?.removeFocus();
    setState(() {
      _searchHasFocus = false;
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

  final ProfileController _controller = Get.put(ProfileController());
  UserModel? _user;
  bool _isUserLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserFavorites();
  }

  void _loadUserData() async {
    final userData = await _controller.getUserData();
    setState(() {
      _user = userData;
      _isUserLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: SliderAppBar(
        title: _getPageTitle(),
        showBackButton: false,
        showDarkModeToggle: true,
        showStreak: true,
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              // 0: Progress Screen
              const ProgressScreen(),

              // 1: Dashboard/Home
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                behavior: HitTestBehavior.translucent,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: tDashboardPadding,
                          bottom: 4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _isUserLoaded
                                ? Text(
                                    '$tDashboardTitle ${_user?.fullName ?? ''}',
                                    style: txtTheme.bodyMedium)
                                : const CircularProgressIndicator(),
                            Text(tDashboardHeading,
                                style: txtTheme.displayMedium),
                          ],
                        ),
                      ),
                    ),

                    // Sticky SearchBar
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickySearchBar(
                        minExtent: 74,
                        maxExtent: 74,
                        child: Column(
                          children: [
                            Container(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              padding: const EdgeInsets.only(
                                top: 10,
                                left: tDashboardPadding,
                                right: tDashboardPadding,
                                bottom: 10,
                              ),
                              child: DashboardSearchBox(
                                key: _searchBoxKey,
                                txtTheme: Theme.of(context).textTheme,
                                onSearchSubmitted: (query) {
                                  _categoriesKey.currentState
                                      ?.updateSearchQuery(query);
                                  setState(() {
                                    _searchHasFocus = false;
                                    _searchText = query;
                                  });
                                },
                                onTextChanged: (query) {
                                  _categoriesKey.currentState
                                      ?.updateSearchQuery(query);
                                  setState(() {
                                    _searchText = query;
                                  });
                                },
                                onFocusChanged: (hasFocus) {
                                  setState(() {
                                    _searchHasFocus = hasFocus;
                                  });
                                },
                              ),
                            ),
                            const Divider(
                              thickness: 1.8,
                              height: 0.8,
                              color: Color.fromARGB(255, 190, 190, 190),
                              indent: 0,
                              endIndent: 0,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Kategorien + All Exercises
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 8.0,
                          left: tDashboardPadding,
                          right: tDashboardPadding,
                          bottom: tDashboardPadding,
                        ),
                        child: DashboardCategories(
                          key: _categoriesKey,
                          txtTheme: txtTheme,
                          onSearchChanged: (text) {},
                          forceShowExercisesOnly:
                              _searchHasFocus || _searchText.isNotEmpty,
                          onReturnedFromFilter: removeSearchFocus,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Banner  --> woanders einbauen? oder wo/wofür nötig?
              //Text(tDashboardInformation, style: txtTheme.headlineMedium?.apply(fontSizeFactor: 1.2)),
              //DashboardBanners(txtTheme: txtTheme, isDark: isDark),
              //const SizedBox(height: tDashboardPadding),

              // 2: Statistics Screen
              Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(tDashboardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tDashboardStatistics,
                          style: txtTheme.headlineMedium
                              ?.apply(fontSizeFactor: 1.2)),
                      const SizedBox(height: 20),
                      StatisticsWidget(txtTheme: txtTheme, isDark: isDark),
                    ],
                  ),
                ),
              ),

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

class _StickySearchBar extends SliverPersistentHeaderDelegate {
  @override
  final double minExtent;
  @override
  final double maxExtent;
  final Widget child;

  _StickySearchBar({
    required this.minExtent,
    required this.maxExtent,
    required this.child,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 4 : 0, // Shadow beim Scrollen
      child: child,
    );
  }

  @override
  bool shouldRebuild(_StickySearchBar oldDelegate) {
    return oldDelegate.maxExtent != maxExtent ||
        oldDelegate.minExtent != minExtent ||
        oldDelegate.child != child;
  }
}
