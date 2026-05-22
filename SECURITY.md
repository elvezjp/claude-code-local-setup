[English](./SECURITY.md) | [日本語](./SECURITY_ja.md)

# Security Policy

## Supported Versions

This repository is a setup guide for scripts and configuration files, not a versioned software package.
Always use the latest version from the `main` branch.

| Version | Supported |
|---------|-----------|
| main branch (latest) | :white_check_mark: |
| Past commits | :x: |

## Reporting a Vulnerability

If you discover a security issue, **please do not post it as a public Issue.**

Instead, please report it using GitHub's [private vulnerability reporting](https://github.com/elvezjp/claude-code-local-setup/security/advisories/new) feature.

Please include the following in your report:

- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact and severity
- Suggested fix or mitigation (if possible)
- Contact information (optional)

## Response Schedule

- **Initial response**: within 48 hours
- **Status update**: within 7 days
- **Resolution**: depending on severity
  - Critical: within 14 days
  - High: within 30 days
  - Medium: within 60 days
  - Low: next release cycle

Status updates will be communicated through the private reporting thread.

## Security Notes for Script Execution

When running scripts from this repository, please be aware of the following:

- The `--dangerously-skip-permissions` option runs all Claude Code operations without confirmation. Use only in trusted environments.
- `ANTHROPIC_API_KEY="sk-no-key-required"` is a local LLM-only setting. Use your actual API key when connecting to the official Anthropic API.
- Download model files only from official sources (the unsloth repository on Hugging Face).
- The Homebrew / Claude Code installation uses `curl | bash`-style scripts. Review the script content before executing if desired.

## Security Best Practices

1. Always use the latest version from the `main` branch
2. Review script content before executing
3. Use `--dangerously-skip-permissions` only in trusted environments
4. Download model files only from official sources
5. Do not mistakenly use local LLM settings (e.g., dummy API keys) when connecting to the official API

## Contact

For general security-related questions that are not vulnerabilities, post to [Issues](https://github.com/elvezjp/claude-code-local-setup/issues) or contact us at:

- **Email**: info@elvez.co.jp
- **Organization**: Elvez Inc.
