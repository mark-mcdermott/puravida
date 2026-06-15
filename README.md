# Puravida

[![tests](https://github.com/mark-mcdermott/puravida/actions/workflows/tests.yml/badge.svg)](https://github.com/mark-mcdermott/puravida/actions/workflows/tests.yml)
[![lint](https://github.com/mark-mcdermott/puravida/actions/workflows/lint.yml/badge.svg)](https://github.com/mark-mcdermott/puravida/actions/workflows/lint.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

<p align="center">
  <img src="illustration.jpg" alt="puravida logo and low-poly isometric fishing village illustration">
</p>

## Overview

`puravida` is a tiny bash script that creates a terminal command that's a simple one-liner replacement for `mkdir` and `touch` and it's also a cleaner replacement for multi-line text insertion like `cat >> file.txt << 'END'` (i.e., [here documents](https://en.wikipedia.org/wiki/Here_document)). I made `puravida` because I used these all the time and it just annoyed me that this didn't already exist. Now I use `puravida` all the time.

## More Detail

Once `puravida` is in your system path, instead of two commands like `mkdir folder` and `echo "hi" >> folder/file.txt` (which of course can be combined in a one-liner like `mkdir folder && echo "hi" >> folder/file.txt`), you can do a clean one-liner with `puravida` like this:

```
puravida folder/file.txt ~~ hi
```

`puravida` can also be a cleaner workaround for putting multiline text in a file in a folder which doesn't exist yet. Instead of

```
mkdir folder
cat >> file.txt << 'END'
first text line
second text line
END
```

you can instead use `puravida` like this:

```
puravida folder/file.txt ~
first text line
second text line
~
```

You can also use puravida instead of `touch` to create an empty file. Instead of `touch file.txt` you can do `puravida file.txt`. Same with `mkdir` - instead of creating just an empty folder with `mkdir folder` you can do `puravida folder`.

`mkdir && touch`, `cat >> file.txt << 'END'` - just whyyyyy. Just use `puravida` and enjoy your life a little more 🌴

## Setup

Install with `make`:

```
git clone https://github.com/mark-mcdermott/puravida.git
cd puravida
sudo make install          # copies the puravida script to /usr/local/bin
```

Or do it by hand — drop the `puravida` script into a directory on your `PATH` (e.g. `/usr/local/bin`; in mac Finder hit `cmd + shift + .` if you don't see the hidden `usr` folder) and make it executable:

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

## Main Use Cases

🌴 usage 1: oneliner combining `mkdir -p` and `touch`. e.g., `puravida dir_1/dir_2/file.txt`. Several paths at once each create their own file or directory: `puravida a.txt b.txt` makes two files.

🌊 usage 2: a leading directory holds the paths created after it (parents made as needed). e.g., `puravida dir/nested_dir file1.txt file2.txt`, or with nesting, `puravida .claude/ settings.json commands/cmd.md`.

🐚 usage 3: create a file with inline contents after a `~~` marker. e.g., `puravida dir/file.txt ~~ hi`. The content is everything after `~~`, joined with spaces, and it attaches to the most recently named file — so `puravida a.txt b.txt ~~ hi` leaves `a.txt` empty and writes `hi` to `b.txt`.

🏖️ usage 4: create a file with (optionally multiline) contents you paste in, using a bare `~` (last line must just say `~` and that's all).
e.g., `puravida dir/file.txt ~` (and then it awaits your content paste ending in a `~` line)

🛠️ flags: `-f`/`--file` forces dotless names to be files, e.g. `puravida -f Makefile LICENSE Dockerfile`.

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

by mark mcdermott 7/6/23, https://markmcdermott.io
open source MIT license
