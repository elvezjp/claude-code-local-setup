# Claude Code + ローカルLLM セットアップ手順（Mac）

> **参考ページ:** https://unsloth.ai/docs/basics/claude-code  
> **動作確認環境:** Apple Silicon Mac（Metal GPU加速）

---

## 最短手順（推奨）

```bash
./scripts/run-local-llm.sh
```

実行後にモデルを選択できます。未準備の場合は次を自動実行します。

- Homebrew / Python 3
- Claude Code インストール
- llama.cpp のビルド
- モデル（GGUF）のダウンロード

通常はこの最短手順だけで十分です。以降の STEP 1-7 は、内部処理を手動で行いたい場合の参考手順です。

ローカルLLM起動後、別ターミナルで Claude Code を使う場合:

```bash
export ANTHROPIC_BASE_URL="http://localhost:8001"
export ANTHROPIC_API_KEY="sk-no-key-required"

# 例: Qwen を使う場合
claude --model unsloth/Qwen3.5-35B-A3B
```

モデルダウンロード中は、ターミナルに進捗バー（% / 速度 / 残り時間）が表示されます。

---

## 前提条件

- Apple Silicon Mac（M1/M2/M3/M4）
- Homebrew / Python 3 は未導入でも `./scripts/run-local-llm.sh` が自動セットアップを試行

> 初回セットアップ時は Homebrew インストールのため、管理者パスワード入力が求められる場合があります。
> モデル容量が大きいため、十分な空きディスク容量（目安: 15GB〜30GB以上）を確保してください。

---

## STEP 1: llama.cpp のインストール

```bash
brew install cmake curl git
git clone https://github.com/ggml-org/llama.cpp
cmake llama.cpp -B llama.cpp/build \
    -DBUILD_SHARED_LIBS=OFF -DGGML_CUDA=OFF   # Mac は OFF に（Metal は自動で有効）
cmake --build llama.cpp/build --config Release -j --clean-first \
    --target llama-cli llama-mtmd-cli llama-server llama-gguf-split
cp llama.cpp/build/bin/llama-* llama.cpp
```

> **Note:** `-DGGML_CUDA=OFF` にするだけで Metal（Apple GPU加速）は自動的に有効になります。

---

## STEP 2: モデルのダウンロード

```bash
python3 -m pip install --user huggingface_hub hf_transfer
```

### Qwen3.5-35B-A3B の場合

```bash
HF_HUB_ENABLE_HF_TRANSFER=1 python3 -m huggingface_hub download unsloth/Qwen3.5-35B-A3B-GGUF \
    --local-dir unsloth/Qwen3.5-35B-A3B-GGUF \
    --include "*UD-Q4_K_XL*"
```

### Qwen3.5-27B の場合

```bash
HF_HUB_ENABLE_HF_TRANSFER=1 python3 -m huggingface_hub download unsloth/Qwen3.5-27B-GGUF \
    --local-dir unsloth/Qwen3.5-27B-GGUF \
    --include "*UD-Q4_K_XL*"
```

### Qwen3.5-122B-A10B の場合（3分割）

```bash
HF_HUB_ENABLE_HF_TRANSFER=1 python3 -m huggingface_hub download unsloth/Qwen3.5-122B-A10B-GGUF \
    --local-dir unsloth/Qwen3.5-122B-A10B-GGUF \
    --include "*UD-Q4_K_XL*"
```

### GLM-4.7-Flash の場合

```bash
HF_HUB_ENABLE_HF_TRANSFER=1 python3 -m huggingface_hub download unsloth/GLM-4.7-Flash-GGUF \
    --local-dir unsloth/GLM-4.7-Flash-GGUF \
    --include "*UD-Q4_K_XL*"
```

> **量子化について:** `UD-Q4_K_XL` はサイズと精度のバランスが最も良いおすすめ設定。

---

## STEP 3: llama-server の起動

### Qwen3.5-35B-A3B の場合

```bash
./llama.cpp/llama-server \
    --model unsloth/Qwen3.5-35B-A3B-GGUF/Qwen3.5-35B-A3B-UD-Q4_K_XL.gguf \
    --alias "unsloth/Qwen3.5-35B-A3B" \
    --temp 0.6 \
    --top-p 0.95 \
    --top-k 20 \
    --min-p 0.00 \
    --port 8001 \
    --kv-unified \
    --cache-type-k q8_0 --cache-type-v q8_0 \
    --flash-attn on --fit on \
    --ctx-size 131072
```

> Thinking モードを無効にしたい場合（コーディング用途で高速化）:  
> 末尾に `--chat-template-kwargs "{\"enable_thinking\": false}"` を追加

### Qwen3.5-27B の場合

```bash
./llama.cpp/llama-server \
    --model unsloth/Qwen3.5-27B-GGUF/Qwen3.5-27B-UD-Q4_K_XL.gguf \
    --alias "unsloth/Qwen3.5-27B" \
    --temp 0.6 \
    --top-p 0.95 \
    --min-p 0.00 \
    --port 8001 \
    --kv-unified \
    --cache-type-k q8_0 --cache-type-v q8_0 \
    --flash-attn on --fit on \
    --ctx-size 131072
```

### Qwen3.5-122B-A10B の場合（3分割）

```bash
./llama.cpp/llama-server \
    --model unsloth/Qwen3.5-122B-A10B-GGUF/UD-Q4_K_XL/Qwen3.5-122B-A10B-UD-Q4_K_XL-00001-of-00003.gguf \
    --alias "unsloth/Qwen3.5-122B-A10B" \
    --temp 0.6 \
    --top-p 0.95 \
    --top-k 20 \
    --min-p 0.00 \
    --port 8001 \
    --kv-unified \
    --cache-type-k q8_0 --cache-type-v q8_0 \
    --flash-attn on --fit on \
    --ctx-size 32768
```

### GLM-4.7-Flash の場合

```bash
./llama.cpp/llama-server \
    --model unsloth/GLM-4.7-Flash-GGUF/GLM-4.7-Flash-UD-Q4_K_XL.gguf \
    --alias "unsloth/GLM-4.7-Flash" \
    --temp 1.0 \
    --top-p 0.95 \
    --min-p 0.01 \
    --port 8001 \
    --kv-unified \
    --cache-type-k q8_0 --cache-type-v q8_0 \
    --flash-attn on --fit on \
    --batch-size 4096 --ubatch-size 1024 \
    --ctx-size 131072
```

> サーバーは別ターミナル（または tmux）で起動しておく。

---

## STEP 4: Claude Code のインストール

```bash
curl -fsSL https://claude.ai/install.sh | bash
# または Homebrew 経由
brew install --cask claude-code
```

---

## STEP 5: 環境変数の設定

```bash
export ANTHROPIC_BASE_URL="http://localhost:8001"
export ANTHROPIC_API_KEY='sk-no-key-required'
```

**永続化したい場合は `~/.zshrc` に追記:**

```bash
echo 'export ANTHROPIC_BASE_URL="http://localhost:8001"' >> ~/.zshrc
echo 'export ANTHROPIC_API_KEY="sk-no-key-required"' >> ~/.zshrc
source ~/.zshrc
```

> **注意:** 永続化すると、llama-server が起動していない時も常に localhost へ接続を試みます。公式 API と切り替えて使う場合は、永続化せずに都度 `export` するか、`unset ANTHROPIC_BASE_URL` でリセットしてください。

---

## STEP 6: Claude Code の設定（重要！）

> ⚠️ この設定をしないと不要なリクエストが発生し、推論が **90% 遅く** なります。

`~/.claude/settings.json` を以下の内容で作成・編集する:

```json
{
  "promptSuggestionEnabled": false,
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "0",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "CLAUDE_CODE_ATTRIBUTION_HEADER": "0"
  },
  "attribution": {
    "commit": "",
    "pr": ""
  },
  "plansDirectory": "./plans",
  "prefersReducedMotion": true,
  "terminalProgressBarEnabled": false,
  "effortLevel": "high"
}
```

> **Note:** `export CLAUDE_CODE_ATTRIBUTION_HEADER=0` では効かない。必ず `settings.json` に書くこと。
> `run-local-llm.sh` は `~/.claude/settings.json` が存在しない場合のみ初期ファイルを作成します。既存ファイルがある場合は、上記キーを手動で反映してください。

---

## STEP 7: Claude Code の起動

```bash
# GLM-4.7-Flash を使う場合
claude --model unsloth/GLM-4.7-Flash

# Qwen3.5-35B-A3B を使う場合
claude --model unsloth/Qwen3.5-35B-A3B

# 承認なしで自動実行（注意: すべての操作が自動で行われる）
claude --model unsloth/GLM-4.7-Flash --dangerously-skip-permissions
```

---

## トラブルシューティング

| 症状 | 対処 |
|------|------|
| `Unable to connect to API (ConnectionRefused)` | `unset ANTHROPIC_BASE_URL` でリセット |
| ログイン画面が出る | `~/.claude.json` に `"hasCompletedOnboarding": true` と `"primaryApiKey": "sk-dummy-key"` を追加 |
| 推論が異常に遅い | STEP 6 の `settings.json` 設定を確認 |
| VRAM が足りない | `--ctx-size` を小さくするか、Qwen3.5-27B / 9B に変更 |
