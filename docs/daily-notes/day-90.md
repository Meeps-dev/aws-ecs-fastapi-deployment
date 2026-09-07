# Day 90 — GitHub Actions Deployment and Rolling Image Update

## What I Did

* Added pull-request quality gates for linting, tests, Docker validation, and Terraform formatting/validation.
* Configured GitHub Actions to authenticate to AWS through OIDC without long-lived access keys.
* Kept Terraform planning separate from application deployment and added no automatic Terraform apply.
* Built the FastAPI image for `linux/amd64`, tagged it with the full Git commit SHA, and prepared it for ECR.
* Configured the deployment workflow to register a new task-definition revision, update the ECS service, wait for stabilization, and verify ALB health.
* Documented ECS rollback, Service Auto Scaling fundamentals, and when AWS Cloud Map service discovery would be needed.
* Recreated `application/.python-version` with Python `3.12` to keep local and CI environments consistent.

## What I Learned

* Immutable Git-SHA tags make container deployments traceable and safer to roll back.
* Every container-image change creates a new ECS task-definition revision.
* With deployment percentages of `100/200`, ECS can keep the old task running while starting one replacement task.
* A service is stable when the desired and running counts match, no tasks are pending, and the replacement target is healthy.
* CI commands must use the correct working directory and build context.
* A single unavailable dependency pin can stop the entire development dependency installation.
* Local tests require a PostgreSQL user, password, database, and `DATABASE_URL` that match the running test database.
* Least-privilege OIDC roles need every read action Terraform uses during state refresh, including metadata operations.

## What Broke and How I Fixed It

* `ruff==0.16.0` could not be resolved from the configured package index, so the development installation stopped and `pytest` was never installed.

  * I corrected the Ruff dependency to an available compatible version and reinstalled the development dependencies.

* The tests failed with `FATAL: role "meeps" does not exist`.

  * I aligned `DATABASE_URL` with the actual local or Docker Compose PostgreSQL user and database before rerunning the test suite.

* `application/.python-version` was deleted, causing the CI Python setup to lose its version source.

  * I restored the file with `3.12`, matching the application Docker image and CI runtime.

* Docker returned `unable to prepare context: path "application" not found`.

  * The command was being run from inside `application` while still using repository-root paths. I corrected the working directory and used either `application/Dockerfile` with the `application` context from the repository root, or `Dockerfile` with `.` from inside the application directory.

* The Docker build later failed because the pinned SQLAlchemy version could not be resolved from the package index available to BuildKit.

  * I corrected the dependency pin and package-index configuration, then rebuilt the image successfully.

* The remote Terraform plan failed because the OIDC plan role lacked `ssm:DescribeParameters`.

  * I added the metadata permission to the Terraform plan role while keeping access to actual SSM parameters restricted to the required ARNs and Region.

## Day 90 Outcome

The CI/CD design now validates application and infrastructure changes, uses GitHub OIDC for AWS access, builds immutable container images, and supports controlled ECS rolling deployments. The local test, dependency, Python-version, Docker-context, package-index, and IAM permission issues were identified and corrected.
