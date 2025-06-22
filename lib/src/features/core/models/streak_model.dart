
class StreakModel {
  final int streak;
  final DateTime lastStreakDate;

  StreakModel({
    required this.streak,
    required this.lastStreakDate,
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      streak: json['streak'] as int,
      lastStreakDate: DateTime.parse(json['lastStreakDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streak': streak,
      'lastStreakDate': lastStreakDate.toIso8601String(),
    };
  }
}