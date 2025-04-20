import 'package:fit_office/src/features/core/screens/dashboard/search_page.dart';
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

  int _selectedIndex = 0;
  List<Map<String, dynamic>> _searchResults = [];

  final ProfileController _controller = Get.put(ProfileController());
  UserModel? _user;
  bool _isUserLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final userData = await _controller.getUserData();
    setState(() {
      _user = userData;
      _isUserLoaded = true;
    });
  }

  void _performSearch(String query) async {
    final dbController = DbController();
    final results = await dbController.getExercises(query);
    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
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
                      currentAccountPicture:
                          const Image(image: AssetImage(tLogoImage)),
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
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(tDashboardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _isUserLoaded
                          ? Text('$tDashboardTitle ${_user?.fullName ?? ''}',
                              style: txtTheme.bodyMedium)
                          : const CircularProgressIndicator(),
                      Text(tDashboardHeading, style: txtTheme.displayMedium),
                      const SizedBox(height: tDashboardPadding),

                      // Search
                      DashboardSearchBox(
                        txtTheme: Theme.of(context).textTheme,
                        onSearchSubmitted: (query) {
                          _performSearch(query);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchPage(query: query),
                            ),
                          ).then((_) {
                            _categoriesKey.currentState?.refreshData();
                          });
                        },
                        onTextChanged: (query) {
                          _performSearch(query);
                          _categoriesKey.currentState?.updateSearchQuery(query);
                        },
                      ),

                      const SizedBox(height: tDashboardPadding),

                      // Categories
                      DashboardCategories(
                        key: _categoriesKey,
                        txtTheme: txtTheme,
                        onSearchChanged: (text) {},
                      ),

                      const SizedBox(height: tDashboardPadding),

                      // Banner  --> woanders einbauen? oder wo/wofür nötig?
                      //Text(tDashboardInformation, style: txtTheme.headlineMedium?.apply(fontSizeFactor: 1.2)),
                      //DashboardBanners(txtTheme: txtTheme, isDark: isDark),
                      //const SizedBox(height: tDashboardPadding),
                    ],
                  ),
                ),
              ),
            ),
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
      ),
    );
  }
}
