# ProofBench Agent v1.0.0

Public Valkyrie package for the [ProofBench agent](https://github.com/vals-ai/proof-bench).

## Install

```bash
valkyrie agent install https://github.com/vals-ai/public-agent-registry/tree/main/agents/proof_bench_agent-v1.0.0
```

## Run

Supply the provider API key required by the selected model through your
Valkyrie configuration.

```bash
valkyrie run start \
  --benchmark proof-bench \
  --agent proof_bench_agent-v1.0.0 \
  --model openai/gpt-4o \
  --slice :1 \
  --concurrency 1
```

The ProofBench benchmark image supplies Lean, Mathlib, and Loogle.
