import 'package:fit_office/src/features/core/controllers/exercise_timer.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/active_dialog.dart';
import 'package:fit_office/src/features/core/screens/profile/admin/exercise_form.dart';
import 'package:fit_office/src/features/core/screens/profile/widgets/about_modal.dart';
import 'package:fit_office/src/features/core/screens/profile/widgets/bug_report_modal.dart';
import 'package:fit_office/src/features/core/screens/profile/widgets/facet_display_card.dart';
import 'package:fit_office/src/features/core/screens/profile/widgets/help_support_modal.dart';
import 'package:fit_office/src/features/core/screens/profile/widgets/privacy_policy_modal.dart';
import 'package:fit_office/src/features/core/screens/profile/widgets/qr_code_dialog.dart';
import 'package:fit_office/src/features/core/screens/profile/widgets/terms_cond_modal.dart';
import 'package:fit_office/src/utils/helper/dialog_helper.dart';
import 'package:fit_office/src/utils/helper/helper_controller.dart';
import 'package:fit_office/src/utils/services/deep_link_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:fit_office/src/constants/sizes.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import 'package:fit_office/src/features/core/screens/profile/widgets/update_profile_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../constants/colors.dart';
import '../../../../repository/authentication_repository/authentication_repository.dart';
import '../../../../utils/helper/app_info.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/statistics_controller.dart';
import 'admin/add_friends.dart';
import 'admin/widgets/all_users.dart';
import 'admin/widgets/friends_box.dart';
import 'admin/widgets/friends_request.dart';
import 'widgets/custom_profile_button.dart';
import 'widgets/avatar.dart';

/// A screen that displays the user's profile, including personal information, statistics, and settings.
/// This screen allows users to view and edit their profile, manage friends, and access various settings and information about the app.
class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final controller = Get.put(ProfileController());

  /// Extracts the campus name from the user's email address.
  /// The email should be in the format of either `@stud.dhbw-{campus}.de` or `@dhbw-{campus}.de`.
  /// If the email does not match these patterns, it returns "Unknown".
  /// @param email The user's email address.
  /// @return The campus name extracted from the email, formatted with spaces and capitalized first letter, or "Unknown" if not found.
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
    final localisation = AppLocalizations.of(context)!;

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
                                return Text('${snapshot.data} ${localisation.tFriends}');
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
                        child: FutureBuilder<int>(
                          future: StatisticsController().getTotalExercises(user.email),
                          builder: (context, snapshot) {
                            return FactDisplayCard(
                              isDark: isDark,
                              icon: LineAwesomeIcons.dumbbell_solid,
                              title: snapshot.data?.toString() ?? '0',
                              subtitle: AppLocalizations.of(context)!.tCompletedWorkouts,
                              iconColor: Colors.orange,
                            );
                          },
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
                        flex: 3,
                        child: CustomProfileButton(
                          isDark: isDark,
                          icon: LineAwesomeIcons.user_edit_solid,
                          label: localisation.tEditProfile,
                          onPress: () async {
                            final timerController =
                                Get.find<ExerciseTimerController>();
                            if (timerController.isRunning.value ||
                                timerController.isPaused.value) {
                              await showUnifiedDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) =>
                                    ActiveTimerDialog.forAction('editprofile', context),
                              );
                              return;
                            }

                            UpdateProfileModal.show(context, user);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        flex: 2,
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
                                    ActiveTimerDialog.forAction('logout', context),
                              );
                              return;
                            }

                            _showLogoutModal(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  FriendsBoxWidget(currentUserId: user.id!),
                  const SizedBox(height: 8),
                  CustomProfileButton(
                    isDark: isDark,
                    icon: LineAwesomeIcons.user_plus_solid,
                    label: AppLocalizations.of(context)!.tAddFriendsHeader,
                    onPress: () async {
                      final timerController =
                      Get.find<ExerciseTimerController>();
                      if (timerController.isRunning.value ||
                          timerController.isPaused.value) {
                        await showUnifiedDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              ActiveTimerDialog.forAction('addfriends', context),
                        );
                        return;
                      }

                      Get.to(() => AddFriendsScreen(currentUserId: user.id!));
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: CustomProfileButton(
                          isDark: isDark,
                          icon: LineAwesomeIcons.share_square,
                          label: 'Send Friend Link',
                          onPress: () {
                            final deepLinkService = Get.find<DeepLinkService>();
                            deepLinkService.shareFriendRequestLink(user.id!);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: CustomProfileButton(
                          isDark: isDark,
                          icon: LineAwesomeIcons.qrcode_solid,
                          label: 'QR Code',
                          onPress: () async {
                            try {
                              QrCodeDialog.show(context, user.id!, user.userName);
                            } catch (e) {
                              Helper.errorSnackBar(
                                  title: 'Error',
                                  message: 'Could not generate QR code'
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  FriendRequestsWidget(currentUserId: user.id!),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(AppLocalizations.of(context)!.tSettings,
                      style: txtTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  CustomProfileButton(
                    isDark: isDark,
                    icon: LineAwesomeIcons.bell_solid,
                    label: AppLocalizations.of(context)!.tNotifications,
                    onPress: () async {
                      Helper.warningSnackBar(title: "Info", message: "Feature not implemented yet");
                    },
                  ),
                  CustomProfileDropdownButton(
                    icon: LineAwesomeIcons.language_solid,
                    isDark: isDark,
                    selectedValue: Get.locale?.languageCode ?? 'en',
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English 🇬🇧')),
                      DropdownMenuItem(value: 'de', child: Text('Deutsch 🇩🇪')),
                    ],
                    onChanged: (val) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('locale', val!);
                      Get.updateLocale(Locale(val));
                    },
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
                    label: AppLocalizations.of(context)!.tAbout,
                    onPress: () {
                      AboutModal.show(context);
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: FactDisplayCard(
                          isDark: isDark,
                          icon: Icons.timer,
                          title: "8h",
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
                          subtitle: "Bugs",
                          iconColor: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FutureBuilder<String>(
                          future: AppInfo.getFullVersionInfo(),
                          builder: (context, snapshot) {
                            return FactDisplayCard(
                              isDark: isDark,
                              icon: LineAwesomeIcons.info_circle_solid,
                              title: snapshot.data ?? '...',
                              subtitle: "Version",
                              iconColor: Colors.blue,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  CustomProfileButton(
                    isDark: isDark,
                    icon: LineAwesomeIcons.question_circle_solid,
                    label: AppLocalizations.of(context)!.tHelpSupport,
                    onPress: () {
                      HelpSupportModal.show(context);
                    },
                  ),
                  CustomProfileButton(
                    isDark: isDark,
                    icon: LineAwesomeIcons.bug_solid,
                    label: AppLocalizations.of(context)!.tReportBug,
                    onPress: () {
                      BugReportModal.show(context);
                    },
                  ),
                  CustomProfileButton(
                    isDark: isDark,
                    icon: LineAwesomeIcons.file_contract_solid,
                    label: AppLocalizations.of(context)!.tTerms,
                    onPress: () {
                      TermsConditionsModal.show(context, isDark: isDark);
                    },
                  ),
                  CustomProfileButton(
                    isDark: isDark,
                    icon: LineAwesomeIcons.file_signature_solid,
                    label: AppLocalizations.of(context)!.tPrivacyPolicy,
                    onPress: () {
                      PrivacyPolicyModal.show(context, isDark: isDark);
                    },
                  ),
                  CustomProfileButton(
                    isDark: isDark,
                    icon: LineAwesomeIcons.file_contract_solid,
                    label: AppLocalizations.of(context)!.tLicenses,
                    onPress: () async {
                      final version = await AppInfo.getFullVersionInfo();
                      showLicensePage(
                        context: context,
                        applicationName: 'FitOffice',
                        applicationVersion: version,
                        applicationLegalese: '© ${DateTime.now().year} DHBW Ravensburg',
                      );
                    },
                  ),
                  if (user.role == "admin") ...[
                    const Divider(),
                    const SizedBox(height: 10),
                    Text(AppLocalizations.of(context)!.tAdminSettings,
                        style: txtTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    CustomProfileButton(
                      //alle vier darunter anpassen!
                      isDark: isDark,
                      icon: Icons.add,
                      label: localisation.tAddExercises,
                      onPress: () async {
                        final timerController =
                            Get.find<ExerciseTimerController>();
                        if (timerController.isRunning.value ||
                            timerController.isPaused.value) {
                          await showUnifiedDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) =>
                                ActiveTimerDialog.forAction('admin', context),
                          );
                          return;
                        }

                        Get.to(() => ExerciseForm(isEdit: false));
                      },
                    ),
                    CustomProfileButton(
                      isDark: isDark,
                      icon: LineAwesomeIcons.user_edit_solid,
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
                                ActiveTimerDialog.forAction('admin', context),
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
                            "© ${DateTime.now().year} DHBW Ravensburg. All rights reserved.",
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

  //TODO: all PopUpModals with Yes and No should be in one style; maybe the same style as all other PopUps! Texts should be added to localizations!
  /// Shows a logout confirmation modal dialog.
  /// This dialog asks the user to confirm if they want to log out of the application.
  /// @param context The BuildContext in which the dialog should be displayed.
  void _showLogoutModal(BuildContext context) {
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
                        AppLocalizations.of(context)!.tLogout,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : tBlackColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppLocalizations.of(context)!.tLogoutMessage,
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
                              label: Text(
                                AppLocalizations.of(context)!.tLogoutPositive,
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
                              label: Text(
                                AppLocalizations.of(context)!.tLogoutNegative,
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

