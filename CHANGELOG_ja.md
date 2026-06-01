[English](./CHANGELOG.md) | [日本語](./CHANGELOG_ja.md)

# 変更履歴

このプロジェクトのすべての重要な変更を記録します。

フォーマットは [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づき、
バージョン管理は [セマンティックバージョニング](https://semver.org/lang/ja/) に準拠しています。

## [Unreleased]

### 追加
- READMEに関連動画リンクを追加

## [0.1.0] - 2026-03-13

初回リリース。Apple Silicon Mac 上でローカルLLMをClaude Codeに接続するためのセットアップガイド。

### 追加
- `scripts/run-local-llm.sh`: セットアップと起動をまとめた単一エントリポイント（Homebrew・Python・Claude Code・llama.cpp・モデルダウンロード・ローカルLLMサーバー起動を自動化）
- モデルのインタラクティブ選択（Qwen3.5-35B-A3B・Qwen3.5-27B・Qwen3.5-122B-A10B・GLM-4.7-Flash）
- `status` サブコマンドで環境状態を確認
- `LOCAL_LLM_PORT` 環境変数によるポート設定
- トラブル時の共有用にログを `logs/` ディレクトリへ自動保存
- `docs/setup-guide.md`: ステップごとの詳細セットアップ手順

## リンク

- [リポジトリ](https://github.com/elvezjp/claude-code-local-setup)
- [Issueトラッカー](https://github.com/elvezjp/claude-code-local-setup/issues)
