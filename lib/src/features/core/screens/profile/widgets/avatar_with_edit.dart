import 'dart:io';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:fit_office/src/features/core/controllers/profile_controller.dart';
import 'package:fit_office/src/repository/firebase_storage/storage_service.dart';
import 'package:fit_office/src/utils/helper/helper_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../../../constants/colors.dart';
import '../../../../../constants/image_strings.dart';
import 'avatar_zoom.dart';

class AvatarWithEdit extends StatefulWidget {
  const AvatarWithEdit({super.key});

  @override
  ImageWithIconSate createState() => ImageWithIconSate();
}

class ImageWithIconSate extends State<AvatarWithEdit> {
  final StorageService _storageService = StorageService();
  final profileController = Get.find<ProfileController>();

  File? _selectedImage;
  late ImageProvider _currentAvatar = const AssetImage(tDefaultAvatar);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final imageProvider = await _storageService.getProfilePicture();
      if (mounted) {
        setState(() {
          _currentAvatar = imageProvider;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading avatar: $e');
      if (mounted) {
        setState(() {
          _currentAvatar = const AssetImage(tDefaultAvatar);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAndCropImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      final imageBytes = await pickedFile.readAsBytes();
      final cropController = CropController();

      final croppedImage = await Navigator.push<File?>(
        context, // Use context directly here since we just checked mounted
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context, null),
              ),
              title: const Text('Crop Image'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.done),
                  onPressed: () => cropController.crop(),
                ),
              ],
            ),
            body: Crop(
              image: imageBytes,
              controller: cropController,
              aspectRatio: 1,
              onCropped: (result) async {
                switch (result) {
                  case CropSuccess(:final croppedImage):
                    final tempDir = Directory.systemTemp;
                    final uniqueFileName = 'cropped_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
                    final tempFile = File('${tempDir.path}/$uniqueFileName');
                    await tempFile.writeAsBytes(croppedImage);

                    try {
                      await StorageService().uploadProfilePicture(XFile(tempFile.path));
                      debugPrint('Avatar uploaded successfully');

                      // Notify profile controller about the profile picture update
                      profileController.notifyProfilePictureUpdated();
                    } catch (e) {
                      debugPrint('Error uploading avatar: $e');
                    }
                    Navigator.pop(context, tempFile);
                    break;
                  case CropFailure(:final cause):
                    debugPrint('Crop failed: $cause');
                    Navigator.pop(context, null);
                    break;
                }
              },
            ),
          ),
        ),
      );

      if (croppedImage != null && mounted) {
        setState(() {
          _selectedImage = croppedImage;
        });

        // Show success message
        if (mounted) {
          Helper.successSnackBar(title: 'Success', message: 'Avatar updated successfully');
        }

        try {
          if (mounted) {
            setState(() {
              _isLoading = true;
            });
          }

          final avatar = await StorageService().getProfilePicture();
          if (mounted) {
            setState(() {
              _currentAvatar = avatar;
              _isLoading = false;
            });
          }
        } catch (error) {
          debugPrint('Error fetching profile picture: $error');
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        : _isLoading ? const AssetImage(tDefaultAvatar) : _currentAvatar,
                  ),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
            child: Hero(
              tag: 'avatarHero',
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : _isLoading ? const AssetImage(tDefaultAvatar) : _currentAvatar,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickAndCropImage,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: tPrimaryColor,
              ),
              child: const Icon(
                LineAwesomeIcons.pencil_alt_solid,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}