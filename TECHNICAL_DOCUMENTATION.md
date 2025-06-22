# Technical Documentation

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

See [PROJECT DOCUMENTATION](/PROJECT_DOCUMENTATION.pdf) for detailed architecture diagrams.

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
├── main.dart                      # Application entry point
├── app/
│   ├── app.dart                  # Main GetMaterialApp configuration
│   ├── bindings/
│   │   └── initial_binding.dart  # GetX controller registration
│   └── routes/
│       └── app_pages.dart        # GetX route definitions
├── core/
│   ├── constants/                # Application constants
│   ├── errors/                   # Error handling utilities
│   ├── services/                 # Core services like network, storage
│   └── utils/                    # Utility functions
├── features/
│   ├── auth/                     # Authentication feature
│   │   ├── controllers/          # GetX controllers
│   │   ├── repositories/
│   │   │   └── authentication_repository.dart
│   │   ├── screens/              # UI screens
│   │   └── widgets/              # Feature-specific widgets
│   ├── home/                     # Home feature
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── screens/
│   │   └── widgets/
│   ├── profile/                  # Profile feature
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── screens/
│   │   └── widgets/
│   └── workout/                  # Workout feature
│       ├── controllers/
│       ├── models/
│       ├── screens/
│       └── widgets/
├── shared/
│   ├── widgets/                  # Common widgets
│   ├── models/                   # Shared data models
│   └── themes/                   # Theme configurations
└── firebase/                     # Firebase service initializations
    └── firebase_options.dart
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

### Entity Models
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

### Data Models
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

### Storage Service
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

### Custom Widgets
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

### Screen Structure
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

*Last updated: [Current Date]*
*Document version: 1.0*