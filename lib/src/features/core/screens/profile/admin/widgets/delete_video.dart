import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/l10n/app_localizations.dart';

/// A custom confirmation dialog widget for deleting a video.
///
/// This widget presents the user with a confirmation prompt containing:
/// - A title asking for video deletion.
/// - A description message explaining the consequence.
/// - A red "Delete" button that confirms deletion and returns `true`.
/// - A gray "Cancel" button that cancels the action and returns `false`.
/// - A close icon in the top-right corner to dismiss the dialog without a result.
///
/// This dialog is localized using [AppLocalizations] and supports dark mode.
///
/// ### Usage:
/// Call it using `showDialog()` and await the result:
/// ```dart
/// final bool? confirmed = await showDialog<bool>(
///   context: context,
///   builder: (context) => const ConfirmVideoDeleteDialog(),
/// );
///
/// if (confirmed == true) {
///   // Perform video deletion
/// }
class ConfirmVideoDeleteDialog extends StatelessWidget {
  const ConfirmVideoDeleteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
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
                      AppLocalizations.of(context)!.tDeleteVideo,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? tWhiteColor : tBlackColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context)!.tDeleteVideoMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: isDarkMode ? tPaleWhiteColor : tPaleBlackColor,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade500,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide.none,
                            ),
                            icon: const Icon(Icons.delete, color: tWhiteColor),
                            label: Text(
                              AppLocalizations.of(context)!.tDeleteVideoPositive,
                              style: TextStyle(
                                fontSize: 18,
                                color: tWhiteColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isDarkMode ? tGreyColor : tPaleBlackColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide.none,
                            ),
                            icon: const Icon(Icons.undo, color: Colors.white),
                            label: Text(
                              AppLocalizations.of(context)!.tDeleteVideoNegative,
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
                    onPressed: () => Navigator.of(context).pop(),
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
    );
  }
}
