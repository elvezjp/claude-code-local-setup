[English](./CHANGELOG.md) | [日本語](./CHANGELOG_ja.md)

# 変更履歴

このプロジェクトのすべての重要な変更を記録します。

フォーマットは [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づき、
バージョン管理は [セマンティックバージョニング](https://semver.org/lang/ja/) に準拠しています。

## [1.0.2] - 2026-08-09

### セキュリティ
- `scripts/run-local-llm.sh`: Claude Code を別ウィンドウで起動する際のコマンド文字列を、シェル用・AppleScript 用の両方でエスケープするよう修正。リポジトリのパスに `"` や `$()` が含まれる場合に、意図しないコマンドが実行されうる問題を解消
- `scripts/run-local-llm.sh`: `LOCAL_LLM_PORT` がポート番号（1-65535）であることを起動時に検証

### 変更
- README に `LOCAL_LLM_PORT` の指定可能な範囲を明記

## [1.0.1] - 2026-06-01

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
