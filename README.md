# 🦥 Claude Code × ローカルLLM セットアップガイド（Mac対応）

> **Tech千一夜** で解説した、Claude Code にローカルLLMを接続する手順をまとめたリポジトリです。

[![YouTube](https://img.shields.io/badge/YouTube-Tech千一夜-red?logo=youtube)](https://www.youtube.com/@tech1018/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 📺 関連動画

> *(動画公開後にURLを追記)*

<!-- 動画サムネイル -->
<!--
[![動画タイトル](https://img.youtube.com/vi/VIDEO_ID/maxresdefault.jpg)](https://www.youtube.com/watch?v=VIDEO_ID)
-->

---

## 🎯 このリポジトリでできること

- **Apple Silicon Mac** で llama.cpp を使いローカルLLMを動かす
- **Claude Code** のバックエンドをローカルLLMに切り替える
- **Qwen3.5-35B-A3B** / **GLM-4.7-Flash** どちらでも動作確認済み

---

## 🚀 クイックスタート（スクリプト実行）

```bash
git clone https://github.com/elvezjp/claude-code-local-setup.git
cd claude-code-local-setup

# 1コマンドで起動（実行後にモデル選択）
# 未準備なら Homebrew/Python/Claude Code/llama.cpp/モデル を自動セットアップ
./scripts/run-local-llm.sh
```

※ 従来どおり `./scripts/run-local-llm.sh qwen` / `glm` の直接指定も可能です。

モデルダウンロード中は、ターミナルに進捗バー（% / 速度 / 残り時間）が表示されます。

このスクリプトは、未準備時に以下を自動セットアップします。

- Homebrew（未導入時）
- Python 3 / pip（未導入時）
- Claude Code（未導入時）
- llama.cpp のビルド
- 選択モデル（GGUF）のダウンロード

ローカルLLM起動後、別ターミナルで Claude Code を使う場合:

```bash
export ANTHROPIC_BASE_URL="http://localhost:8001"
export ANTHROPIC_API_KEY="sk-no-key-required"

# 例: Qwen を使う場合
claude --model unsloth/Qwen3.5-35B-A3B
```

互換ラッパー（従来コマンド）:

```bash
./scripts/start-qwen.sh
./scripts/start-glm.sh
./scripts/setup.sh
```

---

## 📖 詳細手順

ステップごとの詳細は [`docs/setup-guide.md`](docs/setup-guide.md) を参照してください。

---

## 📁 ファイル構成

```
.
├── README.md
├── LICENSE                  # MIT License
├── docs/
│   └── setup-guide.md       # 詳細セットアップ手順
└── scripts/
    ├── setup.sh             # 互換ラッパー（内部で run-local-llm.sh を呼ぶ）
    ├── run-local-llm.sh     # 単一エントリーポイント（未準備なら自動セットアップ）
    ├── start-qwen.sh        # 互換ラッパー（内部で run-local-llm.sh を呼ぶ）
    └── start-glm.sh         # 互換ラッパー（内部で run-local-llm.sh を呼ぶ）
```

---

## 動作確認環境

| 項目 | 内容 |
|------|------|
| デバイス | Apple Silicon Mac（M1〜M4） |
| メモリ | 24GB以上推奨 |
| llama.cpp | 2025年3月時点の最新版 |
| Claude Code | 2026年1月以降のバージョン |

---

## ⚠️ 注意事項

- Claude Code は頻繁にアップデートされます。手順が古くなった場合は Issue でお知らせください。
- `--dangerously-skip-permissions` オプションは、Claude Code がすべての操作を無確認で実行します。使用には注意してください。

---

## 🙏 参考

- [Unsloth 公式ドキュメント](https://unsloth.ai/docs/basics/claude-code)
- [llama.cpp](https://github.com/ggml-org/llama.cpp)
- [Claude Code](https://claude.ai/code)
