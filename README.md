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
git clone https://github.com/hdkworks/claude-code-local-setup.git
cd claude-code-local-setup

# llama.cpp のビルド〜モデルDL〜Claude Code 設定まで一括セットアップ
./scripts/setup.sh
```

セットアップ後はモデルを選んで起動：

```bash
./scripts/start-qwen.sh    # Qwen3.5-35B-A3B を起動
./scripts/start-glm.sh     # GLM-4.7-Flash を起動
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
    ├── setup.sh             # 一括セットアップ（llama.cpp + Claude Code設定）
    ├── start-qwen.sh        # Qwen3.5 サーバー起動
    └── start-glm.sh         # GLM-4.7-Flash サーバー起動
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
