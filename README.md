# Puravida

[![tests](https://github.com/mark-mcdermott/puravida/actions/workflows/tests.yml/badge.svg)](https://github.com/mark-mcdermott/puravida/actions/workflows/tests.yml)
[![lint](https://github.com/mark-mcdermott/puravida/actions/workflows/lint.yml/badge.svg)](https://github.com/mark-mcdermott/puravida/actions/workflows/lint.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

<p align="center">
  <img src="illustration.jpg" alt="puravida logo and low-poly isometric fishing village illustration">
</p>

## Overview

`puravida` is a small Bash script for creating files and directories in a single command. It replaces `mkdir -p` followed by `touch`, and offers a cleaner alternative to here-documents (`cat > file << 'END'`) for writing text into a new file. Parent directories are created as needed.

## Demo

<p align="center">
  <img src="demo.gif" alt="terminal recording demonstrating puravida's main use cases">
</p>

## What it replaces

Creating a file inside a directory that doesn't exist yet normally takes two commands:

```
mkdir -p folder
echo "hi" > folder/file.txt
```

`puravida` does it in one:

```
puravida folder/file.txt ~~ hi
```

Multi-line content usually means a here-document:

```
mkdir -p folder
cat > folder/file.txt << 'END'
first line
second line
END
```

`puravida` reads pasted input directly, ending on a line containing only `~`:

```
puravida folder/file.txt ~
first line
second line
~
```

It also covers the basics: `puravida file.txt` in place of `touch file.txt`, and `puravida folder` in place of `mkdir folder`.

## Setup

Install with `make`:

```
git clone https://github.com/mark-mcdermott/puravida.git
cd puravida
sudo make install          # copies the puravida script to /usr/local/bin
```

Or do it by hand — drop the `puravida` script into a directory on your `PATH` (e.g. `/usr/local/bin`) and make it executable:

```
sudo cp puravida /usr/local/bin/puravida
sudo chmod 755 /usr/local/bin/puravida
```

Now you can use `puravida` anywhere. Run `puravida --help` for usage and `puravida --version` for the version.

Prefer a shorter command? Add a shell alias (`alias pv=puravida` in your `.zshrc`/`.bashrc`) — it only affects interactive shells and is easy to undo. To make the shortcut travel with the install instead, run `sudo make install-pv`, which symlinks `pv` → `puravida` in `/usr/local/bin`. Note that `pv` is also the name of the [pipe viewer](https://www.ivarch.com/programs/pv.shtml) utility, so the symlink will shadow it if you have it installed; remove the shortcut with `sudo make uninstall-pv`.

> **Note:** runs on macOS and Linux — paste mode uses portable `sed`, and CI exercises the test suite on both.

## Synopsis

```
puravida <path>...               create files (dotted leaf) and directories (dotless leaf or trailing /)
puravida <dir> <path>...         a leading directory holds the paths created after it
puravida <file> ~~ <content>...  create a file containing the inline text after ~~
puravida <file> ~                create a file from pasted input ending in a ~ line
puravida -f <name>...            force dotless names to be files (e.g. Makefile)
puravida -h | --help             show usage
puravida --version               show the version
```

A path whose final segment contains a `.` is treated as a file; otherwise it's a directory. A trailing `/` always forces a directory (see [Notes / Limitations](#notes--limitations)).

### Options

| Option | Description |
| --- | --- |
| `-f`, `--file` | Treat dotless names as files (e.g. `Makefile`, `LICENSE`) |
| `-h`, `--help` | Show usage and exit |
| `--version` | Show the version and exit |

### Exit status

| Code | Meaning |
| --- | --- |
| `0` | Success |
| `1` | A runtime error (e.g. a file or directory could not be created) |
| `2` | A usage error (no arguments, an unknown option, or `~~` with no preceding file) |

## Usage

**Files and directories.** A path whose final segment contains a `.` is created as a file, otherwise as a directory; parent directories are made as needed. Pass several paths to create them in one command:

```
puravida src/components/Button.tsx     # nested directories plus a file
puravida a.txt b.txt assets/           # two files and a directory
```

**A leading directory holds the rest.** When the first argument is a directory, the paths named after it are created inside it (with their own parents):

```
puravida .config/ settings.json themes/dark.css
```

**Inline content.** Text after the `~~` marker is written to the most recently named file, joined with spaces:

```
puravida notes.txt ~~ remember the milk
puravida a.txt b.txt ~~ hi             # a.txt stays empty; b.txt gets "hi"
```

**Pasted (multi-line) content.** A bare `~` reads input until a line containing only `~`:

```
puravida poem.txt ~
roses are red
violets are blue
~
```

**Forcing the type.** A trailing `/` forces a directory, even on a dotted name; `-f` forces dotless names to be files:

```
puravida .vscode/                      # a dotted directory
puravida -f Makefile LICENSE           # dotless files
```

## Notes / Limitations

`puravida` decides whether the thing you're creating is a file or a directory by looking at its **final path segment**: if that segment contains a `.` (e.g. `notes.txt`) it's treated as a file, otherwise it's treated as a directory. A period in a *parent* directory is fine: `puravida my.dir/notes` still creates `my.dir/` as a directory. To override the guess at the leaf:

- **Dotted name you want as a directory** (e.g. `.claude`, `.vscode`): add a trailing slash — `puravida .claude/`. The slash works on any argument and composes, e.g. `puravida .claude/ settings.json commands/`.
- **Dotless name you want as a file** (e.g. `Makefile`, `LICENSE`): use `-f` — `puravida -f Makefile`.

**Why there's no `-d` flag.** The trailing slash already forces a directory inline and composably (on any argument, not just the first), so a separate "make this a directory" flag would be redundant. The asymmetry is deliberate: dir-forcing has an inline marker (`/`), so it needs no flag; file-forcing has no clean inline marker, so it gets the `-f` flag.

**Inline content and the `~~` marker.** Content after `~~` is written verbatim into the most recently named file, joined with spaces. Quoting is handled entirely by your shell, so the usual rules apply: double quotes expand `$variables`, backticks, and globs, while single quotes keep everything literal. Prefer single quotes for anything with `$`, quotes, or special characters — `puravida global.css ~~ '@import "tailwindcss";'` writes `@import "tailwindcss";` exactly, whereas leaving it unquoted would drop the quotes and let the shell act on the `;`.

The marker is `~~` (two tildes) rather than one because a bare `~` is reserved for paste mode. `~~` works in every POSIX shell (bash, zsh, dash, ksh) because it isn't a valid tilde-expansion, so the shell passes it through literally. This is technically "unspecified" in POSIX but universal in practice; if a future shell ever expands it, the marker can be swapped for `--`, which is guaranteed by spec.

## Development

Tests use [bats-core](https://github.com/bats-core/bats-core) and linting uses [shellcheck](https://www.shellcheck.net/):

```
brew install bats-core shellcheck   # or your platform's package manager
make test                           # run the test suite
make lint                           # run shellcheck
```

CI runs both on every push and pull request. See [CONTRIBUTING.md](CONTRIBUTING.md) for the full contributor guide.

Created by [Mark McDermott](https://markmcdermott.io) · MIT licensed.
