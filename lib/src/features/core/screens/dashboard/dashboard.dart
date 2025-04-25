import 'package:cached_network_image/cached_network_image.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/statistics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/constants/image_strings.dart';
import 'package:fit_office/src/constants/sizes.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/appbar.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/categories.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/search.dart';
import 'package:fit_office/src/features/core/screens/profile/profile_screen.dart';
import 'package:fit_office/src/features/core/screens/account/account.dart';

import '../../../authentication/models/user_model.dart';
import '../../controllers/db_controller.dart';
import '../../controllers/profile_controller.dart';
import '../progress/progress.dart';

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

  bool _searchHasFocus = false;
  String _searchText = '';

  int _selectedIndex = 0;
  List<String> _userFavorites = [];
  String favoriteCount = '';

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
      appBar: TimerAwareAppBar(
        normalAppBar: AppBar(
          title: Text(tAppName,
              style: Theme.of(context).textTheme.headlineMedium),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        showBackButton: false,
      ),
      drawer: Drawer(
        backgroundColor: tWhiteColor,
        child: ListView(
          children: [
            _isUserLoaded
                ? UserAccountsDrawerHeader(
              currentAccountPicture: _user?.profilePicture != null &&
                  _user!.profilePicture!.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: _user!.profilePicture!,
                placeholder: (context, url) =>
                const CircularProgressIndicator(),
                errorWidget: (context, url, error) =>
                const Icon(Icons.error),
              )
                  : const Image(image: AssetImage(tLogoImage)),
              currentAccountPictureSize: const Size(100, 100),
              accountName: Text(_user?.fullName ?? ''),
              accountEmail: Text(_user?.email ?? ''),
              decoration: const BoxDecoration(color: tSecondaryColor),
            )
                : const UserAccountsDrawerHeader(
              currentAccountPicture:
              Image(image: AssetImage(tLogoImage)),
              accountName: Text('Loading...'),
              accountEmail: Text('Loading...'),
            ),
            ListTile(
                leading: const Icon(Icons.verified_user),
                title: const Text('Profile'),
                onTap: () {
                  FocusScope.of(context).unfocus(); // <-- Fokus entfernen
                  Get.to(() => ProfileScreen());
                }),
            const ListTile(
                leading: Icon(Icons.favorite), title: Text('Friends')),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // 0: Progress Screen
          const ProgressScreen(),

          // 1: Dashboard/Home
          GestureDetector(
            // <-- HINZUGEFÜGT
            onTap: () {
              FocusScope.of(context).unfocus(); // <-- Fokus entfernen
            },
            behavior:
                HitTestBehavior.translucent, // <-- wichtig für leere Flächen
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: tDashboardPadding,
                        bottom: 4), //noch als constant festlegen
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
                    minExtent: 72, // Erhöhe Höhe minimal für Platz + Linie
                    maxExtent: 72,
                    child: Column(
                      children: [
                        Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          padding: const EdgeInsets.only(
                            top: 10,
                            left: tDashboardPadding,
                            right: tDashboardPadding,
                            bottom: 10, // Abstand zur Linie
                          ),
                          child: DashboardSearchBox(
                            key: _searchBoxKey,
                            txtTheme: Theme.of(context).textTheme,
                            onSearchSubmitted: (query) {
                              _categoriesKey.currentState
                                  ?.updateSearchQuery(query);
                              setState(() {
                                _searchHasFocus =
                                    false; // Fokus entfernen nach Enter
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
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: MediaQuery.of(context).size.width -
                                (tDashboardPadding * 2),
                            height: 2,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Kategorien + All Exercises scrollbar
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
                      onReturnedFromFilter: removeSearchFocus, // NEU
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
          const AccountScreen(),
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
  final double minExtent;
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
