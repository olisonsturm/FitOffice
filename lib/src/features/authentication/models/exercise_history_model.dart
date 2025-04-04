
class ExerciseHistoryModel {
  final String id;
  final String userId;
  final String exerciseId;
  final DateTime date;
  final int duration; // in minutes
  final int caloriesBurned;

  ExerciseHistoryModel({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.date,
    required this.duration,
    required this.caloriesBurned,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'exerciseId': exerciseId,
      'date': date.toIso8601String(),
      'duration': duration,
      'caloriesBurned': caloriesBurned,
    };
  }

  factory ExerciseHistoryModel.fromJson(Map<String, dynamic> json) {
    return ExerciseHistoryModel(
      id: json['id'],
      userId: json['userId'],
      exerciseId: json['exerciseId'],
      date: DateTime.parse(json['date']),
      duration: json['duration'],
      caloriesBurned: json['caloriesBurned'],
    );
  }
}