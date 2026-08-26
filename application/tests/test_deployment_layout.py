import re
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]


def test_recommended_deployment_layout_is_present():
    expected_paths = (
        "deploy/users-posts-api.service",
        "scripts/package.sh",
        "scripts/deploy.sh",
        "scripts/health-check.sh",
        "scripts/rollback.sh",
    )
    legacy_paths = (
        "scripts/deploy-ec2.sh",
        "scripts/run-migrations.sh",
        "scripts/start-api.sh",
    )

    for relative_path in expected_paths:
        assert (PROJECT_ROOT / relative_path).is_file()

    for relative_path in legacy_paths:
        assert not (PROJECT_ROOT / relative_path).exists()


def test_systemd_service_uses_the_release_local_virtualenv():
    service = (PROJECT_ROOT / "deploy/users-posts-api.service").read_text()

    assert "WorkingDirectory=/opt/users-posts-api/current" in service
    assert "EnvironmentFile=/opt/users-posts-api/current/.env" in service
    assert "ExecStart=/opt/users-posts-api/current/.venv/bin/python" in service
    assert "/opt/users-posts-api/venv" not in service


def test_workflows_use_the_refactored_deployment_scripts():
    ci_workflow = (PROJECT_ROOT / ".github/workflows/ci.yml").read_text()
    cd_workflow = (PROJECT_ROOT / ".github/workflows/deploy-dev.yml").read_text()

    assert "bash scripts/package.sh" in ci_workflow
    assert "source/scripts/deploy.sh" in cd_workflow
    assert "source/deploy/users-posts-api.service" in cd_workflow

    assert "source/scripts/deploy-ec2.sh" not in cd_workflow
    assert "source/scripts/start-api.sh" not in cd_workflow
    assert "source/scripts/run-migrations.sh" not in cd_workflow


def test_deployment_smoke_data_is_unique_per_workflow_attempt():
    cd_workflow = (PROJECT_ROOT / ".github/workflows/deploy-dev.yml").read_text()

    assert 'smoke_test_id="${GITHUB_RUN_ID}-${GITHUB_RUN_ATTEMPT}"' in cd_workflow
    assert "day76-${short_sha}-${smoke_test_id}@example.com" in cd_workflow
    assert "day76-${short_sha}@example.com" not in cd_workflow
    assert cd_workflow.count("--fail-with-body") >= 4


def test_external_workflow_actions_are_pinned_to_full_commit_shas():
    uses_lines = []
    workflow_directory = PROJECT_ROOT / ".github/workflows"
    workflows = (*workflow_directory.glob("*.yml"), *workflow_directory.glob("*.yaml"))

    for workflow in workflows:
        for line_number, line in enumerate(workflow.read_text().splitlines(), start=1):
            uses_match = re.match(r"^\s*uses:\s*(.+)$", line)
            if not uses_match:
                continue

            action_and_comment = uses_match.group(1)
            action, _, version_comment = action_and_comment.partition("#")
            action = action.strip()

            if action.startswith("./"):
                continue

            uses_lines.append((workflow, line_number, action, version_comment.strip()))

    assert uses_lines

    for workflow, line_number, action, version_comment in uses_lines:
        location = f"{workflow}:{line_number}"

        if action.startswith("docker://"):
            assert re.fullmatch(r"docker://[^@\s]+@sha256:[0-9a-f]{64}", action), (
                f"{location} must pin {action!r} to an image digest"
            )
            continue

        assert re.fullmatch(r"[^@\s]+@[0-9a-f]{40}", action), (
            f"{location} must pin {action!r} to a full commit SHA"
        )
        assert re.fullmatch(r"v\d+\.\d+\.\d+", version_comment), (
            f"{location} must retain an exact version comment"
        )


def test_committed_configuration_has_no_fallback_database_password():
    workflow_directory = PROJECT_ROOT / ".github/workflows"
    config_source = (PROJECT_ROOT / "app/config.py").read_text()
    env_template = (PROJECT_ROOT / ".env.example").read_text().splitlines()
    workflows = (*workflow_directory.glob("*.yml"), *workflow_directory.glob("*.yaml"))

    assert "postgresql://" not in config_source

    env_assignments = {}
    for line in env_template:
        stripped_line = line.strip()
        if not stripped_line or stripped_line.startswith("#"):
            continue

        name, separator, value = stripped_line.partition("=")
        assert separator, f"Invalid environment assignment: {line!r}"
        env_assignments[name] = value

    assert "DATABASE_URL" not in env_assignments
    assert env_assignments["POSTGRES_PASSWORD"] == "replace_with_random_hex_value"

    for path in workflows:
        contents = path.read_text()
        database_passwords = re.findall(
            r"postgresql://[^:\s]+:([^@\s]+)@",
            contents,
        )
        assert all("${{" in password for password in database_passwords), path

        password_values = re.findall(
            r"^\s*POSTGRES_PASSWORD:\s*(.+)$",
            contents,
            flags=re.MULTILINE,
        )
        assert all("${{" in value for value in password_values), path
