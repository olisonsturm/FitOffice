import 'package:flutter/material.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import '../../../../../constants/sizes.dart';

/// A modal bottom sheet that displays the terms and conditions of the FitOffice@DHBW application.
class PrivacyPolicyModal {
  static Future<void> show(BuildContext context, {required bool isDark}) {

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8, // 80% of screen height
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
                Navigator.of(context).pop();
              }
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification) {
                  if (notification.metrics.pixels <= 0 && notification.dragDetails != null && notification.dragDetails!.delta.dy > 0) {
                    Navigator.of(context).pop();
                    return true;
                  }
                }
                return false;
              },
              child: Padding(
                padding: EdgeInsets.only(
                  left: tDefaultSize,
                  right: tDefaultSize,
                  top: tDefaultSize,
                  bottom: MediaQuery.of(context).viewInsets.bottom + tDefaultSize,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag indicator
                      Center(
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white54 : Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Header
                      Center(
                        child: Text(
                          AppLocalizations.of(context)?.tPrivacyPolicy ?? 'Privacy Policy',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Introduction
                      _buildSection(
                        context,
                        isDark: isDark,
                        title: 'Introduction',
                        content: '''
This Privacy Policy explains how FitOffice@DHBW ("we," "our," or "us") collects, uses, and discloses your information when you use our mobile application (the "App").

By using the App, you agree to the collection and use of information in accordance with this policy. This policy is effective as of June 2023 and may be updated periodically.
                        ''',
                      ),

                      const SizedBox(height: 20),

                      // Information We Collect
                      _buildSection(
                        context,
                        isDark: isDark,
                        title: 'Information We Collect',
                        content: '''
• Personal Information: When you create an account, we collect your name, email address, and profile picture.

• Health and Fitness Data: We collect data related to your workout activities, including exercise types, duration, frequency, and performance metrics.

• Device Information: We automatically collect certain information about your device, including IP address, device type, operating system version, and unique device identifiers.

• Usage Information: We collect information about how you use the App, including features accessed, time spent, and interactions with content.
                        ''',
                      ),

                      const SizedBox(height: 20),

                      // How We Use Your Information
                      _buildSection(
                        context,
                        isDark: isDark,
                        title: 'How We Use Your Information',
                        content: '''
• To provide and maintain our Service
• To personalize your experience and deliver content tailored to your preferences
• To improve our App by analyzing usage patterns
• To communicate with you, including sending notifications about updates or changes
• To detect, prevent, and address technical issues and security concerns
                        ''',
                      ),

                      const SizedBox(height: 20),

                      // Firebase Services
                      _buildSection(
                        context,
                        isDark: isDark,
                        title: 'Firebase Services',
                        content: '''
Our App uses Google Firebase services for various functionalities:

• Firebase Authentication: Used for user authentication and account management
• Firebase Realtime Database: Stores user data and workout information
• Firebase Storage: Stores user profile pictures and related media
• Firebase Analytics: Collects anonymous usage statistics to improve the App

Firebase's use of data is governed by Google's privacy policy. For more information, visit: https://policies.google.com/privacy
                        ''',
                      ),

                      const SizedBox(height: 20),

                      // Data Sharing and Disclosure
                      _buildSection(
                        context,
                        isDark: isDark,
                        title: 'Data Sharing and Disclosure',
                        content: '''
We do not sell your personal information to third parties. We may share your information in the following circumstances:

• With your consent
• With service providers that help us operate the App
• To comply with legal obligations
• In connection with a business transfer or merger
• To protect our rights or property

Social features in the App may allow you to share certain information with other users. You control what you share through these features.
                        ''',
                      ),

                      const SizedBox(height: 20),

                      // Data Security
                      _buildSection(
                        context,
                        isDark: isDark,
                        title: 'Data Security',
                        content: '''
We implement appropriate security measures to protect against unauthorized access, alteration, disclosure, or destruction of your data. However, no method of transmission over the Internet or electronic storage is 100% secure.
                        ''',
                      ),

                      const SizedBox(height: 20),

                      // Your Rights
                      _buildSection(
                        context,
                        isDark: isDark,
                        title: 'Your Rights',
                        content: '''
Depending on your location, you may have rights regarding your personal data:

• Access and view the data we have about you
• Request correction of inaccurate data
• Request deletion of your data
• Object to or restrict processing of your data
• Data portability

To exercise these rights, contact us through the information provided at the end of this policy.
                        ''',
                      ),

                      const SizedBox(height: 20),

                      // Children's Privacy
                      _buildSection(
                        context,
                        isDark: isDark,
                        title: 'Children\'s Privacy',
                        content: '''
Our App is not intended for use by children under the age of 13. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us.
                        ''',
                      ),

                      const SizedBox(height: 20),

                      // Changes to Privacy Policy
                      _buildSection(
                        context,
                        isDark: isDark,
                        title: 'Changes to This Policy',
                        content: '''
We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "effective date" at the top. You are advised to review this Privacy Policy periodically for any changes.
                        ''',
                      ),

                      const SizedBox(height: 20),

                      // Copyright
                      Center(
                        child: Text(
                          '© 2025 DHBW Ravensburg. All rights reserved.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildSection(BuildContext context, {
    required bool isDark,
    required String title,
    required String content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.withAlpha(128),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}