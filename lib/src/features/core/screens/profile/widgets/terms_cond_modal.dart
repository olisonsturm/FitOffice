import 'package:flutter/material.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import '../../../../../constants/sizes.dart';

class TermsConditionsModal {
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
                      AppLocalizations.of(context)?.tTerms ?? 'Terms & Conditions',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Terms of Use Section
                  _buildSection(
                    context,
                    isDark: isDark,
                    title: 'Terms of Use',
                    content: '''
  By accessing and using the FitOffice@DHBW application, you agree to be bound by these Terms of Use:
  
  • This application is designed for personal fitness tracking in office environments.
  • You must be at least 18 years old or have parental consent to use this application.
  • You are responsible for maintaining the confidentiality of your account credentials.
  • You agree not to use the application for any illegal or unauthorized purpose.
  • We reserve the right to modify, suspend, or discontinue the service at any time.
  • These terms may be updated at our discretion; continued use constitutes acceptance of changes.
                    ''',
                  ),

                  const SizedBox(height: 20),

                  // User Content
                  _buildSection(
                    context,
                    isDark: isDark,
                    title: 'User Content',
                    content: '''
  • You retain ownership of content you create within the application.
  • By uploading content, you grant us a non-exclusive license to use, display, and distribute your content.
  • You are solely responsible for the content you post and share.
  • We reserve the right to remove any content that violates these terms.
  • Do not upload content that infringes upon intellectual property rights or contains harmful material.
                    ''',
                  ),

                  const SizedBox(height: 20),

                  // Limitations of Liability
                  _buildSection(
                    context,
                    isDark: isDark,
                    title: 'Limitations of Liability',
                    content: '''
  • FitOffice@DHBW is provided "as is" without warranties of any kind, express or implied.
  • We are not liable for any injuries that may occur from performing exercises.
  • We are not responsible for any damages resulting from your use of the application.
  • Always consult with a healthcare professional before beginning any exercise program.
  • Data loss, interruption of service, or other technical issues are not grounds for refunds or compensation.
                    ''',
                  ),

                  const SizedBox(height: 20),

                  // Termination
                  _buildSection(
                    context,
                    isDark: isDark,
                    title: 'Termination',
                    content: '''
  • We may terminate or suspend your account for violations of these terms.
  • Upon termination, your right to use the application will cease immediately.
  • All provisions of these terms which by their nature should survive termination shall survive.
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