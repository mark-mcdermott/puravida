#!/usr/bin/env bats
#
# Test suite for puravida, run with bats-core (https://github.com/bats-core/bats-core).
#   brew install bats-core   # or: apt-get install bats / npm i -g bats
#   bats test/               # or: make test
#
# Each test runs in its own throwaway directory, so there is nothing to clean up
# by hand and no risk of clobbering anything in the working tree.

setup() {
  PURAVIDA="$BATS_TEST_DIRNAME/../puravida"
  WORKDIR="$(mktemp -d)"
  cd "$WORKDIR"
}

teardown() {
  cd /
  rm -rf "$WORKDIR"
}

# --- single path -----------------------------------------------------------

@test "single: creates nested directories and a file from a dotted path" {
  run "$PURAVIDA" dir1/dir2/test.txt
  [ "$status" -eq 0 ]
  [ -d dir1/dir2 ]
  [ -f dir1/dir2/test.txt ]
}

@test "single: a dotless path becomes a directory" {
  run "$PURAVIDA" dir1/dir2
  [ "$status" -eq 0 ]
  [ -d dir1/dir2 ]
}

@test "single: creates one empty file (touch replacement)" {
  run "$PURAVIDA" solo.txt
  [ "$status" -eq 0 ]
  [ -f solo.txt ]
  [ ! -s solo.txt ]
}

@test "single: a dotted leaf is a file, not a directory" {
  run "$PURAVIDA" my.dir
  [ "$status" -eq 0 ]
  [ -f my.dir ]
  [ ! -d my.dir ]
}

@test "single: a dotted name mid-path is treated as a directory" {
  run "$PURAVIDA" logs/api.v2/error.txt
  [ "$status" -eq 0 ]
  [ -d logs/api.v2 ]
  [ -f logs/api.v2/error.txt ]
}

# --- trailing slash forces a directory -------------------------------------

@test "slash: a trailing slash creates an empty directory" {
  run "$PURAVIDA" foo/
  [ "$status" -eq 0 ]
  [ -d foo ]
}

@test "slash: a trailing slash forces a dotted leaf to be a directory" {
  run "$PURAVIDA" my.bak/
  [ "$status" -eq 0 ]
  [ -d my.bak ]
  [ ! -f my.bak ]
}

# --- independent paths (leading arg is a file) -----------------------------

@test "independent: two dotted args create two files" {
  run "$PURAVIDA" a.txt b.txt
  [ "$status" -eq 0 ]
  [ -f a.txt ]
  [ -f b.txt ]
  [ ! -s a.txt ]
  [ ! -s b.txt ]
}

@test "independent: a file and a directory are created side by side" {
  run "$PURAVIDA" a.txt some/dir
  [ "$status" -eq 0 ]
  [ -f a.txt ]
  [ -d some/dir ]
}

# --- container mode (leading arg is a directory) ---------------------------

@test "container: a dotless leading dir holds the named files" {
  run "$PURAVIDA" dir1/dir2 a.txt b.txt
  [ "$status" -eq 0 ]
  [ -f dir1/dir2/a.txt ]
  [ -f dir1/dir2/b.txt ]
}

@test "container: a trailing-slash leading dir holds nested file paths" {
  run "$PURAVIDA" .claude/ settings.json commands/my-command.md
  [ "$status" -eq 0 ]
  [ -d .claude ]
  [ -f .claude/settings.json ]
  [ -d .claude/commands ]
  [ -f .claude/commands/my-command.md ]
}

@test "container: nested dotless sub-paths become nested directories" {
  run "$PURAVIDA" .claude/ settings.json commands/dir1/dir2
  [ "$status" -eq 0 ]
  [ -f .claude/settings.json ]
  [ -d .claude/commands/dir1/dir2 ]
}

# --- the -f / --file flag --------------------------------------------------

@test "flag -f: forces a dotless name to be a file" {
  run "$PURAVIDA" -f Makefile
  [ "$status" -eq 0 ]
  [ -f Makefile ]
  [ ! -d Makefile ]
}

@test "flag --file: forces several dotless names to be files" {
  run "$PURAVIDA" --file Makefile LICENSE Dockerfile
  [ "$status" -eq 0 ]
  [ -f Makefile ]
  [ -f LICENSE ]
  [ -f Dockerfile ]
}

# --- inline content via ~~ -------------------------------------------------

@test "content: ~~ writes a single word to the file" {
  run "$PURAVIDA" dir1/note.txt ~~ hello
  [ "$status" -eq 0 ]
  [ "$(cat dir1/note.txt)" = "hello" ]
}

@test "content: ~~ joins multiple words with spaces" {
  run "$PURAVIDA" note.txt ~~ hello there world
  [ "$status" -eq 0 ]
  [ "$(cat note.txt)" = "hello there world" ]
}

@test "content: ~~ writes shell-special characters verbatim" {
  run "$PURAVIDA" note.txt ~~ 'cost is $5 & 100%'
  [ "$status" -eq 0 ]
  [ "$(cat note.txt)" = 'cost is $5 & 100%' ]
}

@test "content: ~~ preserves quotes inside single-quoted content (the @import case)" {
  run "$PURAVIDA" global.css ~~ '@import "tailwindcss";'
  [ "$status" -eq 0 ]
  [ "$(cat global.css)" = '@import "tailwindcss";' ]
}

@test "content: ~~ attaches only to the last named file" {
  run "$PURAVIDA" f1.txt f2.txt ~~ hi
  [ "$status" -eq 0 ]
  [ ! -s f1.txt ]
  [ "$(cat f2.txt)" = "hi" ]
}

@test "content: ~~ writes content to the last file inside a container" {
  run "$PURAVIDA" proj/ a.txt b.txt ~~ hi
  [ "$status" -eq 0 ]
  [ ! -s proj/a.txt ]
  [ "$(cat proj/b.txt)" = "hi" ]
}

@test "content: ~~ with nothing after it leaves an empty file" {
  run "$PURAVIDA" notes.txt ~~
  [ "$status" -eq 0 ]
  [ -f notes.txt ]
  [ ! -s notes.txt ]
}

@test "content: only the first ~~ is the marker; later ~~ is literal content" {
  run "$PURAVIDA" note.txt ~~ a ~~ b
  [ "$status" -eq 0 ]
  [ "$(cat note.txt)" = "a ~~ b" ]
}

@test "content: ~~ with no preceding file is a usage error" {
  run "$PURAVIDA" src/ ~~ hi
  [ "$status" -eq 2 ]
  [ ! -e src/hi ]
}

@test "content: ~~ with no following space errors instead of making a stray directory" {
  run "$PURAVIDA" notes.txt ~~hello
  [ "$status" -eq 2 ]
  [ ! -e notes.txt ]
  [ ! -e "~~hello" ]
  [[ "$output" == *"needs a space"* ]]
}

# --- multiline mode via ~ --------------------------------------------------

@test "multiline: ~ writes input up to a lone ~ terminator" {
  run bash -c "printf 'a\nb\n~\n' | '$PURAVIDA' dir1/dir2/test.txt ~"
  [ "$status" -eq 0 ]
  [ "$(cat dir1/dir2/test.txt)" = "$(printf 'a\nb')" ]
}

@test "multiline: an immediate ~ produces an empty file" {
  run bash -c "printf '~\n' | '$PURAVIDA' dir1/empty.txt ~"
  [ "$status" -eq 0 ]
  [ -f dir1/empty.txt ]
  [ ! -s dir1/empty.txt ]
}

# --- paths with spaces -----------------------------------------------------

@test "spaces: handles paths that contain spaces, with ~~ content" {
  run "$PURAVIDA" "my dir/my file.txt" ~~ hi
  [ "$status" -eq 0 ]
  [ -f "my dir/my file.txt" ]
  [ "$(cat "my dir/my file.txt")" = "hi" ]
}

# --- leading-dash paths (after the -- end-of-options marker) ----------------

@test "dash: -- lets a leading-dash filename through" {
  run "$PURAVIDA" -- -weird.txt
  [ "$status" -eq 0 ]
  [ -f ./-weird.txt ]
}

@test "dash: -- handles a leading-dash directory in the path" {
  run "$PURAVIDA" -- -d/file.txt
  [ "$status" -eq 0 ]
  [ -d ./-d ]
  [ -f ./-d/file.txt ]
}

# --- flags and errors ------------------------------------------------------

@test "--help prints usage and exits 0" {
  run "$PURAVIDA" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "-h prints usage and exits 0" {
  run "$PURAVIDA" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "--version prints the version and exits 0" {
  run "$PURAVIDA" --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"puravida"* ]]
}

@test "no arguments prints usage and exits 2 (usage error)" {
  run "$PURAVIDA"
  [ "$status" -eq 2 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "an unknown option errors and exits 2" {
  run "$PURAVIDA" --bogus
  [ "$status" -eq 2 ]
  [[ "$output" == *"unknown option"* ]]
}
