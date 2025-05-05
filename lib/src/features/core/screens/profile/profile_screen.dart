import 'package:fit_office/src/features/core/screens/profile/widgets/facet_display_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:fit_office/src/constants/sizes.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/core/screens/profile/widgets/update_profile_modal.dart';
import '../../../../common_widgets/buttons/primary_button.dart';
import '../../../../repository/authentication_repository/authentication_repository.dart';
import '../../controllers/profile_controller.dart';
import 'admin/add_exercises.dart';
import 'admin/add_friends.dart';
import 'admin/edit_user_page.dart';
import 'admin/widgets/all_users.dart';
import 'widgets/custom_profile_button.dart';
import 'widgets/avatar.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final controller = Get.put(ProfileController());

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    controller.fetchUserData();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: tDefaultSize),
          child: Obx(() {
            final user = controller.user.value;
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Avatar(),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('@${user.userName}', style: txtTheme.headlineMedium),
                            const SizedBox(height: 10),
                            Text(user.fullName, style: txtTheme.headlineSmall),
                            Text(user.email, style: txtTheme.bodyLarge),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FactDisplayCard(
                          isDark: isDark,
                          icon: LineAwesomeIcons.dumbbell_solid,
                          title: "100",
                          subtitle: "Completed Workouts",
                          iconColor: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FactDisplayCard(
                          isDark: isDark,
                          icon: LineAwesomeIcons.map_marked_alt_solid,
                          title: _extractCampusFromEmail(user.email),
                          subtitle: "Campus",
                          iconColor: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: CustomProfileButton(
                          isDark: isDark,
                          icon: LineAwesomeIcons.user_edit_solid,
                          label: tEditProfile,
                          onPress: () => UpdateProfileModal.show(context, user),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        flex: 3,
                        child: CustomProfileButton(
                          isDark: isDark,
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
                  const Divider(),
                  const SizedBox(height: 10),
                  Text("Friends", style: txtTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FactDisplayCard(
                          isDark: isDark,
                          icon: Icons.group,
                          title: "4",
                          subtitle: "Friends",
                          iconColor: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FactDisplayCard(
                          isDark: isDark,
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
                          isDark: isDark,
                          icon: Icons.star,
                          title: "5",
                          subtitle: "Friend Streaks",
                          iconColor: Colors.yellow,
                        ),
                      ),
                    ],
                  ),
                  CustomProfileButton(
                    isDark: isDark,
                    icon: LineAwesomeIcons.user_plus_solid,
                    label: "Add Friends",
                    onPress: () => Get.to(() => AddFriendsScreen(currentUserId: user.id!)),
                  ),
                  CustomProfileButton(
                    isDark: isDark,
                    icon: LineAwesomeIcons.user_friends_solid,
                    label: "View Friends",
                    onPress: () => Get.to(() => const AllUsersPage()),
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text("Settings", style: txtTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  CustomProfileButton(
                    isDark: isDark,
                    icon: LineAwesomeIcons.bell_solid,
                    label: "Notifications",
                    onPress: () {},
                  ),
                  CustomProfileButton(
                    isDark: isDark,
                    icon: LineAwesomeIcons.language_solid,
                    label: "Language",
                    onPress: () {},
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text("Information", style: txtTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  CustomProfileButton(
                    isDark: isDark,
                    icon: LineAwesomeIcons.info_solid,
                    label: "About",
                    onPress: () {},
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: FactDisplayCard(
                          isDark: isDark,
                          icon: Icons.timer,
                          title: "24h",
                          subtitle: "Support",
                          iconColor: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FactDisplayCard(
                          isDark: isDark,
                          icon: LineAwesomeIcons.bug_solid,
                          title: "No Bugs",
                          subtitle: "Bugs Found",
                          iconColor: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FactDisplayCard(
                          isDark: isDark,
                          icon: LineAwesomeIcons.info_circle_solid,
                          title: "Version 1.0",
                          subtitle: "FitOffice",
                          iconColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  CustomProfileButton(
                    isDark: isDark,
                    icon: LineAwesomeIcons.question_circle_solid,
                    label: "Help & Support",
                    onPress: () {},
                  ),
                  CustomProfileButton(
                    isDark: isDark,
                    icon: LineAwesomeIcons.bug_solid,
                    label: "Report a Bug",
                    onPress: () {},
                  ),
                  CustomProfileButton(
                    isDark: isDark,
                    icon: LineAwesomeIcons.file_contract_solid,
                    label: "Terms & Conditions",
                    onPress: () {},
                  ),
                  CustomProfileButton(
                    isDark: isDark,
                    icon: LineAwesomeIcons.file_signature_solid,
                    label: "Privacy Policy",
                    onPress: () {},
                  ),
                  CustomProfileButton(
                    isDark: isDark,
                    icon: LineAwesomeIcons.file_contract_solid,
                    label: "Licenses",
                    onPress: () {},
                  ),
                  if (user.role == "admin") ...[
                    const Divider(),
                    const SizedBox(height: 10),
                    Text("Admin Settings", style: txtTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    CustomProfileButton(
                      isDark: isDark,
                      icon: Icons.add,
                      label: tAddExercises,
                      onPress: () => Get.to(() => AddExercises(currentUserId: user.id!)),
                    ),
                    CustomProfileButton(
                      isDark: isDark,
                      icon: Icons.delete,
                      label: tDeleteEditUser,
                      onPress: () => Get.to(() => const AllUsersPage()),
                    ),
                    CustomProfileButton(
                      isDark: isDark,
                      icon: Icons.person_add,
                      label: tAddUser,
                      onPress: () => Get.to(() => const EditUserPage()),
                    ),
                    CustomProfileButton(
                      isDark: isDark,
                      icon: LineAwesomeIcons.user_check_solid,
                      label: "User Management",
                      onPress: () => Get.to(() => const AllUsersPage()),
                    ),
                  ],
                  const Divider(),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Proudly crafted with ❤️ and ☕",
                            textAlign: TextAlign.center,
                            style: txtTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.grey : Colors.blueGrey[700],
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "by passionate students of\nHealth Management & Business Information Systems\nat DHBW Ravensburg",
                            textAlign: TextAlign.center,
                            style: txtTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.grey : Colors.blueGrey[700],
                              height: 1.6,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "© ${DateTime.now().year} FitOffice",
                            textAlign: TextAlign.center,
                            style: txtTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  //TODO: all PopUpModals with Yes and No should be in one style!
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
      cancel: SizedBox(
        width: 100,
        child: OutlinedButton(
          onPressed: () => Get.back(),
          child: const Text("No"),
        ),
      ),
    );
  }
}

