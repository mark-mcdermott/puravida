# Contributing

Thanks for your interest in improving puravida! It's a single bash script
(`puravida`), so the surface area is small and changes are easy to review.

## Development setup

Tests use [bats-core](https://github.com/bats-core/bats-core) and linting uses
[shellcheck](https://www.shellcheck.net/):

```
brew install bats-core shellcheck   # macOS; on Linux use apt or your package manager
make test                           # run the bats suite
make lint                           # run shellcheck
```

## Pull requests

- Keep the script working on both macOS and Linux (prefer portable POSIX-ish
  constructs; the existing test matrix runs on both).
- Add or update tests in `test/puravida.bats` for any behavior change.
- Make sure `make test` and `make lint` pass — CI runs both on every pull request.
- Note user-facing changes under "Unreleased" in `CHANGELOG.md`.

## Reporting issues

Open an issue describing what you ran, what you expected, and what actually
happened. Include your OS and the output of `bash --version`.
