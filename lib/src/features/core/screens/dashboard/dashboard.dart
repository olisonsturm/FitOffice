import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/constants/image_strings.dart';
import 'package:fit_office/src/constants/sizes.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/appbar.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/banners.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/categories.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/search.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/top_courses.dart';
import 'package:fit_office/src/features/core/screens/profile/profile_screen.dart';

import '../../../authentication/models/user_model.dart';
import '../../controllers/profile_controller.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    //Variables
    final txtTheme = Theme.of(context).textTheme;
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark; //Dark mode

    final controller = Get.put(ProfileController());

    return SafeArea(
      child: Scaffold(
        appBar: DashboardAppBar(isDark: isDark),
        /// Create a new Header
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
                      final userName = user.userName;

                      return UserAccountsDrawerHeader(
                        currentAccountPicture: const Image(image: AssetImage(tLogoImage)),
                        currentAccountPictureSize: const Size(100, 100),
                        accountName: Text(userName),
                        accountEmail: Text(email),
                        decoration: const BoxDecoration(color: tSecondaryColor),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    } else {
                      return const Center(child: Text('Something went wrong'));
                    }
                  } else {
                    return const Column(
                      children: [
                        UserAccountsDrawerHeader(
                          currentAccountPicture: Image(image: AssetImage(tLogoImage)),
                          currentAccountPictureSize: Size(100, 100),
                          accountName: Text('Loading...'),
                          accountEmail: Text('Loading...'),
                          arrowColor: Colors.black,
                        ),
                      ],
                    );
                  }
                }
              ),
              ListTile(leading: const Icon(Icons.verified_user), title: const Text('Profile'), onTap: () { Get.to(() => ProfileScreen()); }),
              ListTile(leading: const Icon(Icons.favorite), title: const Text('Friends')),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(tDashboardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Heading
                FutureBuilder(
                    future: controller.getUserData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          UserModel user = snapshot.data as UserModel;
                          return Text('$tDashboardTitle ${user.userName}', style: txtTheme.bodyMedium);
                        } else if (snapshot.hasError) {
                          return Center(child: Text(snapshot.error.toString()));
                        } else {
                          return const Center(child: Text('Something went wrong'));
                        }
                      } else {
                        return Text('$tDashboardTitle ...', style: txtTheme.bodyMedium);
                      }
                    }
                ),
                Text(tDashboardHeading, style: txtTheme.displayMedium),
                const SizedBox(height: tDashboardPadding),

                //Search Box
                DashboardSearchBox(txtTheme: txtTheme),
                const SizedBox(height: tDashboardPadding),

                //Categories
                DashboardCategories(txtTheme: txtTheme),
                const SizedBox(height: tDashboardPadding),

                //Banners
                DashboardBanners(txtTheme: txtTheme, isDark: isDark),
                const SizedBox(height: tDashboardPadding),

                //Top Course
                Text(tDashboardTopCourses, style: txtTheme.headlineMedium?.apply(fontSizeFactor: 1.2)),
                DashboardTopCourses(txtTheme: txtTheme, isDark: isDark)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
