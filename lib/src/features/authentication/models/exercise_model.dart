
class ExerciseModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int duration; // in seconds
  final int caloriesBurned; // in kcal

  ExerciseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.duration,
    required this.caloriesBurned,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      duration: json['duration'],
      caloriesBurned: json['caloriesBurned'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'duration': duration,
      'caloriesBurned': caloriesBurned,
    };
  }
}