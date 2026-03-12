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
PORT="${LOCAL_LLM_PORT:-8001}"
LOG_DIR="${REPO_ROOT}/logs"

# =============================================================
# status サブコマンド
# =============================================================

show_status() {
    echo "========================================"
    echo " 環境ステータス"
    echo "========================================"

    # システム
    local arch mem_gb free_gb
    arch="$(uname -m)"
    mem_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{printf "%.0f", $1/1024/1024/1024}')
    free_gb=$(df -g "${REPO_ROOT}" | awk 'NR==2{print $4}')
    echo ""
    echo "[システム]"
    echo "  macOS:           $(sw_vers -productVersion 2>/dev/null || echo '不明')"
    echo "  アーキテクチャ:   ${arch}"
    echo "  メモリ:          ${mem_gb}GB"
    echo "  空きディスク:     ${free_gb}GB"

    # ツール
    echo ""
    echo "[ツール]"
    if command -v brew >/dev/null 2>&1; then
        echo "  Homebrew:        ✅ $(brew --version 2>/dev/null | head -1)"
    else
        echo "  Homebrew:        ❌ 未インストール"
    fi

    if command -v python3 >/dev/null 2>&1; then
        echo "  Python 3:        ✅ $(python3 --version 2>/dev/null)"
    else
        echo "  Python 3:        ❌ 未インストール"
    fi

    if python3 -m huggingface_hub download --help >/dev/null 2>&1; then
        echo "  huggingface_hub: ✅"
    else
        echo "  huggingface_hub: ❌ 未インストール"
    fi

    if command -v claude >/dev/null 2>&1; then
        echo "  Claude Code:     ✅ $(claude --version 2>/dev/null || echo 'インストール済み')"
    else
        echo "  Claude Code:     ❌ 未インストール"
    fi

    if [ -x "${LLAMA_SERVER_BIN}" ]; then
        echo "  llama-server:    ✅ ${LLAMA_SERVER_BIN}"
    else
        echo "  llama-server:    ❌ 未ビルド"
    fi

    # settings.json
    echo ""
    echo "[設定]"
    local settings="${HOME}/.claude/settings.json"
    if [ -f "${settings}" ]; then
        echo "  settings.json:   ✅ ${settings}"
    else
        echo "  settings.json:   ❌ 未作成（初回起動時に自動作成）"
    fi

    # モデル
    echo ""
    echo "[ダウンロード済みモデル]"
    local found=0
    for d in unsloth/*/; do
        if [ -d "${d}" ] && ls "${d}"*UD-Q4_K_XL* >/dev/null 2>&1; then
            local size
            size=$(du -sh "${d}" 2>/dev/null | awk '{print $1}')
            echo "  ✅ ${d} (${size})"
            found=1
        elif [ -d "${d}" ]; then
            # 分割ファイル（サブディレクトリ内）
            if ls "${d}"UD-Q4_K_XL/*UD-Q4_K_XL* >/dev/null 2>&1; then
                local size
                size=$(du -sh "${d}" 2>/dev/null | awk '{print $1}')
                echo "  ✅ ${d} (${size})"
                found=1
            fi
        fi
    done
    if [ "${found}" -eq 0 ]; then
        echo "  （なし）"
    fi

    # ポート
    echo ""
    echo "[ポート]"
    if lsof -i :"${PORT}" >/dev/null 2>&1; then
        local pid
        pid=$(lsof -ti :"${PORT}" 2>/dev/null | head -1)
        echo "  ポート ${PORT}:    🟢 使用中 (PID: ${pid})"
    else
        echo "  ポート ${PORT}:    ⚪ 空き"
    fi

    echo ""
    exit 0
}

# status サブコマンドの早期処理
if [ "${1:-}" = "status" ]; then
    show_status
fi

# =============================================================
# ログ保存
# =============================================================

setup_logging() {
    mkdir -p "${LOG_DIR}"
    LOG_FILE="${LOG_DIR}/run-$(date +%Y%m%d-%H%M%S).log"
    echo "▶ ログ保存先: ${LOG_FILE}"
    # 標準出力・標準エラーを tee でログに記録（ターミナル表示も維持）
    exec > >(tee -a "${LOG_FILE}") 2>&1
}

# =============================================================
# 事前チェック
# =============================================================

preflight_check() {
    echo "▶ 環境を確認します..."

    # Apple Silicon チェック
    local arch
    arch="$(uname -m)"
    if [ "${arch}" != "arm64" ]; then
        echo "❌ Apple Silicon (arm64) が必要です（検出: ${arch}）"
        echo ""
        echo "   このスクリプトは Apple Silicon Mac 専用です。"
        echo "   Intel Mac では Metal GPU 加速が使えないため、実用的な速度が出ません。"
        exit 1
    fi

    # macOS チェック
    if [ "$(uname -s)" != "Darwin" ]; then
        echo "❌ macOS が必要です（検出: $(uname -s)）"
        echo ""
        echo "   Linux の場合は CUDA 版 llama.cpp を直接ビルドしてください:"
        echo "   https://github.com/ggml-org/llama.cpp"
        exit 1
    fi

    # メモリチェック
    local mem_gb
    mem_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{printf "%.0f", $1/1024/1024/1024}')
    echo "  メモリ: ${mem_gb}GB"
    if [ "${mem_gb}" -lt 16 ]; then
        echo "❌ 16GB 以上のメモリが必要です（検出: ${mem_gb}GB）"
        echo ""
        echo "   GLM-4.7-Flash (~10GB) なら 16GB で動作可能です。"
        echo "   再実行: $0 glm"
        exit 1
    fi

    # 空きディスク容量チェック
    local free_gb
    free_gb=$(df -g "${REPO_ROOT}" | awk 'NR==2{print $4}')
    echo "  空きディスク: ${free_gb}GB"
    if [ "${free_gb}" -lt "${REQUIRED_DISK_GB}" ]; then
        echo "❌ 空きディスク容量が不足しています（必要: ${REQUIRED_DISK_GB}GB, 空き: ${free_gb}GB）"
        echo ""
        echo "   不要なファイルを削除するか、より小さいモデルを選択してください:"
        echo "   $0 glm  (必要: 15GB)"
        echo "   $0 qwen (必要: 30GB)"
        exit 1
    fi

    # メモリがモデルサイズに対して十分かチェック
    if [ "${mem_gb}" -lt "${RECOMMENDED_RAM_GB}" ]; then
        echo "  ⚠️  推奨メモリ: ${RECOMMENDED_RAM_GB}GB 以上（現在: ${mem_gb}GB）"
        echo "     メモリ不足で動作が遅くなる、または起動に失敗する可能性があります。"
        echo "     より小さいモデルを推奨: $0 qwen または $0 glm"
        read -rp "  続行しますか? [y/N]: " CONT
        if [ "${CONT}" != "y" ] && [ "${CONT}" != "Y" ]; then
            exit 0
        fi
    fi

    # ポート使用チェック
    if lsof -i :"${PORT}" >/dev/null 2>&1; then
        local pid
        pid=$(lsof -ti :"${PORT}" 2>/dev/null | head -1)
        echo "❌ ポート ${PORT} は既に使用されています (PID: ${pid})"
        echo ""
        echo "   対処方法:"
        echo "   1) 既存プロセスを停止: kill ${pid}"
        echo "   2) 別のポートを使用:   LOCAL_LLM_PORT=8002 $0 ${MODEL_CHOICE}"
        exit 1
    fi

    echo "  ✅ 環境チェック完了"
}

# =============================================================
# セットアップ関数
# =============================================================

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
        echo ""
        echo "   ターミナルを再起動してから再実行してください。"
        echo "   手動インストール: https://brew.sh"
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
        echo ""
        echo "   次のコマンドを試してください:"
        echo "   brew install python"
        echo "   python3 -m ensurepip --upgrade"
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
    if ! python3 -m huggingface_hub download --help >/dev/null 2>&1; then
        echo "❌ huggingface_hub CLI の準備に失敗しました。"
        echo ""
        echo "   次のコマンドを試してください:"
        echo "   python3 -m pip install --user huggingface_hub hf_transfer"
        echo ""
        echo "   externally-managed-environment エラーの場合:"
        echo "   python3 -m pip install --break-system-packages huggingface_hub hf_transfer"
        exit 1
    fi
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

# =============================================================
# モデルダウンロード（汎用）
# =============================================================

download_model() {
    local repo_id="$1"
    local local_dir="$2"
    local display_name="$3"
    local size_info="$4"

    echo "  📥 ${display_name} をダウンロードします..."
    echo "     保存先: ${local_dir}"
    echo "     目安サイズ: ${size_info}"
    echo "     進捗: ターミナルにプログレスバーが表示されます"
    HF_HUB_ENABLE_HF_TRANSFER=1 python3 -m huggingface_hub download "${repo_id}" \
        --local-dir "${local_dir}" \
        --include "*UD-Q4_K_XL*"
    echo "  ✅ ${display_name} ダウンロード完了"
}

# =============================================================
# モデル選択
# =============================================================

MODEL_CHOICE="${1:-}"
if [ -z "${MODEL_CHOICE}" ]; then
    echo "▶ 起動するモデルを選んでください"
    echo "  1) qwen     (Qwen3.5-35B-A3B   — MoE,   ~22GB, RAM 24GB〜)"
    echo "  2) qwen27b  (Qwen3.5-27B       — Dense,  ~18GB, RAM 24GB〜)"
    echo "  3) qwen122b (Qwen3.5-122B-A10B — MoE,   ~77GB, RAM 96GB〜)"
    echo "  4) glm      (GLM-4.7-Flash     —        ~10GB, RAM 16GB〜)"
    read -rp "番号を入力してください [1/2/3/4]: " NUM

    case "${NUM}" in
        1) MODEL_CHOICE="qwen" ;;
        2) MODEL_CHOICE="qwen27b" ;;
        3) MODEL_CHOICE="qwen122b" ;;
        4) MODEL_CHOICE="glm" ;;
        *) echo "❌ 無効な入力です"; exit 1 ;;
    esac
fi

case "${MODEL_CHOICE}" in
    qwen)
        MODEL_REPO="unsloth/Qwen3.5-35B-A3B-GGUF"
        MODEL_DIR="unsloth/Qwen3.5-35B-A3B-GGUF"
        MODEL_PATH="${MODEL_DIR}/Qwen3.5-35B-A3B-UD-Q4_K_XL.gguf"
        MODEL_ALIAS="unsloth/Qwen3.5-35B-A3B"
        MODEL_DISPLAY="Qwen3.5-35B-A3B"
        MODEL_SIZE_INFO="約22GB (UD-Q4_K_XL)"
        START_ARGS=(--temp 0.6 --top-p 0.95 --top-k 20 --min-p 0.00 --ctx-size 131072)
        REQUIRED_DISK_GB=30
        RECOMMENDED_RAM_GB=24
        ;;
    qwen27b)
        MODEL_REPO="unsloth/Qwen3.5-27B-GGUF"
        MODEL_DIR="unsloth/Qwen3.5-27B-GGUF"
        MODEL_PATH="${MODEL_DIR}/Qwen3.5-27B-UD-Q4_K_XL.gguf"
        MODEL_ALIAS="unsloth/Qwen3.5-27B"
        MODEL_DISPLAY="Qwen3.5-27B"
        MODEL_SIZE_INFO="約17.6GB (UD-Q4_K_XL)"
        START_ARGS=(--temp 0.6 --top-p 0.95 --min-p 0.00 --ctx-size 131072)
        REQUIRED_DISK_GB=25
        RECOMMENDED_RAM_GB=24
        ;;
    qwen122b)
        MODEL_REPO="unsloth/Qwen3.5-122B-A10B-GGUF"
        MODEL_DIR="unsloth/Qwen3.5-122B-A10B-GGUF"
        MODEL_PATH="${MODEL_DIR}/UD-Q4_K_XL/Qwen3.5-122B-A10B-UD-Q4_K_XL-00001-of-00003.gguf"
        MODEL_ALIAS="unsloth/Qwen3.5-122B-A10B"
        MODEL_DISPLAY="Qwen3.5-122B-A10B"
        MODEL_SIZE_INFO="約77GB (UD-Q4_K_XL, 3分割)"
        START_ARGS=(--temp 0.6 --top-p 0.95 --top-k 20 --min-p 0.00 --ctx-size 32768)
        REQUIRED_DISK_GB=90
        RECOMMENDED_RAM_GB=96
        ;;
    glm)
        MODEL_REPO="unsloth/GLM-4.7-Flash-GGUF"
        MODEL_DIR="unsloth/GLM-4.7-Flash-GGUF"
        MODEL_PATH="${MODEL_DIR}/GLM-4.7-Flash-UD-Q4_K_XL.gguf"
        MODEL_ALIAS="unsloth/GLM-4.7-Flash"
        MODEL_DISPLAY="GLM-4.7-Flash"
        MODEL_SIZE_INFO="約10GB (UD-Q4_K_XL)"
        START_ARGS=(--temp 1.0 --top-p 0.95 --min-p 0.01 --batch-size 4096 --ubatch-size 1024 --ctx-size 131072)
        REQUIRED_DISK_GB=15
        RECOMMENDED_RAM_GB=16
        ;;
    *)
        echo "❌ 対応モデル: qwen / qwen27b / qwen122b / glm"
        echo ""
        echo "   使用例: $0 qwen"
        echo "   状態確認: $0 status"
        exit 1
        ;;
esac

# =============================================================
# メイン処理
# =============================================================

echo "========================================"
echo " Claude Code × ローカルLLM 起動"
echo " Tech千一夜"
echo " https://www.youtube.com/@tech1018/"
echo "========================================"

setup_logging
preflight_check
ensure_homebrew
ensure_python_runtime
ensure_llama_cpp
ensure_python_deps
ensure_claude_code
ensure_claude_settings

if [ ! -f "${MODEL_PATH}" ]; then
    echo "▶ モデルが未ダウンロードのため取得します"
    download_model "${MODEL_REPO}" "${MODEL_DIR}" "${MODEL_DISPLAY}" "${MODEL_SIZE_INFO}"
else
    echo "▶ モデルは既に存在します: ${MODEL_PATH}"
fi

echo ""
echo "▶ ${MODEL_ALIAS} を起動します（ポート ${PORT}）"
echo "  停止するには Ctrl+C"
echo "  別ターミナルで Claude Code を使うときは以下を実行:"
echo "    export ANTHROPIC_BASE_URL='http://localhost:${PORT}'"
echo "    export ANTHROPIC_API_KEY='sk-no-key-required'"
echo "    claude --model ${MODEL_ALIAS}"
echo ""

"${LLAMA_SERVER_BIN}" \
    --model "${MODEL_PATH}" \
    --alias "${MODEL_ALIAS}" \
    --port "${PORT}" \
    --kv-unified \
    --cache-type-k q8_0 --cache-type-v q8_0 \
    --flash-attn on --fit on \
    "${START_ARGS[@]}"
