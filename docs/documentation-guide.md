# Documentation Guide

This document describes what to document, where, and how in ScritchyCam.

---

## Principles

**Document the why, not the what.**
Code already shows what it does. Comments and docs exist to explain constraints, trade-offs, and non-obvious decisions that future readers (including yourself) can't derive from reading the code.

**Documentation lives close to the code it describes.**
A comment next to the code it explains stays up to date. A doc that describes code from a distance drifts.

**Short and specific beats long and general.**
A one-line comment that explains a real constraint is worth more than a paragraph restating what the function signature already says.

---

## What to Document

### Always document:

- **Non-obvious constraints.** If a value must stay within a range for a reason external to the code (hardware limit, OS behavior, UX decision), say why.
  ```dart
  // Android requires CAMERA permission to be requested at runtime on API 23+
  ```

- **Workarounds.** If you did something a non-obvious way to work around a specific bug or library limitation, leave a note.
  ```dart
  // Scale clamped manually here because InteractiveViewer's minScale doesn't
  // apply correctly when the child is smaller than the viewport
  ```

- **Architectural decisions.** When you make a structural choice with trade-offs (e.g. why Riverpod over Bloc, why no database), record it in `docs/architecture.md`.

### Do not document:

- What the code does when the name already says it.
  ```dart
  // BAD: Picks image from gallery
  Future<File?> pickFromGallery() async { ... }
  ```

- Obvious parameter meanings, return types, or class responsibilities that are clear from names and types.

- Temporary state ("WIP", "TODO: fix later") — use GitHub issues for tracked work instead.

---

## Where Documentation Lives

| What                              | Where                          |
|-----------------------------------|--------------------------------|
| Non-obvious code behavior         | Inline comment in the file     |
| Architectural decisions           | `docs/architecture.md`         |
| Feature design or trade-off notes | `docs/` — add a new file       |
| Bug tracking / future work        | GitHub Issues                  |
| Shader-specific behavior          | Comment at top of `.glsl` file |

---

## Inline Comment Style

Use `//` comments only. No block comments (`/* */`) and no multi-line comment walls.

```dart
// Good: one line, explains a non-obvious reason
final scale = size.aspectRatio * (1 / controller.value.aspectRatio);

// Bad: restates the obvious
// Calculate the scale by dividing the size aspect ratio by the controller aspect ratio
final scale = size.aspectRatio * (1 / controller.value.aspectRatio);
```

---

## Docs Folder Conventions

- One file per topic. Don't merge unrelated decisions into one document.
- Use Markdown. Keep headings short.
- Date significant decisions if timing matters (e.g. "switched from X to Y in v0.3 because...").
- Update docs when the code changes. A doc that contradicts the code is worse than no doc.

---

## What Not to Write

- Do not write a CHANGELOG here — git log is the changelog.
- Do not duplicate the README — it belongs at the project root if ever added.
- Do not copy-paste API docs from packages into this repo.
