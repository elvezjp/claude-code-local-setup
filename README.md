# Claude Code × Local LLM Setup Guide (for Mac)

[English](./README.md) | [日本語](./README_ja.md)

[![Elvez](https://img.shields.io/badge/Elvez-Product-3F61A7?style=flat-square)](https://elvez.co.jp/)
[![YouTube](https://img.shields.io/badge/YouTube-Tech千一夜-red?logo=youtube)](https://www.youtube.com/@tech1018/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Contributing](https://img.shields.io/badge/contributions-welcome-brightgreen.svg)](CONTRIBUTING.md)

> A repository summarizing the steps to connect local LLMs to Claude Code, as explained on **Tech千一夜**.

<p align="center"><a href="https://www.youtube.com/channel/UCASQiIkKCsZmaJHc4SDxyVg"><img src="./images/channel_icon.png" width="120" alt="Tech千一夜 YouTube Channel"></a></p>

---

## Related Video

[![Related Video](https://img.youtube.com/vi/q1Xtrr_Crrc/maxresdefault.jpg)](https://www.youtube.com/watch?v=q1Xtrr_Crrc)

---

## Background

This tool is a small utility born from the development of **IXV**, an AI development ecosystem designed for Japanese engineering teams.

IXV delivers a methodology and OSS that put AI to practical use in real development workflows. This repository publishes a portion of that work.

---

## Use Cases

- **Cost reduction**: Run Claude Code with a local LLM without API costs
- **Offline development**: Use Claude Code without an internet connection
- **Privacy**: Avoid sending code to the cloud
- **Experimentation / learning**: Try out combinations of local LLMs with Claude Code

---

## Features

- Run a local LLM on an **Apple Silicon Mac** using llama.cpp
- Switch the Claude Code backend to a local LLM
- Confirmed working with the following models (selectable from the script)

| Model | Type | Size (Q4) | Recommended Memory | Notes |
|-------|------|-----------|-------------------|-------|
| **Qwen3.5-35B-A3B** | MoE | ~22 GB | 24 GB+ | Lightweight and fast. Great coding performance |
| **Qwen3.5-27B** | Dense | ~18 GB | 24 GB+ | Dense, high accuracy. General purpose |
| **Qwen3.5-122B-A10B** | MoE | ~77 GB | 96 GB+ | Large-scale, high accuracy. For high-memory environments |
| **GLM-4.7-Flash** | Dense | ~10 GB | 16 GB+ | Lightest option. For lower-memory environments |

---

## Setup

### Prerequisites

- Apple Silicon Mac (M1–M4)
- 16 GB or more of memory (24 GB+ recommended for Qwen3.5 models)
- macOS 13 (Ventura) or later recommended
- Internet connection (for initial setup)

### Quick Start

```bash
git clone https://github.com/elvezjp/claude-code-local-setup.git
cd claude-code-local-setup

# Launch with a single command (model selection after execution)
# Automatically sets up Homebrew/Python/Claude Code/llama.cpp/model if not ready
./scripts/run-local-llm.sh
```

You can also specify a model directly: `./scripts/run-local-llm.sh qwen` / `qwen27b` / `qwen122b` / `glm`.

A progress bar (% / speed / remaining time) is shown during model download.

The script automatically sets up the following if not already installed:

- Homebrew
- Python 3 / pip
- Claude Code
- llama.cpp build
- Selected model (GGUF) download

---

## Usage

After launching the local LLM, use Claude Code in a separate terminal:

```bash
export ANTHROPIC_BASE_URL="http://localhost:8001"
export ANTHROPIC_API_KEY="sk-no-key-required"

# Example: using Qwen
claude --model unsloth/Qwen3.5-35B-A3B
```

Check environment status:

```bash
./scripts/run-local-llm.sh status
```

Change the port:

```bash
LOCAL_LLM_PORT=8002 ./scripts/run-local-llm.sh qwen
```

`LOCAL_LLM_PORT` accepts only a port number (1-65535). Out-of-range or non-numeric values cause an error at startup.

Setup and launch logs are automatically saved to the `logs/` directory, useful for sharing when troubleshooting.

> Security note: Homebrew / Claude Code installation uses `curl | bash`-style scripts as guided by their official sources. If you want to review the content before executing, open the URL in a browser to check the script.

---

## Detailed Steps

For step-by-step details, see [`docs/setup-guide.md`](docs/setup-guide.md).

---

## Directory Structure

```
.
├── README.md                # English README
├── README_ja.md             # Japanese README
├── CHANGELOG.md             # English changelog
├── CHANGELOG_ja.md          # Japanese changelog
├── CONTRIBUTING.md          # English contributing guide
├── CONTRIBUTING_ja.md       # Japanese contributing guide
├── SECURITY.md              # English security policy
├── SECURITY_ja.md           # Japanese security policy
├── LICENSE                  # MIT License
├── .gitignore               # Excludes llama.cpp/, unsloth/, etc.
├── docs/
│   └── setup-guide.md       # Detailed setup steps
└── scripts/
    └── run-local-llm.sh     # Single entrypoint (setup through launch)
```

---

## Tested Environment

| Item | Details |
|------|---------|
| Device | Apple Silicon Mac (M1–M4) |
| Memory | 24 GB or more recommended |
| llama.cpp | Latest as of March 2025 |
| Claude Code | Latest recommended |

---

## Documentation

- [CHANGELOG.md](CHANGELOG.md) / [CHANGELOG_ja.md](CHANGELOG_ja.md) — Version history
- [CONTRIBUTING.md](CONTRIBUTING.md) / [CONTRIBUTING_ja.md](CONTRIBUTING_ja.md) — How to contribute
- [SECURITY.md](SECURITY.md) / [SECURITY_ja.md](SECURITY_ja.md) — Security policy
- [docs/setup-guide.md](docs/setup-guide.md) — Detailed setup steps

---

## Security

For security details, see [SECURITY.md](SECURITY.md).

- Use `--dangerously-skip-permissions` only in trusted environments
- Do not mistakenly use the dummy API key for local LLMs when connecting to the official API
- Download model files only from official sources (the unsloth repository on Hugging Face)

---

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

- Bug reports: [GitHub Issues](https://github.com/elvezjp/claude-code-local-setup/issues)
- Feature proposals: [GitHub Issues](https://github.com/elvezjp/claude-code-local-setup/issues)
- Pull requests: [GitHub Pull Requests](https://github.com/elvezjp/claude-code-local-setup/pulls)

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for details.

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

## Contact

- **Email**: info@elvez.co.jp
- **Organization**: Elvez Inc.

For bug reports and questions, post to [Issues](https://github.com/elvezjp/claude-code-local-setup/issues).

---

## References

- [Unsloth Official Documentation](https://unsloth.ai/docs/basics/claude-code)
- [llama.cpp](https://github.com/ggml-org/llama.cpp)
- [Claude Code](https://claude.ai/code)
