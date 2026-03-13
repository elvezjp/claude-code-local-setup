# Contributing Guide

本リポジトリへの貢献を歓迎します。

## 貢献の種類

- バグ報告・動作確認環境の追記
- ドキュメントの誤記修正・改善
- スクリプトの不具合修正
- 新しいモデル対応の追加

## 環境のセットアップ

```bash
git clone https://github.com/elvezjp/claude-code-local-setup.git
cd claude-code-local-setup
```

依存ツールのインストールは不要です。`scripts/run-local-llm.sh` 自体がセットアップを行います。

動作確認には Apple Silicon Mac（M1〜M4）と 16GB 以上のメモリが必要です。

## テスト

自動テストはありません。変更後は以下を手動で確認してください。

```bash
# スクリプトの動作確認（モデル選択画面が表示されれば OK）
./scripts/run-local-llm.sh

# 環境状態の確認
./scripts/run-local-llm.sh status
```

スクリプトを変更した場合は、影響する選択肢（モデル選択・自動セットアップ・ポート変更など）を一通り確認してください。

## Issue の報告

バグ報告や提案は [Issues](https://github.com/elvezjp/claude-code-local-setup/issues) に投稿してください。

報告の際は以下を含めると対応しやすくなります。

- macOS バージョン・チップ型番（例: M2 Pro）
- 実行したコマンドと出力結果
- `logs/` ディレクトリのログファイル（存在する場合）

セキュリティ上の問題は Issue ではなく [SECURITY.md](SECURITY.md) の手順で報告してください。

## Pull Request の手順

1. このリポジトリを Fork する
2. 変更用のブランチを作成する（例: `fix/model-download-error`）
3. 変更を加えて動作確認する
4. Pull Request を作成する

PR の説明には「何を・なぜ変更したか」と「確認した動作」を記載してください。

## コミットメッセージの規則

特定の規約は設けていませんが、変更内容が分かる簡潔なメッセージを書いてください。

```
# 例
fix: Qwen3.5-27B ダウンロード時のパスエラーを修正
docs: setup-guide.md にトラブルシューティング項目を追加
feat: Llama 3.3 70B サポートを追加
```

## ライセンス

本リポジトリへの貢献は [MIT License](LICENSE) のもとで公開されます。
