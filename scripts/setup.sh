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

"${SCRIPT_DIR}/run-local-llm.sh" "$@"
