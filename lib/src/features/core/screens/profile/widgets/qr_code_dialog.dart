import 'package:fit_office/src/features/core/screens/profile/widgets/custom_profile_button.dart';
import 'package:fit_office/src/utils/helper/helper_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../constants/colors.dart';
import '../../../../../utils/services/deep_link_service.dart';

/// A dialog that displays a QR code for adding a user as a friend.
class QrCodeDialog extends StatelessWidget {
  final String link;
  final String userName;
  final String userId;

  const QrCodeDialog({super.key, required this.link, required this.userName, required this.userId,});

  static Future<void> show(BuildContext context, String userId, String userName) async {
    final link = await DeepLinkService.generateFriendRequestLink(userId);

    showDialog(
      context: context,
      builder: (_) => QrCodeDialog(link: link, userName: userName, userId: userId,),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add @$userName as Friend',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: QrImageView(
                data: link,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.transparent,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: isDark ? Colors.white : Colors.black,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Copy to clipboard row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    link,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copy link',
                  color: tPrimaryColor,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: link));
                    Helper.successSnackBar(title: 'Link Copied', message: 'The link has been copied to your clipboard.');
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Scan this QR code to send a friend request',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            Divider(height: 1, color: isDark ? Colors.grey[700] : Colors.grey[300]),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: CustomProfileButton(
                    isDark: isDark,
                    icon: Icons.close,
                    label: 'Close',
                    onPress: () {
                      Navigator.of(context).pop();
                    },
                    iconColor: isDark ? Colors.grey[300]! : Colors.grey[800]!,
                    textColor: isDark ? Colors.grey[300]! : Colors.grey[800]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomProfileButton(
                    isDark: isDark,
                    icon: Icons.share,
                    label: 'Share Link',
                    onPress: () async {
                      SharePlus.instance.share(
                        ShareParams(
                          text: 'Add me as a friend on FitOffice@DHBW!\n$link',
                          subject: 'Friend Request',
                        ),
                      );
                    },
                    iconColor: tPrimaryColor,
                    textColor: tPrimaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}