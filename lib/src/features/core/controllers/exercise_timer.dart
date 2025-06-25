import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_office/fit_office.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Controller for managing the global exercise timer.
/// Tracks running time, handles pause/resume logic, saves exercise logs to Firestore,
/// and manages user streaks.
class ExerciseTimerController extends GetxController {
  var isRunning = false.obs;
  var isPaused = false.obs;
  var exerciseName = ''.obs;
  var exerciseCategory = ''.obs;
  var elapsed = Duration.zero.obs;
  var autoPaused = false.obs;

  late final Stopwatch _stopwatch;
  late final RxString formattedTime = "0:00".obs;
  late final Worker _ticker;
  StatisticsController statisticsController = StatisticsController();

  bool _isDisposed = false; // Add disposal flag

  /// Stops the timer and optionally saves the session to Firestore.
  /// Also checks and updates the user's streak based on completed time.
  void stopAndSave({required bool shouldSave}) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && shouldSave) {
      final now = DateTime.now();
      final startTime = now.subtract(elapsed.value);
      final durationInSeconds = elapsed.value.inSeconds;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('exerciseLogs')
          .add({
        'exerciseName': exerciseName.value,
        'category': exerciseCategory.value,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(now),
        'duration': durationInSeconds,
        //in Sekunden --> am Tag dann 300 Sekunden ingesamt nötig, dass die Streak verlängert wird, bzw. die tägliche Mindestdauer erreicht/erfüllt wird
      });

      // Check and update streak - Fixed null safety
      if ((await statisticsController.isStreakActive(user.email!) == false) &&
          (await statisticsController.getDoneExercisesInSeconds(user.email!) >=
              300)) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('streaks')
            .add({'isActive': true, 'startedAt': Timestamp.now()});
      }

      // Update streak controller
      final streakCtrl = Get.find<StreakController>();
      await streakCtrl.loadStreakData();

      // Reset timer state
      _stopwatch.stop();
      _stopwatch.reset();
      isRunning.value = false;
      isPaused.value = false;
      exerciseName.value = '';
      exerciseCategory.value = '';
      elapsed.value = Duration.zero;

      String? currentRoute = Get.currentRoute;
      if (kDebugMode) {
        print("Saving exercise from this route: $currentRoute");
      }

      // Always navigate to Progress screen with animation flag
      Get.to(
        () => const Dashboard(initialIndex: 0),
        arguments: {
          'exerciseCompleted': true,
        },
        preventDuplicates: false, // Allow navigation even if already on Dashboard
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    _stopwatch = Stopwatch();
    _ticker = ever(elapsed, (_) {
      formattedTime.value =
          "${elapsed.value.inMinutes}:${(elapsed.value.inSeconds % 60).toString().padLeft(2, '0')}";
    });
    updateElapsed();
  }

  /// Continuously updates the elapsed time while the stopwatch is running.
  void updateElapsed() async {
    while (!_isDisposed) {
      // Fixed infinite loop with disposal check
      await Future.delayed(const Duration(seconds: 1));
      if (_stopwatch.isRunning && !_isDisposed) {
        elapsed.value = _stopwatch.elapsed;
      }
    }
  }

  /// Starts the timer for a given exercise name and category.
  void start(String name, String category) {
    exerciseName.value = name;
    exerciseCategory.value = category;
    isRunning.value = true;
    isPaused.value = false;
    _stopwatch.start();
  }

  void pause() {
    _stopwatch.stop();
    isPaused.value = true;
  }

  void resume() {
    _stopwatch.start();
    isPaused.value = false;
  }

  /// Stops and resets the timer without saving.
  void stop() {
    _stopwatch.stop();
    _stopwatch.reset();
    isRunning.value = false;
    isPaused.value = false;
    exerciseName.value = '';
    exerciseCategory.value = '';
    elapsed.value = Duration.zero;
  }

  @override
  void onClose() {
    _isDisposed = true; // Stop the infinite loop
    _ticker.dispose(); // Dispose of the worker
    super.onClose();
  }
}

