import os
import subprocess
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
HEALTH_CHECK_SCRIPT = PROJECT_ROOT / "scripts/health-check.sh"
ROLLBACK_SCRIPT = PROJECT_ROOT / "scripts/rollback.sh"


def make_command(directory: Path, name: str, body: str = "exit 0") -> None:
    command = directory / name
    command.write_text(f"#!/usr/bin/env bash\n{body}\n")
    command.chmod(0o755)


def deployment_environment(fake_bin: Path) -> dict[str, str]:
    env = os.environ.copy()
    env["PATH"] = f"{fake_bin}:{env['PATH']}"
    return env


def test_health_check_reports_success_and_failure(tmp_path):
    fake_bin = tmp_path / "bin"
    fake_bin.mkdir()
    make_command(fake_bin, "curl", 'exit "${FAKE_CURL_EXIT:-0}"')

    env = deployment_environment(fake_bin)
    env["HEALTH_CHECK_ATTEMPTS"] = "1"
    env["HEALTH_CHECK_INTERVAL_SECONDS"] = "0"

    success = subprocess.run(
        ["bash", str(HEALTH_CHECK_SCRIPT), "http://example.test/health"],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )

    assert success.returncode == 0
    assert "Health check passed" in success.stdout

    env["FAKE_CURL_EXIT"] = "22"

    failure = subprocess.run(
        ["bash", str(HEALTH_CHECK_SCRIPT), "http://example.test/health"],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )

    assert failure.returncode == 1
    assert "Health check failed" in failure.stdout


def test_rollback_restores_the_previous_release_symlink(tmp_path):
    fake_bin = tmp_path / "bin"
    fake_bin.mkdir()
    make_command(fake_bin, "curl")
    make_command(fake_bin, "journalctl")
    make_command(fake_bin, "systemctl")

    previous_release = tmp_path / "previous"
    failed_release = tmp_path / "failed"
    previous_release.mkdir()
    failed_release.mkdir()

    current_link = tmp_path / "current"
    current_link.symlink_to(failed_release)

    service_unit = tmp_path / "users-posts-api.service"
    service_unit.write_text("test unit")

    env = deployment_environment(fake_bin)
    env.update(
        {
            "CURRENT_LINK": str(current_link),
            "EXPECTED_PORT": "8080",
            "HEALTH_CHECK_SCRIPT": str(HEALTH_CHECK_SCRIPT),
            "PLACEHOLDER_SERVICE": "placeholder.service",
            "PLACEHOLDER_WAS_ACTIVE": "false",
            "PREVIOUS_RELEASE": str(previous_release),
            "SERVICE_NAME": "users-posts-api.service",
            "SERVICE_UNIT_BACKUP": str(tmp_path / "unit.backup"),
            "SERVICE_UNIT_CHANGED": "false",
            "SERVICE_UNIT_PATH": str(service_unit),
            "SWITCHED_RELEASE": "true",
        }
    )

    result = subprocess.run(
        ["bash", str(ROLLBACK_SCRIPT)],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )

    assert result.returncode == 0, result.stderr
    assert current_link.resolve() == previous_release.resolve()
    assert "Rollback completed." in result.stdout


def test_first_release_rollback_removes_the_failed_current_link(tmp_path):
    fake_bin = tmp_path / "bin"
    fake_bin.mkdir()
    make_command(fake_bin, "journalctl")
    make_command(fake_bin, "systemctl")

    failed_release = tmp_path / "failed"
    failed_release.mkdir()

    current_link = tmp_path / "current"
    current_link.symlink_to(failed_release)

    service_unit = tmp_path / "users-posts-api.service"
    service_unit.write_text("test unit")

    env = deployment_environment(fake_bin)
    env.update(
        {
            "CURRENT_LINK": str(current_link),
            "EXPECTED_PORT": "8080",
            "HEALTH_CHECK_SCRIPT": str(HEALTH_CHECK_SCRIPT),
            "PLACEHOLDER_SERVICE": "placeholder.service",
            "PLACEHOLDER_WAS_ACTIVE": "true",
            "PREVIOUS_RELEASE": "",
            "SERVICE_NAME": "users-posts-api.service",
            "SERVICE_UNIT_BACKUP": str(tmp_path / "unit.backup"),
            "SERVICE_UNIT_CHANGED": "false",
            "SERVICE_UNIT_PATH": str(service_unit),
            "SWITCHED_RELEASE": "true",
        }
    )

    result = subprocess.run(
        ["bash", str(ROLLBACK_SCRIPT)],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )

    assert result.returncode == 0, result.stderr
    assert not current_link.exists()
    assert not current_link.is_symlink()
    assert "Restoring placeholder service" in result.stdout
