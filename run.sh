#!/bin/bash
set -o pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROBLEM_FILE="$1"
TASK_ID="$2"
MODEL="$3"

mkdir -p /logs

"$SCRIPT_DIR/proof-bench/.venv/bin/python" "$SCRIPT_DIR/run.py" \
  --model "$MODEL" \
  --problem-file "$PROBLEM_FILE" \
  --task-id "$TASK_ID" \
  --output /workspace/result.json \
  --lean-project /workspace 2>&1 | tee /logs/proof_bench_agent.log

status=${PIPESTATUS[0]}
cp -f /workspace/result.json /logs/result.json 2>/dev/null || true
exit "$status"
