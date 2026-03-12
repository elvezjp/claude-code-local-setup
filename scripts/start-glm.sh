#!/bin/bash
# =============================================================
# start-glm.sh — GLM-4.7-Flash サーバー起動
# Tech千一夜: https://www.youtube.com/@tech1018/
# =============================================================

MODEL_PATH="unsloth/GLM-4.7-Flash-GGUF/GLM-4.7-Flash-UD-Q4_K_XL.gguf"

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
echo "▶ GLM-4.7-Flash を起動します（ポート 8001）..."
echo "   停止するには Ctrl+C"
echo ""

./llama.cpp/llama-server \
    --model "$MODEL_PATH" \
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
