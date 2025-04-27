import 'package:fit_office/src/constants/colors.dart';
import 'package:flutter/material.dart';

class SliderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final bool showFavoriteIcon;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onBack;

  const SliderAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.showFavoriteIcon = false,
    this.isFavorite = false,
    this.onToggleFavorite,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final Widget centerTitle = subtitle == null
        ? Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold, // IMMER fett
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold, // IMMER fett
                  color: Colors.black,
                ),
              ),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold, // SUBTITLE auch fett
                  color: Colors.black45,
                ),
              ),
            ],
          );

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Stack(
        alignment: Alignment.center,
        children: [
          centerTitle,

          // ← LINKS: Back-Button wenn showBackButton == true
          Align(
            alignment: Alignment.centerLeft,
            child: Builder(
              builder: (context) {
                if (showBackButton) {
                  return IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: onBack ?? () => Navigator.of(context).pop(),
                  );
                } else {
                  return const SizedBox(); // NICHTS anzeigen
                }
              },
            ),
          ),

          // → RECHTS: Favoriten-Icon
          if (showFavoriteIcon)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.black54,
                ),
                onPressed: onToggleFavorite,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
