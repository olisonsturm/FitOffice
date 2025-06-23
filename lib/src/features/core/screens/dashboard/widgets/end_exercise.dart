import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/l10n/app_localizations.dart';

/// A confirmation dialog to end an ongoing exercise session.
///
/// This widget shows a modal with:
/// - The exercise name
/// - A message asking if the user wants to end the exercise
/// - Two action buttons:
///   - "Finish" (returns `true`)
///   - "Continue" (returns `false`)
///
/// The dialog adapts its styling based on the current brightness mode.
class EndExerciseDialog extends StatelessWidget {
  final String exerciseName;

  const EndExerciseDialog({super.key, required this.exerciseName});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
        child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  365, // Ensures dialog remains nicely sized on all screens
              minWidth: 300,
            ),
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
                          AppLocalizations.of(context)!.tEndExercisePopUp,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : tBlackColor),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        // Message explaining the consequence of ending the exercise
                        Text(
                          AppLocalizations.of(context)!
                              .tEndExerciseConfirmation,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color:
                                isDarkMode ? tPaleWhiteColor : tPaleBlackColor,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          exerciseName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: isDarkMode ? tWhiteColor : tBlackColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        Column(
                          children: [
                            // Button to confirm ending the exercise (returns true)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: tStartExerciseColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.check_circle,
                                    color: Colors.white),
                                label: Text(
                                  AppLocalizations.of(context)!
                                      .tEndExercisePositive,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Cancel the dialog, continue the exercise (returns false)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade500,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.undo_sharp,
                                    color: tWhiteColor),
                                label: Text(
                                  AppLocalizations.of(context)!
                                      .tEndExerciseNegative,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: tWhiteColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
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
                        padding: EdgeInsets.all(4),
                        constraints: BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }
}
