# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `make install-user` / `make uninstall-user` for a per-user install under
  `~/.local` (no `sudo`). The README now leads with this; `sudo make install`
  remains the system-wide option.

## [2.0.0] - 2026-06-14

### Changed
- **BREAKING:** Redesigned the argument grammar.
  - Inline content now requires a `~~` marker — `puravida notes.txt ~~ hello`
    (previously `puravida notes.txt "hello"`). Content is everything after the
    first `~~`, joined with spaces, and attaches to the most recently named file.
  - Multiple paths each create their own file (dotted leaf) or directory
    (dotless leaf), so `puravida a.txt b.txt` now creates two files (previously
    it wrote `b.txt` into `a.txt`).
  - A trailing `/` forces a directory, even on a dotted leaf (`puravida .claude/`).
  - A leading directory still contains the paths named after it, now supporting
    nested sub-paths with auto-created parents
    (`puravida .claude/ settings.json commands/cmd.md`).
- Standardized the `--help` output to the conventional `Usage:` / `Options:` /
  `Examples:` layout, and removed the emoji from it.
- Usage errors (no arguments, an unknown option, or `~~` with no preceding file)
  exit with code `2`.

### Added
- `-f`/`--file` flag to force dotless names (e.g. `Makefile`, `LICENSE`) to be files.
- Optional `make install-pv` target that symlinks `pv` → `puravida`.
- A `man` page (`man/puravida.1`), installed by `make install`.
- Synopsis, Options, and Exit status sections in the README.
- Unknown options are now rejected with a clear error.

### Removed
- Inline content without the `~~` marker (quoted or bare) — see the BREAKING note.
  There is intentionally no `-d` flag; a trailing `/` forces a directory inline.

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
- Multiline mode now uses portable `sed`, so the tool runs on Linux as well as macOS.
- Switched the tilde check to `[[ ]]` for safer, more idiomatic bash.
- Renamed the script from `puravida.sh` to `puravida` and marked it executable.

### Fixed
- The tilde check no longer errors with `too many arguments` on multi-word
  second arguments.

[Unreleased]: https://github.com/mark-mcdermott/puravida/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/mark-mcdermott/puravida/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/mark-mcdermott/puravida/releases/tag/v1.0.0
