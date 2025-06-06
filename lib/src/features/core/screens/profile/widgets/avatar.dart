import 'dart:io';

import 'package:fit_office/src/repository/firebase_storage/storage_service.dart';
import 'package:flutter/material.dart';

import '../../../../../constants/image_strings.dart';
import 'avatar_zoom.dart';

class Avatar extends StatefulWidget {
  final String? userEmail;
  const Avatar({super.key, this.userEmail});

  @override
  ImageWithIconSate createState() => ImageWithIconSate();
}

class ImageWithIconSate extends State<Avatar> {

  final StorageService _storageService = StorageService();

  File? _selectedImage;
  late ImageProvider _currentAvatar = const AssetImage(tDefaultAvatar);

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    try {
      final imageProvider = await _storageService.getProfilePicture(userEmail: widget.userEmail);
      setState(() {
        _currentAvatar = imageProvider;
      });
    } catch (e) {
      debugPrint('Error loading avatar: $e');
      setState(() {
        _currentAvatar = const AssetImage(tDefaultAvatar);
      });
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
                        : _currentAvatar,
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
                    : _currentAvatar,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
