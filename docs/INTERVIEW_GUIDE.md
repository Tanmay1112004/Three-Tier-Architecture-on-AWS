# Beginner interview guide

This guide is for explaining the AWS project. Keep answers in your own words and be clear that it is a learning project.

## One-minute project explanation

“I built a small campus help desk portal and deployed it with Terraform on AWS. The frontend is served by Nginx EC2 instances behind a public Application Load Balancer. Nginx forwards API requests to an internal load balancer and private PHP EC2 instances. The backend stores support requests in a private Multi-AZ MySQL RDS database. Security groups restrict traffic between tiers, and the backend reads database credentials from Secrets Manager through an IAM role. I used Terraform so I can review and recreate the infrastructure, and I documented the costs and limitations of the demo.”

## Questions you may be asked

### Why use three tiers?

It separates the user interface, application logic, and stored data. Each tier can have its own network access rules and can be changed or scaled independently.

### What is public, and what is private?

The frontend load balancer is public because browsers connect to it. Frontend EC2, backend load balancer, backend EC2, and RDS are private. The database does not accept internet traffic.

### Why are there two load balancers?

The public load balancer receives website traffic. The internal load balancer gives the frontend tier a private path to backend instances without exposing the API servers directly to the internet.

### What does the NAT Gateway do?

It lets private EC2 instances make outbound connections, such as downloading packages during startup. It does not make those instances publicly reachable. This demo uses one NAT Gateway to limit cost, which creates a single-AZ dependency.

### How are database credentials handled?

Terraform generates a database password and stores it in Secrets Manager. The backend EC2 role is allowed to read that secret at startup. The PHP code reads the runtime configuration file; the password is not hard-coded in the application source.

### What does Multi-AZ mean here?

RDS maintains a standby database in another Availability Zone for managed failover. It does not mean the demo's EC2 frontend and backend have multiple instances in every zone.

### Why use Terraform?

Terraform describes the AWS resources as code. I can run `plan` to review intended changes and `apply` to create or update them. It also makes the network and security configuration repeatable.

### What would you improve before production?

I would add HTTPS and a domain, authentication and authorization, request rate limits, stronger monitoring and alerting, a NAT Gateway per AZ, multiple EC2 instances per tier, remote encrypted Terraform state with locking, and a tested backup/restore process.

### What was a practical problem you solved?

The AWS account had a small EC2 vCPU quota, so the original instance count could not launch. I reduced the default Auto Scaling desired capacity to one instance per tier and documented that this is a cost/quota trade-off rather than full EC2 high availability.

## Be accurate about your contribution

Say you built and deployed a beginner portfolio project. Do not claim production use, real student users, authentication, automatic traffic-based scaling, HTTPS, or EC2 failover unless you add and verify those features yourself.
