import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fit_office/src/utils/helper/helper_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final storage = FirebaseStorage.instance.ref();


  /// Uploads a profile picture for a user
  Future<void> uploadProfilePicture(String userId, XFile imageFile) async {
    uploadFile(file: imageFile, storagePath: 'avatars/$userId', contentType: 'image/jpeg');
  }

  /// Deletes a user's profile picture
  Future<void> deleteProfilePicture(String userId) async {
    try {
      // Reference the file in Firebase Storage
      Reference ref = storage.child('avatars/$userId');

      // Delete the file
      await ref.delete();

      Helper.successSnackBar(title: 'Profile picture deleted successfully');
    } catch (e) {
      // Handle errors (e.g., file not found)
      throw Exception('Failed to delete profile picture: $e');
    }
  }

  /// Retrieves the public URL of a user's profile picture
  Future<String> getProfilePictureUrl(String userId) async {
    try {
      // Reference the file in Firebase Storage
      Reference ref = storage.child('avatars/$userId');

      // Get the download URL
      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      // Handle errors (e.g., file not found)
      throw Exception('Failed to retrieve profile picture URL: $e');
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

  Future<void> _downloadLink(Reference ref) async {
    final link = await ref.getDownloadURL();

    await Clipboard.setData(
      ClipboardData(
        text: link,
      ),
    );

    Helper.successSnackBar(title: 'Success!\n Copied download URL to Clipboard!');
  }

  Future<void> _downloadFile(Reference ref) async {
    final Directory systemTempDir = Directory.systemTemp;
    final File tempFile = File('${systemTempDir.path}/temp-${ref.name}');
    if (tempFile.existsSync()) await tempFile.delete();

    await ref.writeToFile(tempFile);

    Helper.successSnackBar(title: 'Success!\n Downloaded ${ref.name} \n from bucket: ${ref.bucket}\n '
        'at path: ${ref.fullPath} \n'
        'Wrote "${ref.fullPath}" to tmp-${ref.name}');
  }

  Future<void> _delete(Reference ref) async {
    await ref.delete();

    Helper.successSnackBar(title: 'Success!\n deleted ${ref.name} \n from bucket: ${ref.bucket}\n '
        'at path: ${ref.fullPath} \n');
  }
}