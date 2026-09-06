# ECS Service Discovery Decision

## Current Decision

AWS Cloud Map service discovery is not required for this deployment.

The project contains one public-facing FastAPI service, and clients reach it
through the Application Load Balancer:

Client -> ALB -> ECS Fargate task

### When It Would Be Needed

Service discovery becomes useful when multiple internal ECS services must find each other without fixed task IP addresses.

### Example:

Public ALB -> API service -> Internal worker or authentication service

AWS Cloud Map can provide private DNS names and register the private addresses of ECS tasks.

ECS service discovery uses AWS Cloud Map to manage service namespaces and DNS records; task private IPs are registered so internal clients do not rely on fixed addresses. 

