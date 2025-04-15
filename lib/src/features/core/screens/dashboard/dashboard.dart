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
import 'package:fit_office/src/features/core/screens/account/account.dart';

import '../../../authentication/models/user_model.dart';
import '../../controllers/profile_controller.dart';
import '../progress/progress.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

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
                        currentAccountPicture:
                            const Image(image: AssetImage(tLogoImage)),
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
                      currentAccountPicture:
                          Image(image: AssetImage(tLogoImage)),
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
                            return Text('$tDashboardTitle ${user.fullName}',
                                style: txtTheme.bodyMedium);
                          } else {
                            return const Center(
                                child: Text('Something went wrong'));
                          }
                        } else {
                          return Text('$tDashboardTitle ...',
                              style: txtTheme.bodyMedium);
                        }
                      },
                    ),
                    Text(tDashboardHeading, style: txtTheme.displayMedium),
                    const SizedBox(height: tDashboardPadding),

                    // Search
                    DashboardSearchBox(txtTheme: txtTheme),
                    const SizedBox(height: tDashboardPadding),

                    // Categories
                    DashboardCategories(txtTheme: txtTheme),
                    const SizedBox(height: tDashboardPadding),

                    // Banner  --> woanders einbauen? oder wo/wofür nötig?
//                  //Text(tDashboardInformation, style: txtTheme.headlineMedium?.apply(fontSizeFactor: 1.2)),
//                  //DashboardBanners(txtTheme: txtTheme, isDark: isDark),
//                  //const SizedBox(height: tDashboardPadding),

//                  // Statistics
//                  //Text(tDashboardStatistics, style: txtTheme.headlineMedium?.apply(fontSizeFactor: 1.2)),
//                  //StatisticsWidget(txtTheme: txtTheme, isDark: isDark),
                  ],
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
            const FriendsScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType
              .fixed, // <- sicherstellen, dass alle Icons angezeigt werden
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

//         body: IndexedStack(
//           index: _selectedIndex,
//           children: [
//             SingleChildScrollView(
//               child: Container(
//                 padding: const EdgeInsets.all(tDashboardPadding),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header
//                     FutureBuilder(
//                       future: controller.getUserData(),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState == ConnectionState.done) {
//                           if (snapshot.hasData) {
//                             UserModel user = snapshot.data as UserModel;
//                             return Text('$tDashboardTitle ${user.fullName}', style: txtTheme.bodyMedium);
//                           } else {
//                             return const Center(child: Text('Something went wrong'));
//                           }
//                         } else {
//                           return Text('$tDashboardTitle ...', style: txtTheme.bodyMedium);
//                         }
//                       },
//                     ),
//                     Text(tDashboardHeading, style: txtTheme.displayMedium),
//                     const SizedBox(height: tDashboardPadding),

//                     // Search
//                     DashboardSearchBox(txtTheme: txtTheme),
//                     const SizedBox(height: tDashboardPadding),

//                     // Categories
//                     DashboardCategories(txtTheme: txtTheme),
//                     const SizedBox(height: tDashboardPadding),

//                     // Banner  --> woanders einbauen? oder wo/wofür nötig?
//                     //Text(tDashboardInformation, style: txtTheme.headlineMedium?.apply(fontSizeFactor: 1.2)),
//                     //DashboardBanners(txtTheme: txtTheme, isDark: isDark),
//                     //const SizedBox(height: tDashboardPadding),

//                     // Statistics
//                     //Text(tDashboardStatistics, style: txtTheme.headlineMedium?.apply(fontSizeFactor: 1.2)),
//                     //StatisticsWidget(txtTheme: txtTheme, isDark: isDark),
//                   ],
//                 ),
//               ),
//             ),
//             //Progress Screen
//             const ProgressScreen(),
//             ListTile(
//               leading: const Icon(Icons.favorite),
//               title: const Text('Friends'),
//               onTap: () {
//                 // Add functionality for "Friends" here
//               },
//             ),
//             const StatisticsScreen(),
//             ListTile(
//               leading: const Icon(Icons.apple),
//               title: const Text('Test'),
//               onTap: () {
//                 // Add functionality for "Settings" here
//               },
//             ),
//           ],
//         ),

//         bottomNavigationBar: BottomNavigationBar(
//           currentIndex: _selectedIndex,
//           onTap: (index) {
//             setState(() {
//               _selectedIndex = index;
//             });
//           },
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.book),
//               label: 'Library',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.route),
//               label: 'Progress',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.insert_chart),
//               label: 'Statitics',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person_add),
//               label: 'Friends',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
