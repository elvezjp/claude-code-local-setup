#!/bin/bash
# =============================================================
# start-qwen.sh — Qwen3.5-35B-A3B サーバー起動
# Tech千一夜: https://www.youtube.com/@tech1018/
# =============================================================

MODEL_PATH="unsloth/Qwen3.5-35B-A3B-GGUF/Qwen3.5-35B-A3B-UD-Q4_K_XL.gguf"

if [ ! -f "$MODEL_PATH" ]; then
    echo "❌ モデルが見つかりません: $MODEL_PATH"
    echo "   先に ./scripts/setup.sh を実行してください。"
    exit 1
fi

echo "========================================"
echo " Tech千一夜"
echo " https://www.youtube.com/@tech1018/"
echo "========================================"
echo ""
echo "▶ Qwen3.5-35B-A3B を起動します（ポート 8001）..."
echo "   停止するには Ctrl+C"
echo ""

./llama.cpp/llama-server \
    --model "$MODEL_PATH" \
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
