import 'package:fit_office/src/features/core/screens/libary/library_screen.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/global_overlay.dart';
import 'package:get/get.dart';

import '../../features/core/controllers/exercise_timer.dart';

/// Displays a unified dialog with proper timer and focus handling.
/// Ensures:
/// - Global timer is paused/resumed as needed
/// - Focus state (esp. search bar) is preserved/restored correctly
/// - Overlay state is updated to indicate dialog visibility
Future<T?> showUnifiedDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  LibraryScreenState? libraryState,
}) async {
  final timerController = Get.find<ExerciseTimerController>();
  final overlayManager = GlobalExerciseOverlay();
  final dashboard =
      libraryState ?? context.findAncestorStateOfType<LibraryScreenState>();

  if (dashboard?.searchHasFocus == true) {
    dashboard?.wasSearchFocusedBeforeNavigation = true;
  } else {
    dashboard?.wasSearchFocusedBeforeNavigation = false;
  }

  dashboard?.forceRedirectFocus();


  if (dashboard?.searchHasFocus == true) {
    dashboard?.wasSearchFocusedBeforeNavigation = true;
  } else {
    dashboard?.wasSearchFocusedBeforeNavigation = false;
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // Stop the timer if it is running
  final wasRunning =
      timerController.isRunning.value && !timerController.isPaused.value;

  if (wasRunning) {
    timerController.pause();
    timerController.autoPaused.value = true;
  }

  overlayManager.setDialogOpen(true);

  final result = await showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: builder,
  );

  overlayManager.setDialogOpen(false);

  // If the timer was paused due to showing the dialog, we resume it
  if (timerController.autoPaused.value) {
    timerController.resume();
    timerController.autoPaused.value = false;
  }

  // If the timer was running before showing the dialog, we resume it
  dashboard?.handleReturnedFromExercise();

  return result;
}
