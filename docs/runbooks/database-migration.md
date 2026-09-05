# Database Migration Strategy

## Decision

Database migrations will run as a one-off ECS Fargate task before the ECS
service is created or updated.

## Migration Command

alembic upgrade head