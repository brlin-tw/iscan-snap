# AI agent instruction file

This file contains instructions and guidelines for AI agents interacting with this repository. It outlines the expected behavior, coding standards, and collaboration protocols to ensure effective and efficient contributions.

## Agent Skills Overview

This project make use of [Agent Skills](https://agentskills.io/), which are modular capabilities that AI agents can utilize to perform specific tasks.

If you don't have the concept of Agent Skills, refer to the following instructions to make use of them:

1. List the leading directories of the following sub-directories to understand which skills are available:
    + `.claude/skills/`
    + `~/.claude/skills/`
    + `.gemini/skills/`
    + `~/.gemini/skills/`
    + `.github/skills/`
    + `~/.copilot/skills/`
1. Read the `description` key of the YAML front matter of the SKILL.md file under each leading directory to understand its purpose and when to use it.
1. Fully read the SKILL.md file of a skill only if its trigger condition matches the task.  For example, code-review tasks must load `skills/code-review/SKILL.md`.  Once loaded, follow the process and output format defined in the skill file so that the final response remains consistent.

**Response contract**:

* Explicitly state which skills and rules are in effect.
* Provide findings, recommendations, or code while enforcing all loaded constraints. If any conflicts arise, ask for clarification before diverging.

## Contributor Guidelines

### Project Structure & Module Organization

The Snap recipe lives in `snap/snapcraft.yaml`. Repository-specific launchers,
build scriptlets, utilities, patches, and branding assets are under
`snap/local/`; desktop metadata and the application icon are under `snap/gui/`.
Keep user-facing Snap documentation in `snap/README.md` and packaging-level
notes in the root `README.md`. GitHub Actions workflows in `.github/workflows/`
provide build and static-check coverage. Licensing metadata is maintained in
`.reuse/dep5` and `LICENSES/`.

### Build, Test, and Development Commands

Run `snapcraft pack` from the repository root to build the Snap using
`snap/snapcraft.yaml`. Use `snapcraft clean` before a clean rebuild when cached
parts may hide packaging changes. Run `pre-commit run --all-files` to reproduce
the repository's static-check workflow; it checks YAML, Markdown, file hygiene,
and REUSE compliance. Install the resulting artifact locally with
`sudo snap install --dangerous ./iscan_*.snap` for manual testing.

### Coding Style & Naming Conventions

Follow `.editorconfig`: use UTF-8, LF line endings, final newlines, four spaces
by default, and two spaces for YAML. Use lowercase, hyphenated names for shell
helpers, such as `install-non-free-plugins.sh`. Bash variables use
`lowercase_with_underscores`; environment variables remain uppercase. New Bash
scripts should use `#!/usr/bin/env bash`, `test` for ordinary conditions,
`printf` for messages, and `${variable}` expansion. Run ShellCheck when
changing shell code.

### Testing Guidelines

There is no standalone unit-test suite. Treat a successful Snapcraft build as
the minimum packaging test. For launcher, interface, or plugin-installer
changes, install the Snap and exercise the affected flow on a disposable
system with relevant EPSON hardware where possible. Static checks must pass
before submission.

### Commit & Pull Request Guidelines

History follows Conventional Commit-style subjects, including `feat:`, `fix:`,
`refactor:`, and `lint:`. Keep the subject imperative and focused, for example
`fix: Handle missing plugin archive`. Pull requests should explain the user
impact, list validation performed, link related issues, and include screenshots
for dialog or desktop-visible changes. Call out confinement, interface, or
licensing changes explicitly; never add non-redistributable EPSON plugins to
the repository or built Snap.
