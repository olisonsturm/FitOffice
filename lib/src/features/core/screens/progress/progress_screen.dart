import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/constants/sizes.dart';
import 'package:fit_office/src/features/core/screens/progress/widgets/progress_chapter_widget.dart';
import 'package:fit_office/src/features/core/controllers/statistics_controller.dart';
import 'package:fit_office/src/features/core/controllers/profile_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

/// ProgressScreen displays the user's progress through chapters of exercises,
/// allowing them to see their current step, chapter completion, and animations
/// for chapter transitions.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => ProgressScreenState();
}

class ProgressScreenState extends State<ProgressScreen>
    with TickerProviderStateMixin {
  int currentStep = 0;
  final int stepsPerChapter = 5;
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _chapterKeys = [];

  // Konstante für die berechnete Höhe pro Kapitel (basierend auf deinen Logs)
  static const double chapterHeight = 693.0; // 677 + 16 padding
  static const double separatorHeight = 18.0; // 2 + 8 + 8 margins
  static const double totalChapterHeight = chapterHeight + separatorHeight; // 711.0

  // Animation controllers
  late AnimationController _stepAnimationController;
  late AnimationController _chapterAnimationController;
  late Animation<double> _stepAnimation;
  late Animation<double> _chapterAnimation;

  bool _isAnimating = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers - Animation schneller machen
    _stepAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400), // Reduziert von 800ms auf 400ms
      vsync: this,
    );

    _chapterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600), // Reduziert von 1200ms auf 600ms
      vsync: this,
    );

    _stepAnimation = CurvedAnimation(
      parent: _stepAnimationController,
      curve: Curves.easeOutQuad, // Sanftere, schnellere Kurve statt easeInOutBack
    );

    _chapterAnimation = CurvedAnimation(
      parent: _chapterAnimationController,
      curve: Curves.elasticOut,
    );

    // Check if we arrived from completing an exercise
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if we have arguments from exercise completion
      if (Get.arguments != null &&
          Get.arguments['exerciseCompleted'] == true &&
          Get.arguments['isFirstInTimeWindow'] == true) {
        // Advance step as this is the first exercise in the time window
        advanceStep();
      } else {
        // Regular initialization - load progress normally
        _loadProgressFromStatistics();
      }

      // After short delay, scroll to current chapter
      Future.delayed(const Duration(milliseconds: 300), () {
        if (currentStep > 0) {
          _scrollToCurrentChapter();
        }
      });
    });
  }

  @override
  void dispose() {
    _stepAnimationController.dispose();
    _chapterAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProgressFromStatistics() async {
    try {
      final profileController = Get.find<ProfileController>();
      final user = await profileController.getUserData();
      final statisticsController = StatisticsController();

      // Get streak information
      final streakSteps = await statisticsController.getStreakSteps(user.email);
      final secondsToday = await statisticsController.getDoneExercisesInSeconds(user.email);

      // Calculate current step based on streak and daily goal
      int calculatedStep = _calculateCurrentStep(streakSteps, secondsToday);

      // Animate to the calculated step
      if (calculatedStep > 0) {
        await _animateToStep(calculatedStep);
      }

      setState(() {
        _isInitialized = true;
      });

    } catch (e) {
      if (kDebugMode) {
        print('Error loading progress: $e');
      }
      setState(() {
        _isInitialized = true;
      });
    }
  }

  int _calculateCurrentStep(int streakSteps, int secondsToday) {
    const int dailyGoalSeconds = 300; // 5 minutes

    // If no streak or streak broken for too long, reset to 0
    if (streakSteps == 0) {
      return 0;
    }

    // If today's goal is not met, don't advance
    if (secondsToday < dailyGoalSeconds) {
      // Return the last completed step (streak - 1)
      return streakSteps > 0 ? streakSteps : 0;
    }

    // Return current streak + 1 (today's completion)
    return streakSteps + 1;
  }

  Future<void> _animateToStep(int targetStep) async {
    if (_isAnimating || targetStep <= currentStep) return;

    setState(() {
      _isAnimating = true;
    });

    // Animate each step with a slight delay
    for (int step = currentStep + 1; step <= targetStep; step++) {
      await _animateSingleStep(step);
      await Future.delayed(const Duration(milliseconds: 200));
    }

    setState(() {
      _isAnimating = false;
    });
  }

  Future<void> _animateSingleStep(int step) async {
    // Prüfen, ob wir zum nächsten Kapitel wechseln müssen (Tag 1 eines neuen Kapitels)
    final bool isFirstStepOfNewChapter = step % stepsPerChapter == 1 && step > stepsPerChapter;
    // Prüfen, ob wir am Ende eines Kapitels sind (Tag 5)
    final bool isLastStepOfChapter = step % stepsPerChapter == 0;

    // nächste Kapitel berechnen
    final int nextChapter = (step / stepsPerChapter).floor();

    // Wenn wir zum ersten Schritt eines neuen Kapitels wechseln, zuerst scrollen,
    // damit der Benutzer die Animation sehen kann
    if (isFirstStepOfNewChapter) {
      // Hier scrollen wir zum neuen Kapitel vor der Animation
      await _scrollToChapterAndWait(nextChapter);
    }

    // Jetzt aktualisieren wir den aktuellen Schritt und starten die Animation
    setState(() {
      currentStep = step;
    });

    // Trigger step animation
    _stepAnimationController.reset();
    await _stepAnimationController.forward();

    // Wenn wir gerade das letzte Step eines Kapitels abgeschlossen haben (Tag 5),
    // sofort zum nächsten Kapitel scrollen, damit es bereit ist für Tag 1
    if (isLastStepOfChapter) {
      // Animation für das AKTUELLE Kapitel (nicht das nächste)
      final int completedChapter = (step / stepsPerChapter).floor() - 1;

      if (completedChapter >= 0 && completedChapter < _chapterKeys.length) {
        // Kapitel-Animation auslösen
        await _animateChapterCompletion();

        // HIER NEU: Nach Tag 5 Animation und Kapitelabschluss bereits zum
        // nächsten Kapitel scrollen, ohne auf Tag 1 Animation zu warten
        await _scrollToChapterAndWait(nextChapter);
      }
    }
  }

  // Neue Hilfsmethode: Scrollt zum Kapitel und wartet auf Abschluss der Animation
  Future<void> _scrollToChapterAndWait(int chapterIndex) async {
    if (!_scrollController.hasClients) return;

    // Sicherstellen, dass wir immer zum korrekten Kapitel scrollen
    if (kDebugMode) {
      print("Springe zu Kapitel: $chapterIndex");
    }

    // Warte kurz, damit alle Widgets gerendert sind, dann scrolle zum Widget
    return await Future.delayed(const Duration(milliseconds: 100), () async {

      final context = _chapterKeys[chapterIndex].currentContext!;

      if (_scrollController.hasClients &&
          chapterIndex < _chapterKeys.length &&
          _chapterKeys[chapterIndex].currentContext != null) {

        final RenderBox renderBox = context.findRenderObject() as RenderBox;

        // Berechne die absolute Position des Widgets
        final Offset position = renderBox.localToGlobal(Offset.zero);

        // Berechne die gewünschte Scroll-Position
        final double targetOffset = _scrollController.offset + position.dy - kToolbarHeight - 50.0 - 8.0;

        if (kDebugMode) {
          print("Widget-Position: ${position.dy}, Scroll-Offset: ${_scrollController.offset}");
          print("Ziel-Position: $targetOffset");
        }

        // Sicheres Scrollen
        final double clampedOffset = targetOffset.clamp(
            0.0,
            _scrollController.position.maxScrollExtent
        );

        // Langsames Scrollen statt jumpTo
        await _scrollController.animateTo(
          clampedOffset,
          duration: const Duration(milliseconds: 800), // Etwas schneller als 1200ms
          curve: Curves.easeOutCubic, // Sanftere Kurve für schnelleres Scrollen
        );

        // Kurze Pause, damit der Benutzer das neue Kapitel sehen kann, bevor die Animation beginnt
        return await Future.delayed(const Duration(milliseconds: 200));
      } else {
        // Fallback, wenn das Kapitel noch nicht gerendert ist
        double targetOffset = chapterIndex * 720.0;
        targetOffset = targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);

        await _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
        );

        return await Future.delayed(const Duration(milliseconds: 200));
      }
    });
  }

  Future<void> _animateChapterCompletion() async {
    _chapterAnimationController.reset();
    await _chapterAnimationController.forward();
  }

  void _scrollToCurrentChapter() {
    final int currentChapter = (currentStep / stepsPerChapter).floor();
    if (currentChapter > 0) {
      _scrollToChapter(currentChapter);
    }
  }

  void advanceStep() {
    if (_isAnimating) return;

    final nextStep = currentStep + 1;
    _animateToStep(nextStep);
  }

  void _scrollToChapter(int chapterIndex) {
    if (!_scrollController.hasClients) return;

    // Verwende die gleiche Widget-basierte Methode
    _scrollToChapterAndWait(chapterIndex);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: isDark ? tBlackColor : tWhiteColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: tPrimaryColor,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.tLoadingProgress,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    // Calculate visible chapters
    final int lastFinishedChapter = (currentStep / stepsPerChapter).floor();
    final int visibleChapters = lastFinishedChapter + 2;

    // Stelle sicher, dass genügend Keys vorhanden sind
    while (_chapterKeys.length < visibleChapters) {
      _chapterKeys.add(GlobalKey());
    }

    return Scaffold(
      backgroundColor: isDark ? tBlackColor : tWhiteColor,
      body: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: tDefaultSize),
            child: ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              clipBehavior: Clip.none,
              itemCount: visibleChapters,
              separatorBuilder: (context, index) => Container(
                height: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              itemBuilder: (context, chapterIndex) {
                final int chapterStart = chapterIndex * stepsPerChapter;
                final bool isLocked = currentStep < chapterStart;

                return AnimatedBuilder(
                  animation: _stepAnimation,
                  builder: (context, child) {
                    // Wir entfernen die Skalierung (Transform.scale) und belassen nur das Padding
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        clipBehavior: Clip.none,
                        child: ProgressChapterWidget(
                          key: _chapterKeys[chapterIndex],
                          chapterIndex: chapterIndex,
                          title: '${AppLocalizations.of(context)!.tChapter} ${chapterIndex + 1}',
                          currentStep: currentStep,
                          startStep: chapterStart,
                          stepCount: stepsPerChapter,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          isLocked: isLocked,
                          stepAnimation: _stepAnimation,
                          chapterAnimation: _chapterAnimation,
                          isAnimating: _isAnimating,
                          stepsPerChapter: stepsPerChapter,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Floating progress indicator
          if (_isAnimating)
            Positioned(
              top: 2,
              right: 16,
              child: AnimatedBuilder(
                animation: _stepAnimation,
                builder: (context, child) {
                  // Berechne den Tag innerhalb des aktuellen Kapitels (1-basiert)
                  // Berechnung des currentChapter und dayInChapter korrigiert
                  final int currentChapter = (currentStep / stepsPerChapter).floor();
                  int dayInChapter = currentStep - (currentChapter * stepsPerChapter);

                  // Tag 0 sollte als Tag 5 angezeigt werden (Ende des vorherigen Kapitels)
                  if (dayInChapter == 0) {
                    dayInChapter = stepsPerChapter; // Damit wird 0 zu 5 (wenn stepsPerChapter=5 ist)
                  }

                  // Bei Übergang zum nächsten Kapitel: Wenn wir den ersten Step eines neuen Kapitels machen,
                  // aber noch die Animation des letzten Steps vom vorherigen Kapitel läuft, zeige direkt Tag 1 an
                  final bool isFirstStepOfNewChapter =
                      dayInChapter == 1 && currentStep > stepsPerChapter && _isAnimating;

                  // Beim Übergang zum neuen Kapitel direkt Tag 1 anzeigen, nicht Tag 5
                  final String displayText = 'Tag ${isFirstStepOfNewChapter ? 1 : dayInChapter}';

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: tPrimaryColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: tPrimaryColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LineAwesomeIcons.paw_solid,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          displayText, // "Step" durch "Tag" ersetzt und Kapitel-relative Zahl
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),

      // Temporary manual trigger (remove in production)
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: _isAnimating ? null : advanceStep,
    //     backgroundColor: _isAnimating ? Colors.grey : tPrimaryColor,
    //     child: _isAnimating
    //         ? const SizedBox(
    //       width: 20,
    //       height: 20,
    //       child: CircularProgressIndicator(
    //         color: Colors.white,
    //         strokeWidth: 2,
    //       ),
    //     )
    //         : const Icon(Icons.arrow_forward),
    //   ),
    );
  }
}


