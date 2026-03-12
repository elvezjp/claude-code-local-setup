#!/bin/bash
# =============================================================
# setup.sh — Claude Code + ローカルLLM 一括セットアップ（Mac）
# Tech千一夜: https://www.youtube.com/@tech1018/
# =============================================================

set -e

echo "========================================"
echo " Claude Code × ローカルLLM セットアップ"
echo " Tech千一夜"
echo " https://www.youtube.com/@tech1018/"
echo "========================================"
echo ""

# --- STEP 1: llama.cpp のビルド ---
echo "▶ STEP 1: llama.cpp をビルドします..."

if [ ! -d "llama.cpp" ]; then
    brew install cmake curl git 2>/dev/null || true
    git clone https://github.com/ggml-org/llama.cpp
    cmake llama.cpp -B llama.cpp/build \
        -DBUILD_SHARED_LIBS=OFF -DGGML_CUDA=OFF
    cmake --build llama.cpp/build --config Release -j --clean-first \
        --target llama-cli llama-mtmd-cli llama-server llama-gguf-split
    cp llama.cpp/build/bin/llama-* llama.cpp
    echo "  ✅ llama.cpp ビルド完了"
else
    echo "  ✅ llama.cpp はすでに存在します。スキップします。"
fi

echo ""

# --- STEP 2: Python パッケージのインストール ---
echo "▶ STEP 2: huggingface_hub をインストールします..."
pip install -q huggingface_hub hf_transfer
echo "  ✅ インストール完了"
echo ""

# --- STEP 3: モデル選択 ---
echo "▶ STEP 3: ダウンロードするモデルを選んでください"
echo "  1) Qwen3.5-35B-A3B（推奨: コーディング性能が高い）"
echo "  2) GLM-4.7-Flash（軽量・高速）"
echo "  3) 両方"
read -rp "番号を入力してください [1/2/3]: " MODEL_CHOICE
echo ""

download_qwen() {
    echo "  📥 Qwen3.5-35B-A3B をダウンロードします..."
    hf download unsloth/Qwen3.5-35B-A3B-GGUF \
        --local-dir unsloth/Qwen3.5-35B-A3B-GGUF \
        --include "*UD-Q4_K_XL*"
    echo "  ✅ Qwen3.5-35B-A3B ダウンロード完了"
}

download_glm() {
    echo "  📥 GLM-4.7-Flash をダウンロードします..."
    python3 -c "
import os; os.environ['HF_HUB_ENABLE_HF_TRANSFER'] = '1'
from huggingface_hub import snapshot_download
snapshot_download(
    repo_id='unsloth/GLM-4.7-Flash-GGUF',
    local_dir='unsloth/GLM-4.7-Flash-GGUF',
    allow_patterns=['*UD-Q4_K_XL*'],
)
"
    echo "  ✅ GLM-4.7-Flash ダウンロード完了"
}

case "$MODEL_CHOICE" in
    1) download_qwen ;;
    2) download_glm ;;
    3) download_qwen; download_glm ;;
    *) echo "  ⚠️  無効な入力です。スキップします。" ;;
esac

echo ""

# --- STEP 4: Claude Code のインストール ---
echo "▶ STEP 4: Claude Code をインストールします..."
if ! command -v claude &> /dev/null; then
    curl -fsSL https://claude.ai/install.sh | bash
    echo "  ✅ Claude Code インストール完了"
else
    echo "  ✅ Claude Code はすでにインストール済みです。"
fi
echo ""

# --- STEP 5: ~/.claude/settings.json の設定 ---
echo "▶ STEP 5: ~/.claude/settings.json を設定します..."
mkdir -p ~/.claude

SETTINGS_FILE="$HOME/.claude/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
    echo "  ⚠️  既存の settings.json が見つかりました。バックアップします..."
    cp "$SETTINGS_FILE" "${SETTINGS_FILE}.bak"
fi

cat > "$SETTINGS_FILE" << 'EOF'
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
EOF
echo "  ✅ settings.json を設定しました（KVキャッシュ最適化済み）"
echo ""

# --- 完了メッセージ ---
echo "========================================"
echo " ✅ セットアップ完了！"
echo "========================================"
echo ""
echo "次のコマンドでサーバーを起動してください："
echo ""
echo "  Qwen3.5:  ./scripts/start-qwen.sh"
echo "  GLM:      ./scripts/start-glm.sh"
echo ""
echo "サーバー起動後、Claude Code を実行："
echo ""
echo "  export ANTHROPIC_BASE_URL='http://localhost:8001'"
echo "  export ANTHROPIC_API_KEY='sk-no-key-required'"
echo "  claude --model unsloth/Qwen3.5-35B-A3B"
echo ""
