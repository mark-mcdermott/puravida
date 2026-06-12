#!/usr/bin/env bats
#
# Test suite for puravida, run with bats-core (https://github.com/bats-core/bats-core).
#   brew install bats-core   # or: npm i -g bats
#   bats test/               # or: make test
#
# Each test runs in its own throwaway BATS_TEST_TMPDIR, so there is nothing to
# clean up and no risk of clobbering anything in the working tree.

setup() {
  PURAVIDA="$BATS_TEST_DIRNAME/../puravida"
  cd "$BATS_TEST_TMPDIR"
}

@test "usage 1: creates a nested directory and a file from a single dotted path" {
  run "$PURAVIDA" dir1/dir2/test.txt
  [ "$status" -eq 0 ]
  [ -d dir1/dir2 ]
  [ -f dir1/dir2/test.txt ]
}

@test "usage 1: creates just the directory when the path has no extension" {
  run "$PURAVIDA" dir1/dir2
  [ "$status" -eq 0 ]
  [ -d dir1/dir2 ]
}

@test "usage 2: creates a directory with multiple empty files" {
  run "$PURAVIDA" dir1/dir2 a.txt b.txt
  [ "$status" -eq 0 ]
  [ -f dir1/dir2/a.txt ]
  [ -f dir1/dir2/b.txt ]
}

@test "usage 3: writes double-quoted inline contents to the file" {
  run "$PURAVIDA" dir1/note.txt "hello there"
  [ "$status" -eq 0 ]
  [ "$(cat dir1/note.txt)" = "hello there" ]
}

@test "usage 3: joins multiple unquoted content args with spaces" {
  run "$PURAVIDA" note.txt hello world
  [ "$status" -eq 0 ]
  [ "$(cat note.txt)" = "hello world" ]
}

@test "usage 4: writes pasted heredoc-style input up to the ~ terminator" {
  run bash -c "printf 'a\nb\n~\n' | '$PURAVIDA' dir1/dir2/test.txt ~"
  [ "$status" -eq 0 ]
  [ "$(cat dir1/dir2/test.txt)" = "$(printf 'a\nb')" ]
}

@test "handles paths that contain spaces" {
  run "$PURAVIDA" "my dir/my file.txt" "hi"
  [ "$status" -eq 0 ]
  [ -f "my dir/my file.txt" ]
  [ "$(cat "my dir/my file.txt")" = "hi" ]
}

@test "--help prints usage and exits 0" {
  run "$PURAVIDA" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"usage 1"* ]]
}

@test "-h prints usage and exits 0" {
  run "$PURAVIDA" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"usage 1"* ]]
}

@test "--version prints the version and exits 0" {
  run "$PURAVIDA" --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"puravida"* ]]
}

@test "no arguments prints usage and exits non-zero" {
  run "$PURAVIDA"
  [ "$status" -ne 0 ]
  [[ "$output" == *"usage 1"* ]]
}
