import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../constants/sizes.dart';

class HelpSupportModal {
  static void show(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: GestureDetector(
            // This empty gesture detector with behavior set to opaque
            // allows taps to be captured but doesn't interfere with scrolling
            behavior: HitTestBehavior.opaque,
            onVerticalDragEnd: (details) {
              // Only close if the drag is downward and with sufficient velocity
              if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
                Navigator.of(context).pop();
              }
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // Allow swiping to dismiss only when at the top of the scroll view
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
                      const SizedBox(height: 40),

                      // Header with Support Icon
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.support_agent,
                            size: 40,
                            color: Colors.blue,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Center(
                        child: Text(
                          'Help & Support',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Center(
                        child: Text(
                          'We\'re here to help you',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Contact Information
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Get in Touch',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildContactItem(
                              Icons.email_outlined,
                              'Email Support',
                              'fitoffice@dhbw-ravensburg.de',
                              isDark,
                              onTap: () => _launchEmail('fitoffice@dhbw-ravensburg.de'),
                            ),

                            const SizedBox(height: 12), // Add spacing between items

                            _buildContactItem(
                              Icons.lightbulb_outline,
                              'Feature Request',
                              'Suggest improvements',
                              isDark,
                              onTap: () => _launchUrl('https://github.com/olisonsturm/FitOffice/issues/new?labels=enhancement'),
                            ),

                            const SizedBox(height: 12),

                            _buildContactItem(
                              Icons.school_outlined,
                              'University',
                              'DHBW Ravensburg',
                              isDark,
                              onTap: () => _launchUrl('https://www.dhbw-ravensburg.de'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // FAQ & Documentation
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resources',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildContactItem(
                              Icons.help_outline,
                              'Documentation',
                              'User guide & FAQ',
                              isDark,
                              onTap: () => _launchUrl('https://github.com/olisonsturm/FitOffice/wiki'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Response Time Notice
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'We typically respond within 24-48 hours during business days.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ),
                          ],
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

  static Widget _buildContactItem(
      IconData icon,
      String title,
      String subtitle,
      bool isDark, {
        VoidCallback? onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
          ],
        ),
      ),
    );
  }

  static Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Fit Office Support Request',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }
}