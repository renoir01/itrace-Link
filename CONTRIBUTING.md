# Contributing to iTraceLink

First off, thank you for considering contributing to iTraceLink! It's people like you that make iTraceLink such a great tool for improving nutrition security in Rwanda.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to support@itracelink.rw.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples**
- **Describe the behavior you observed and what you expected**
- **Include screenshots if possible**
- **Include your environment details** (Flutter version, device, OS version)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- **Use a clear and descriptive title**
- **Provide a detailed description of the suggested enhancement**
- **Provide specific examples to demonstrate the enhancement**
- **Explain why this enhancement would be useful**

### Pull Requests

Please follow these steps:

1. **Fork the repository** and create your branch from `main`
2. **Follow the development setup** in README.md
3. **Make your changes** following our coding standards
4. **Add tests** for your changes
5. **Ensure the test suite passes** (`flutter test`)
6. **Make sure your code lints** (`flutter analyze`)
7. **Format your code** (`flutter format .`)
8. **Update documentation** as needed
9. **Write a good commit message**

## Development Process

### 1. Setting Up Your Development Environment

```bash
# Fork and clone the repository
git clone https://github.com/YOUR_USERNAME/itrace-Link.git
cd itrace-Link

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/itrace-Link.git

# Install dependencies
flutter pub get

# Set up environment variables
cp .env.example .env
# Edit .env with your credentials
```

### 2. Creating a Feature Branch

```bash
# Update your local main branch
git checkout main
git pull upstream main

# Create a new feature branch
git checkout -b feature/your-feature-name
```

### 3. Making Changes

- Write clean, readable code
- Follow the Dart style guide
- Add comments for complex logic
- Keep commits atomic and well-described

### 4. Testing Your Changes

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test

# Check for linting errors
flutter analyze

# Format code
flutter format .
```

### 5. Committing Your Changes

We follow conventional commits:

```bash
# Format: <type>(<scope>): <subject>

# Examples:
git commit -m "feat(auth): add phone verification"
git commit -m "fix(orders): resolve null pointer exception"
git commit -m "docs(readme): update installation instructions"
git commit -m "test(farmer): add cooperative registration tests"
```

**Commit Types:**
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### 6. Pushing and Creating a Pull Request

```bash
# Push your changes
git push origin feature/your-feature-name

# Create a pull request on GitHub
```

**Pull Request Template:**

```markdown
## Description
Brief description of what this PR does

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## Screenshots (if applicable)
Add screenshots here

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests added and passing
```

## Coding Standards

### Dart Style Guide

Follow the [official Dart style guide](https://dart.dev/guides/language/effective-dart).

### Key Points

**1. Naming Conventions**
```dart
// Classes: PascalCase
class UserService {}

// Variables/Functions: camelCase
String userName = '';
void getUserData() {}

// Files: snake_case
user_service.dart
```

**2. Code Organization**
```dart
// Import order
import 'dart:async';              // Dart SDK
import 'package:flutter/material.dart';  // Flutter
import 'package:provider/provider.dart';  // Packages
import '../models/user_model.dart';      // Local
```

**3. Widget Best Practices**
```dart
// Use const constructors
const Text('Hello')

// Extract complex widgets
class CustomCard extends StatelessWidget {
  const CustomCard({super.key});
  // ...
}

// Use named parameters for clarity
void createOrder({
  required String id,
  required double amount,
}) {}
```

**4. Error Handling**
```dart
try {
  await riskyOperation();
} on SpecificException catch (e) {
  // Handle specific exception
} catch (e) {
  // Handle general exception
} finally {
  // Cleanup
}
```

### Comments

```dart
// Good: Explain WHY, not WHAT
// Retry failed requests to handle network instability
await retryRequest();

// Avoid: Stating the obvious
// Set the user name
userName = 'John';
```

## Project Structure

When adding new features, follow this structure:

```
lib/features/your_feature/
├── screens/              # UI screens
│   └── your_screen.dart
├── widgets/              # Feature-specific widgets
│   └── your_widget.dart
├── providers/            # State management
│   └── your_provider.dart
└── models/              # Data models (if needed)
    └── your_model.dart
```

## Testing Guidelines

### Unit Tests

```dart
// test/services/user_service_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserService', () {
    late UserService service;

    setUp(() {
      service = UserService();
    });

    test('creates user successfully', () async {
      final result = await service.createUser(...);
      expect(result, isNotNull);
    });
  });
}
```

### Widget Tests

```dart
// test/widgets/user_card_test.dart
testWidgets('UserCard displays correct information', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: UserCard(user: testUser)),
  );

  expect(find.text('John Doe'), findsOneWidget);
});
```

### Integration Tests

```dart
// integration_test/app_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('complete login flow', (tester) async {
    // Test implementation
  });
}
```

## Documentation

- Update README.md for major changes
- Update CHANGELOG.md for all changes
- Add inline documentation for public APIs
- Update DEVELOPMENT_GUIDE.md for architectural changes

## Questions?

Feel free to:
- Open an issue for discussion
- Contact the maintainers
- Join our community discussions

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation

Thank you for contributing to iTraceLink! 🎉
