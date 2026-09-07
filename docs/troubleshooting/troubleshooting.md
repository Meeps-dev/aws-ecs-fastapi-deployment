# ECS — Troubleshooting Notes

## ECR Digest Resolution Failed

* **Cause:** Bash-style `read -p` was used in Zsh, and the SHA was placed in the prompt instead of the variable.
* **Fix:** Assigned the existing Git-SHA directly and resolved the digest with `aws ecr describe-images`.

## Terraform Outputs Were Missing

* **Cause:** ECS and ALB values existed in configuration but were not exposed and saved as root-module outputs.
* **Fix:** Added environment-level outputs, created a fresh plan, and applied the output changes to state.

## S3 State Lock Returned `412 PreconditionFailed`

* **Cause:** An interrupted Terraform command left a stale S3-native state lock.
* **Fix:** Confirmed no Terraform process was active, ran `terraform force-unlock`, and retried with `-lock-timeout=3m`.

## Local Tests Could Not Connect to PostgreSQL

* **Cause:** `DATABASE_URL` referenced a PostgreSQL role that did not exist.
* **Fix:** Aligned the test connection string with the actual local or Compose database user, password, and database.

## Development Dependencies Failed to Install

* **Cause:** Unavailable Ruff and SQLAlchemy version pins stopped dependency installation.
* **Fix:** Updated the pins to compatible available versions and reinstalled the dependencies.

## Docker Build Context Was Not Found

* **Cause:** Repository-root paths were used while running the command inside `application/`.
* **Fix:** Ran the build from the repository root or used `Dockerfile` and `.` from inside `application/`.

## CI Python Version File Was Missing

* **Cause:** `application/.python-version` had been deleted.
* **Fix:** Restored it with Python `3.12` to match the Docker and CI runtime.

## Terraform Plan Failed on SSM Metadata

* **Cause:** The GitHub plan role lacked `ssm:DescribeParameters`.
* **Fix:** Added that metadata action with `Resource = "*"` and a Region restriction while retaining ARN-scoped secret access.

## Intentional ECS Task Failure

* **Cause:** A task-definition revision referenced the nonexistent ECR tag `tag-does-not-exist`.
* **Investigation:** Checked ECS service events, stopped-task reason, container reason, ECR tags, CloudWatch streams, and ALB target health.
* **Fix:** Restored the known-good digest, registered a corrected revision, updated the service, and confirmed a healthy target and successful API response.
