import 'package:fit_office/global_overlay.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/sections/exercise_history.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/sections/exercise_info.dart';
import 'package:fit_office/src/features/core/screens/profile/admin/exercise_form.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/appbar.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../utils/helper/dialog_helper.dart';
import '../../../controllers/db_controller.dart';
import '../../../controllers/exercise_timer.dart';
import '../../../controllers/profile_controller.dart';
import 'active_dialog.dart';

/// Screen displaying the details of a specific exercise.
///
/// Features:
/// - Info and History tabs (switchable)
/// - Favorite toggle (with DB sync)
/// - Admin edit capability
/// - Integrated scroll-to-bottom button
/// - Locale-sensitive display
/// - Reactive overlay padding when the global exercise timer is active
class ExerciseDetailScreen extends StatefulWidget {
  /// Globally tracks the currently opened exercise name
  static RxnString currentExerciseName = RxnString();

  /// Globally tracks the currently selected tab index (0 = Info, 1 = History)
  static RxInt currentTabIndex = 0.obs;

  final Map<String, dynamic> exerciseData;
  final bool isFavorite;

  const ExerciseDetailScreen(
      {super.key, required this.exerciseData, this.isFavorite = false});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  int selectedTab = 0;
  bool isFavorite = false;
  bool favoriteChanged = false;
  bool isAdmin = false;
  bool isProcessing = false;
  bool showScrollDownButton = false;
  String? _locale;

  final ScrollController _scrollController = ScrollController();
  final DbController _dbController = DbController();
  final ProfileController _profileController = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
            // Track current exercise globally for use in overlays
      ExerciseDetailScreen.currentExerciseName.value =
          widget.exerciseData['name'];
      ExerciseDetailScreen.currentTabIndex.value = 0;

      // Determine if scroll-to-bottom button is needed
      final position = _scrollController.position;
      final isScrollable = position.maxScrollExtent > 0;

      setState(() {
        showScrollDownButton = isScrollable;
      });

      // Hide scroll button when near bottom
      _scrollController.addListener(() {
        final position = _scrollController.position;
        const delta = 40.0;

        final isNearBottom =
            position.maxScrollExtent - position.pixels <= delta;

        if (isNearBottom && !position.outOfRange) {
          if (showScrollDownButton) {
            setState(() => showScrollDownButton = false);
          }
        }
      });
    });

    isFavorite = widget.isFavorite;
    _loadFavoriteStatus();
    _loadUserRole();
    _loadLocale();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ExerciseDetailScreen.currentExerciseName.value = '';
      ExerciseDetailScreen.currentTabIndex.value = -1;
    });
    super.dispose();
  }

  /// Load current user's role to determine admin rights
  void _loadUserRole() async {
    final user = await _profileController.getUserData();
    setState(() {
      isAdmin = user.role == 'admin';
    });
  }

  /// Check if the exercise is in user's favorites
  void _loadFavoriteStatus() async {
    final user = await _profileController.getUserData();
    final favorites = await _dbController.getFavouriteExercises(user.email);

    setState(() {
      isFavorite = favorites
          .map((e) => e['name'] as String)
          .contains(widget.exerciseData['name']);
    });
  }

  /// Toggle the favorite status of the exercise
  void toggleFavorite() async {
    if (isProcessing) return;
    setState(() {
      isProcessing = true;
      isFavorite = !isFavorite;
      favoriteChanged = true;
    });

    final user = await _profileController.getUserData();
    final exerciseName = widget.exerciseData['name'];

    try {
      await _dbController.toggleFavorite(
        email: user.email,
        exerciseName: exerciseName,
        isCurrentlyFavorite: !isFavorite,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          isFavorite = !isFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.tUpdateFavoriteException)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  void _handleBack() {
    Navigator.pop(context, favoriteChanged);
  }

  /// Opens edit screen for admins. Blocks edit when timer is active.
  void _editExercise() async {
    final timerController = Get.find<ExerciseTimerController>();
    if (timerController.isRunning.value || timerController.isPaused.value) {
      await showUnifiedDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => ActiveTimerDialog.forAction('edit', context),
      );
      return;
    }

    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ExerciseForm(
                isEdit: true,
                exercise: widget.exerciseData,
                exerciseName: widget.exerciseData['name'],
              )),
    );

    if (updated != null && updated is Map<String, dynamic>) {
      setState(() {
        widget.exerciseData.clear();
        widget.exerciseData.addAll(updated);
      });
    }
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _locale = prefs.getString('locale') ?? 'de';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : tWhiteColor,
      appBar: SliderAppBar(
        title: _locale == 'de'
            ? widget.exerciseData['name'] ?? ''
            : widget.exerciseData['name_en'] ?? '',
        subtitle: widget.exerciseData['category'] ?? '',
        showBackButton: true,
        showFavoriteIcon: true,
        isFavorite: isFavorite,
        isAdmin: isAdmin,
        exercise: widget.exerciseData,
        onToggleFavorite: toggleFavorite,
        onBack: _handleBack,
        onEdit: _editExercise,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color:
                      isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.grey.shade700
                        : tBottomNavBarUnselectedColor,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode ? Colors.transparent : Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TabButton(
                        text: AppLocalizations.of(context)!.tExerciseAbout,
                        isSelected: selectedTab == 0,
                        onTap: () {
                          setState(() => selectedTab = 0);
                          ExerciseDetailScreen.currentTabIndex.value = 0;
                        },
                      ),
                    ),
                    Expanded(
                      child: _TabButton(
                        text: AppLocalizations.of(context)!.tExerciseHistory,
                        isSelected: selectedTab == 1,
                        onTap: () {
                          setState(() => selectedTab = 1);
                          ExerciseDetailScreen.currentTabIndex.value = 1;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  final isOverlayVisible =
                      Get.find<ExerciseTimerController>().isRunning.value;
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      isOverlayVisible
                          ? GlobalExerciseOverlay.overlayHeight
                          : 0,
                    ),
                    child: selectedTab == 0
                        ? ExerciseInfoTab(
                            exerciseData: widget.exerciseData,
                            scrollController: _scrollController,
                          )
                        : ExerciseHistoryTab(
                            name: (widget.exerciseData['name'] ?? '')
                                .toString()
                                .trim(),
                            scrollController: _scrollController,
                          ),
                  );
                }),
              ),
            ],
          ),

          // Scroll-to-Bottom Button
          if (showScrollDownButton)
            Positioned(
              bottom: Get.find<ExerciseTimerController>().isRunning.value
                  ? GlobalExerciseOverlay.overlayHeight + 16
                  : 32,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                    );
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: tBottomNavBarSelectedColor,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
/// Reusable tab button used for switching between Info and History tabs.
class _TabButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? tBottomNavBarSelectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDarkMode ? Colors.white70 : Colors.black),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}