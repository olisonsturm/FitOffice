import 'package:fit_office/src/features/core/screens/libary/library_screen.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/global_overlay.dart';
import 'package:get/get.dart';

import '../../features/core/controllers/exercise_timer.dart';

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

  // 🧠 Nur merken, wenn der Fokus aktuell NOCH aktiv ist
  if (dashboard?.searchHasFocus == true) {
    dashboard?.wasSearchFocusedBeforeNavigation = true;
  } else {
    dashboard?.wasSearchFocusedBeforeNavigation = false;
  }

  dashboard?.forceRedirectFocus();

  // FocusManager.instance.primaryFocus?.unfocus();
  // dashboard?.removeSearchFocus();

  if (dashboard?.searchHasFocus == true) {
    dashboard?.wasSearchFocusedBeforeNavigation = true;
  } else {
    dashboard?.wasSearchFocusedBeforeNavigation = false;
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // Timer pausieren, falls aktiv
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

  // Timer ggf. wieder starten
  if (timerController.autoPaused.value) {
    timerController.resume();
    timerController.autoPaused.value = false;
  }

  // Fokus korrekt behandeln
  dashboard?.handleReturnedFromExercise();

  return result;
}
