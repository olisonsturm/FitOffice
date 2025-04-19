import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../../../constants/colors.dart';
import '../../../../../repository/supabase_repository/supabase_service.dart';
import 'avatar.dart';

class ImageWithIcon extends StatefulWidget {
  const ImageWithIcon({super.key});

  @override
  ImageWithIconSate createState() => ImageWithIconSate();
}

class ImageWithIconSate extends State<ImageWithIcon> {

  File? _selectedImage;
  String _currentAvatarUrl =
      'https://eycjcipufiabddbzaqip.supabase.co/storage/v1/object/public/users/'+ FirebaseAuth.instance.currentUser!.uid +'/avatar.png';
  //TODO String _currentAvatarUrl = SupabaseService().getProfilePictureUrl(FirebaseAuth.instance.currentUser!.uid) as String;


  Future<void> _pickAndCropImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _selectedImage = File(croppedFile.path);
        });

        // Upload the new avatar
        await SupabaseService().uploadProfilePicture(
          FirebaseAuth.instance.currentUser!.uid,
          croppedFile as File,
        );
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
                LineAwesomeIcons.alternate_pencil,
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
