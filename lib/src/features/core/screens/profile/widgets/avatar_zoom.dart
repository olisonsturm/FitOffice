import 'package:flutter/material.dart';

class AvatarZoom extends StatelessWidget {
  final ImageProvider imageProvider;
  final String heroTag;

  const AvatarZoom({
    super.key,
    required this.imageProvider,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: heroTag,
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40, // Adjust the position as needed
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop(); // Navigate back
              },
            ),
          ),
        ],
      ),
    );
  }
}