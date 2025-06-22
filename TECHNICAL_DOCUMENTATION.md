# Technical Documentation

This document only provides a high-level overview of the project architecture, core components, and development practices. For detailed implementation and architecture diagrams, please refer to the [FitOffice PROJECT DOCUMENTATION](/PROJECT_DOCUMENTATION.pdf).

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Project Structure](#project-structure)
4. [Core Components](#core-components)
5. [State Management](#state-management)
6. [Data Models](#data-models)
7. [Services](#services)
8. [UI Components](#ui-components)
9. [Development Setup](#development-setup)
10. [Build and Deployment](#build-and-deployment)
11. [Code Style and Conventions](#code-style-and-conventions)
12. [Troubleshooting](#troubleshooting)

## Project Overview

This is a Flutter application built with modern architecture patterns and best practices. The project follows a clean architecture approach with clear separation of concerns, making it maintainable and scalable.

[FitOffice PROJECT DOCUMENTATION](/PROJECT_DOCUMENTATION.pdf) provides a comprehensive overview of the project, including architecture diagrams and implementation details.

### Key Features
- Cross-platform mobile application (iOS & Android)
- Modern Flutter UI
- Responsive design
- State management using GetX
- Dependency injection with GetX
- Firebase integration for backend services

### Technology Stack
- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: GetX
- **Routing**: GetX for navigation
- **Dependency Injection**: GetX
- **Database**: Firebase Firestore for cloud storage, SharedPreferences for local storage

## Architecture

See [PROJECT DOCUMENTATION](/PROJECT_DOCUMENTATION.pdf) for detailed information on the architecture.

### Architecture Principles
1. **Dependency Inversion**: High-level modules don't depend on low-level modules
2. **Single Responsibility**: Each class has one reason to change
3. **Open/Closed**: Open for extension, closed for modification
4. **Interface Segregation**: Clients shouldn't depend on interfaces they don't use
5. **Dependency Injection**: Dependencies are injected rather than created

### Entity Relationship Model 

![Entity Relationship Model](/assets/diagrams/ERM.png)

## Project Structure

```
lib/
├── main.dart                           # Application entry point
├── app.dart                           # Main app configuration
├── global_overlay.dart                # Global overlay functionality
├── firebase_options.dart             # Firebase configuration
├── l10n/                             # Localization files
│   ├── app_localizations.dart        # Main localization
│   ├── app_localizations_de.dart     # German translations
│   └── app_localizations_en.dart     # English translations
└── src/
    ├── constants/                     # Application constants
    │   ├── colors.dart               # Color definitions
    │   ├── image_strings.dart        # Image path constants
    │   ├── sizes.dart                # Size constants
    │   └── text_strings.dart         # Text constants
    ├── repository/                    # Data repositories
    │   ├── authentication_repository/
    │   │   ├── authentication_repository.dart
    │   │   └── exceptions/
    │   │       └── t_exceptions.dart
    │   ├── user_repository/
    │   │   └── user_repository.dart
    │   └── firebase_storage/
    │       └── storage_service.dart
    ├── features/
    │   ├── authentication/            # Authentication feature
    │   │   ├── controllers/
    │   │   │   ├── login_controller.dart
    │   │   │   ├── signup_controller.dart
    │   │   │   ├── on_boarding_controller.dart
    │   │   │   └── mail_verification_controller.dart
    │   │   ├── models/
    │   │   │   ├── user_model.dart
    │   │   │   └── model_on_boarding.dart
    │   │   └── screens/
    │   │       ├── welcome/
    │   │       │   └── welcome_screen.dart
    │   │       ├── on_boarding/
    │   │       │   ├── on_boarding_screen.dart
    │   │       │   └── on_boarding_page_widget.dart
    │   │       ├── login/
    │   │       │   ├── login_screen.dart
    │   │       │   └── widgets/
    │   │       │       └── login_form_widget.dart
    │   │       ├── signup/
    │   │       │   ├── signup_screen.dart
    │   │       │   └── widgets/
    │   │       │       └── signup_form_widget.dart
    │   │       ├── forget_password/
    │   │       │   └── forget_password_model_bottom_sheet.dart
    │   │       └── mail_verification/
    │   │           └── mail_verification.dart
    │   └── core/                      # Core app features
    │       ├── controllers/
    │       │   ├── db_controller.dart
    │       │   ├── exercise_controller.dart
    │       │   ├── exercise_timer.dart
    │       │   ├── friends_controller.dart
    │       │   ├── profile_controller.dart
    │       │   └── statistics_controller.dart
    │       ├── models/
    │       │   ├── dashboard/
    │       │   │   ├── courses_model.dart
    │       │   │   └── categories_model.dart
    │       │   ├── exercise_model.dart
    │       │   ├── exercise_history_model.dart
    │       │   ├── friendship_model.dart
    │       │   └── streak_model.dart
    │       └── screens/
    │           ├── dashboard/         # Main dashboard
    │           │   ├── dashboard.dart
    │           │   ├── exercise_filter.dart
    │           │   └── widgets/
    │           │       ├── appbar.dart
    │           │       ├── banners.dart
    │           │       ├── categories.dart
    │           │       ├── search.dart
    │           │       ├── top_courses.dart
    │           │       ├── exercises_list.dart
    │           │       ├── view_exercise.dart
    │           │       ├── start_exercise.dart
    │           │       ├── cancel_exercise.dart
    │           │       ├── end_exercise.dart
    │           │       ├── video_player.dart
    │           │       ├── active_dialog.dart
    │           │       └── sections/
    │           │           ├── exercise_info.dart
    │           │           ├── exercise_history.dart
    │           │           ├── mental_filter.dart
    │           │           ├── physicals_filter.dart
    │           │           └── favorites_filter.dart
    │           ├── profile/           # User profiles
    │           │   ├── profile_screen.dart
    │           │   ├── friend_profile.dart
    │           │   ├── all_users.dart
    │           │   ├── widgets/
    │           │   │   ├── avatar.dart
    │           │   │   ├── avatar_with_edit.dart
    │           │   │   ├── avatar_zoom.dart
    │           │   │   ├── profile_form.dart
    │           │   │   ├── profile_menu.dart
    │           │   │   ├── custom_profile_button.dart
    │           │   │   ├── facet_display_card.dart
    │           │   │   ├── qr_code_dialog.dart
    │           │   │   ├── update_profile_modal.dart
    │           │   │   ├── help_support_modal.dart
    │           │   │   ├── bug_report_modal.dart
    │           │   │   ├── about_modal.dart
    │           │   │   ├── terms_cond_modal.dart
    │           │   │   └── privacy_policy_modal.dart
    │           │   └── admin/         # Admin functionality
    │           │       ├── exercise_form.dart
    │           │       ├── edit_user_page.dart
    │           │       ├── add_friends.dart
    │           │       ├── upload_video.dart
    │           │       ├── delete_exercise.dart
    │           │       └── widgets/
    │           │           ├── friends_box.dart
    │           │           ├── friends_search.dart
    │           │           ├── friends_request.dart
    │           │           ├── add_friends_button.dart
    │           │           ├── save_button.dart
    │           │           ├── navigation_button.dart
    │           │           ├── delete_video.dart
    │           │           ├── replace_video.dart
    │           │           ├── confirmation_dialog.dart
    │           │           └── all_users.dart
    │           ├── progress/          # Progress tracking
    │           │   ├── progress_screen.dart
    │           │   └── widgets/
    │           │       └── progress_chapter_widget.dart
    │           ├── statistics/        # Statistics and analytics
    │           │   ├── statistics_screen.dart
    │           │   └── widgets/
    │           │       └── statistics.dart
    │           └── libary/           # Library/content management
    │               └── library_screen.dart
    ├── utils/                        # Utility functions and helpers
    │   ├── app_bindings.dart         # Dependency injection bindings
    │   ├── helper/
    │   │   ├── app_info.dart
    │   │   ├── helper_controller.dart
    │   │   └── dialog_helper.dart
    │   ├── services/
    │   │   ├── deep_link_service.dart
    │   │   └── fcm_token_service.dart
    │   ├── theme/                    # App theming
    │   │   ├── theme.dart
    │   │   └── widget_themes/
    │   │       ├── text_theme.dart
    │   │       ├── elevated_button_theme.dart
    │   │       ├── outlined_button_theme.dart
    │   │       ├── appbar_theme.dart
    │   │       ├── text_field_theme.dart
    │   │       └── dialog_theme.dart
    │   └── animations/              # Animation utilities
    │       └── fade_in_animation/
    │           ├── animation_design.dart
    │           ├── fade_in_animation_controller.dart
    │           └── fade_in_animation_model.dart
    └── common_widgets/              # Shared/reusable widgets
        └── form/
            └── form_header_widget.dart
```

## Core Components

### General
1. **Splash Screen anzeigen, bis Daten geladen sind, und nach dem Laden `FlutterNativeSplash.remove()` aufrufen:**  
   In diesem Fall wird es in der Methode `onReady()` der `AuthenticationRepository()` entfernt.
2. **Vor dem Start der App:**  
   Firebase initialisieren und nach der Initialisierung das `AuthenticationRepository` aufrufen, um zu überprüfen, welcher Bildschirm angezeigt werden soll.
3. **Lösung für Probleme mit `Get.lazyPut` und `Get.Put()`:**  
   Alle Controller werden in `InitialBinding` definiert.
4. **Bildschirmübergänge:**  
   Verwenden Sie diese zwei Eigenschaften in `GetMaterialApp`:
    - `defaultTransition: Transition.leftToRightWithFade,`
    - `transitionDuration: const Duration(milliseconds: 500),`
5. **HOME-BILDSCHIRM:**
    - Zeigen Sie einen Fortschrittsindikator oder Splash Screen an, bis alle Daten aus der Cloud geladen sind.
    - Lassen Sie das `AuthenticationRepository` entscheiden, welcher Bildschirm als erstes angezeigt wird.
6. **Authentication Repository:**
    - Wird für die Benutzer-Authentifizierung und Bildschirmweiterleitungen verwendet.
    - Wird beim Start der App aus `main.dart` aufgerufen.
    - Die Methode `onReady()` setzt den `firebaseUser`-Zustand, entfernt den Splash Screen und leitet zum entsprechenden Bildschirm weiter.
    - Nutzung in anderen Klassen: `[final auth = AuthenticationRepository.instance;]`

### App Configuration
- **Theme Management**: Centralized theme configuration with light/dark mode support
- **Localization**: Multi-language support using Flutter's internationalization

## State Management

The application uses a GetX-based state management approach, which allows for reactive programming and efficient state updates.

### State Management Principles
1. **Reactive Programming**: UI updates automatically when state changes
2. **Separation of Concerns**: UI logic is separated from business logic
3. **Dependency Injection**: Controllers and services are injected where needed
4. **Single Source of Truth**: Each piece of state is managed in one place
5. **Scoped State**: State is scoped to the feature or module it belongs to
6. **Lifecycle Management**: Controllers are initialized and disposed of properly to avoid memory leaks
7. **Error Handling**: Centralized error handling for state management
8. **Performance Optimization**: Use of `GetBuilder` and `Obx` for efficient updates

## Models

### Example Entity Models
Business logic entities that represent core business concepts:

```dart
class User {
  final String id;
  final String name;
  final String email;
  
  User({
    required this.id,
    required this.name,
    required this.email,
  });
}
```

### Example Data Models
Models used for data transfer and serialization:

```dart
class UserModel extends User {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
```

## Services

### Example Storage Service
Manages local data persistence:

```dart
class StorageService {
  static const String _userKey = 'user_data';
  
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
  
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }
}
```

## UI Components

### Example Custom Widgets
Reusable UI components following Material Design principles:

```dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading 
        ? CircularProgressIndicator()
        : Text(text),
    );
  }
}
```

### Example Screen Structure
Each screen follows a consistent structure:

```dart
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Initialize screen-specific data
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: _,
    );
  }
}
```

## Development Setup

Please see [Setup & Run Instructions](https://github.com/olisonsturm/FitOffice/#setup--run-instructions) in README.md for detailed setup instructions.

## Build and Deployment

### Android Build
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App Bundle for Play Store
flutter build appbundle --release
```

### iOS Build
```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release
```

### Build Configuration
Configure build settings in `android/app/build.gradle` and `ios/Runner.xcodeproj`.

## Code Style and Conventions

### Dart Style Guide
Follow the official Dart style guide with these additions:

1. **File Naming**: Use snake_case for file names
2. **Class Naming**: Use PascalCase for class names
3. **Variable Naming**: Use camelCase for variables and functions
4. **Constants**: Use SCREAMING_SNAKE_CASE for constants
5. **Comments**: Use `///` for documentation comments, `//` for inline comments

## Troubleshooting

### Common Issues

#### Build Issues
- **Gradle build fails**: Clean and rebuild
  ```bash
  flutter clean
  flutter pub get
  flutter build apk
  ```

#### Runtime Issues
- **State not updating**: Check if `notifyListeners()` is called
- **Navigation issues**: Verify route configuration
- **Network errors**: Check API endpoints and network permissions

#### Development Issues
- **Hot reload not working**: Restart the app
- **Dependencies conflicts**: Run `flutter pub deps` to check dependencies

### Debug Tools
- Flutter Inspector for widget tree analysis
- Dart DevTools for performance profiling
- Network inspector for API debugging

### Performance Optimization
1. Use `const` constructors where possible
2. Implement `ListView.builder` for large lists
3. Optimize image loading with caching
4. Use `RepaintBoundary` for expensive widgets

## Additional Resources

### Documentation Links
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [Material Design Guidelines](https://material.io/design)
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire](https://firebase.flutter.dev/)
- [Flutter DevTools](https://flutter.dev/docs/development/tools/devtools)
- [GetX Documentation](https://pub.dev/packages/get)

### Development Tools
- Flutter Inspector
- Dart DevTools
- Android Studio/VS Code Flutter extensions
- Postman for API testing
- Firebase Console for backend management
- Git for version control
- GitHub for collaboration and issue tracking
- GitHub Actions to automate deployment of dart code documentation to GitHub Pages
- GitHub Pages for hosting documentation

--- 

*Document version: 2.0*