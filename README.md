# ScritchyCam

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.44.3-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/platform-Android-3DDC84?logo=android&logoColor=white)](https://developer.android.com)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

A quirky, personal camera app built with Flutter. The first feature is an AR tracing overlay: pick any image from your gallery and it appears transparently over the live camera feed so you can trace it onto paper or canvas. More camera experiments to come.

---

## Features

- Full-screen live camera preview
- Transparent image overlay for tracing reference drawings
- Adjustable overlay opacity via toggleable slider
- Drag to reposition and pinch to scale the overlay
- Camera zoom via slider or pinch gesture
- Front/back camera switch
- Hide/show all UI controls for a clean view

---

## Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) 3.44.x or later
- Android SDK 34+ with build tools
- An Android device or emulator with a camera

### Installation

```bash
git clone https://github.com/kunohami/scritchycam.git
cd scritchycam
flutter pub get
```

### Running

Connect an Android device with USB debugging enabled, then:

```bash
flutter run
```

For a release build:

```bash
flutter build apk --release
```

---

## Architecture

ScritchyCam uses a feature-based folder structure with [Riverpod](https://riverpod.dev) for state management. There is no local database — photos are written to the device gallery and preferences use `shared_preferences` when needed.

```
lib/
  features/
    camera/       # Camera preview, zoom, controller state
    overlay/      # Reference image state and controls
  services/       # Thin wrappers around camera and image_picker packages
  main.dart
```

Full architecture notes and documentation practices are in the [`docs/`](docs/) folder.

---

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

---

## License

[MIT](LICENSE) — kunohami, 2026
