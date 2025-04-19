import 'dart:io';
import 'package:fit_office/src/features/authentication/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  /// Creates a bucket if it doesn't exist
Future<void> createBucketIfNotExists(String bucketId) async {
  try {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    final buckets = await supabase.storage.listBuckets();
    if (!buckets.any((bucket) => bucket.id == bucketId)) {
      await supabase.storage.createBucket(bucketId);
      await supabase.storage.updateBucket(bucketId, const BucketOptions(public: true));
    }
  } catch (e) {
    throw Exception('Error creating bucket: $e');
  }
}

  /// Uploads a profile picture for a user
  Future<String> uploadProfilePicture(String userId, File imageFile) async {
    const bucketId = 'users';
    final filePath = '$userId/avatar.png';
    try {
      // Ensure the bucket exists
      // await createBucketIfNotExists(bucketId);

      // Upload the file TODO fullPath???
      final String fullPath =
      await supabase.storage.from(bucketId).upload(
        filePath,
        imageFile,
        fileOptions: const FileOptions(upsert: true),
      );

      // Retrieve the public URL
      final String publicUrl = supabase.storage.from(bucketId).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      throw Exception('Error uploading profile picture: $e');
    }
  }

  /// Deletes a user's profile picture
  Future<void> deleteProfilePicture(String userId) async {
    const bucketId = 'users';
    final filePath = '$userId/avatar.png';

    try {
      await supabase.storage.from(bucketId).remove([filePath]);
    } catch (e) {
      throw Exception('Error deleting profile picture: $e');
    }
  }

  /// Retrieves the public URL of a user's profile picture
  Future<String> getProfilePictureUrl(String userId) async {
    const bucketId = 'users';
    final filePath = '$userId/avatar.png';

    try {
      final String publicUrl = supabase.storage.from(bucketId).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      throw Exception('Error retrieving profile picture URL: $e');
    }
  }
}