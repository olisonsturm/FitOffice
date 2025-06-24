import 'dart:io';

import 'package:fit_office/src/features/core/controllers/profile_controller.dart';
import 'package:fit_office/src/repository/firebase_storage/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../constants/image_strings.dart';
import 'avatar_zoom.dart';

/// A widget that displays a user's avatar with an option to edit it.
/// This widget allows users to pick an image from their gallery, crop it, and upload it as their profile picture.
/// It uses a [StorageService] to handle image storage and retrieval.
class Avatar extends StatefulWidget {
  final String? userEmail;
  const Avatar({super.key, this.userEmail});

  @override
  ImageWithIconState createState() => ImageWithIconState();
}

class ImageWithIconState extends State<Avatar> {
  final StorageService _storageService = StorageService();
  final profileController = Get.find<ProfileController>();

  File? _selectedImage;
  late ImageProvider _currentAvatar = const AssetImage(tDefaultAvatar);

  @override
  void initState() {
    super.initState();
    _loadAvatar();

    // Listen to profile picture updates
    ever(profileController.profilePictureUpdated, (_) {
      _loadAvatar();
    });
  }

  @override
  void didUpdateWidget(covariant Avatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userEmail != widget.userEmail) {
      _loadAvatar();
    }
  }

  Future<void> _loadAvatar() async {
    try {
      final imageProvider = await _storageService.getProfilePicture(userEmail: widget.userEmail);
      if (mounted) {
        setState(() {
          _currentAvatar = imageProvider;
        });
      }
    } catch (e) {
      debugPrint('Error loading avatar: $e');
      if (mounted) {
        setState(() {
          _currentAvatar = const AssetImage(tDefaultAvatar);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate a unique tag based on the user email if available
    final String heroTag = 'profileAvatar${widget.userEmail ?? "main"}';

    return Stack(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => AvatarZoom(
                    imageProvider: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : _currentAvatar,
                    heroTag: heroTag,
                  ),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
            child: Hero(
              tag: heroTag,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: const AssetImage(tDefaultAvatar), // Immer als Hintergrund
                foregroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : _currentAvatar, // Wird über den Hintergrund gelegt
              ),
            ),
          ),
        ),
      ],
    );
  }
}
