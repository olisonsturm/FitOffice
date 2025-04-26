import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/text_strings.dart';

class SliderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final PreferredSizeWidget? normalAppBar;
  final bool showBackButton;
  final bool showFavoriteIcon;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onBack;

  const SliderAppBar({
    super.key,
    this.normalAppBar,
    this.showBackButton = false,
    this.showFavoriteIcon = false,
    this.isFavorite = false,
    this.onToggleFavorite,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final Widget centerTitle =
        (normalAppBar is AppBar && (normalAppBar as AppBar).title != null)
            ? (normalAppBar as AppBar).title!
            : Text(tAppName, style: Theme.of(context).textTheme.headlineSmall);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Stack(
        alignment: Alignment.center,
        children: [
          centerTitle,

          // ← LINKS: Back- oder Menübutton
          Align(
            alignment: Alignment.centerLeft,
            child: Builder(
              builder: (context) {
                if (showBackButton) {
                  return IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: onBack ?? () => Navigator.pop(context),
                  );
                } else {
                  return IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  );
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




// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:fit_office/src/features/core/controllers/exercise_timer.dart';
// import 'package:fit_office/src/features/core/screens/dashboard/widgets/end_exercise.dart';

// class TimerAwareAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final PreferredSizeWidget normalAppBar;
//   final bool showBackButton;
//     final bool hideIcons; 

//   const TimerAwareAppBar({
//     super.key,
//     required this.normalAppBar,
//     this.hideIcons = false,
//     this.showBackButton = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final timerController = Get.find<ExerciseTimerController>();

//     return Obx(() {
//       final isRunning = timerController.isRunning.value;
//       final isInfoTab =
//           ModalRoute.of(context)?.settings.name == '/exercise_info';

//       if (!isRunning) return normalAppBar;

//       return AppBar(
//         elevation: 0,
//         backgroundColor: Colors.orange,
//         automaticallyImplyLeading: false,
//         centerTitle: true,
//         title: Stack(
//           alignment: Alignment.center,
//           children: [
//             /// CENTER: Übungsname + Kategorie (immer zentriert)
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   timerController.exerciseName.value,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 Text(
//                   timerController.exerciseCategory.value,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     color: Colors.white,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),

//             /// LEFT: zurück-Button (optional) + Timer
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (showBackButton)
//                     IconButton(
//                       icon: const Icon(Icons.arrow_back, color: Colors.white),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 2, right: 12),
//                     child: Text(
//                       timerController.formattedTime.value,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             /// RIGHT: Pause + Stop
//             Align(
//               alignment: Alignment.centerRight,
//               child: hideIcons
//                   ? const SizedBox.shrink()
//                   : Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: Icon(
//                             timerController.isPaused.value
//                                 ? Icons.play_arrow
//                                 : Icons.pause,
//                             size: 28,
//                             color: Colors.white,
//                           ),
//                           onPressed: () {
//                             timerController.isPaused.value
//                                 ? timerController.resume()
//                                 : timerController.pause();
//                           },
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.stop,
//                               size: 28, color: Colors.white),
//                           onPressed: () async {
//                             final confirmed = await showDialog<bool>(
//                               context: context,
//                               barrierDismissible: false,
//                               builder: (_) => const EndExerciseDialog(),
//                             );
//                             if (confirmed == true) timerController.stop();
//                           },
//                         ),
//                       ],
//                     ),
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }
