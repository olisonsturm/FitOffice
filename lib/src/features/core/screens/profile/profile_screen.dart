import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:fit_office/src/common_widgets/buttons/primary_button.dart';
import 'package:fit_office/src/constants/sizes.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/core/screens/profile/update_profile_screen.dart';
import 'package:fit_office/src/features/core/screens/profile/widgets/image_with_icon.dart';
import 'package:fit_office/src/features/core/screens/profile/widgets/profile_menu.dart';

import '../../../../repository/authentication_repository/authentication_repository.dart';
import '../../../authentication/models/user_model.dart';
import '../../controllers/profile_controller.dart';
import 'all_users.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Get.back(), icon: const Icon(LineAwesomeIcons.angle_left_solid)),
        title: Text(tProfile, style: Theme.of(context).textTheme.headlineMedium),
        actions: [IconButton(onPressed: () {}, icon: Icon(isDark ? LineAwesomeIcons.sun : LineAwesomeIcons.moon))],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(tDefaultSpace),
          child: Column(
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

                      return Column(
                        children: [

                          /// -- IMAGE with ICON
                          const ImageWithIcon(),
                          const SizedBox(height: 10),

                          Text(userName, style: Theme
                              .of(context)
                              .textTheme
                              .headlineMedium),
                          Text(email, style: Theme
                              .of(context)
                              .textTheme
                              .bodyMedium),
                          const SizedBox(height: 20),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    } else {
                      return const Center(child: Text('Something went wrong'));
                    }
                  } else {
                    return const Column(
                      children: [
                        SizedBox(height: 10),
                        CircularProgressIndicator(),
                        SizedBox(height: 10)
                      ],
                    );
                  }
                }
              ),
              Column(
                children: [
                  /// -- BUTTON
                  TPrimaryButton(
                      isFullWidth: false,
                      width: 200,
                      text: tEditProfile,
                      onPressed: () => Get.to(() => UpdateProfileScreen())
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),

                  /// -- MENU
                  ProfileMenuWidget(title: "Settings",
                      icon: LineAwesomeIcons.cog_solid,
                      onPress: () {}),
                  ProfileMenuWidget(title: "Billing Details",
                      icon: LineAwesomeIcons.wallet_solid,
                      onPress: () {}),
                  ProfileMenuWidget(
                      title: "User Management",
                      icon: LineAwesomeIcons.user_check_solid,
                      onPress: () => Get.to(() => AllUsers())),
                  const Divider(),
                  const SizedBox(height: 10),
                  ProfileMenuWidget(title: "Information",
                      icon: LineAwesomeIcons.info_solid,
                      onPress: () {}),
                  ProfileMenuWidget(
                    title: "Logout",
                    icon: LineAwesomeIcons.sign_out_alt_solid,
                    textColor: Colors.red,
                    endIcon: false,
                    onPress: () => _showLogoutModal(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showLogoutModal() {
    Get.defaultDialog(
      title: "LOGOUT",
      titleStyle: const TextStyle(fontSize: 20),
      content: const Padding(
        padding: EdgeInsets.symmetric(vertical: 15.0),
        child: Text("Are you sure, you want to Logout?"),
      ),
      confirm: TPrimaryButton(
        isFullWidth: false,
        onPressed: () => AuthenticationRepository.instance.logout(),
        text: "Yes",
      ),
      cancel: SizedBox(width: 100, child: OutlinedButton(onPressed: () => Get.back(), child: const Text("No"))),
    );
  }
}
