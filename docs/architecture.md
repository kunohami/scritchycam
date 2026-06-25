# ScritchyCam — Architecture

## Overview

ScritchyCam is a Flutter Android app (with multiplatform groundwork) built around a live camera preview with a transparent image overlay for tracing reference drawings. The architecture is intentionally simple and feature-based, designed to grow incrementally as new camera features are added.

---

## Folder Structure

```
lib/
  features/
    camera/
      camera_screen.dart       # Main UI screen, composes all layers
      camera_controller.dart   # Riverpod StateNotifier + CameraState
    overlay/
      overlay_state.dart       # Overlay image state (image, opacity, position, scale)
      overlay_picker.dart      # UI controls for picking and adjusting the overlay
  services/
    camera_service.dart        # Thin wrapper around the camera package
    image_service.dart         # Thin wrapper around image_picker
  main.dart                    # App entry point, ProviderScope root
docs/
  architecture.md              # This file
  documentation-guide.md       # Documentation practices for this project
```

---

## State Management — Riverpod

All mutable state lives in Riverpod `StateNotifierProvider`s:

| Provider         | State class    | Owns                                              |
|------------------|---------------|---------------------------------------------------|
| `cameraProvider` | `CameraState` | The active `CameraController`, initialization status, errors |
| `overlayProvider`| `OverlayState`| Selected image file, opacity, drag position, scale |

Neither provider depends on the other. `CameraScreen` watches both and composes them into a `Stack`.

---

## UI Composition

The camera screen is a `Stack` of three independent layers:

```
Stack
├── _CameraPreview        — full-screen live camera feed
├── _OverlayLayer         — transparent image, handles drag + pinch gestures
└── _BottomControls       — opacity slider, image picker button, camera switch
```

This layered approach makes it easy to insert new layers (filters, stickers, effects) without restructuring existing code.

---

## Data Flow

```
User gesture / button tap
        │
        ▼
  Riverpod Notifier (CameraNotifier or OverlayNotifier)
        │
        ▼
  StateNotifier.state updated
        │
        ▼
  Widgets rebuild via ref.watch(...)
```

No side effects outside the notifiers. No shared mutable state.

---

## Services

Services are plain Dart classes with static methods. They exist to isolate third-party package APIs from the rest of the app. If the `camera` or `image_picker` packages change their API, only the relevant service file needs updating.

---

## Adding New Camera Features

Each new feature (double exposure, distortions, filters, stickers) follows the same pattern:

1. Add a new `features/<feature-name>/` folder.
2. Create a `StateNotifier` + state class for any new state.
3. Add a new layer to the `Stack` in `camera_screen.dart`.
4. Wire controls into `_BottomControls` or a new controls widget.

For GPU-heavy effects (distortions, real-time filters), GLSL fragment shaders go in `lib/shaders/` and are registered in `pubspec.yaml` under `flutter: shaders:`.

---

## No Database

There is no local database. Persistence needs for this app are minimal:
- Captured photos → written to device gallery via the `image_gallery_saver` package (not yet added)
- User preferences (e.g. default opacity) → `shared_preferences` (add when needed)

SQLite would be over-engineering for this use case.
