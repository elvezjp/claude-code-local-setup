[English](./CONTRIBUTING.md) | [日本語](./CONTRIBUTING_ja.md)

# Contributing Guide

Contributions to this repository are welcome.

## Types of Contributions

- Bug reports and additional environment verification
- Documentation corrections and improvements
- Script bug fixes
- Adding support for new models

## Environment Setup

### Prerequisites

- Apple Silicon Mac (M1–M4)
- 16 GB or more of memory
- macOS 13 (Ventura) or later recommended

### Setup Steps

```bash
git clone https://github.com/elvezjp/claude-code-local-setup.git
cd claude-code-local-setup
```

No additional dependency installation is required. `scripts/run-local-llm.sh` handles setup automatically.

## Testing

There are no automated tests. After making changes, please verify manually:

```bash
# Verify script operation (OK if model selection screen appears)
./scripts/run-local-llm.sh

# Check environment status
./scripts/run-local-llm.sh status
```

If you modify the script, check all affected paths (model selection, auto-setup, port configuration, etc.).

## Reporting Issues

Submit bug reports and proposals to [Issues](https://github.com/elvezjp/claude-code-local-setup/issues).

Include the following when reporting a bug:

- A clear, descriptive title
- Steps to reproduce the problem
- Expected behavior and actual behavior
- macOS version and chip model (e.g., M2 Pro)
- Command executed and its output
- Log file from the `logs/` directory (if it exists)

For feature proposals, include:

- A detailed description of the proposed feature
- Use cases and benefits

For security issues, please follow the procedure in [SECURITY.md](SECURITY.md) rather than opening a public Issue.

## Pull Request Procedure

1. Fork this repository
2. Create a branch for your changes (branch naming: `{username}/{YYYYMMDD}-{description}`)
3. Make your changes and verify they work
4. Create a Pull Request

In the PR description, include "what and why you changed" and "the behavior you confirmed".

## Coding Guidelines

Scripts in this repository are written in Bash.

- Use 2-space indentation
- Use snake_case for variable names (e.g., `model_name`)
- Use snake_case for function names
- Use `bash -n` for shell script syntax checks

```bash
bash -n scripts/run-local-llm.sh
```

## Commit Message Rules

There is no strict convention, but please write concise messages that clearly describe the change.

```
# Good examples
fix: Fix path error when downloading Qwen3.5-27B
docs: Add troubleshooting section to setup-guide.md
feat: Add Llama 3.3 70B support

# Avoid
fix
update
```

## License

Contributions to this repository are published under the [MIT License](LICENSE).

## Contact

For questions or consultations, post to [Issues](https://github.com/elvezjp/claude-code-local-setup/issues) or contact us at:

- **Email**: info@elvez.co.jp
- **Organization**: Elvez Inc.
