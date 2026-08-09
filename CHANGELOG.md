[English](./CHANGELOG.md) | [日本語](./CHANGELOG_ja.md)

# Changelog

All notable changes to this project will be recorded in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2026-08-09

### Security
- `scripts/run-local-llm.sh`: escape the command string used to launch Claude Code in a separate window for both the shell and AppleScript layers, fixing a case where a repository path containing `"` or `$()` could execute unintended commands
- `scripts/run-local-llm.sh`: validate that `LOCAL_LLM_PORT` is a port number (1-65535) at startup

### Changed
- Document the valid range of `LOCAL_LLM_PORT` in the README

## [1.0.1] - 2026-06-01

### Added
- Related video link added to README

## [0.1.0] - 2026-03-13

Initial release. Setup guide for connecting local LLMs to Claude Code on Apple Silicon Mac.

### Added
- `scripts/run-local-llm.sh`: single entrypoint for automated setup and launch (Homebrew, Python, Claude Code, llama.cpp, model download, local LLM server)
- Interactive model selection (Qwen3.5-35B-A3B, Qwen3.5-27B, Qwen3.5-122B-A10B, GLM-4.7-Flash)
- `status` subcommand to check environment state
- Port configuration via `LOCAL_LLM_PORT` environment variable
- Log saving to `logs/` directory for troubleshooting
- `docs/setup-guide.md`: step-by-step setup guide

## Links

- [Repository](https://github.com/elvezjp/claude-code-local-setup)
- [Issue Tracker](https://github.com/elvezjp/claude-code-local-setup/issues)
