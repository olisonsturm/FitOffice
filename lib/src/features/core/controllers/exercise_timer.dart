import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

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
        'duration': durationInSeconds,   //in Sekunden --> am Tag dann 300 Sekunden ingesamt nötig, dass die Streak verlängert wird, bzw. die tägliche Mindestdauer erreicht/erfüllt wird
      });
    }

    _stopwatch.stop();
    _stopwatch.reset();
    isRunning.value = false;
    isPaused.value = false;
    exerciseName.value = '';
    exerciseCategory.value = '';
    elapsed.value = Duration.zero;
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
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      if (_stopwatch.isRunning) {
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
}
