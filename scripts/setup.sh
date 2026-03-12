#!/bin/bash
# setup.sh は後方互換用ラッパーです。
# 実処理は run-local-llm.sh に集約しました。

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo " setup.sh は互換モードで実行されています"
echo " 実処理は run-local-llm.sh に統合済みです"
echo "========================================"
echo ""

echo "モデルを選択してください:"
echo "  1) qwen (Qwen3.5-35B-A3B)"
echo "  2) glm  (GLM-4.7-Flash)"
read -rp "番号を入力してください [1/2]: " NUM

case "${NUM}" in
    1) MODEL="qwen" ;;
    2) MODEL="glm" ;;
    *) echo "❌ 無効な入力です"; exit 1 ;;
esac

"${SCRIPT_DIR}/run-local-llm.sh" "${MODEL}"
