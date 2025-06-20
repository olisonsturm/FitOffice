import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_office/src/features/core/controllers/statistics_controller.dart';
import 'package:get/get.dart';

import '../screens/dashboard/dashboard.dart';

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

  void stopAndSave({required bool shouldSave}) async {
    final user = FirebaseAuth.instance.currentUser;
    bool isFirstExerciseInTimeWindow = false;

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

      // Check if this is the first exercise in the last 4 hours
      isFirstExerciseInTimeWindow = await checkIfFirstExerciseInTimeWindow(user.uid);

      // Check and update streak - Fixed null safety
      if ((await statisticsController.isStreakActive(user.email!) == false) &&
          (await statisticsController.getDoneExercisesInSeconds(user.email!) >= 300)) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('streaks')
            .add({'isActive': true, 'startedAt': Timestamp.now()});
      }

      // Update streak controller
      final streakCtrl = Get.find<StreakController>();
      await streakCtrl.loadStreakData();
    }

    // Reset timer state
    _stopwatch.stop();
    _stopwatch.reset();
    isRunning.value = false;
    isPaused.value = false;
    exerciseName.value = '';
    exerciseCategory.value = '';
    elapsed.value = Duration.zero;

    // Navigate to dashboard with Progress tab selected
    Get.offAll(
            () => Dashboard(initialIndex: 0),
        arguments: {
          'exerciseCompleted': true,
          'isFirstInTimeWindow': isFirstExerciseInTimeWindow
        }
    );
  }

// New method to check if this is the first exercise in the last 4 hours
  Future<bool> checkIfFirstExerciseInTimeWindow(String userId) async {
    final now = DateTime.now();
    final fourHoursAgo = now.subtract(const Duration(hours: 4));

    // Query for any completed exercises in the last 4 hours
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('exerciseLogs')
        .where('endTime', isGreaterThan: Timestamp.fromDate(fourHoursAgo))
        .orderBy('endTime', descending: true)
        .limit(2)  // Get at most 2 to check if the current one is first
        .get();

    // If there's only 1 result (the one we just added), it's the first in 4 hours
    return snapshot.docs.length <= 1;
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

  void updateElapsed() async {
    while (!_isDisposed) { // Fixed infinite loop with disposal check
      await Future.delayed(const Duration(seconds: 1));
      if (_stopwatch.isRunning && !_isDisposed) {
        elapsed.value = _stopwatch.elapsed;
      }
    }
  }

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