import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fit_office/src/repository/user_repository/user_repository.dart';
import 'package:fit_office/src/utils/helper/helper_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';

import '../../features/authentication/models/user_model.dart';
import '../../features/core/controllers/profile_controller.dart';

class StorageService {
  final Reference storage = FirebaseStorage.instance.ref();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final UserRepository userRepository = UserRepository.instance;
  final controller = Get.put(ProfileController());


  /// Uploads a profile picture for a user
  Future<void> uploadProfilePicture(XFile imageFile) async {
    try {
      final userData = await controller.getUserData();
      final UserModel user = userData;

      // Ensure the user ID is valid
      if (user.id == null) {
        throw Exception('User ID is null');
      }

      // Define the storage path
      final storagePath = 'avatars/${user.id}';

      // Upload the file to Firebase Storage
      final uploadTask = await uploadFile(
        file: imageFile,
        storagePath: storagePath,
        contentType: 'image/jpeg',
      );

      if (uploadTask != null) {
        await uploadTask.whenComplete(() async {
          // Update the user's Firestore document with the download URL
          await userRepository.updateUserRecord(user.id!, {'profilePicture': storagePath});
        });
      }
    } catch (e) {
      // Handle errors (e.g., file not found)
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  /// Deletes a user's profile picture
  Future<void> deleteProfilePicture(String userId) async {
    try {
      // Reference the file in Firebase Storage
      Reference ref = storage.child('avatars/$userId');

      // Delete the file
      await ref.delete();

      // Update the user's Firestore document to set profilePicture to an empty string
      await firestore.collection('users').doc(userId).update({'profilePicture': ''});
    } catch (e) {
      // Handle errors (e.g., file not found)
      throw Exception('Failed to delete profile picture: $e');
    }
  }

  /// Retrieves the public URL of a user's profile picture
  Future<ImageProvider> getProfilePicture() async {
    try {
      // Retrieve the user document
      final userData = await controller.getUserData();
      final UserModel user = userData;

      // Ensure the user ID is valid
      if (user.id == null) {
        throw Exception('User ID is null');
      }

      // Fetch the user's Firestore document
      final userDoc = await firestore.collection('users').doc(user.id).get();

      if (!userDoc.exists) {
        throw Exception('User document not found for userId: ${user.id}');
      }

      // Retrieve the profilePicture field (file path) from the document
      final profilePicturePath = userDoc.data()?['profilePicture'] as String?;

      if (profilePicturePath == null || profilePicturePath.isEmpty) {
        // Fallback to a default profile picture from assets
        return const AssetImage('assets/images/profile/default_avatar.png');
      }

      // Dynamically generate the download URL
      final ref = FirebaseStorage.instance.ref(profilePicturePath);
      final downloadUrl = await ref.getDownloadURL();
      return CachedNetworkImageProvider(downloadUrl);
    } catch (e) {
      debugPrint('Error fetching profile picture: $e');
      return const AssetImage('assets/images/profile/default_avatar.png');
    }
  }

  Future<UploadTask?> uploadFile({
    required XFile? file,
    required String storagePath, // Path in the storage bucket
    String contentType = 'image/jpeg', // Default content type
    Map<String, String>? customMetadata, // Optional custom metadata
  }) async {
    if (file == null) {
      Helper.warningSnackBar(title: 'No file was selected');
      return null;
    }

    UploadTask uploadTask;

    // Create a Reference to the file
    Reference ref = storage.child(storagePath);

    final metadata = SettableMetadata(
      contentType: contentType,
      customMetadata: customMetadata ?? {'picked-file-path': file.path},
    );

    if (kIsWeb) {
      uploadTask = ref.putData(await file.readAsBytes(), metadata);
    } else {
      uploadTask = ref.putFile(File(file.path), metadata);
    }

    return Future.value(uploadTask);
  }

}