import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/constants/sizes.dart';
import 'package:fit_office/src/features/core/screens/progress/widgets/progress_chapter_widget.dart';
import 'package:fit_office/src/features/core/controllers/statistics_controller.dart';
import 'package:fit_office/src/features/core/controllers/profile_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import 'package:get/get.dart';

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

    // Initialize animation controllers
    _stepAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _chapterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _stepAnimation = CurvedAnimation(
      parent: _stepAnimationController,
      curve: Curves.easeInOutBack,
    );

    _chapterAnimation = CurvedAnimation(
      parent: _chapterAnimationController,
      curve: Curves.elasticOut,
    );

    // Nach dem Widget-Build zum aktuellen Kapitel scrollen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Verzögerung hinzufügen, damit alle Widgets gerendert sind
      Future.delayed(const Duration(milliseconds: 300), () {
        if (currentStep > 0) {
          _scrollToCurrentChapter();
        }
      });
    });

    // Load progress when screen opens
    _loadProgressFromStatistics();
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
    //const int maxStreakBreakDays = 5; // Reset after 5 days without training

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
    setState(() {
      currentStep = step;
    });

    // Trigger step animation
    _stepAnimationController.reset();
    await _stepAnimationController.forward();

    // Kapitelwechsel nur bei bestimmten Schritten
    final int currentChapter = (currentStep / stepsPerChapter).floor();

    // Check if we completed a chapter
    if (step % stepsPerChapter == 0) {
      // Animation für das AKTUELLE Kapitel (nicht das nächste)
      final int completedChapter = (step / stepsPerChapter).floor() - 1;

      if (completedChapter >= 0 && completedChapter < _chapterKeys.length) {
        // Kapitel-Animation auslösen
        await _animateChapterCompletion();
      }
    }
    // Nur beim ersten Schritt eines neuen Kapitels scrollen
    else if (step % stepsPerChapter == 1 && step > stepsPerChapter) {
      // Hier scrollen wir zum neuen Kapitel
      _jumpToChapter(currentChapter);
    }
    // Bei allen anderen Schritten NICHT scrollen
  }

  // Neue Methode: Direktes Springen ohne Animation
  void _jumpToChapter(int chapterIndex) {
    if (!_scrollController.hasClients || chapterIndex >= _chapterKeys.length) return;

    if (kDebugMode) {
      print("Springe zu Kapitel: $chapterIndex");
    } // Debug-Info

    // Sicherstellen, dass wir immer zum korrekten Kapitel scrollen, nicht zu einem vorherigen
    final int currentChapter = (currentStep / stepsPerChapter).floor();
    if (chapterIndex < currentChapter) {
      if (kDebugMode) {
        print("Korrektur: Springe zu aktuellem Kapitel $currentChapter statt zu $chapterIndex");
      }
      chapterIndex = currentChapter;
    }

    // Absolute Position berechnen, unabhängig von aktueller Scroll-Position
    double targetOffset = 0.0;
    for (int i = 0; i < chapterIndex; i++) {
      // Summiere die Höhen aller vorherigen Kapitel + Trennlinien
      final double itemHeight = _getItemHeight(i);
      targetOffset += itemHeight;
      targetOffset += 18.0; // Höhe der Trennlinie (2) + Margins (8+8)
    }

    // Sicheres Scrollen - verhindert Überschreiten der Grenzen
    targetOffset = targetOffset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent
    );

    if (kDebugMode) {
      print("Scrolle zu Position: $targetOffset");
    } // Debug-Info

    // Direktes Springen ohne Animation
    _scrollController.jumpTo(targetOffset);
  }

  Future<void> _animateChapterCompletion() async {
    _chapterAnimationController.reset();
    await _chapterAnimationController.forward();
  }

  void _scrollToCurrentChapter() {
    final int currentChapter = (currentStep / stepsPerChapter).floor();
    if (currentChapter > 0 && currentChapter < _chapterKeys.length) {
      _scrollToChapter(currentChapter);
    }
  }

  void advanceStep() {
    if (_isAnimating) return;

    final nextStep = currentStep + 1;
    _animateToStep(nextStep);
  }

  double _getItemHeight(int chapterIndex) {
    if (chapterIndex >= _chapterKeys.length) return 0.0;

    final context = _chapterKeys[chapterIndex].currentContext;
    if (context != null) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      return renderBox.size.height + tDefaultSize;
    }
    return 300.0; // Default height estimate
  }

  void _scrollToChapter(int chapterIndex) {
    if (!_scrollController.hasClients) return;

    // Prüfen, ob das Kapitel bereits sichtbar ist, um unnötiges Scrollen zu vermeiden
    final currentContext = _chapterKeys[chapterIndex].currentContext;
    if (currentContext != null) {
      final RenderBox box = currentContext.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero);

      // Bildschirmgröße bestimmen
      final screenHeight = MediaQuery.of(currentContext).size.height;
      final topPadding = MediaQuery.of(currentContext).padding.top;
      final chapterHeight = box.size.height;

      // Berechne den sichtbaren Bereich
      final visibleAreaTop = _scrollController.offset;
      final visibleAreaBottom = _scrollController.offset + screenHeight - topPadding - kToolbarHeight;

      // Prüfe, ob Kapitel bereits im sichtbaren Bereich ist
      // Toleranz: Das Kapitel muss mindestens zu 75% sichtbar sein
      final chapterTopY = position.dy - topPadding - kToolbarHeight;
      final chapterBottomY = chapterTopY + chapterHeight;

      final isChapterVisible =
          chapterTopY >= visibleAreaTop - chapterHeight * 0.25 &&
          chapterBottomY <= visibleAreaBottom + chapterHeight * 0.25;

      // Nur scrollen, wenn das Kapitel nicht bereits sichtbar ist
      if (!isChapterVisible) {
        // Berechne die optimale Scroll-Position
        final scrollOffset = position.dy -
            MediaQuery.of(currentContext).padding.top -
            kToolbarHeight - 16.0;

        _scrollController.animateTo(
          scrollOffset,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutQuint,
        );
      }
    } else {
      // Fallback-Methode bleibt unverändert
      double targetOffset = 0.0;
      for (int i = 0; i < chapterIndex; i++) {
        targetOffset += _getItemHeight(i);
      }

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutQuint,
      );
    }
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
              clipBehavior: Clip.none, // Wichtig: Verhindert Abschneiden der Animation
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

                // Ensure we have enough keys
                while (_chapterKeys.length <= chapterIndex) {
                  _chapterKeys.add(GlobalKey());
                }

                return AnimatedBuilder(
                  animation: _stepAnimation,
                  builder: (context, child) {
                    // Korrigierte Logik für die Zoom-Animation des Kapitels
                    final bool shouldAnimateThisChapter;

                    if (_isAnimating && currentStep % stepsPerChapter == 0) {
                      // Wenn wir genau am Ende eines Kapitels sind,
                      // animiere das ABGESCHLOSSENE Kapitel (nicht das nächste)
                      final int completedChapterIndex = (currentStep / stepsPerChapter).floor() - 1;
                      shouldAnimateThisChapter = chapterIndex == completedChapterIndex;
                    } else {
                      // Normale Animation innerhalb eines Kapitels
                      shouldAnimateThisChapter = _isAnimating &&
                            currentStep >= chapterStart &&
                            currentStep < chapterStart + stepsPerChapter;
                    }

                    final double animationScale = shouldAnimateThisChapter
                        ? 1.0 + (_stepAnimation.value * 0.04)
                        : 1.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Transform.scale(
                        scale: animationScale,
                        alignment: Alignment.center,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          clipBehavior: Clip.none, // Wichtig: Verhindert Abschneiden der Animation
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
                            stepsPerChapter: stepsPerChapter, // Neuer Parameter wird übergeben
                          ),
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
              top: 50,
              right: 20,
              child: AnimatedBuilder(
                animation: _stepAnimation,
                builder: (context, child) {
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
                          Icons.pets,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Step $currentStep',
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
      floatingActionButton: FloatingActionButton(
        onPressed: _isAnimating ? null : advanceStep,
        backgroundColor: _isAnimating ? Colors.grey : tPrimaryColor,
        child: _isAnimating
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Icon(Icons.arrow_forward),
      ),
    );
  }
}
