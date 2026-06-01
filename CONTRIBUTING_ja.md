[English](./CONTRIBUTING.md) | [日本語](./CONTRIBUTING_ja.md)

# コントリビューションガイド

本リポジトリへの貢献を歓迎します。

## 貢献の種類

- バグ報告・動作確認環境の追記
- ドキュメントの誤記修正・改善
- スクリプトの不具合修正
- 新しいモデル対応の追加

## 環境のセットアップ

### 前提条件

- Apple Silicon Mac（M1〜M4）
- メモリ 16GB 以上
- macOS 13（Ventura）以上推奨

### セットアップ手順

```bash
git clone https://github.com/elvezjp/claude-code-local-setup.git
cd claude-code-local-setup
```

依存ツールのインストールは不要です。`scripts/run-local-llm.sh` 自体がセットアップを行います。

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

- 明確で説明的なタイトル
- 問題を再現する手順
- 期待される動作と実際の動作
- macOS バージョン・チップ型番（例: M2 Pro）
- 実行したコマンドと出力結果
- `logs/` ディレクトリのログファイル（存在する場合）

機能改善の提案は Issue に以下を含めてください。

- 提案する機能の詳細な説明
- ユースケースとメリット

セキュリティ上の問題は Issue ではなく [SECURITY.md](SECURITY.md) の手順で報告してください。

## Pull Request の手順

1. このリポジトリを Fork する
2. 変更用のブランチを作成する（ブランチ命名規則: `{ユーザー名}/{日付YYYYMMDD}-{内容}`）
3. 変更を加えて動作確認する
4. Pull Request を作成する

PR の説明には「何を・なぜ変更したか」と「確認した動作」を記載してください。

## コーディングガイドライン

本リポジトリのスクリプトは Bash で書かれています。

- インデントはスペース 2 文字を使用する
- 変数名はスネークケース（例: `model_name`）を使用する
- 関数名はスネークケースを使用する
- シェルスクリプトの構文チェックには `bash -n` を活用する

```bash
bash -n scripts/run-local-llm.sh
```

## コミットメッセージの規則

特定の規約は設けていませんが、変更内容が分かる簡潔なメッセージを書いてください。

```
# 良い例
fix: Qwen3.5-27B ダウンロード時のパスエラーを修正
docs: setup-guide.md にトラブルシューティング項目を追加
feat: Llama 3.3 70B サポートを追加

# 避ける例
fix
update
```

## リリース手順

### バージョンを上げるタイミング

リポジトリに意味のある変更（新機能・バグ修正・ドキュメントの大きな追加や変更など）があったときにバージョンを上げます。
依存ライブラリの更新のみ（Dependabot によるセキュリティパッチなど）ではバージョンを上げません。
その場合は `[Unreleased]` に記録しておき、次に意味のある変更をリリースする際にまとめて含めてください。

### タグを打つ手順

バージョン更新コミットが `main` にマージされたら、そのコミットにタグを打ってリモートへ反映します。

```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

## ライセンス

本リポジトリへの貢献は [MIT License](LICENSE) のもとで公開されます。

## 問い合わせ先

質問や相談は [Issues](https://github.com/elvezjp/claude-code-local-setup/issues) に投稿するか、以下まで連絡してください。

- **メールアドレス**: info@elvez.co.jp
- **宛先**: 株式会社エルブズ
