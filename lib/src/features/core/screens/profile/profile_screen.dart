import 'package:fit_office/src/features/core/screens/profile/widgets/facet_display_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:fit_office/src/constants/sizes.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/core/screens/profile/update_profile_screen.dart';
import '../../../../common_widgets/buttons/primary_button.dart';
import '../../../../repository/authentication_repository/authentication_repository.dart';
import '../../../authentication/models/user_model.dart';
import '../../controllers/profile_controller.dart';
import 'admin/add_exercises.dart';
import 'admin/add_friends.dart';
import 'admin/edit_user_page.dart';
import 'admin/widgets/all_users.dart';
import 'widgets/custom_profile_button.dart';
import 'widgets/avatar.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final controller = Get.put(ProfileController());
  late Future<UserModel> _userFuture;
  late UserModel _user;

  @override
  void initState() {
    super.initState();
    // Fetch user data and then setState to refresh the widget
    _userFuture = controller.getUserData();
    _userFuture.then((user) {
      setState(() {
        _user = user;  // Refresh UI with the updated user data
      });
    });
  }

  String _extractCampusFromEmail(String email) {
    final campusRegex = RegExp(r'@stud\.dhbw-([a-z\-]+)\.de$|@dhbw-([a-z\-]+)\.de$');
    final match = campusRegex.firstMatch(email);
    if (match != null) {
      return match.group(1)?.replaceAll('-', ' ').capitalizeFirst ??
          match.group(2)?.replaceAll('-', ' ').capitalizeFirst ??
          "Unknown";
    }
    return "Unknown";
  }

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: tDefaultSize),
          child: FutureBuilder<UserModel>(
            future: _userFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                _user = snapshot.data!;  // Ensure _user is updated with the latest data
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Default alignment for the rest of the sections
                    children: [
                      const SizedBox(height: 20),
                      // Profile Section - Image on Left, Info on Right
                      Row(
                        children: [
                          // Profile Picture (ImageWithIcon is now placed left)
                          const Avatar(),
                          const SizedBox(width: 20),
                          // User Info (Name and Email)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('@${_user.userName}', style: txtTheme.headlineMedium),
                                const SizedBox(height: 10),
                                Text(_user.fullName, style: txtTheme.headlineSmall),
                                Text(_user.email, style: txtTheme.bodyLarge),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Additional User Info Section (Last Changed, Created At, etc.)
                      const Divider(),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: FactDisplayCard(
                              icon: LineAwesomeIcons.dumbbell_solid,
                              title: "100",
                              subtitle: "Completed Workouts",
                              iconColor: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FactDisplayCard(
                              icon: LineAwesomeIcons.map_marked_alt_solid,
                              title: _extractCampusFromEmail(_user.email),
                              subtitle: "Campus",
                              iconColor: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2, // 2/3 der Breite
                            child: CustomProfileButton(
                              icon: LineAwesomeIcons.user_edit_solid,
                              label: tEditProfile,
                              onPress: () => Get.to(() => UpdateProfileScreen()),
                            ),
                          ),
                          const SizedBox(width: 10), // Abstand zwischen den Buttons
                          Expanded(
                            flex: 1,
                            child: CustomProfileButton(
                              icon: LineAwesomeIcons.sign_out_alt_solid,
                              iconColor: Colors.red,
                              label: "Logout",
                              textColor: Colors.red,
                              onPress: () => _showLogoutModal(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Friends Section
                      const Divider(),
                      const SizedBox(height: 10),
                      Text("Friends", style: txtTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: FactDisplayCard(
                              icon: Icons.group,
                              title: "4",
                              subtitle: "Friends",
                              iconColor: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FactDisplayCard(
                              icon: LineAwesomeIcons.award_solid,
                              title: "1",
                              subtitle: "Place",
                              iconColor: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: FactDisplayCard(
                              icon: Icons.star,
                              title: "5",
                              subtitle: "Friend Streaks",
                              iconColor: Colors.yellow,
                            ),
                          ),
                        ],
                      ),
                      CustomProfileButton(
                        icon: LineAwesomeIcons.user_plus_solid,  // Icon for adding friends
                        label: "Add Friends",  // Label for the button
                        onPress: () => Get.to(() => AddFriendsScreen(currentUserId: _user.id!,)),  // Navigate to AddFriendsScreen
                      ),
                      CustomProfileButton(
                        icon: LineAwesomeIcons.user_friends_solid,  // Icon for viewing friends
                        label: "View Friends",  // Label for the button
                        onPress: () => Get.to(() => const AllUsersPage()),  // Navigate to AllUsersPage
                      ),

                      // Settings Section
                      const Divider(),
                      const SizedBox(height: 10),
                      Text("Settings", style: txtTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      CustomProfileButton(
                        icon: LineAwesomeIcons.bell_solid,
                        label: "Notifications",
                        onPress: () {},
                      ),
                      CustomProfileButton(
                        icon: LineAwesomeIcons.language_solid,
                        label: "Language",
                        onPress: () {},
                      ),
                      const Divider(),
                      const SizedBox(height: 10),

                      // Information Section
                      Text("Information", style: txtTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),

                      CustomProfileButton(
                        icon: LineAwesomeIcons.info_solid,
                        label: "About",
                        onPress: () {},
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: FactDisplayCard(
                              icon: Icons.timer,
                              title: "24h",
                              subtitle: "Support",
                              iconColor: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FactDisplayCard(
                              icon: LineAwesomeIcons.bug_solid,
                              title: "No Bugs",
                              subtitle: "Bugs Found",
                              iconColor: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FactDisplayCard(
                              icon: LineAwesomeIcons.info_circle_solid,
                              title: "Version 1.0",
                              subtitle: "App Version",
                              iconColor: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      CustomProfileButton(
                        icon: LineAwesomeIcons.question_circle_solid,
                        label: "Help & Support",
                        onPress: () {},
                      ),
                      CustomProfileButton(
                        icon: LineAwesomeIcons.bug_solid,
                        label: "Report a Bug",
                        onPress: () {},
                      ),
                      CustomProfileButton(
                        icon: LineAwesomeIcons.file_contract_solid,
                        label: "Terms & Conditions",
                        onPress: () {},
                      ),
                      CustomProfileButton(
                        icon: LineAwesomeIcons.file_signature_solid,
                        label: "Privacy Policy",
                        onPress: () {},
                      ),
                      CustomProfileButton(
                        icon: LineAwesomeIcons.file_contract_solid,
                        label: "Licenses",
                        onPress: () {},
                      ),

                      // Admin Section
                      if (_user.role == "admin") ...[
                        const Divider(),
                        const SizedBox(height: 10),
                        Text("Admin Settings", style: txtTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        CustomProfileButton(
                          icon: Icons.add,
                          label: tAddExercises,
                          onPress: () => Get.to(() => AddExercises(currentUserId: _user.id!)),
                        ),
                        CustomProfileButton(
                          icon: Icons.delete,
                          label: tDeleteEditUser,
                          onPress: () => Get.to(() => const AllUsersPage()),
                        ),
                        CustomProfileButton(
                          icon: Icons.person_add,
                          label: tAddUser,
                          onPress: () => Get.to(() => const EditUserPage()),
                        ),
                        CustomProfileButton(
                          icon: LineAwesomeIcons.user_check_solid,
                          label: "User Management",
                          onPress: () => Get.to(() => const AllUsersPage()),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],

                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }

  void _showLogoutModal() {
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
