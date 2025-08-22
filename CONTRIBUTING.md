# Contributing to IforEvents

Thank you for your interest in contributing to IforEvents! We welcome contributions from the community and are excited to see what you'll bring to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to [innovafour@innovafour.com](mailto:innovafour@innovafour.com).

### Our Standards

- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- Git
- A code editor (VS Code, Android Studio, or IntelliJ IDEA recommended)

### Development Setup

1. **Fork the repository**
   ```bash
   # Fork the repo on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/flutter_iforevents.git
   cd flutter_iforevents
   ```

2. **Install dependencies**
   ```bash
   # Install dependencies for all packages
   flutter pub get
   cd iforevents && flutter pub get && cd ..
   cd iforevents_firebase && flutter pub get && cd ..
   cd iforevents_mixpanel && flutter pub get && cd ..
   cd iforevents_algolia && flutter pub get && cd ..
   ```

3. **Run tests**
   ```bash
   # Run tests for all packages
   flutter test
   ```

4. **Set up your development environment**
   ```bash
   # Create a new branch for your feature
   git checkout -b feature/your-feature-name
   ```

## How to Contribute

### Reporting Bugs

Before submitting a bug report:
- Check the [existing issues](https://github.com/innovafour/flutter_iforevents/issues) to avoid duplicates
- Use the latest version of the package
- Provide detailed reproduction steps

When submitting a bug report, include:
- A clear, descriptive title
- Detailed description of the issue
- Steps to reproduce the problem
- Expected vs. actual behavior
- Environment details (Flutter version, platform, etc.)
- Code snippets or minimal reproduction example

### Suggesting Features

We welcome feature suggestions! Please:
- Check existing issues for similar requests
- Provide a clear description of the feature
- Explain the use case and benefits
- Consider the scope and complexity

### Submitting Changes

1. **Create an issue** (for significant changes)
2. **Fork the repository**
3. **Create a feature branch**
4. **Make your changes**
5. **Add tests** for your changes
6. **Update documentation** if needed
7. **Submit a pull request**

## Pull Request Process

### Before Submitting

- [ ] Code follows our [coding standards](#coding-standards)
- [ ] All tests pass (`flutter test`)
- [ ] New code has appropriate test coverage
- [ ] Documentation is updated (if applicable)
- [ ] Commit messages are clear and descriptive
- [ ] No merge conflicts with main branch

### PR Guidelines

1. **Title**: Use a clear, descriptive title
2. **Description**: Explain what changes you made and why
3. **References**: Link to relevant issues
4. **Testing**: Describe how you tested your changes
5. **Breaking Changes**: Clearly mark any breaking changes

### Review Process

- All PRs require at least one review from a maintainer
- PRs may require changes before being merged
- We'll provide constructive feedback and work with you to get your contribution merged

## Coding Standards

### Dart Code Style

We follow the [official Dart style guide](https://dart.dev/guides/language/effective-dart/style). Key points:

- Use `dart format` to format your code
- Follow naming conventions:
  - `camelCase` for variables, functions, and parameters
  - `PascalCase` for classes, enums, typedefs
  - `snake_case` for package names, file names
- Use meaningful variable and function names
- Add documentation comments for public APIs

### File Organization

```
iforevents/
├── lib/
│   ├── iforevents.dart          # Main export file
│   ├── models/                  # Data models
│   ├── integration/             # Integration interfaces
│   └── utils/                   # Utility classes
├── test/                        # Unit tests
├── example/                     # Example app
└── pubspec.yaml
```

### Code Quality

- Write self-documenting code
- Add comments for complex logic
- Use meaningful commit messages
- Keep functions small and focused
- Handle errors appropriately
- Follow the single responsibility principle

## Testing

### Writing Tests

- Write unit tests for all new functionality
- Use descriptive test names
- Test both success and error cases
- Mock external dependencies
- Aim for high test coverage

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/specific_test.dart
```

### Test Structure

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:iforevents/iforevents.dart';

void main() {
  group('Iforevents', () {
    late Iforevents iforevents;

    setUp(() {
      iforevents = const Iforevents();
    });

    test('should initialize successfully', () async {
      // Test implementation
    });

    group('track method', () {
      test('should track events correctly', () {
        // Test implementation
      });
    });
  });
}
```

## Documentation

### API Documentation

- Use `///` for public API documentation
- Follow [effective Dart documentation guidelines](https://dart.dev/guides/language/effective-dart/documentation)
- Include examples in documentation when helpful
- Document parameters, return values, and exceptions

### Example Documentation

```dart
/// Tracks an event with optional properties.
///
/// [eventName] is required and should be a descriptive name for the event.
/// [eventType] defaults to [EventType.track] if not specified.
/// [properties] contains additional data associated with the event.
///
/// Example:
/// ```dart
/// iforevents.track(
///   eventName: 'button_clicked',
///   properties: {'button_name': 'signup'},
/// );
/// ```
void track({
  required String eventName,
  EventType eventType = EventType.track,
  Map<String, dynamic> properties = const {},
}) {
  // Implementation
}
```

## Development Workflow

### Branching Strategy

- `main` - stable, production-ready code
- `develop` - integration branch for features
- `feature/feature-name` - individual feature branches
- `hotfix/fix-name` - urgent fixes

### Commit Messages

Use conventional commit format:

```
type(scope): description

body (optional)

footer (optional)
```

Types:
- `feat`: new feature
- `fix`: bug fix
- `docs`: documentation changes
- `style`: formatting changes
- `refactor`: code refactoring
- `test`: adding tests
- `chore`: maintenance tasks

Examples:
```
feat(core): add automatic IP detection
fix(firebase): resolve initialization timing issue
docs(readme): update installation instructions
```

## Integration Development

### Adding New Integrations

When adding a new analytics integration:

1. Create a new package following the naming convention `iforevents_[platform]`
2. Implement the `Integration` abstract class
3. Follow the existing integration patterns
4. Add comprehensive tests
5. Update documentation
6. Add example usage

### Integration Structure

```dart
import 'package:iforevents/models/integration.dart';

class YourIntegration extends Integration {
  const YourIntegration({required this.apiKey});

  final String apiKey;

  @override
  Future<void> init() async {
    // Initialize your analytics platform
  }

  @override
  Future<void> identify({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    // Identify user with your platform
  }

  @override
  Future<void> track({
    required String eventName,
    EventType eventType = EventType.track,
    Map<String, dynamic> properties = const {},
  }) async {
    // Track event with your platform
  }

  @override
  Future<void> reset() async {
    // Reset user data
  }
}
```

## Release Process

Releases are handled by maintainers. The process includes:

1. Version bump in `pubspec.yaml`
2. Update `CHANGELOG.md`
3. Create a git tag
4. Publish to pub.dev
5. Create GitHub release

## Getting Help

- 📧 Email: [innovafour@innovafour.com](mailto:innovafour@innovafour.com)
- 💬 Discussions: [GitHub Discussions](https://github.com/innovafour/flutter_iforevents/discussions)
- 🐛 Issues: [GitHub Issues](https://github.com/innovafour/flutter_iforevents/issues)

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Package documentation

Thank you for contributing to IforEvents! 🎉
