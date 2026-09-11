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

For a custom model server, set `CUSTOM_ENDPOINT` and `CUSTOM_API_KEY` in the
agent environment. Keep the model's provider prefix, such as `openai/my-model`,
to select its API protocol. Without a custom endpoint, the agent uses the
selected provider's normal API key.

Each task writes `/logs/<task-id>/generation.json` and
`/workspace/submission.lean`. The Lean file preserves the proof submitted by the
agent, including helper declarations. Hosted evaluation independently verifies
that proof. The internal `/workspace/result.json` output is also retained.
