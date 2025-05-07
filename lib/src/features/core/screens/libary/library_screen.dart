import 'package:fit_office/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/sizes.dart';
import '../../../../constants/text_strings.dart';
import '../../../authentication/models/user_model.dart';
import '../../controllers/db_controller.dart';
import '../../controllers/profile_controller.dart';
import '../dashboard/widgets/categories.dart';
import '../dashboard/widgets/search.dart';

final GlobalKey<LibraryScreenState> libraryKey = GlobalKey<LibraryScreenState>();

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

  List<String> _userFavorites = [];
  String favoriteCount = '';

  void forceRedirectFocus() {
    if (!wasSearchFocusedBeforeNavigation && mounted) {
      FocusScope.of(context).unfocus();
    }
  }

  void handleReturnedFromExercise() {
    if (!wasSearchFocusedBeforeNavigation) {
      removeSearchFocus();
    } else {
      _searchBoxKey.currentState?.requestFocus();
    }
  }

  void removeSearchFocus() {
    FocusScope.of(context).unfocus();
    _searchBoxKey.currentState?.removeFocus();
    setState(() {
      _searchHasFocus = false;
    });
  }

  //TODO: Unused by now
  void _toggleFavorite(String exerciseName) async {
    final user = await _profileController.getUserData();
    final isFavorite = _userFavorites.contains(exerciseName);

    if (isFavorite) {
      await _dbController.removeFavorite(user.email, exerciseName);
    } else {
      await _dbController.addFavorite(user.email, exerciseName);
    }

    _loadUserFavorites();
  }

  void _loadUserFavorites() async {
    final user = await _profileController.getUserData();
    final userFavorites = await _dbController.getFavouriteExercises(user.email);
    final favoriteNames =
    userFavorites.map((e) => e['name'] as String).toList();

    setState(() {
      _userFavorites = favoriteNames;
      favoriteCount = "${favoriteNames.length} $tDashboardExerciseUnits";
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
                        '$tDashboardTitle ${_user?.fullName ?? ''}',
                        style: txtTheme.bodyMedium)
                        : const CircularProgressIndicator(),
                    Text(tDashboardHeading,
                        style: txtTheme.displayMedium),
                  ],
                ),
              ),
            ),

            // Sticky SearchBar
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

            // Kategorien + All Exercises
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

class _StickySearchBar extends SliverPersistentHeaderDelegate {
  @override
  final double minExtent;
  @override
  final double maxExtent;
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