#!/bin/bash
# 互換用ラッパー。未準備なら自動セットアップして起動します。
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"${SCRIPT_DIR}/run-local-llm.sh" glm
