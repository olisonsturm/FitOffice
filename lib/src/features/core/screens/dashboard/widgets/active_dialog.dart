import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ActiveTimerDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;

  const ActiveTimerDialog({
    super.key,
    required this.title,
    required this.message,
    required this.buttonText,
  });

  factory ActiveTimerDialog.forAction(String actionType, BuildContext context) {
    switch (actionType) {
      case 'delete':
        return ActiveTimerDialog(
          title: AppLocalizations.of(context)!.tActiveExercise,
          message: AppLocalizations.of(context)!.tActiveExerciseDialogMessageDelete,
          buttonText: AppLocalizations.of(context)!.tActiveExerciseAnswer,
        );
      case 'edit':
        return ActiveTimerDialog(
          title: AppLocalizations.of(context)!.tActiveExercise,
          message: AppLocalizations.of(context)!.tActiveExerciseDialogMessageEdit,
          buttonText: AppLocalizations.of(context)!.tActiveExerciseAnswer,
        );
      case 'start':
        return ActiveTimerDialog(
          title: AppLocalizations.of(context)!.tActiveExercise,
          message: AppLocalizations.of(context)!.tActiveExerciseDialogMessageStart,
          buttonText: AppLocalizations.of(context)!.tActiveExerciseAnswer,
        );
        case 'editprofile':
        return ActiveTimerDialog(
          title: AppLocalizations.of(context)!.tActiveExercise,
          message: AppLocalizations.of(context)!.tActiveExerciseDialogMessageEditProfile,
          buttonText: AppLocalizations.of(context)!.tActiveExerciseAnswer,
        );
        case 'logout':
        return ActiveTimerDialog(
          title: AppLocalizations.of(context)!.tActiveExercise,
          message: AppLocalizations.of(context)!.tActiveExerciseDialogMessageLogout,
          buttonText: AppLocalizations.of(context)!.tActiveExerciseAnswer,
        );
        case 'addfriends':
        return ActiveTimerDialog(
          title: AppLocalizations.of(context)!.tActiveExercise,
          message: AppLocalizations.of(context)!.tActiveExerciseDialogMessageAddFriends,
          buttonText: AppLocalizations.of(context)!.tActiveExerciseAnswer,
        );
        case 'viewfriends':
        return ActiveTimerDialog(
          title: AppLocalizations.of(context)!.tActiveExercise,
          message: AppLocalizations.of(context)!.tActiveExerciseDialogMessageViewFriends,
          buttonText: AppLocalizations.of(context)!.tActiveExerciseAnswer,
        );
        case 'admin':
        return ActiveTimerDialog(
          title: AppLocalizations.of(context)!.tActiveExercise,
          message: AppLocalizations.of(context)!.tActiveExerciseDialogMessageAdmin,
          buttonText: AppLocalizations.of(context)!.tActiveExerciseAnswer,
        );
      default:
        return ActiveTimerDialog(
          title: AppLocalizations.of(context)!.tActiveExercise,
          message: AppLocalizations.of(context)!.tActiveExerciseDialogMessageDefault,
          buttonText: AppLocalizations.of(context)!.tActiveExerciseAnswer,
        );
    }
  }

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
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : tBlackColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: isDarkMode ? tPaleWhiteColor : tPaleBlackColor,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDarkMode ? tGreyColor : tPaleBlackColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide.none,
                        ),
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: Text(
                          buttonText,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
