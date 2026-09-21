## 0.2.0

* **Requires `iforevents` ^0.2.0.** Picks up the typed API errors and the
  quota-aware queue of the core; no changes to this integration's own API.

## 0.1.0

### 💥 Breaking

* **Requires `iforevents` ^0.1.0.** The previous `^0.0.5` constraint could not
  resolve against the current core, so this package silently held users back on
  the old core that still carried a project secret. Upgrade both together.

### 📦 Release

* First publication to pub.dev. The package existed in the repository but was
  never released, so `iforevents_segment` could not be depended on.

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2024-11-02

### Added
- Initial release of IForEvents Segment integration
- User identification with custom traits
- Event tracking with properties
- Screen/page view tracking
- Group analytics support
- User aliasing functionality
- Reset functionality for user data clearing
- Automatic application lifecycle event tracking
- Deep link tracking support
- Debug mode for development
- Manual flush capability
- Comprehensive documentation and examples
