#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PUBLIC_AGENT_DIR="$SCRIPT_DIR/proof-bench"

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH:-}"
export DEBIAN_FRONTEND=noninteractive

curl -LsSf https://astral.sh/uv/0.7.13/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
ln -sf "$HOME/.local/bin/uv" /usr/local/bin/uv
ln -sf "$HOME/.local/bin/uvx" /usr/local/bin/uvx

uv sync --project "$PUBLIC_AGENT_DIR" --frozen
uv tool install lean-lsp-mcp==0.26.1
ln -sf "$HOME/.local/bin/lean-lsp-mcp" /usr/local/bin/lean-lsp-mcp

mkdir -p /logs
index_file=$(find /opt/loogle/index -maxdepth 1 -name 'mathlib-*.idx' -print -quit)
test -n "$index_file"

"$PUBLIC_AGENT_DIR/.venv/bin/python" -m proof_bench.loogle_daemon \
  --port 8765 \
  --binary /usr/local/bin/loogle \
  --index "$index_file" \
  > /logs/loogle_daemon.log 2>&1 &

sleep 2
kill -0 $!
