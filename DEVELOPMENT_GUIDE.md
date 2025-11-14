# iTraceLink Development Guide

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Project Structure](#project-structure)
3. [Development Setup](#development-setup)
4. [Coding Standards](#coding-standards)
5. [Feature Development Workflow](#feature-development-workflow)
6. [Testing Strategy](#testing-strategy)
7. [Deployment Process](#deployment-process)

## Architecture Overview

### Application Architecture
iTraceLink follows a feature-based architecture with clear separation of concerns:

```
┌─────────────────────────────────────────────┐
│         Flutter Mobile Application          │
│         (Material Design 3 + Provider)      │
└─────────────────┬───────────────────────────┘
                  │
    ┌─────────────┼─────────────┐
    │             │             │
    ▼             ▼             ▼
┌─────────┐  ┌─────────┐  ┌─────────┐
│Firebase │  │Firebase │  │Firebase │
│  Auth   │  │Firestore│  │ Storage │
└─────────┘  └─────────┘  └─────────┘
    │             │             │
    └─────────────┼─────────────┘
                  │
    ┌─────────────┼─────────────┐
    │             │             │
    ▼             ▼             ▼
┌─────────┐  ┌─────────┐  ┌─────────┐
│   FCM   │  │  SMS    │  │  Maps   │
│         │  │ (AT)    │  │  API    │
└─────────┘  └─────────┘  └─────────┘
```

### State Management
- **Provider** for app-wide state management
- **ChangeNotifier** for reactive UI updates
- **Services** for business logic encapsulation

### Key Design Patterns
1. **Repository Pattern**: Services layer abstracts data access
2. **Provider Pattern**: State management and dependency injection
3. **Feature-First Structure**: Code organized by features, not layers

## Project Structure

```
lib/
├── core/                      # Core app functionality
│   ├── constants/            # App-wide constants
│   │   └── app_constants.dart
│   ├── routes/               # Navigation configuration
│   │   └── app_router.dart   # GoRouter configuration
│   ├── theme/                # App theming
│   │   └── app_theme.dart    # Material Design theme
│   └── utils/                # Utility functions
│
├── features/                  # Feature modules
│   ├── auth/                 # Authentication
│   │   ├── screens/          # UI screens
│   │   ├── widgets/          # Reusable widgets
│   │   └── providers/        # State management
│   ├── farmer/               # Farmer features
│   ├── aggregator/           # Aggregator features
│   ├── institution/          # Institution features
│   ├── agro_dealer/          # Agro-dealer features
│   └── seed_producer/        # Seed producer features
│
├── models/                    # Data models
│   ├── user_model.dart
│   ├── cooperative_model.dart
│   ├── order_model.dart
│   └── ...
│
├── services/                  # Business logic services
│   ├── auth_service.dart     # Authentication logic
│   ├── localization_service.dart
│   ├── notification_service.dart
│   └── firestore_service.dart
│
├── widgets/                   # Shared widgets
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   └── loading_indicator.dart
│
└── main.dart                 # App entry point
```

## Development Setup

### Prerequisites
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / VS Code
- Firebase CLI
- Git

### Initial Setup

1. **Clone and Install**
   ```bash
   git clone https://github.com/yourusername/itrace-Link.git
   cd itrace-Link
   flutter pub get
   ```

2. **Environment Configuration**
   ```bash
   cp .env.example .env
   # Edit .env with your credentials
   ```

3. **Firebase Configuration**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli

   # Configure Firebase
   flutterfire configure
   ```

4. **Run the App**
   ```bash
   # Development mode
   flutter run

   # With specific device
   flutter run -d <device_id>

   # Release mode
   flutter run --release
   ```

### IDE Setup

#### VS Code Extensions
- Dart
- Flutter
- Flutter Intl
- Error Lens
- Prettier

#### Android Studio Plugins
- Flutter
- Dart
- Firebase

## Coding Standards

### Dart Style Guide
Follow the [official Dart style guide](https://dart.dev/guides/language/effective-dart/style).

### Naming Conventions

**Files and Folders**
- Use `snake_case` for file names: `user_service.dart`
- Use `snake_case` for folder names: `auth_screens`

**Classes**
- Use `PascalCase`: `UserService`, `AuthProvider`

**Variables and Functions**
- Use `camelCase`: `userName`, `getUserData()`

**Constants**
- Use `lowerCamelCase`: `const appName = 'iTraceLink';`
- For enum-like constants: `const String userTypeFarmer = 'farmer';`

### Code Organization

**Import Order**
1. Dart SDK imports
2. Flutter imports
3. Package imports
4. Local imports

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
```

### Widget Best Practices

**Use Const Constructors**
```dart
const Text('Hello World')  // Good
Text('Hello World')        // Avoid if possible
```

**Extract Widgets**
```dart
// Good - Reusable widget
class UserCard extends StatelessWidget {
  final User user;
  const UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(...);
  }
}

// Avoid - Inline complex widgets
Widget build(BuildContext context) {
  return Column(
    children: [
      Card(...), // Complex widget inline
    ],
  );
}
```

**Use Named Parameters**
```dart
// Good
void createOrder({
  required String buyerId,
  required String sellerId,
  required double quantity,
}) {}

// Avoid for multiple parameters
void createOrder(String buyerId, String sellerId, double quantity) {}
```

## Feature Development Workflow

### 1. Create Feature Branch
```bash
git checkout -b feature/farmer-registration
```

### 2. Implement Feature

#### A. Create Models
```dart
// lib/models/cooperative_model.dart
class CooperativeModel {
  final String id;
  final String name;
  // ... other fields

  CooperativeModel({required this.id, required this.name});

  factory CooperativeModel.fromFirestore(DocumentSnapshot doc) {
    // Implementation
  }

  Map<String, dynamic> toFirestore() {
    // Implementation
  }
}
```

#### B. Create Service
```dart
// lib/services/cooperative_service.dart
class CooperativeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createCooperative(CooperativeModel coop) async {
    await _firestore
        .collection('cooperatives')
        .doc(coop.id)
        .set(coop.toFirestore());
  }
}
```

#### C. Create Provider (if needed)
```dart
// lib/features/farmer/providers/cooperative_provider.dart
class CooperativeProvider extends ChangeNotifier {
  final CooperativeService _service;
  CooperativeModel? _cooperative;

  CooperativeProvider(this._service);

  Future<void> loadCooperative(String id) async {
    _cooperative = await _service.getCooperative(id);
    notifyListeners();
  }
}
```

#### D. Create UI Screens
```dart
// lib/features/farmer/screens/register_cooperative_screen.dart
class RegisterCooperativeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register Cooperative')),
      body: // Form implementation
    );
  }
}
```

### 3. Add Tests
```dart
// test/services/cooperative_service_test.dart
void main() {
  group('CooperativeService', () {
    test('creates cooperative successfully', () async {
      // Test implementation
    });
  });
}
```

### 4. Update Documentation
- Update README.md if needed
- Add inline comments for complex logic
- Update API documentation

### 5. Create Pull Request
```bash
git add .
git commit -m "feat: implement farmer cooperative registration"
git push origin feature/farmer-registration
```

## Testing Strategy

### Unit Tests
Test individual functions and classes:

```dart
// test/services/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('login succeeds with valid credentials', () async {
      final result = await authService.login('test@test.com', 'password');
      expect(result, isTrue);
    });
  });
}
```

### Widget Tests
Test UI components:

```dart
// test/widgets/user_card_test.dart
void main() {
  testWidgets('UserCard displays user information', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UserCard(user: mockUser),
      ),
    );

    expect(find.text('John Doe'), findsOneWidget);
  });
}
```

### Integration Tests
Test complete user flows:

```dart
// integration_test/login_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete login flow', (tester) async {
    // Test implementation
  });
}
```

### Running Tests
```bash
# Unit and widget tests
flutter test

# Integration tests
flutter test integration_test

# Coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Deployment Process

### Pre-deployment Checklist
- [ ] All tests passing
- [ ] No linter warnings: `flutter analyze`
- [ ] Code formatted: `flutter format .`
- [ ] Dependencies updated
- [ ] .env configured for production
- [ ] Firebase security rules updated
- [ ] API keys secured

### Build Process

#### Android APK
```bash
flutter build apk --release
```

#### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
```

#### iOS Build
```bash
flutter build ios --release
```

### Version Management

Update version in `pubspec.yaml`:
```yaml
version: 1.0.0+1
#        |   |  |
#        |   |  └─ Build number
#        |   └──── Patch version
#        └──────── Major.Minor version
```

### Release Process

1. **Update Version**
   ```bash
   # Update pubspec.yaml version
   # Update CHANGELOG.md
   ```

2. **Build Release**
   ```bash
   flutter build appbundle --release
   ```

3. **Test Release Build**
   ```bash
   flutter install --release
   ```

4. **Tag Release**
   ```bash
   git tag -a v1.0.0 -m "Version 1.0.0"
   git push origin v1.0.0
   ```

5. **Upload to Play Store**
   - Use Google Play Console
   - Upload AAB file
   - Complete store listing
   - Submit for review

## Common Issues and Solutions

### Issue: Firebase not initialized
**Solution**: Ensure `firebase_options.dart` is configured correctly.

### Issue: Hot reload not working
**Solution**:
```bash
flutter clean
flutter pub get
```

### Issue: Build fails on Android
**Solution**:
```bash
cd android
./gradlew clean
cd ..
flutter build apk
```

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart)
- [Material Design](https://material.io/)

## Support

For development questions:
- Check existing issues
- Create new issue with detailed description
- Contact: dev@itracelink.rw

---

**Happy Coding! 🚀**
