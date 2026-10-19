# Three-Tier Architecture on AWS

A beginner-friendly AWS portfolio project. The application is a small **Campus Help Desk Portal** where a student can submit a support request and see recent requests. The main project is the AWS architecture and Terraform deployment; the application stays intentionally simple so the infrastructure is easy to explain in an interview.

![Three-tier AWS architecture](aws-three-tier-architecture.png)

## What the application does

- Displays recent campus support requests.
- Accepts a title, category, and short description.
- Saves each request with an `Open` status and submission time.
- Shows a simple success or error message.

The demo has no login or staff workflow. Use sample information only; do not submit personal or confidential data.

## Architecture

1. A public Application Load Balancer receives browser traffic.
2. Nginx on private frontend EC2 instances serves the page and forwards `/api/` requests to an internal backend load balancer.
3. PHP on private backend EC2 instances validates requests and reads/writes records in private Amazon RDS for MySQL.
4. Backend instances read database credentials from AWS Secrets Manager using an EC2 IAM role.

Terraform creates the VPC, subnets, route tables, Internet Gateway, one NAT Gateway, security groups, load balancers, launch templates, Auto Scaling groups, and Multi-AZ RDS database. See [Architecture notes](docs/ARCHITECTURE.md) for the request flow and design choices.

## Folder structure

```text
three-tier-architecture-aws/
├── backend/api/                 # PHP request, health-check, and database code
├── database/                    # MySQL table and demo seed data
├── docs/                        # Architecture and beginner interview notes
├── frontend/                    # HTML, CSS, and browser JavaScript
├── infrastructure/terraform/    # AWS infrastructure and deployment guide
└── aws-three-tier-architecture.png
```

## Deploy to AWS

Follow [the PowerShell deployment guide](infrastructure/terraform/DEPLOYMENT.md). It covers AWS credentials, Terraform commands, app releases, checking the site, and destroying the demo stack.

## Run locally

Install XAMPP, start Apache and MySQL from the XAMPP Control Panel, and import `database/database_setup.sql` using phpMyAdmin. In PowerShell, run the following from the project root (change the XAMPP path if needed):

```powershell
$projectRoot = (Get-Location).Path
$webRoot = "C:\xampp\htdocs\campus-helpdesk"
New-Item -ItemType Directory -Force "$webRoot\api" | Out-Null
Copy-Item "$projectRoot\frontend\*" $webRoot -Recurse -Force
Copy-Item "$projectRoot\backend\api\*" "$webRoot\api" -Recurse -Force
```

Create `$webRoot\.htaccess` with the local MySQL settings. The default XAMPP MySQL `root` account often has an empty password; use the password configured on your computer:

```powershell
@'
SetEnv DB_HOST 127.0.0.1
SetEnv DB_NAME hello_world
SetEnv DB_USER root
SetEnv DB_PASSWORD
'@ | Set-Content "$webRoot\.htaccess"
```

Open `http://localhost/campus-helpdesk/` in a browser. For help answering basic project questions, read the [interview guide](docs/INTERVIEW_GUIDE.md).

The starter configuration runs one `t3.micro` instance in each EC2 tier to fit a small account quota. RDS is Multi-AZ, but the EC2 tiers do not have instance-level failover at this capacity. The stack creates billable resources, including NAT Gateway, load balancers, EC2 instances, and RDS. Run `terraform destroy` when you finish practicing.

## How to describe it on a resume

**Three-Tier Architecture on AWS | Student Portfolio Project**

Designed and deployed a PHP and MySQL help desk demo on AWS using Terraform. Separated the public entry point, frontend, backend, and database into controlled network tiers; used Application Load Balancers, EC2 Auto Scaling groups, private Multi-AZ RDS, security groups, and Secrets Manager.

Use only the services and details you can explain. The [interview guide](docs/INTERVIEW_GUIDE.md) has short explanations and honest limitations for this learning deployment.
