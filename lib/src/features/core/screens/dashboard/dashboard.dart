import 'package:fit_office/src/features/core/screens/dashboard/search_page.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/statistics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/constants/image_strings.dart';
import 'package:fit_office/src/constants/sizes.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/appbar.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/banners.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/categories.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/search.dart';
import 'package:fit_office/src/features/core/screens/profile/profile_screen.dart';

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
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _searchResults = [];

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

    final controller = Get.put(ProfileController());

    return SafeArea(
      child: Scaffold(
        appBar: DashboardAppBar(isDark: isDark),
        drawer: Drawer(
          backgroundColor: tWhiteColor,
          child: ListView(
            children: [
              FutureBuilder(
                future: controller.getUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      UserModel user = snapshot.data as UserModel;

                      //Controllers
                      final email = user.email;
                      final fullName = user.fullName;
                      
                      return UserAccountsDrawerHeader(
                        currentAccountPicture: const Image(image: AssetImage(tLogoImage)),
                        currentAccountPictureSize: const Size(100, 100),
                        accountName: Text(fullName),
                        accountEmail: Text(email),
                        decoration: const BoxDecoration(color: tSecondaryColor),
                      );
                    } else {
                      return const Center(child: Text('Something went wrong'));
                    }
                  } else {
                    return const UserAccountsDrawerHeader(
                      currentAccountPicture: Image(image: AssetImage(tLogoImage)),
                      accountName: Text('Loading...'),
                      accountEmail: Text('Loading...'),
                    );
                  }
                },
              ),
              ListTile(
                  leading: const Icon(Icons.verified_user),
                  title: const Text('Profile'),
                  onTap: () {
                    Get.to(() => ProfileScreen());
                  }),
              const ListTile(leading: Icon(Icons.favorite), title: Text('Friends')),
            ],
          ),
        ),

        body: IndexedStack(
          index: _selectedIndex,
          children: [
            SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(tDashboardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    FutureBuilder(
                      future: controller.getUserData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            UserModel user = snapshot.data as UserModel;
                            return Text('$tDashboardTitle ${user.fullName}', style: txtTheme.bodyMedium);
                          } else {
                            return const Center(child: Text('Something went wrong'));
                          }
                        } else {
                          return Text('$tDashboardTitle ...', style: txtTheme.bodyMedium);
                        }
                      },
                    ),
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
                        );
                      },
                    ),
                    const SizedBox(height: tDashboardPadding),

                    // Categories
                    DashboardCategories(txtTheme: txtTheme),
                    const SizedBox(height: tDashboardPadding),

                    // Banner
                    Text(tDashboardInformation, style: txtTheme.headlineMedium?.apply(fontSizeFactor: 1.2)),
                    DashboardBanners(txtTheme: txtTheme, isDark: isDark),
                    const SizedBox(height: tDashboardPadding),

                    // Statistics
                    Text(tDashboardStatistics, style: txtTheme.headlineMedium?.apply(fontSizeFactor: 1.2)),
                    StatisticsWidget(txtTheme: txtTheme, isDark: isDark),
                  ],
                ),
              ),
            ),
            const ProgressScreen(),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Friends'),
              onTap: () {
                // Add functionality for "Friends" here
              },
            ),
          ],
        ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [

            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.route),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_add),
              label: 'Friends',
            ),
          ],
        ),
      ),
    );
  }
}
