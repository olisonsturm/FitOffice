import 'package:fit_office/src/features/core/controllers/exercise_timer.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/active_dialog.dart';
import 'package:fit_office/src/features/core/screens/profile/widgets/facet_display_card.dart';
import 'package:fit_office/src/utils/helper/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:fit_office/src/constants/sizes.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/core/screens/profile/widgets/update_profile_modal.dart';
import '../../../../common_widgets/buttons/primary_button.dart';
import '../../../../constants/colors.dart';
import '../../../../repository/authentication_repository/authentication_repository.dart';
import '../../controllers/profile_controller.dart';
import 'admin/add_exercises.dart';
import 'admin/add_friends.dart';
import 'admin/edit_user_page.dart';
import 'admin/widgets/all_users.dart';
import 'admin/widgets/friends_box.dart';
import 'admin/widgets/friends_request.dart';
import 'widgets/custom_profile_button.dart';
import 'widgets/avatar.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final controller = Get.put(ProfileController());

  String _extractCampusFromEmail(String email) {
    final campusRegex =
        RegExp(r'@stud\.dhbw-([a-z\-]+)\.de$|@dhbw-([a-z\-]+)\.de$');
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
        backgroundColor: isDark ? tBlackColor : tWhiteColor,
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
                            Text('@${user.userName}',
                                style: txtTheme.headlineMedium),
                            const SizedBox(height: 10),
                            Text(user.fullName, style: txtTheme.headlineSmall),
                            Text(user.email, style: txtTheme.bodyLarge),
                            FutureBuilder<int>(
                              future: ProfileController.instance.getNumberOfFriends(user.userName),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox.shrink();
                                }
                                return Text('${snapshot.data} $tFriends');
                              },
                            ),
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
                          onPress: () async {
                            final timerController =
                                Get.find<ExerciseTimerController>();
                            if (timerController.isRunning.value ||
                                timerController.isPaused.value) {
                              await showUnifiedDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) =>
                                    ActiveTimerDialog.forAction('editprofile'),
                              );
                              return;
                            }

                            UpdateProfileModal.show(context, user);
                          },
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
                          onPress: () async {
                            final timerController =
                                Get.find<ExerciseTimerController>();
                            if (timerController.isRunning.value ||
                                timerController.isPaused.value) {
                              await showUnifiedDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) =>
                                    ActiveTimerDialog.forAction('logout'),
                              );
                              return;
                            }

                            _showLogoutModal();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  FriendsBoxWidget(currentUserId: user.id!),
                  const SizedBox(height: 10),
                  FriendRequestsWidget(currentUserId: user.id!),
                  const SizedBox(height: 10),
                  CustomProfileButton(
                    isDark: isDark,
                    icon: LineAwesomeIcons.user_plus_solid,
                    label: "Add Friends",
                    onPress: () async {
                      final timerController =
                          Get.find<ExerciseTimerController>();
                      if (timerController.isRunning.value ||
                          timerController.isPaused.value) {
                        await showUnifiedDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              ActiveTimerDialog.forAction('addfriends'),
                        );
                        return;
                      }

                      Get.to(() => AddFriendsScreen(currentUserId: user.id!));
                    },
                  ),
                  CustomProfileButton(
                    //auch mit dem Dialog anpassen!
                    isDark: isDark,
                    icon: LineAwesomeIcons.user_friends_solid,
                    label: "View Friends",
                    onPress: () async {
                      final timerController =
                          Get.find<ExerciseTimerController>();
                      if (timerController.isRunning.value ||
                          timerController.isPaused.value) {
                        await showUnifiedDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              ActiveTimerDialog.forAction('viewfriends'),
                        );
                        return;
                      }

                      Get.to(() => const AllUsersPage());
                    },
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text("Settings",
                      style: txtTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
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
                  Text("Information",
                      style: txtTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
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
                    Text("Admin Settings",
                        style: txtTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    CustomProfileButton(
                      //alle vier darunter anpassen!
                      isDark: isDark,
                      icon: Icons.add,
                      label: tAddExercises,
                      onPress: () async {
                        final timerController =
                            Get.find<ExerciseTimerController>();
                        if (timerController.isRunning.value ||
                            timerController.isPaused.value) {
                          await showUnifiedDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) =>
                                ActiveTimerDialog.forAction('admin'),
                          );
                          return;
                        }

                        Get.to(() => AddExercises(currentUserId: user.id!));
                      },
                    ),
                    CustomProfileButton(
                      isDark: isDark,
                      icon: Icons.delete,
                      label: tDeleteEditUser,
                      onPress: () async {
                        final timerController =
                            Get.find<ExerciseTimerController>();
                        if (timerController.isRunning.value ||
                            timerController.isPaused.value) {
                          await showUnifiedDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) =>
                                ActiveTimerDialog.forAction('admin'),
                          );
                          return;
                        }

                        Get.to(() => const AllUsersPage());
                      },
                    ),
                    CustomProfileButton(
                      isDark: isDark,
                      icon: Icons.person_add,
                      label: tAddUser,
                      onPress: () async {
                        final timerController =
                            Get.find<ExerciseTimerController>();
                        if (timerController.isRunning.value ||
                            timerController.isPaused.value) {
                          await showUnifiedDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) =>
                                ActiveTimerDialog.forAction('admin'),
                          );
                          return;
                        }

                        Get.to(() => const EditUserPage());
                      },
                    ),
                    CustomProfileButton(
                      isDark: isDark,
                      icon: LineAwesomeIcons.user_check_solid,
                      label: "User Management",
                      onPress: () async {
                        final timerController =
                            Get.find<ExerciseTimerController>();
                        if (timerController.isRunning.value ||
                            timerController.isPaused.value) {
                          await showUnifiedDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) =>
                                ActiveTimerDialog.forAction('admin'),
                          );
                          return;
                        }

                        Get.to(() => const AllUsersPage());
                      },
                    ),
                  ],
                  const Divider(),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24.0, horizontal: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Proudly crafted with ❤️ and ☕",
                            textAlign: TextAlign.center,
                            style: txtTheme.bodyMedium?.copyWith(
                              color:
                                  isDark ? Colors.grey : Colors.blueGrey[700],
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "by passionate students of\nHealth Management & Business Information Systems\nat DHBW Ravensburg",
                            textAlign: TextAlign.center,
                            style: txtTheme.bodySmall?.copyWith(
                              color:
                                  isDark ? Colors.grey : Colors.blueGrey[700],
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

  //TODO: all PopUpModals with Yes and No should be in one style; maybe the same style as all other PopUps! Texts should be added to text_strings.dart
  void _showLogoutModal() {
    final isDarkMode = Get.isDarkMode;

    Get.dialog(
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 365, minWidth: 300),
          child: Material(
            borderRadius: BorderRadius.circular(20),
            color: isDarkMode ? tDarkGreyColor : tWhiteColor,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        tLogout,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : tBlackColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        tLogoutMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                AuthenticationRepository.instance.logout();
                                Get.back();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: tStartExerciseColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide.none,
                              ),
                              icon:
                                  const Icon(Icons.logout, color: Colors.white),
                              label: const Text(
                                tLogoutPositive,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => Get.back(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade500,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide.none,
                                ),
                                side: BorderSide.none,
                              ),
                              icon:
                                  const Icon(Icons.cancel, color: Colors.white),
                              label: const Text(
                                tLogoutNegative,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    right: -12,
                    top: -12,
                    child: IconButton(
                      icon: Icon(
                        Icons.cancel_outlined,
                        color: isDarkMode ? tPaleWhiteColor : tPaleBlackColor,
                      ),
                      onPressed: () => Get.back(),
                      iconSize: 28,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
