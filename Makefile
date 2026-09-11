.PHONY: install test

install:
	uv sync --project proof-bench --frozen --dev

test:
	uv run --project proof-bench python -m pytest tests
