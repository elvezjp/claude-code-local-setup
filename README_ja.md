# claude-code-local-setup

[English](./README.md) | [日本語](./README_ja.md)

[![Elvez](https://img.shields.io/badge/Elvez-Product-3F61A7?style=flat-square)](https://elvez.co.jp/)
[![YouTube](https://img.shields.io/badge/YouTube-Tech千一夜-red?logo=youtube)](https://www.youtube.com/@tech1018/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Contributing](https://img.shields.io/badge/contributions-welcome-brightgreen.svg)](CONTRIBUTING_ja.md)

> **Tech千一夜** で解説した、Claude Code にローカルLLMを接続する手順をまとめたリポジトリです。

<p align="center"><a href="https://www.youtube.com/channel/UCASQiIkKCsZmaJHc4SDxyVg"><img src="./images/channel_icon.png" width="120" alt="Tech千一夜 YouTubeチャンネル"></a></p>

---

## 関連動画

[![関連動画](https://img.youtube.com/vi/q1Xtrr_Crrc/maxresdefault.jpg)](https://www.youtube.com/watch?v=q1Xtrr_Crrc)

---

## 開発の背景

本ツールは、日本の開発現場でAIを活かすためのAI開発エコシステム **IXV（イクシブ）** の開発過程で生まれた小さな実用品です。

IXVでは、開発方法論とOSSを提供することで、AI活用を現場に根付かせる取り組みを進めており、本リポジトリでは、その一部を切り出して公開しています。

---

## ユースケース

- **コスト削減**: APIコストをかけずに Claude Code をローカルLLMで動かしたい
- **オフライン開発**: インターネット接続なしで Claude Code を使いたい
- **プライバシー**: コードをクラウドに送信したくない
- **実験・学習**: ローカルLLMと Claude Code の組み合わせを試したい

---

## このリポジトリでできること

- **Apple Silicon Mac** で llama.cpp を使いローカルLLMを動かす
- **Claude Code** のバックエンドをローカルLLMに切り替える
- 下記モデルで動作確認済み（スクリプトから選択可能）

| モデル | タイプ | サイズ (Q4) | 推奨メモリ | 特徴 |
|--------|--------|------------|-----------|------|
| **Qwen3.5-35B-A3B** | MoE | ~22GB | 24GB〜 | 軽量で高速。コーディング性能◎ |
| **Qwen3.5-27B** | Dense | ~18GB | 24GB〜 | Dense で高精度。汎用向き |
| **Qwen3.5-122B-A10B** | MoE | ~77GB | 96GB〜 | 大規模・高精度。大メモリ環境向け |
| **GLM-4.7-Flash** | Dense | ~10GB | 16GB〜 | 最軽量。メモリが少ない環境向け |

---

## セットアップ

### 必要環境

- Apple Silicon Mac（M1〜M4）
- メモリ 16GB 以上（Qwen3.5 系は 24GB 以上推奨）
- macOS 13（Ventura）以上推奨
- インターネット接続（初回セットアップ時）

### クイックスタート

```bash
git clone https://github.com/elvezjp/claude-code-local-setup.git
cd claude-code-local-setup

# 1コマンドで起動（実行後にモデル選択）
# 未準備なら Homebrew/Python/Claude Code/llama.cpp/モデル を自動セットアップ
./scripts/run-local-llm.sh
```

※ 従来どおり `./scripts/run-local-llm.sh qwen` / `qwen27b` / `qwen122b` / `glm` の直接指定も可能です。

モデルダウンロード中は、ターミナルに進捗バー（% / 速度 / 残り時間）が表示されます。

このスクリプトは、未準備時に以下を自動セットアップします。

- Homebrew（未導入時）
- Python 3 / pip（未導入時）
- Claude Code（未導入時）
- llama.cpp のビルド
- 選択モデル（GGUF）のダウンロード

---

## 使い方

ローカルLLM起動後、別ターミナルで Claude Code を使う場合:

```bash
export ANTHROPIC_BASE_URL="http://localhost:8001"
export ANTHROPIC_API_KEY="sk-no-key-required"

# 例: Qwen を使う場合
claude --model unsloth/Qwen3.5-35B-A3B
```

環境の状態を確認:

```bash
./scripts/run-local-llm.sh status
```

ポートを変更したい場合:

```bash
LOCAL_LLM_PORT=8002 ./scripts/run-local-llm.sh qwen
```

セットアップ・起動のログは `logs/` ディレクトリに自動保存されます。トラブル時の共有に便利です。

> セキュリティ注記: Homebrew / Claude Code の導入には、各公式が案内する `curl | bash` 形式のインストール手順を利用しています。実行前に内容確認したい場合は、URLをブラウザで開いてスクリプト内容を確認してから実行してください。

---

## 詳細手順

ステップごとの詳細は [`docs/setup-guide.md`](docs/setup-guide.md) を参照してください。

---

## ディレクトリ構成

```
.
├── README.md                # 英語版 README
├── README_ja.md             # 日本語版 README
├── CHANGELOG.md             # 英語版変更履歴
├── CHANGELOG_ja.md          # 日本語版変更履歴
├── CONTRIBUTING.md          # 英語版コントリビューションガイド
├── CONTRIBUTING_ja.md       # 日本語版コントリビューションガイド
├── SECURITY.md              # 英語版セキュリティポリシー
├── SECURITY_ja.md           # 日本語版セキュリティポリシー
├── LICENSE                  # MIT License
├── .gitignore               # llama.cpp/ unsloth/ 等を除外
├── docs/
│   └── setup-guide.md       # 詳細セットアップ手順
└── scripts/
    └── run-local-llm.sh     # 単一エントリーポイント（セットアップ〜起動まで）
```

---

## 動作確認環境

| 項目 | 内容 |
|------|------|
| デバイス | Apple Silicon Mac（M1〜M4） |
| メモリ | 24GB以上推奨 |
| llama.cpp | 2025年3月時点の最新版 |
| Claude Code | 最新版推奨 |

---

## ドキュメント

- [CHANGELOG.md](CHANGELOG.md) / [CHANGELOG_ja.md](CHANGELOG_ja.md) — 変更履歴
- [CONTRIBUTING.md](CONTRIBUTING.md) / [CONTRIBUTING_ja.md](CONTRIBUTING_ja.md) — コントリビューション方法
- [SECURITY.md](SECURITY.md) / [SECURITY_ja.md](SECURITY_ja.md) — セキュリティポリシー
- [docs/setup-guide.md](docs/setup-guide.md) — 詳細セットアップ手順

---

## セキュリティ

セキュリティに関する詳細は [SECURITY_ja.md](SECURITY_ja.md) を参照してください。

- `--dangerously-skip-permissions` は信頼できる環境でのみ使用してください
- ローカルLLM用のダミーAPIキーを公式 API 接続時に誤用しないでください
- モデルファイルは公式ソース（Hugging Face の unsloth リポジトリ）からダウンロードしてください

---

## 注意事項

- Claude Code は頻繁にアップデートされます。手順が古くなった場合は Issue でお知らせください。
- `--dangerously-skip-permissions` オプションは、Claude Code がすべての操作を無確認で実行します。使用には注意してください。

---

## コントリビューション

コントリビューションを歓迎します。詳細は [CONTRIBUTING_ja.md](CONTRIBUTING_ja.md) を参照してください。

- バグ報告: [GitHub Issues](https://github.com/elvezjp/claude-code-local-setup/issues)
- 機能提案: [GitHub Issues](https://github.com/elvezjp/claude-code-local-setup/issues)
- プルリクエスト: [GitHub Pull Requests](https://github.com/elvezjp/claude-code-local-setup/pulls)

---

## 変更履歴

詳細は [CHANGELOG_ja.md](CHANGELOG_ja.md) を参照してください。

---

## ライセンス

MIT License — 詳細は [LICENSE](LICENSE) を参照してください。

---

## 問い合わせ先

- **メールアドレス**: info@elvez.co.jp
- **宛先**: 株式会社エルブズ

バグ報告・質問は [Issues](https://github.com/elvezjp/claude-code-local-setup/issues) へ。

---

## 参考

- [Unsloth 公式ドキュメント](https://unsloth.ai/docs/basics/claude-code)
- [llama.cpp](https://github.com/ggml-org/llama.cpp)
- [Claude Code](https://claude.ai/code)
