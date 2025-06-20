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
9. [Routing](#routing)
10. [Development Setup](#development-setup)
11. [Build and Deployment](#build-and-deployment)
12. [Contributing Guidelines](#contributing-guidelines)
13. [Code Style and Conventions](#code-style-and-conventions)
14. [Testing](#testing)
15. [Troubleshooting](#troubleshooting)

## Project Overview

This is a Flutter application built with modern architecture patterns and best practices. The project follows a clean architecture approach with clear separation of concerns, making it maintainable and scalable.

### Key Features
- Cross-platform mobile application (iOS & Android)
- Modern Flutter UI with Material Design 3
- State management using Provider/Riverpod pattern
- Clean architecture with separation of concerns
- Responsive design for different screen sizes
- Local data persistence
- Network connectivity handling

### Technology Stack
- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: Provider/Riverpod
- **Local Storage**: SharedPreferences/Hive
- **HTTP Client**: Dio/http
- **Architecture**: Clean Architecture + MVVM

## Architecture

The application follows Clean Architecture principles with the following layers:

```
┌─────────────────────────────────────┐
│           Presentation Layer        │
│  (UI, Widgets, State Management)    │
├─────────────────────────────────────┤
│           Business Layer            │
│     (Use Cases, Business Logic)     │
├─────────────────────────────────────┤
│             Data Layer              │
│  (Repositories, Data Sources, APIs) │
└─────────────────────────────────────┘
```

### Architecture Principles
1. **Dependency Inversion**: High-level modules don't depend on low-level modules
2. **Single Responsibility**: Each class has one reason to change
3. **Open/Closed**: Open for extension, closed for modification
4. **Interface Segregation**: Clients shouldn't depend on interfaces they don't use
5. **Dependency Injection**: Dependencies are injected rather than created

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── app/                      # App-level configuration
│   ├── app.dart             # Main app widget
│   ├── routes/              # Route definitions
│   └── themes/              # App themes and styling
├── core/                     # Core utilities and shared code
│   ├── constants/           # App constants
│   ├── errors/              # Error handling
│   ├── network/             # Network utilities
│   ├── utils/               # Utility functions
│   └── extensions/          # Dart extensions
├── features/                 # Feature modules
│   └── [feature_name]/      # Individual feature
│       ├── data/            # Data layer
│       │   ├── datasources/ # Remote/Local data sources
│       │   ├── models/      # Data models
│       │   └── repositories/ # Repository implementations
│       ├── domain/          # Business logic layer
│       │   ├── entities/    # Business entities
│       │   ├── repositories/ # Repository interfaces
│       │   └── usecases/    # Use cases
│       └── presentation/    # UI layer
│           ├── pages/       # Screen widgets
│           ├── widgets/     # Reusable widgets
│           └── providers/   # State management
├── shared/                   # Shared components
│   ├── widgets/             # Common widgets
│   ├── services/            # Shared services
│   └── models/              # Shared models
└── generated/               # Generated files (assets, l10n)
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

### main.dart
The application entry point that initializes the app and sets up global configurations.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await initializeServices();
  
  runApp(MyApp());
}
```

### App Configuration
- **Theme Management**: Centralized theme configuration with light/dark mode support
- **Routing**: Declarative routing using GoRouter or Navigator 2.0
- **Localization**: Multi-language support using Flutter's internationalization

## State Management

The application uses a combination of state management solutions:

### Provider Pattern
Used for simple state management and dependency injection:

```dart
class UserProvider extends ChangeNotifier {
  User? _user;
  
  User? get user => _user;
  
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}
```

### Riverpod (if applicable)
For more complex state management with better testing support:

```dart
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
```

## Data Models

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

### Network Service
Handles HTTP requests and API communication:

```dart
class NetworkService {
  final Dio _dio;
  
  NetworkService(this._dio);
  
  Future<Response> get(String endpoint) async {
    try {
      return await _dio.get(endpoint);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
}
```

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
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    // Build screen content
  }
}
```

## Routing

### Route Configuration
Using GoRouter for declarative routing:

```dart
final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => ProfilePage(),
    ),
  ],
);
```

### Navigation
Consistent navigation patterns throughout the app:

```dart
// Navigate to a new screen
context.go('/profile');

// Navigate with parameters
context.go('/user/${userId}');

// Navigate back
context.pop();
```

## Development Setup

### Prerequisites
- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher
- Android Studio / VS Code with Flutter extensions
- iOS development: Xcode (for iOS development)

### Installation Steps
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd <project-name>
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate necessary files:
   ```bash
   flutter packages pub run build_runner build
   ```

4. Run the application:
   ```bash
   flutter run
   ```

### Environment Configuration
Create environment-specific configuration files:

```dart
// lib/core/config/app_config.dart
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );
  
  static const bool isDebug = bool.fromEnvironment('DEBUG', defaultValue: false);
}
```

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

## Contributing Guidelines

### Code Review Process
1. Create a feature branch from `develop`
2. Implement changes following coding standards
3. Write/update tests for new functionality
4. Submit a pull request with detailed description
5. Address review feedback
6. Merge after approval

### Branch Naming Convention
- Feature: `feature/feature-name`
- Bug fix: `bugfix/bug-description`
- Hotfix: `hotfix/critical-fix`

### Commit Message Format
```
type(scope): description

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## Code Style and Conventions

### Dart Style Guide
Follow the official Dart style guide with these additions:

1. **File Naming**: Use snake_case for file names
2. **Class Naming**: Use PascalCase for class names
3. **Variable Naming**: Use camelCase for variables and functions
4. **Constants**: Use SCREAMING_SNAKE_CASE for constants

### Widget Organization
```dart
class MyWidget extends StatelessWidget {
  // 1. Constructor and properties
  final String title;
  
  const MyWidget({Key? key, required this.title}) : super(key: key);
  
  // 2. Build method
  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }
  
  // 3. Private helper methods
  Widget _buildContent() {
    // Implementation
  }
}
```

### Error Handling
```dart
try {
  final result = await apiService.getData();
  return Right(result);
} on NetworkException catch (e) {
  return Left(NetworkFailure(e.message));
} catch (e) {
  return Left(UnknownFailure(e.toString()));
}
```

## Testing

### Test Structure
```
test/
├── unit/                    # Unit tests
├── widget/                  # Widget tests
├── integration/             # Integration tests
└── helpers/                 # Test helpers and mocks
```

### Testing Guidelines
1. Write unit tests for business logic
2. Write widget tests for UI components
3. Write integration tests for user flows
4. Maintain test coverage above 80%

### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/user_service_test.dart
```

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
5. Profile app performance regularly

## Additional Resources

### Documentation Links
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [Material Design Guidelines](https://material.io/design)

### Useful Packages
- `provider` - State management
- `dio` - HTTP client
- `shared_preferences` - Local storage
- `go_router` - Routing
- `flutter_bloc` - BLoC pattern implementation

### Development Tools
- Flutter Inspector
- Dart DevTools
- Android Studio/VS Code Flutter extensions
- Flipper for debugging

---

## Changelog

### Version 1.0.0
- Initial release with core functionality
- User authentication
- Basic CRUD operations
- Responsive UI design

---

*Last updated: [Current Date]*
*Document version: 1.0*