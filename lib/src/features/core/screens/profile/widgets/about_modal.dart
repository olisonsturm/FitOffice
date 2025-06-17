import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/utils/helper/app_info.dart';
import 'package:flutter/material.dart';
import '../../../../../constants/sizes.dart';

class AboutModal {
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

                      // App Logo/Icon
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            // Using withAlpha instead of withOpacity
                            color: tPrimaryColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.fitness_center,
                            size: 50,
                            color: tPrimaryColor
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // App Name
                      Center(
                        child: Text(
                          'FitOffice@DHBW',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Version
                      Center(
                        child: FutureBuilder<String>(
                          future: AppInfo.getFullVersionInfo(),
                          builder: (context, snapshot) {
                            String version = snapshot.hasData
                                ? 'Version ${snapshot.data}'
                                : 'Version 1.0.0';
                            return Text(
                              version,
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 30),

                      // About Content
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            // Using withAlpha instead of withOpacity
                            color: Colors.grey.withAlpha(128),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'About FitOffice@DHBW',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'The original FitOffice@DHBW App. Made with ❤️ at DHBW Ravensburg. Brought to life by health management students. Developed by business information systems students.',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Features
                            Text(
                              'Features:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildFeatureItem('• Exercise tracking and analytics', isDark),
                            _buildFeatureItem('• Social fitness community with friends', isDark),
                            _buildFeatureItem('• Personalized workout plans', isDark),
                            _buildFeatureItem('• Progress statistics and monitoring', isDark),
                            _buildFeatureItem('• Office-friendly exercise library', isDark),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Development Team
                      Container(
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
                              'Development Team',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'This app is a collaborative project between health management students and business information systems students at DHBW Ravensburg.',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
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

  static Widget _buildFeatureItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }
}