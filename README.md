# Lefthook
Forked from [project-cemetery/lefthook]<https://github.com/project-cemetery/lefthook>.

> The fastest polyglot Git hooks manager out there

<img align="right" width="147" height="100" title="Lefthook logo"
     src="https://raw.githubusercontent.com/Arkweid/lefthook/master/logo_sign.svg?sanitize=true">

Fast and powerful Git hooks manager for Node.js, Ruby or any other type of projects.

* **Fast.** It is written in Go. Can run commands in parallel.
* **Powerful.** With a few lines in the config you can check only the changed files on `pre-push` hook.
* **Simple.** It is single dependency-free binary which can work in any environment.

## Original tool

This repo is just Dart-wrapper for [Lefthook](https://github.com/Arkweid/lefthook). For detailed documentation, check the main repository.

## Installation

```sh
pub global activate lefthook
```

You are beautiful! Just create `lefthook.yml` in root of your project, add description of hooks, and start using it.

## Examples

### Flutter

For project based on Flutter, you can run formatter before every commit and run tests and static analysis before push.

```yml
# lefthook.yml

pre-push:
  parallel: true
  commands:
    tests:
      run: flutter test
    linter:
      run: flutter analyze lib

pre-commit:
  commands:
    pretty:
      glob: "*.dart"
      run: flutter format {staged_files}
```

### More

More examples in [documentation of original repository](https://github.com/Arkweid/lefthook/blob/master/docs/full_guide.md#examples).
