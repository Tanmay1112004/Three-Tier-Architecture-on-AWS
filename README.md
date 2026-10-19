# Campus Help Desk on AWS

A beginner cloud project that demonstrates how a small web app can run on AWS with separate frontend, backend, and database tiers. Students can submit campus support requests and browse recent requests.

**Built with:** AWS, Terraform, Nginx, PHP, JavaScript, and MySQL.

- [Open the demo](http://hello-world-three-tier-web-1347202854.us-east-1.elb.amazonaws.com)
- [View the GitHub repository](https://github.com/Tanmay1112004/Three-Tier-Architecture-on-AWS)

> This is a learning demo. Requests are visible to visitors, the site uses HTTP, and it has no sign-in. Use sample data only—do not enter personal or confidential information.

## What the app does

- Submit a request with a title, category, and description.
- Save requests in a MySQL database.
- Browse up to 20 recent requests, with search and category/status filters.
- See request counts grouped by status.

New requests start with **Open** status. Staff sign-in and changing request statuses are not implemented yet.

## How it works

![Three-tier AWS architecture](aws-three-tier-architecture.png)

```text
Browser
  │
  ▼
Public Application Load Balancer
  │
  ▼
Private Nginx frontend (EC2)
  │  /api requests
  ▼
Internal Application Load Balancer
  │
  ▼
Private PHP backend (EC2)
  │
  ▼
Private Amazon RDS for MySQL
```

1. The browser opens the site through the public load balancer.
2. Nginx serves the page and forwards API requests to the internal load balancer.
3. PHP validates requests and reads or writes data in RDS.
4. The backend gets database credentials from Secrets Manager using its IAM role.

Security groups control which tier can connect to the next. RDS is private and is not open to internet traffic.

## AWS services used

| Service | What it does in this project |
| --- | --- |
| VPC and subnets | Separate the public entry point, web servers, application servers, and database network. |
| Application Load Balancer | Routes browser traffic to the frontend and API traffic to the backend. |
| EC2 and Auto Scaling | Run the Nginx and PHP application tiers. |
| RDS for MySQL | Store help desk requests. |
| IAM and Secrets Manager | Allow backend instances to retrieve database credentials. |
| Terraform | Create and update the AWS infrastructure from code. |

## Run the project on AWS

### Prerequisites

- An AWS account and AWS CLI.
- Terraform 1.6 or newer.
- A public GitHub repository that EC2 can clone.

### Deploy

Open PowerShell in the project folder:

```powershell
cd infrastructure/terraform
Copy-Item terraform.tfvars.example terraform.tfvars
```

Review `terraform.tfvars`. Confirm the AWS region and repository URL, then check your AWS identity and review the Terraform plan:

```powershell
aws sts get-caller-identity
terraform init
terraform plan
```

If the plan looks right, create the resources:

```powershell
terraform apply
terraform output application_url
```

Wait for the load balancer targets to become healthy, then open the application URL. For app updates, change `app_release` in `terraform.tfvars` so Terraform refreshes the EC2 instances.

See the [deployment guide](infrastructure/terraform/DEPLOYMENT.md) for more detail.

### Clean up AWS resources

AWS resources in this project can incur charges, especially the NAT Gateway, load balancers, EC2, and RDS. When you finish the demo, review and run:

```powershell
terraform destroy
```

This deletes the database too. Export any data you want to keep first.

## Run locally

For local development, use XAMPP with Apache, PHP, and MySQL. Import `database/database_setup.sql`, copy the `frontend` files into your local web root and the `backend/api` files into its `api` folder, then configure the database connection for your local MySQL account.

Open `http://localhost/campus-helpdesk/` in a browser. See the [interview guide](docs/INTERVIEW_GUIDE.md) for beginner-friendly explanations of the application and its AWS design.

## Project structure

```text
backend/api/                 PHP API and database connection
database/                    MySQL schema and sample requests
docs/                        Architecture and interview notes
frontend/                    HTML, CSS, and JavaScript
infrastructure/terraform/    AWS resources and deployment guide
screenshots/                 Screenshots of the running app
aws-three-tier-architecture.png
```

Add your screenshots to `screenshots/` and link them here when they are uploaded.

## Resume description

**Campus Help Desk on AWS | Student Project**

Deployed a PHP and MySQL help desk demo using Terraform and a three-tier AWS architecture. Configured VPC networking, load balancers, EC2 Auto Scaling, private RDS, IAM roles, and Secrets Manager. Practiced troubleshooting API and backend deployment issues.

Describe only the services and work you can explain. This demo uses one EC2 instance per application tier by default, so it does not provide EC2 failover across multiple Availability Zones.

## Acknowledgements

Thanks to **Ajit Sir** for the YouTube explanation of AWS three-tier architecture that helped me understand the design and build this project.
