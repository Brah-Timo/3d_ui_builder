# Contributing to three_d_ui_builder

Thank you for considering a contribution.  This document covers the conventions and workflow expected for all contributors.

---

## Prerequisites

| Tool | Version |
|------|---------|
| Flutter | ≥ 3.24.0 |
| Dart | ≥ 3.3.0 |
| Git | ≥ 2.40 |

---

## Setting Up the Repository

```sh
git clone https://github.com/your-org/3d_ui_builder.git
cd 3d_ui_builder/three_d_ui_builder

# Install dependencies
flutter pub get

# Run all tests
flutter test

# Run the analyzer
flutter analyze
```

Both commands must exit with code 0 before you open a pull request.

---

## Project Structure

```
three_d_ui_builder/
├── lib/
│   ├── three_d_ui_builder.dart    ← barrel export (add exports here)
│   └── src/
│       ├── core/
│       │   ├── engine/
│       │   ├── foundation/
│       │   └── math/
│       ├── widgets/
│       │   ├── base/
│       │   ├── buttons/
│       │   ├── cards/
│       │   ├── containers/
│       │   ├── lists/
│       │   ├── scene/
│       │   └── text/
│       ├── animation/
│       ├── gestures/
│       ├── painters/
│       ├── theme/
│       └── utils/
├── test/
│   ├── core/
│   ├── widgets/
│   └── animation/
├── example/
└── doc/
```

---

## Coding Standards

### Dart Style

Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart/style) style guide in full. Key points:

- Use `lowerCamelCase` for variables, parameters, and function names.
- Use `UpperCamelCase` for classes, enums, typedefs, and type parameters.
- Use `SCREAMING_SNAKE_CASE` only for constants in enums (optional).
- Prefer `final` over `var` where the variable is never reassigned.
- Prefer `const` constructors wherever possible.

### File Names

- One public class (or closely related set of classes) per file.
- File name = the primary class name in `snake_case`.
- Example: `class FlipCard3D` → file `flip_card_3d.dart`

### Public API Documentation

Every public class, method, property, and parameter must have a `///` doc comment.  Follow this template:

```dart
/// One-sentence summary ending with a period.
///
/// Longer explanation of behaviour, edge cases, or context if needed.
///
/// ### Example
/// ```dart
/// final result = MyClass.doSomething(param: 42);
/// ```
///
/// See also: [RelatedClass], [anotherMethod].
```

### No Magic Numbers

Avoid inline numeric literals in non-trivial calculations.  Extract them as named local variables or constants with descriptive names:

```dart
// ❌ Magic number
final scale = 0.55 + 0.45 * normZ;

// ✅ Named constants
const minScale = 0.55;
const scaleRange = 0.45;
final scale = minScale + scaleRange * normZ;
```

### No Mock Data in Tests

All tests must exercise real implementations. Do not use fake/stub classes that return hardcoded values for the thing being tested.

```dart
// ❌ Wrong — mocking the thing under test
class FakeVec3 { double get length => 1.0; }

// ✅ Correct — test the real implementation
expect(const Vec3(3, 4, 0).length, closeTo(5.0, 1e-10));
```

---

## Adding a New Widget

1. **Create the file** in the appropriate `src/widgets/` subdirectory.
2. **Implement the widget** with full `///` documentation on every public member.
3. **Export it** from `lib/three_d_ui_builder.dart`.
4. **Write tests** in `test/widgets/` covering:
   - The widget renders without throwing.
   - Core parameters affect the rendered output.
   - Controller API (if the widget has one) works correctly.
5. **Add an example screen** in `example/lib/screens/` if the widget has non-obvious usage.
6. **Update `doc/widgets.md`** with the new widget's API table.
7. **Update `CHANGELOG.md`** under `[Unreleased] → Added`.

---

## Test Requirements

Every pull request must maintain or improve test coverage.

### Test File Location

| Code location | Test location |
|---------------|---------------|
| `src/core/math/*.dart` | `test/core/` |
| `src/widgets/**/*.dart` | `test/widgets/` |
| `src/animation/*.dart` | `test/animation/` |
| `src/gestures/*.dart` | `test/gestures/` |
| `src/theme/*.dart` | `test/theme/` |

### Minimum Test Cases per Widget

- ✅ Widget renders without throwing
- ✅ Default parameters produce expected visual state
- ✅ `onPressed` / `onFlipComplete` / `onFaceVisible` callbacks fire
- ✅ Controller API methods execute without error
- ✅ Disabled/null state handled correctly

### Running Tests

```sh
# All tests
flutter test

# Specific test file
flutter test test/widgets/flip_card_test.dart

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## Pull Request Process

1. **Fork** the repository and create a branch from `main`:
   ```sh
   git checkout -b feat/my-new-widget
   ```

2. **Write your code and tests.**

3. **Check quality:**
   ```sh
   flutter test          # all tests pass
   flutter analyze       # zero issues
   dart format . --set-exit-if-changed   # code is formatted
   ```

4. **Write a clear commit message** following [Conventional Commits](https://www.conventionalcommits.org/):
   ```
   feat(widgets): add PyramidMenu3D with tap-to-expand items
   fix(spring): clamp spring simulation output to prevent NaN at extreme stiffness
   docs(widgets): add TiltCard parameter table to widgets.md
   test(flip_card): add test for FlipAxis.z rotation
   ```

5. **Open a pull request** targeting `main`.  Fill in the PR template (auto-populated).

6. **Respond to review comments** — address all requests or explain why they should not be applied.

7. The PR is merged by a maintainer once:
   - All CI checks pass.
   - At least one maintainer has approved.
   - `CHANGELOG.md` is updated.

---

## Commit Message Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer(s)]
```

**Types:** `feat`, `fix`, `docs`, `test`, `refactor`, `perf`, `chore`, `ci`

**Scopes:** `widgets`, `math`, `animation`, `theme`, `gestures`, `painters`, `example`, `docs`

---

## Code of Conduct

Be respectful.  Contributions from anyone are welcome regardless of experience level, background, or identity.  See [Contributor Covenant](https://www.contributor-covenant.org/) for the full code of conduct.
