#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PUBLIC_AGENT_DIR="$SCRIPT_DIR/proof-bench"

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH:-}"
export DEBIAN_FRONTEND=noninteractive

uv_installer=$(mktemp)
trap 'rm -f "$uv_installer"' EXIT
curl -LsSf https://astral.sh/uv/0.13.5/install.sh -o "$uv_installer"
printf '%s  %s\n' '1c6e7f025499664633ac2dce43a210800510e9ef0625c52e034a8afdf8bf177a' "$uv_installer" | sha256sum -c -
UV_UNMANAGED_INSTALL="$HOME/.local/bin" sh "$uv_installer"
export PATH="$HOME/.local/bin:$PATH"
ln -sf "$HOME/.local/bin/uv" /usr/local/bin/uv
ln -sf "$HOME/.local/bin/uvx" /usr/local/bin/uvx

uv sync --project "$PUBLIC_AGENT_DIR" --frozen
uv tool install --exclude-newer "7 days" lean-lsp-mcp==0.26.1
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
