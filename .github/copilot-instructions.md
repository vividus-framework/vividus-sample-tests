# VIVIDUS Sample Tests

Gradle-based test automation project using the VIVIDUS framework (BDD/JBehave). All test logic lives in `.story`, `.steps`, `.table`, and `.properties` files under `src/main/resources/`. There is no Java source — do not create `.java` files.

## Bootstrap

The `vividus-build-system` submodule must be initialized before any Gradle task will work:

```bash
git submodule update --init
```

## Build & Validate

```bash
./gradlew build           # Spotless formatting checks + VIVIDUS init validation
./gradlew spotlessApply   # Auto-fix formatting violations
```

## Project Layout

```text
src/main/resources/
  properties/
    configuration.properties               # Maps configuration-set names to profiles, suites, environments
    suite/<suite-name>/suite.properties    # Per-suite: batch story locations, composite step paths
  story/**/*.story                         # Test scenarios
  steps/**/*.steps                         # Composite step definitions
  known-issues.json                        # Known issue patterns
  overriding.properties                    # Local overrides (e.g. configuration-set.active=web-app)
build.gradle                               # VIVIDUS BOM + plugin dependencies
.github/workflows/                         # CI workflows (see CI section)
```

Story and step file locations per suite are discovered by:

1. Resolving suite name(s) from `configuration-set.<active-set>.suites` in `configuration.properties`.
2. Reading `batch-<N>.resource-location` in each suite's `suite.properties` to find stories at `src/main/resources/<value>/**/*.story`.
3. Reading `engine.composite-paths` in each suite's `suite.properties` to find composite steps at `src/main/resources/<glob>`.

## Running Tests

```bash
./gradlew runStories -Pvividus.configuration-set.active=rest-api    # REST API (no browser)
./gradlew runStories -Pvividus.configuration-set.active=web-app     # Web UI (requires Chrome)
./gradlew runStories -Pvividus.configuration-set.active=ios-app     # iOS (macOS + Appium + simulator)
./gradlew runStories -Pvividus.configuration-set.active=android-app # Android (macOS + Appium + emulator)
./gradlew runStories -Pvividus.configuration-set.active=electron    # Electron (VS Code is a system under test)
```

```bash
./gradlew debugStories -Pvividus.configuration-set.active=rest-api
```

`runStories` runs Spotless formatting checks and VIVIDUS init validation before executing tests. Use `debugStories` to skip all build checks.
