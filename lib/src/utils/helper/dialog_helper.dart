import 'package:flutter/material.dart';
import 'package:fit_office/src/features/core/controllers/exercise_timer.dart';
import 'package:fit_office/src/features/core/screens/dashboard/dashboard.dart';
import 'package:fit_office/global_overlay.dart';
import 'package:get/get.dart';

Future<T?> showUnifiedDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  DashboardState? dashboardState,
}) async {
  final timerController = Get.find<ExerciseTimerController>();
  final overlayManager = GlobalExerciseOverlay();
  final dashboard =
      dashboardState ?? context.findAncestorStateOfType<DashboardState>();

  // Fokus vor Dialog merken
  final wasFocused = dashboardState?.searchHasFocus ?? false;
  dashboardState?.wasSearchFocusedBeforeNavigation = wasFocused;

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
