import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/l10n/app_localizations.dart';

class StartExerciseDialog extends StatelessWidget {
  final String exerciseName;

  const StartExerciseDialog({super.key, required this.exerciseName});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
        child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 365,
              minWidth: 300,
            ),
            child: Material(
              borderRadius: BorderRadius.circular(20),
              color: isDarkMode ? tDarkColor : tWhiteColor,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context)!.tStartExercisePopUp,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : tBlackColor),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          AppLocalizations.of(context)!.tStartExerciseConfirmation,
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
                                icon: const Icon(Icons.play_arrow,
                                    color: Colors.white),
                                label: Text(
                                  AppLocalizations.of(context)!.tStartExercisePositive,
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
                                  AppLocalizations.of(context)!.tStartExerciseNegative,
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
                          color: isDarkMode
                              ? tPaleWhiteColor
                              : tPaleBlackColor,
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
