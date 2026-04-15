# CLAUDE.md

## General

Follow the existing style and structure of the repository. Do not introduce new
patterns, naming schemes, or architectural conventions unless explicitly asked.
If no conventions exist, follow the defaults defined here.

## Override Rule

Repository conventions take precedence over this document. Do not mix styles or
partially apply these rules within an existing codebase.

## Code Style

### Comments
- Write comments only when they add real value.
- Do not add banner comments, section dividers, or decorative comment headers.
- Do not restate what the code already makes obvious.
- Prefer self-documenting code through clear naming and structure.

## Naming Conventions (Default)

- Files: `snake_case`
- Types (classes, structs, enums, aliases): `PascalCase`
- Functions, methods, variables, parameters: `camelCase`
- Member variables: `camelCase_`

### C++ Style
- Prefer modern C++.
- Avoid unnecessary macros.
- Avoid clever or dense code when simpler alternatives exist.
- Keep functions focused and reasonably small.
- Prefer scoped enums (`enum class`).

## Formatting and Linting

- If present, follow `.clang-format` and `.clang-tidy` exactly.
- Do not introduce formatting that conflicts with repository configuration.
- If not present, default to LLVM-style formatting and strict modern C++
  linting.

## Project Structure

Prefer this layout unless the repository already uses something else:

```
src/
include/<project_name>/
tests/
build/
```

If a repository already defines a structure, follow it exactly.

## CMake

Use modern CMake.

Defaults:
- Set language standard explicitly
- Require the standard
- Disable compiler extensions
- Export compile commands
- Enable warnings:
  - `-Wall`
  - `-Wextra`
  - `-Wpedantic`

Testing:
- Prefer GoogleTest
- Prefer `FetchContent`
- Use `gtest_discover_tests(...)` when appropriate

## Includes

- Keep include paths consistent with the project structure.
- Prefer project includes of the form:

  #include "project_name/header.h"

- Do not mix relative and project-root include styles arbitrarily.
- Follow repository include ordering conventions.

## File Extensions (C++)

Default:
- Header files: `.h`
- Source files: `.cpp`

Do not introduce alternative extensions (`.hpp`, `.cc`, `.cxx`, etc.)
in a project that does not already use them.

If the repository already uses a different convention, follow it exactly.
Do not mix extensions within the same project.
Ensure include directives match the chosen file extensions exactly.
