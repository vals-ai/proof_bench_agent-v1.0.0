import json
import sys

import pytest
from model_library.agent import AgentResult, SerializableException

import run


@pytest.mark.parametrize("failure,status", [(None, "success"), ("MaxTurnsExceeded", "max_turns"), ("RuntimeError", "error")])
def test_cli_writes_exact_submission_and_generation_result(tmp_path, monkeypatch, failure, status):
    problem = tmp_path / "problem.json"
    problem.write_text(json.dumps({"id": "task-1", "statement": "Prove True", "header": "", "formal": "theorem target : True := by"}))
    proof = "theorem helper : True := by trivial\ntheorem target : True := helper\n"
    logs = tmp_path / "logs"
    submission = tmp_path / "submission.lean"
    submission.write_text("stale proof")

    async def fake_agent(*args, **kwargs):
        assert submission.read_text() == ""
        assert json.loads((logs / "task-1/generation.json").read_text())["status"] == "error"
        kwargs["state"]["full_proof_code"] = proof
        return AgentResult(
            final_answer="helper", turns=[], final_history=[], final_duration_seconds=1,
            output_dir=logs / "task-1",
            final_error=SerializableException(type=failure, message="stopped") if failure else None,
        )

    monkeypatch.setattr(run, "run_agent", fake_agent)
    monkeypatch.setattr(run, "snapshot_environment", lambda _: {})
    monkeypatch.setattr(run, "build_tool_configs", lambda _: ({}, {}))
    monkeypatch.setattr(sys, "argv", [
        "run.py", "--model", "openai/test", "--problem-file", str(problem),
        "--task-id", "task-1", "--output", str(tmp_path / "result.json"),
        "--lean-project", str(tmp_path), "--log-dir", str(logs),
    ])
    if status == "error":
        with pytest.raises(SystemExit, match="1"):
            run.main()
    else:
        run.main()
    assert submission.read_text() == proof
    assert json.loads((logs / "task-1/generation.json").read_text()) == {
        "task_id": "task-1", "status": status, "data": proof,
    }
    assert json.loads((tmp_path / "result.json").read_text())["full_proof_code"] == proof
