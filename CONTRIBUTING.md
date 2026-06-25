# Contributing to ScritchyCam

Thanks for taking the time to contribute. ScritchyCam is a personal project open to collaboration — whether that is fixing a bug, suggesting a camera feature, or improving the docs.

---

## Before You Start

- Check the [open issues](https://github.com/kunohami/scritchycam/issues) to see if the work is already tracked or being discussed.
- For anything beyond a small fix, open an issue first to describe what you want to do and why. This avoids wasted effort if the direction does not fit the project.

---

## Development Setup

1. Fork the repository and clone your fork.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Connect an Android device with USB debugging enabled and run:
   ```bash
   flutter run
   ```

See [`docs/architecture.md`](docs/architecture.md) for a walkthrough of the project structure before making changes.

---

## Submitting a Pull Request

- Keep PRs focused on a single concern. One bug fix or one feature per PR.
- Match the existing code style. No unnecessary reformatting of unrelated lines.
- Test on a physical Android device if the change touches the camera or image pipeline.
- Write a clear PR description: what changed, why, and how to verify it.

---

## Adding a Camera Feature

The project is designed to grow incrementally with new camera effects and tools. If you want to add a feature (filters, distortions, double exposure, stickers, etc.):

1. Create a new folder under `lib/features/<feature-name>/`.
2. Add a `StateNotifier` + state class if the feature has its own state.
3. Add a new layer to the `Stack` in `camera_screen.dart`.
4. For GPU effects, add GLSL shaders to `lib/shaders/` and register them in `pubspec.yaml`.

See [`docs/architecture.md`](docs/architecture.md) for the full pattern.

---

## Reporting Bugs

Open an issue with:
- Device model and Android version
- Flutter version (`flutter --version`)
- Steps to reproduce
- What you expected vs. what happened

---

## AI-Assisted Contributions

Using AI tools to help write or understand code is fine. However you are responsible for your code and you should understand it, so you must review the code yourself personally before submitting anything.

