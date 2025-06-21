import 'package:fit_office/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/sizes.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import '../../../authentication/models/user_model.dart';
import '../../controllers/db_controller.dart';
import '../../controllers/profile_controller.dart';
import '../dashboard/widgets/categories.dart';
import '../dashboard/widgets/search.dart';

/// Global key used to access the state of [LibraryScreenState] from outside the widget tree.
final GlobalKey<LibraryScreenState> libraryKey = GlobalKey<LibraryScreenState>();

/// A screen displaying the user's exercise library, including search and category-based filtering.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  LibraryScreenState createState() => LibraryScreenState();
}

class LibraryScreenState extends State<LibraryScreen> {

  final GlobalKey<DashboardCategoriesState> _categoriesKey =
  GlobalKey<DashboardCategoriesState>();
  final GlobalKey<DashboardSearchBoxState> _searchBoxKey =
  GlobalKey<DashboardSearchBoxState>();
  final ProfileController _profileController = Get.put(ProfileController());
  final DbController _dbController = DbController();

  bool wasSearchFocusedBeforeNavigation = false;
  bool get searchHasFocus => _searchHasFocus;

  bool _searchHasFocus = false;
  String _searchText = '';

  String favoriteCount = '';

  /// Forces the app to unfocus any input fields when returning from another screen.
  void forceRedirectFocus() {
    if (!wasSearchFocusedBeforeNavigation && mounted) {
      FocusScope.of(context).unfocus();
    }
  }

  /// Handles logic after returning from an exercise screen,
  /// restoring or removing focus based on previous state.
  void handleReturnedFromExercise() {
    if (!wasSearchFocusedBeforeNavigation) {
      removeSearchFocus();
    } else {
      _searchBoxKey.currentState?.requestFocus();
    }
  }

  /// Removes focus from the search box and resets focus state.
  void removeSearchFocus() {
    FocusScope.of(context).unfocus();
    _searchBoxKey.currentState?.removeFocus();
    setState(() {
      _searchHasFocus = false;
    });
  }

  /// Loads the user's favorite exercises and updates the UI to show the count.
  void _loadUserFavorites() async {
    final user = await _profileController.getUserData();
    final userFavorites = await _dbController.getFavouriteExercises(user.email);
    final favoriteNames =
    userFavorites.map((e) => e['name'] as String).toList();

    setState(() {
      favoriteCount = "${favoriteNames.length} ${AppLocalizations.of(context)!.tDashboardExerciseUnits}";
    });
  }

  final ProfileController _controller = Get.put(ProfileController());
  UserModel? _user;
  bool _isUserLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserFavorites();
  }

  /// Loads the currently authenticated user's data into [_user].
  void _loadUserData() async {
    final userData = await _controller.getUserData();
    setState(() {
      _user = userData;
      _isUserLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;

    return Container(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: tDashboardPadding,
                  bottom: 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _isUserLoaded
                        ? Text(
                        '${AppLocalizations.of(context)!.tDashboardTitle} ${_user?.fullName ?? ''}',
                        style: txtTheme.bodyMedium)
                        : Text(
                        '${AppLocalizations.of(context)!.tDashboardTitle} ...',
                        style: txtTheme.bodyMedium),
                    Text(AppLocalizations.of(context)!.tDashboardHeading,
                        style: txtTheme.displayMedium),
                  ],
                ),
              ),
            ),

            /// Sticky search bar with text input and listeners
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickySearchBar(
                minExtent: 74,
                maxExtent: 74,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: tDashboardPadding,
                        right: tDashboardPadding,
                        bottom: 10,
                      ),
                      child: DashboardSearchBox(
                        key: _searchBoxKey,
                        txtTheme: Theme.of(context).textTheme,
                        onSearchSubmitted: (query) {
                          _categoriesKey.currentState
                              ?.updateSearchQuery(query);
                          setState(() {
                            _searchHasFocus = false;
                            _searchText = query;
                          });
                        },
                        onTextChanged: (query) {
                          _categoriesKey.currentState
                              ?.updateSearchQuery(query);
                          setState(() {
                            _searchText = query;
                          });
                        },
                        onFocusChanged: (hasFocus) {
                          setState(() {
                            _searchHasFocus = hasFocus;
                          });
                        },
                      ),
                    ),
                    const Divider(
                      height: 0.8,
                    ),
                  ],
                ),
              ),
            ),

            /// Main dashboard content (categories + exercises)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                  left: tDashboardPadding,
                  right: tDashboardPadding,
                  bottom: tDashboardPadding,
                ),
                child: DashboardCategories(
                  key: _categoriesKey,
                  txtTheme: txtTheme,
                  onSearchChanged: (text) {},
                  forceShowExercisesOnly:
                  _searchHasFocus || _searchText.isNotEmpty,
                  onReturnedFromFilter: removeSearchFocus,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A custom sticky header used to display the search bar.
/// This delegate ensures the header stays visible while scrolling.
class _StickySearchBar extends SliverPersistentHeaderDelegate {
  @override
  final double minExtent;
  @override
  final double maxExtent;
  /// The widget to render inside the sticky header.
  final Widget child;

  _StickySearchBar({
    required this.minExtent,
    required this.maxExtent,
    required this.child,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? tBlackColor : tWhiteColor,
      elevation: overlapsContent ? 4 : 0,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _StickySearchBar oldDelegate) {
    return true; // Always rebuild to reflect changes
  }
}