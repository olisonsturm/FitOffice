import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String userName;
  final String email;
  final String fullName;
  /// Password should not be stored in the database.
  /// Authentication will handle login logout for us.
  /// So just use this variable to get data from user and pass it to authentication.
  final String? password;

  /// Constructor
  const UserModel(
      {this.id, required this.email, this.password, required this.userName, required this.fullName});

  /// convert model to Json structure so that you can use it to store data in Firebase
  toJson() {
    return {
      "username": userName,
      "email": email,
      "fullName": fullName,
    };
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
        email: data["email"] ?? '',
        userName: data["username"] ?? '',
        fullName: data["fullName"] ?? ''
    );
  }
}
