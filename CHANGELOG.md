# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-06-11

### Added
- Inline file contents from a quoted argument (usage 3), e.g. `puravida dir/file.txt "hi"`.
- `-h`/`--help` and `--version` flags.
- bats-core test suite (`test/puravida.bats`).
- `Makefile` with `install`, `uninstall`, `test`, and `lint` targets.
- GitHub Actions CI: shellcheck (lint) and bats (tests on macOS and Linux).
- Top-level MIT `LICENSE` file.

### Changed
- Quoted all variable expansions and enabled `set -euo pipefail`, so paths with
  spaces are handled correctly.
- Paste mode now uses portable `sed`, so the tool runs on Linux as well as macOS.
- Switched the tilde check to `[[ ]]` for safer, more idiomatic bash.
- Renamed the script from `puravida.sh` to `puravida` and marked it executable.

### Fixed
- The tilde check no longer errors with `too many arguments` on multi-word
  second arguments.

[Unreleased]: https://github.com/mark-mcdermott/puravida/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/mark-mcdermott/puravida/releases/tag/v1.0.0
