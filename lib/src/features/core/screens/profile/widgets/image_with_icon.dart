import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_office/src/repository/firebase_storage/storage_service.dart';
import 'package:fit_office/src/utils/helper/helper_controller.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../../../constants/colors.dart';
import 'avatar.dart';

class ImageWithIcon extends StatefulWidget {
  const ImageWithIcon({super.key});

  @override
  ImageWithIconSate createState() => ImageWithIconSate();
}

class ImageWithIconSate extends State<ImageWithIcon> {

  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final User _user = FirebaseAuth.instance.currentUser!;
  final StorageService _storageService = StorageService();

  File? _selectedImage;
  String _currentAvatarUrl = '';

  @override
  void initState() {
    super.initState();
    _loadAvatarUrl();
  }

  Future<void> _loadAvatarUrl() async {
    final url = await _storageService.getProfilePictureUrl(_user.uid);
    setState(() {
      _currentAvatarUrl = url;
    });
  }

  Future<void> _pickAndCropImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      final cropController = CropController();

      final croppedImage = await Navigator.push<File?>(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context, null), // Rückgabe von null bei Abbruch
              ),
              title: const Text('Crop Image'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.done),
                  onPressed: () => cropController.crop(), // Cropping auslösen
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

                    // TODO hochladen des neuen Avatars
                    StorageService().uploadProfilePicture(_user.uid, XFile(tempFile.path));

                    Navigator.pop(context, tempFile); // Rückgabe des zugeschnittenen Bildes
                    break;
                  case CropFailure(:final cause):
                    debugPrint('Crop failed: $cause');
                    Navigator.pop(context, null); // Rückgabe von null bei Fehler
                    break;
                }
              },
            ),
          ),
        ),
      );

      if (croppedImage != null) {
        setState(() {
          _selectedImage = croppedImage;
          Helper.successSnackBar(title: 'Success', message: 'Avatar updated successfully');
        });

        StorageService().getProfilePictureUrl(_user.uid).then((url) {
          setState(() {
            _currentAvatarUrl = url;
          });
        }).catchError((error) {
          debugPrint('Error fetching profile picture URL: $error');
        });
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
                  pageBuilder: (_, __, ___) => Avatar(imageProvider: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : CachedNetworkImageProvider(_currentAvatarUrl) as ImageProvider),
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
                    : CachedNetworkImageProvider(_currentAvatarUrl) as ImageProvider,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickAndCropImage, // Open picker when pencil icon is clicked
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
