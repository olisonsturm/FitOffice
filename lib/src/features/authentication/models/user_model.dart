import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String userName;
  final String email;
  final String fullName;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final String? fitnessLevel;
  final int? completedExercises;
  final String? profilePicture;
  final String? role;
  /// Password should not be stored in the database.
  /// Authentication will handle login logout for us.
  /// So just use this variable to get data from user and pass it to authentication.
  final String? password;

  /// Constructor
  const UserModel(
      {this.id, required this.email, this.password, required this.userName, required this.fullName, this.createdAt, this.updatedAt, this.fitnessLevel, this.completedExercises, this.profilePicture, this.role});

  /// convert model to Json structure so that you can use it to store data in Firebase
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "username": userName,
      "email": email,
      "fullName": fullName,
    };

    if (createdAt != null) data["createdAt"] = createdAt;
    if (updatedAt != null) data["updatedAt"] = updatedAt;
    if (fitnessLevel != null) data["fitnessLevel"] = fitnessLevel;
    if (completedExercises != null) data["completedExercises"] = completedExercises;
    if (profilePicture != null) data["profilePicture"] = profilePicture;
    if (role != null) data["role"] = role;

    return data;
  }

  /// Empty Constructor for UserModel
  static UserModel empty () => const UserModel(id: '', email: '', userName: '', fullName: '');

  /// Map Json oriented document snapshot from Firebase to UserModel
  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    // If document is empty then return an empty Model as created above.
    if(document.data() == null || document.data()!.isEmpty) return UserModel.empty();
    final data = document.data()!;
    return UserModel(
        id: document.id,
        email: data["email"],
        userName: data["username"],
        fullName: data["fullName"],
        createdAt: data["createdAt"],
        updatedAt: data["updatedAt"],
        fitnessLevel: data["fitnessLevel"] ?? "beginner",
        completedExercises: data["completedExercises"] ?? 0,
        profilePicture: data["profilePicture"] ?? "",
        role: data["role"] ?? "user",
    );
  }
}
