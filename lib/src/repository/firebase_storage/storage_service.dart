import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fit_office/src/repository/user_repository/user_repository.dart';
import 'package:fit_office/src/utils/helper/helper_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/colors.dart';
import '../../constants/image_strings.dart';
import '../../features/authentication/models/user_model.dart';
import '../../features/core/controllers/profile_controller.dart';

/// StorageService is responsible for managing file uploads and retrievals
/// to Firebase Storage and Firestore.
class StorageService {
  final Reference storage = FirebaseStorage.instance.ref();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final UserRepository userRepository = UserRepository.instance;
  final controller = Get.put(ProfileController());


  /// Uploads a profile picture for a user
  /// @param imageFile The image file to be uploaded
  /// @throws Exception if the user ID is null or if the upload fails
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
  /// @param userId The ID of the user whose profile picture is to be deleted
  /// @throws Exception if the deletion fails
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
  /// @param userEmail The email of the user whose profile picture is to be retrieved
  /// @return A Future that resolves to an ImageProvider for the profile picture
  /// @throws Exception if the user document is not found or if the profile picture path is invalid
  Future<ImageProvider> getProfilePicture({String? userEmail}) async {
    try {
      late final DocumentSnapshot doc;

      // Fetch the user's Firestore document
      if (userEmail != null){
        final querySnapshot = await firestore
            .collection('users')
            .where('email', isEqualTo: userEmail)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          doc = querySnapshot.docs.first;
        }
      } else {
        final userData = await controller.getUserData();
        final UserModel user = userData;

        // Ensure the user ID is valid
        if (user.id == null) {
          throw Exception('User ID is null');
        }
        doc = await firestore.collection('users').doc(user.id).get();
        if (!doc.exists) {
          throw Exception('User document not found for userId: ${user.id}');
        }
      }

      // Retrieve the profilePicture field (file path) from the document
      final profilePicturePath = (doc.data() as Map<String, dynamic>?)?['profilePicture'] as String?;

      if (profilePicturePath == null || profilePicturePath.isEmpty) {
        // Fallback to a default profile picture from assets
        return const AssetImage(tDefaultAvatar);
      }

      // Dynamically generate the download URL
      final ref = FirebaseStorage.instance.ref(profilePicturePath);
      final downloadUrl = await ref.getDownloadURL();

      if (downloadUrl.startsWith('http')) {
        final cachedImage = CachedNetworkImage(
          imageUrl: downloadUrl,
          placeholder: (context, url) => const Center(
            child: CupertinoActivityIndicator(
              color: tPrimaryColor,
            ),
          ),
          errorWidget: (context, url, error) => const Image(
            image: AssetImage(tDefaultAvatar),
          ),
        );

        return CachedNetworkImageProvider(
          cachedImage.imageUrl,
          cacheManager: cachedImage.cacheManager,
        );
      }
      // If the URL is not valid, return a default image
      return const AssetImage(tDefaultAvatar);
    } catch (e) {
      debugPrint('Error fetching profile picture: $e');
      return const AssetImage(tDefaultAvatar);
    }
  }

  /// Uploads a file to Firebase Storage
  /// @param file The file to be uploaded
  /// @param storagePath The path in the storage bucket where the file will be stored
  /// @param contentType The content type of the file (default is 'image/jpeg')
  /// @param customMetadata Optional custom metadata to be associated with the file
  /// @return A Future that resolves to an UploadTask if the upload is successful, or null if no file was selected
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