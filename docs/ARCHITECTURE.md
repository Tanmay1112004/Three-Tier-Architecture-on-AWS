# Architecture overview

## Request path

```text
Student browser
    │ HTTP
    ▼
Public frontend Application Load Balancer
    │ HTTP
    ▼
Private Nginx EC2 Auto Scaling group
    │ /api/ requests over HTTP
    ▼
Internal backend Application Load Balancer
    │ HTTP
    ▼
Private Apache/PHP EC2 Auto Scaling group
    │ MySQL port 3306
    ▼
Private Multi-AZ Amazon RDS for MySQL
```

The frontend page and API share the same public hostname. Nginx serves static files and sends `/api/` traffic to the internal backend load balancer. The database has no public route. The backend instance role reads its database password from Secrets Manager during startup.

## Network layout

The VPC uses `10.0.0.0/16` and has four subnet tiers in each of three Availability Zones:

| Tier | Subnets | Route |
| --- | --- | --- |
| Public web | 3 | Internet Gateway |
| Private web | 3 | One NAT Gateway for outbound package and source downloads |
| Private app | 3 | One NAT Gateway for outbound package and source downloads |
| Private database | 3 | Local VPC traffic only |

Each subnet has a route table associated with its tier and Availability Zone. Security groups allow traffic only along the application path: public ALB to frontend instances, frontend instances to internal ALB, internal ALB to backend instances, and backend instances to MySQL.

## Availability and learning limits

- The RDS instance uses Multi-AZ for managed database standby failover.
- For small account quotas the demo starts with one EC2 instance per tier. The subnets span three Availability Zones, but one instance per tier does not provide EC2 instance failover across all three zones.
- One NAT Gateway reduces the number of NAT resources but is a single-AZ dependency and adds hourly/data-processing charges.
- The public listener uses HTTP for a simple lab. A real service needs HTTPS, a domain, authentication, request limits, and monitoring.
- Terraform state includes sensitive values. The guide explains why state must be protected and why production teams normally use a secured remote backend.
