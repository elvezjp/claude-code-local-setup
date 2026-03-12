#!/bin/bash
# =============================================================
# run-local-llm.sh — ローカルLLM起動（未準備なら自動セットアップ）
# =============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

LLAMA_REPO_DIR="${REPO_ROOT}/llama.cpp"
LLAMA_SERVER_BIN="${LLAMA_REPO_DIR}/llama-server"

ensure_homebrew() {
    echo "▶ Homebrew を確認します..."
    if command -v brew >/dev/null 2>&1; then
        echo "  ✅ Homebrew は準備済みです。"
        return
    fi

    echo "  📥 Homebrew をインストールします..."
    NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    if ! command -v brew >/dev/null 2>&1; then
        echo "❌ Homebrew のインストール確認に失敗しました。"
        echo "   ターミナルを再起動してから再実行してください。"
        exit 1
    fi
    echo "  ✅ Homebrew インストール完了"
}

ensure_python_runtime() {
    echo "▶ Python 3 を確認します..."
    if ! command -v python3 >/dev/null 2>&1; then
        echo "  📥 Python 3 をインストールします..."
        brew install python
    fi

    if ! python3 -m pip --version >/dev/null 2>&1; then
        echo "  📦 pip を初期化します..."
        python3 -m ensurepip --upgrade || true
    fi

    if ! python3 -m pip --version >/dev/null 2>&1; then
        echo "❌ Python/pip の準備に失敗しました。"
        exit 1
    fi
    echo "  ✅ Python 3 / pip 準備完了"
}

ensure_llama_cpp() {
    echo "▶ llama.cpp を確認します..."
    if [ -x "${LLAMA_SERVER_BIN}" ]; then
        echo "  ✅ llama.cpp は準備済みです。"
        return
    fi

    brew install cmake curl git

    if [ ! -d "${LLAMA_REPO_DIR}" ]; then
        git clone https://github.com/ggml-org/llama.cpp "${LLAMA_REPO_DIR}"
    fi

    cmake "${LLAMA_REPO_DIR}" -B "${LLAMA_REPO_DIR}/build" \
        -DBUILD_SHARED_LIBS=OFF -DGGML_CUDA=OFF
    cmake --build "${LLAMA_REPO_DIR}/build" --config Release -j --clean-first \
        --target llama-cli llama-mtmd-cli llama-server llama-gguf-split
    cp "${LLAMA_REPO_DIR}/build/bin/llama-"* "${LLAMA_REPO_DIR}"
    echo "  ✅ llama.cpp のビルド完了"
}

ensure_python_deps() {
    echo "▶ Python 依存を確認します..."
    python3 -m pip install --user -q huggingface_hub hf_transfer 2>/dev/null \
        || python3 -m pip install -q huggingface_hub hf_transfer
    echo "  ✅ huggingface_hub / hf_transfer 準備完了"
}

ensure_claude_code() {
    echo "▶ Claude Code を確認します..."
    if command -v claude >/dev/null 2>&1; then
        echo "  ✅ Claude Code は準備済みです。"
        return
    fi

    echo "  📥 Claude Code をインストールします..."
    curl -fsSL https://claude.ai/install.sh | bash
    echo "  ✅ Claude Code インストール完了"
}

ensure_claude_settings() {
    SETTINGS_DIR="${HOME}/.claude"
    SETTINGS_FILE="${SETTINGS_DIR}/settings.json"
    mkdir -p "${SETTINGS_DIR}"

    if [ -f "${SETTINGS_FILE}" ]; then
        echo "▶ ${SETTINGS_FILE} は既に存在するためそのまま利用します。"
        return
    fi

    echo "▶ ${SETTINGS_FILE} を初期作成します..."
    cat > "${SETTINGS_FILE}" << 'EOF'
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
    echo "  ✅ settings.json 初期作成完了"
}

download_qwen() {
    echo "  📥 Qwen3.5-35B-A3B をダウンロードします..."
    echo "     保存先: unsloth/Qwen3.5-35B-A3B-GGUF"
    echo "     目安サイズ: 約22GB (UD-Q4_K_XL)"
    echo "     進捗: ターミナルにプログレスバーが表示されます"
    hf download unsloth/Qwen3.5-35B-A3B-GGUF \
        --local-dir unsloth/Qwen3.5-35B-A3B-GGUF \
        --include "*UD-Q4_K_XL*"
    echo "  ✅ Qwen3.5-35B-A3B ダウンロード完了"
}

download_glm() {
    echo "  📥 GLM-4.7-Flash をダウンロードします..."
    echo "     保存先: unsloth/GLM-4.7-Flash-GGUF"
    echo "     目安サイズ: 約10GB (UD-Q4_K_XL)"
    echo "     進捗: ターミナルにプログレスバーが表示されます"
    HF_HUB_ENABLE_HF_TRANSFER=1 hf download unsloth/GLM-4.7-Flash-GGUF \
        --local-dir unsloth/GLM-4.7-Flash-GGUF \
        --include "*UD-Q4_K_XL*"
    echo "  ✅ GLM-4.7-Flash ダウンロード完了"
}

MODEL_CHOICE="${1:-}"
if [ -z "${MODEL_CHOICE}" ]; then
    echo "▶ 起動するモデルを選んでください"
    echo "  1) qwen (Qwen3.5-35B-A3B)"
    echo "  2) glm  (GLM-4.7-Flash)"
    read -rp "番号を入力してください [1/2]: " NUM

    case "${NUM}" in
        1) MODEL_CHOICE="qwen" ;;
        2) MODEL_CHOICE="glm" ;;
        *) echo "❌ 無効な入力です"; exit 1 ;;
    esac
fi

case "${MODEL_CHOICE}" in
    qwen)
        MODEL_PATH="unsloth/Qwen3.5-35B-A3B-GGUF/Qwen3.5-35B-A3B-UD-Q4_K_XL.gguf"
        MODEL_ALIAS="unsloth/Qwen3.5-35B-A3B"
        START_ARGS=(--temp 0.6 --top-p 0.95 --top-k 20 --min-p 0.00 --ctx-size 131072)
        DOWNLOAD_FN=download_qwen
        ;;
    glm)
        MODEL_PATH="unsloth/GLM-4.7-Flash-GGUF/GLM-4.7-Flash-UD-Q4_K_XL.gguf"
        MODEL_ALIAS="unsloth/GLM-4.7-Flash"
        START_ARGS=(--temp 1.0 --top-p 0.95 --min-p 0.01 --batch-size 4096 --ubatch-size 1024 --ctx-size 131072)
        DOWNLOAD_FN=download_glm
        ;;
    *)
        echo "❌ モデル指定は qwen / glm のみ対応です"
        exit 1
        ;;
esac

echo "========================================"
echo " Claude Code × ローカルLLM 起動"
echo " Tech千一夜"
echo " https://www.youtube.com/@tech1018/"
echo "========================================"

ensure_homebrew
ensure_python_runtime
ensure_llama_cpp
ensure_python_deps
ensure_claude_code
ensure_claude_settings

if [ ! -f "${MODEL_PATH}" ]; then
    echo "▶ モデルが未ダウンロードのため取得します: ${MODEL_PATH}"
    "${DOWNLOAD_FN}"
else
    echo "▶ モデルは既に存在します: ${MODEL_PATH}"
fi

echo ""
echo "▶ ${MODEL_ALIAS} を起動します（ポート 8001）"
echo "  停止するには Ctrl+C"
echo "  別ターミナルで Claude Code を使うときは以下を実行:"
echo "    export ANTHROPIC_BASE_URL='http://localhost:8001'"
echo "    export ANTHROPIC_API_KEY='sk-no-key-required'"
echo "    claude --model ${MODEL_ALIAS}"
echo ""

"${LLAMA_SERVER_BIN}" \
    --model "${MODEL_PATH}" \
    --alias "${MODEL_ALIAS}" \
    --port 8001 \
    --kv-unified \
    --cache-type-k q8_0 --cache-type-v q8_0 \
    --flash-attn on --fit on \
    "${START_ARGS[@]}"
