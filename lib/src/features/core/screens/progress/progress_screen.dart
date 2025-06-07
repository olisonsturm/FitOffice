import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/constants/sizes.dart';
import 'package:fit_office/src/features/core/screens/progress/widgets/progress_chapter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => ProgressScreenState();
}

class ProgressScreenState extends State<ProgressScreen> {
  int currentStep = 1;
  final int stepsPerChapter = 5;
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _chapterKeys = []; // Liste von GlobalKeys für Kapitel

  void advanceStep() {
    setState(() {
      currentStep++;
    });

    // Check if the current step is the first step of a new chapter
    if ((currentStep - 1) % stepsPerChapter == 0) {
      final int lastFinishedChapter = (currentStep / stepsPerChapter).floor();
      final int targetIndex = lastFinishedChapter;

      // Ensure the targetIndex is within bounds
      if (targetIndex >= 0 && targetIndex < _chapterKeys.length) {
        _scrollToChapter(targetIndex);
      }
    }
  }

  double _getItemHeight(int chapterIndex) {
    final context = _chapterKeys[chapterIndex].currentContext;
    if (context != null) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      return renderBox.size.height + tDefaultSize; // Returns the height of the item
    }
    return 0.0; // Default height if context is null
  }
  
  // TODO: Workaround weil Chapter finden und an den Anfang davon scrollen noch nicht funktioniert
  void _scrollToChapter(int chapterIndex) {
    final double targetOffset = _scrollController.offset + _getItemHeight(chapterIndex);

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Letztes vollständig abgeschlossenes Kapitel:
    final int lastFinishedChapter = (currentStep / stepsPerChapter).floor();

    // Wir zeigen das aktuelle Kapitel und das nächste (auch wenn gesperrt)
    final int visibleChapters = lastFinishedChapter + 2;

    return Scaffold(
      backgroundColor: isDark ? tBlackColor : tWhiteColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: tDefaultSize),
        child: ListView.separated(
          controller: _scrollController, // ScrollController wird hier gesetzt
          physics: const NeverScrollableScrollPhysics(), // Deaktiviert eigenes Scrollen TODO: Workaround weil Chapter finden und an den anfang davon scrollen noch nicht funktioniert
          itemCount: visibleChapters,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, chapterIndex) {
            final int chapterStart = chapterIndex * stepsPerChapter;

            // Kapitel ist gesperrt, wenn der aktuelle Step kleiner ist als der Start des Kapitels
            final bool isLocked = currentStep < chapterStart;

            // GlobalKey für jedes Kapitel hinzufügen
            if (_chapterKeys.length <= chapterIndex) {
              _chapterKeys.add(GlobalKey());
            }

            return ProgressChapterWidget(
              key: _chapterKeys[chapterIndex], // GlobalKey für jedes Kapitel
              chapterIndex: chapterIndex,
              title: '${AppLocalizations.of(context)!.tChapter} ${chapterIndex + 1}',
              currentStep: currentStep,
              startStep: chapterStart,
              stepCount: stepsPerChapter,
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              isLocked: isLocked,
            );
          },
        ),
      ),
      //TODO Only temporary until setps get counted in user model
      floatingActionButton: FloatingActionButton(
        onPressed: advanceStep,
        backgroundColor: tPrimaryColor,
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
