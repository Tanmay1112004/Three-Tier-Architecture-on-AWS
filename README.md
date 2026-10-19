# ☁️ Three-Tier Architecture on AWS | Campus Help Desk Portal

**A hands-on AWS Cloud Engineering project demonstrating secure networking, scalable application architecture, Infrastructure as Code, and managed database deployment using Terraform.**

[![AWS](https://img.shields.io/badge/AWS-Cloud%20Computing-orange?logo=amazonaws&logoColor=white)](https://aws.amazon.com/)
[![Terraform](https://img.shields.io/badge/Terraform-Infrastructure%20as%20Code-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![PHP](https://img.shields.io/badge/PHP-Backend-777BB4?logo=php&logoColor=white)](https://www.php.net/)
[![MySQL](https://img.shields.io/badge/MySQL-Database-4479A1?logo=mysql&logoColor=white)](https://www.mysql.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📌 Project Overview

The **Campus Help Desk Portal** is a beginner-friendly cloud engineering project built to demonstrate how a web application can be deployed on AWS using a traditional three-tier architecture.

The application allows students to submit campus support requests and view recently submitted requests. While the application itself is intentionally lightweight, the primary focus is on designing the AWS infrastructure, separating application tiers, managing network access, securing database credentials, and provisioning resources with Terraform.

This project demonstrates practical knowledge of AWS infrastructure, cloud networking, load balancing, EC2, Auto Scaling, managed databases, IAM, Secrets Manager, and Infrastructure as Code (IaC).

## 📸 Application Screenshots

> Replace the image paths below with your actual screenshot filenames. Create an `screenshots/` directory in your repository and upload your application screenshots there.

### Application Dashboard

<!-- Replace with your actual dashboard screenshot -->

![Campus Help Desk Portal Dashboard](https://github.com/Tanmay1112004/Three-Tier-Architecture-on-AWS/blob/main/screenshots/Screenshot%202026-10-19%20192433.png)

### Submit a Support Request

<!-- Replace with your actual form screenshot -->

![Submit a Support Request](https://github.com/Tanmay1112004/Three-Tier-Architecture-on-AWS/blob/main/screenshots/Screenshot%202026-10-19%20192501.png)

### Project Setup

<!-- Replace with your actual requests screenshot -->

![Project setup](https://github.com/Tanmay1112004/Three-Tier-Architecture-on-AWS/blob/main/screenshots/Screenshot%202026-10-19%20191933.png)

![Project setup](https://github.com/Tanmay1112004/Three-Tier-Architecture-on-AWS/blob/main/screenshots/Screenshot%202026-10-19%20192008.png)

![Project setup](https://github.com/Tanmay1112004/Three-Tier-Architecture-on-AWS/blob/main/screenshots/Screenshot%202026-10-19%20192030.png)

![Project setup](https://github.com/Tanmay1112004/Three-Tier-Architecture-on-AWS/blob/main/screenshots/Screenshot%202026-10-19%20192416.png)


### AWS Three-Tier Architecture

<!-- Keep the architecture diagram in the repository root or update this path -->

![AWS Three-Tier Architecture](aws-three-tier-architecture.png)

## 🏗️ Architecture Overview

The application follows a **three-tier architecture** that separates the presentation layer, application logic, and data storage.

Each tier has a specific responsibility, and security groups control communication between the relevant components.

### Architecture Diagram

![Three-Tier Architecture on AWS](aws-three-tier-architecture.png)

### Request Flow

1. A student opens the application through the public Application Load Balancer.
2. The load balancer distributes incoming HTTP/HTTPS traffic to the frontend EC2 instances in private subnets.
3. Nginx serves the frontend and forwards `/api/` requests to the internal application load balancer.
4. The internal load balancer forwards API requests to the PHP backend instances.
5. The PHP API validates incoming data and interacts with Amazon RDS for MySQL.
6. The backend retrieves database credentials from AWS Secrets Manager using an IAM role attached to the EC2 instances.
7. The API returns the result to the frontend, which displays a success message or the latest support requests.

**Design principle:** The database is not publicly accessible, the application servers are not directly exposed to the internet, and access between tiers is restricted through security groups.

## 🧰 Technology Stack

| Category | Technology | Purpose |
|---|---|---|
| Cloud Platform | Amazon Web Services (AWS) | Cloud infrastructure and hosting |
| Infrastructure as Code | Terraform | Provisioning and managing AWS resources |
| Networking | Amazon VPC | Network isolation and segmentation |
| Network Access | Public and private subnets | Separating public entry points from application resources |
| Web Tier | Amazon EC2, Nginx | Serving the frontend |
| Application Tier | Amazon EC2, PHP | Processing application requests |
| Load Balancing | Application Load Balancer (ALB) | Distributing traffic across application instances |
| Scaling | EC2 Launch Templates and Auto Scaling Groups | Managing instance configuration and scaling capacity |
| Database | Amazon RDS for MySQL | Managed relational data storage |
| High Availability | Multi-AZ RDS deployment | Database availability across Availability Zones |
| Security | AWS IAM | Controlling permissions for AWS resources |
| Secrets Management | AWS Secrets Manager | Storing and retrieving database credentials |
| Frontend | HTML, CSS, JavaScript | User interface and browser interactions |
| Database Setup | SQL | Creating database tables and initial data |
| Local Development | XAMPP | Running the PHP application locally |

## ✨ Application Features

- **View support requests:** Display recently submitted campus help desk requests.
- **Submit a request:** Enter a title, category, and short description.
- **Store request data:** Persist requests in a MySQL database.
- **Track request status:** Create new requests with an initial `Open` status.
- **Display timestamps:** Record when a request is submitted.
- **User feedback:** Display simple success or error messages.
- **Frontend and API separation:** Use JavaScript Fetch API calls to communicate with the PHP backend.

The application is a demonstration project. It does not currently include student authentication, staff assignment, role-based workflows, or a production-grade authorization system.

## ☁️ AWS Infrastructure Components

### 1. Amazon VPC and Network Design

Created a dedicated Virtual Private Cloud to isolate the application's resources and organize the network into separate tiers.

The network design includes:

- Public subnets for internet-facing infrastructure.
- Private frontend subnets for Nginx EC2 instances.
- Private application subnets for PHP EC2 instances.
- Private database subnets for Amazon RDS.
- Route tables to control traffic between subnets and gateways.
- An Internet Gateway for public-subnet internet connectivity.
- A NAT Gateway to allow eligible private-subnet resources to initiate outbound internet connections.

### 2. Application Load Balancers

**Public ALB**
- Provides the public entry point for the application.
- Distributes incoming traffic to the frontend tier.
- Uses target groups and health checks to route traffic to healthy registered targets.

**Internal ALB**
- Receives API traffic forwarded by the Nginx frontend tier.
- Distributes requests to the PHP backend instances.
- Keeps the backend entry point internal rather than directly internet-facing.

### 3. Amazon EC2 and Auto Scaling

The frontend and backend tiers use separate EC2 launch templates and Auto Scaling Groups.

- Frontend instances run Nginx.
- Backend instances run PHP and the required web/API components.
- Launch templates define the EC2 instance configuration.
- Auto Scaling Groups manage instance membership and desired capacity.
- Load balancer target groups provide health-based traffic routing.

**Capacity note:** The starter configuration uses one `t3.micro` instance in each EC2 tier to accommodate a small account quota. An Auto Scaling Group does not automatically guarantee high availability when only one instance is running. Multi-instance capacity and suitable scaling policies must be configured and tested for stronger application-tier resilience.

### 4. Amazon RDS for MySQL

Amazon RDS provides managed relational database storage for help desk requests.

- Stores support request details and timestamps.
- Uses a DB subnet group spanning private database subnets.
- Is configured for Multi-AZ deployment.
- Restricts database access to authorized application-tier resources.
- Avoids exposing the database directly to the public internet.

Multi-AZ improves database availability, but it does not replace application-tier redundancy or a complete disaster recovery strategy.

### 5. AWS IAM and Secrets Manager

Security is an important part of the architecture.

- IAM roles provide AWS permissions to application instances.
- AWS Secrets Manager stores database connection credentials.
- Backend instances retrieve credentials through their assigned IAM role.
- Security groups restrict communication between tiers.
- Database credentials should not be hardcoded in application source code or committed to GitHub.

## 🔐 Network Security Model

The intended traffic flow is:

| Source | Destination | Allowed traffic |
|---|---|---|
| Internet | Public ALB | HTTP/HTTPS as configured |
| Public ALB | Frontend EC2 | Frontend application port |
| Frontend EC2 | Internal ALB | API traffic |
| Internal ALB | Backend EC2 | Backend application port |
| Backend EC2 | Amazon RDS | MySQL port, TCP 3306 |
| Backend EC2 | AWS Secrets Manager | HTTPS, TCP 443, through the configured AWS network path |

These rules represent the intended design. Actual security-group rules and listener configurations should be verified against the deployed Terraform configuration.

For a production deployment, configure HTTPS with an appropriate TLS certificate, restrict administrative access, review IAM permissions, and validate all ingress and egress rules.

## 📂 Repository Structure

```text
three-tier-architecture-aws/
│
├── backend/
│   └── api/
│       ├── health.php
│       ├── get_requests.php
│       ├── save_request.php
│       └── db_connection.php
│
├── database/
│   └── database_setup.sql
│
├── docs/
│   ├── ARCHITECTURE.md
│   └── INTERVIEW_GUIDE.md
│
├── frontend/
│   ├── index.html
│   ├── styles.css
│   └── app.js
│
├── infrastructure/
│   └── terraform/
│       ├── DEPLOYMENT.md
│       └── *.tf
│
├── screenshots/
│   ├── app-dashboard.png
│   ├── submit-request.png
│   └── recent-requests.png
│
├── aws-three-tier-architecture.png
├── .gitignore
├── LICENSE
└── README.md
```

*Note: The file names shown above are illustrative. Keep the directory structure and filenames aligned with the actual files in your repository.*

## 🚀 Deployment Guide

The AWS infrastructure is managed using Terraform.

Before deployment, ensure you have:

- An AWS account with the required service quotas.
- AWS CLI installed and configured.
- Terraform installed.
- Appropriate AWS IAM permissions.
- Access to the project repository.

### Step 1: Clone the Repository

```powershell
git clone https://github.com/Tanmay1112004/Three-Tier-Architecture-on-AWS.git
cd Three-Tier-Architecture-on-AWS
```

### Step 2: Configure AWS Credentials

Configure a suitable AWS profile using the AWS CLI:

```powershell
aws configure
```

Verify the identity associated with your active credentials:

```powershell
aws sts get-caller-identity
```

Never commit access keys, secret keys, session tokens, or Terraform state files containing sensitive information.

### Step 3: Initialize Terraform

Navigate to the Terraform directory:

```powershell
cd infrastructure/terraform
terraform init
```

### Step 4: Validate the Configuration

```powershell
terraform fmt -check
terraform validate
terraform plan
```

Review the plan carefully before creating resources. Confirm the AWS Region, resource sizes, networking configuration, and estimated costs.

### Step 5: Deploy the Infrastructure

```powershell
terraform apply
```

Review the proposed changes and confirm the operation when prompted.

Wait for the resources to finish provisioning. Deployment time depends on resource creation, database initialization, and configuration.

### Step 6: Access the Application

Retrieve the public ALB DNS name from the Terraform outputs, if the project exposes it:

```powershell
terraform output
```

Open the configured application URL in your browser. Use HTTPS if it has been configured with a valid TLS certificate.

For the exact deployment commands, application release procedure, troubleshooting steps, and teardown instructions, see:

**[Terraform Deployment Guide](infrastructure/terraform/DEPLOYMENT.md)**

## 💻 Run the Application Locally

Local development allows you to test the frontend, PHP API, and MySQL database without deploying the complete AWS infrastructure.

### Prerequisites

- XAMPP with Apache and MySQL.
- PHP with the required database extensions.
- A web browser.
- The project repository cloned locally.

### Setup

1. Start Apache and MySQL from the XAMPP Control Panel.
2. Open phpMyAdmin and import `database/database_setup.sql`.
3. Copy the frontend files into `C:\xampp\htdocs\campus-helpdesk`.
4. Copy the backend API files into `C:\xampp\htdocs\campus-helpdesk\api`.
5. Configure the local database connection using the application's supported configuration method.
6. Open the application in your browser:

```text
http://localhost/campus-helpdesk/
```

Use the database username and password configured on your computer. Avoid assuming that the default XAMPP MySQL account is passwordless.

For the local configuration details and troubleshooting, refer to the application's actual PHP database connection code.

## 🧪 Testing and Validation

After deployment, validate the application at each layer.

| Test | Expected result |
|---|---|
| Open the application URL | Frontend page loads |
| Submit a valid support request | Request is stored and success feedback is displayed |
| Refresh the page | Newly created request appears in the recent requests list |
| Submit invalid input | Request is rejected or an appropriate error is displayed |
| Check ALB target health | Registered targets report their configured health status |
| Test database connectivity | Backend connects to RDS using the configured credentials |
| Verify private access | Backend and database resources are not directly exposed to the internet |
| Test application instance replacement | Traffic recovers as expected for the configured Auto Scaling capacity |

These are validation steps, not a claim that every test has already passed. Record the results from your actual deployment before presenting them as completed testing.

## 🛡️ Security and Cost Considerations

This project is intended for learning and portfolio demonstration, not direct production use.

### Security

- Do not store AWS credentials or database passwords in Git.
- Use IAM roles and least-privilege policies.
- Restrict database connectivity to authorized backend resources.
- Configure HTTPS for production-facing traffic.
- Add authentication, authorization, input validation, and appropriate request limits before supporting real users.
- Review PHP error handling, SQL queries, CORS settings, and database permissions.
- Treat submitted information as untrusted input.

### AWS Costs

The stack can create billable AWS resources, including:

- NAT Gateway and associated data processing.
- Application Load Balancers.
- EC2 instances and associated storage.
- Amazon RDS and Multi-AZ database capacity.
- Data transfer and other service usage.

**Important:** Run `terraform destroy` when you finish practicing, after confirming that you no longer need the deployed resources or data.

```powershell
terraform destroy
```

Review the destruction plan and confirm before proceeding. Check the AWS Billing console afterward for any remaining billable resources, retained storage, snapshots, or other charges. Destroying the Terraform-managed stack does not necessarily remove every separately created resource.

## 🎯 Key Learning Outcomes

Through this project, I gained practical exposure to:

- Designing a three-tier cloud application architecture.
- Building VPC networking with public and private subnets.
- Configuring route tables, Internet Gateway, and NAT Gateway.
- Separating web and application traffic using load balancers.
- Provisioning EC2 instances and Auto Scaling Groups.
- Connecting a PHP backend to Amazon RDS for MySQL.
- Managing database credentials through AWS Secrets Manager.
- Applying IAM roles and security-group-based access controls.
- Automating infrastructure provisioning using Terraform.
- Troubleshooting issues across networking, compute, application, and database layers.
- Understanding the trade-offs between cost, availability, scalability, and security.

## 💼 Resume Description

**Three-Tier Architecture on AWS | Cloud Engineering Project**

Designed and deployed a PHP and MySQL Campus Help Desk application using a three-tier AWS architecture. Provisioned cloud infrastructure with Terraform, including VPC networking, public and private subnets, Application Load Balancers, EC2 Auto Scaling Groups, and private Multi-AZ Amazon RDS. Implemented IAM-based access and AWS Secrets Manager for database credentials, with security groups controlling communication between application tiers.

*Describe only the components you personally implemented and validated. Be ready to explain the architecture, security rules, deployment process, costs, and current limitations during interviews.*

## 📚 Documentation

- **[Architecture Notes](docs/ARCHITECTURE.md)** — Architecture decisions, component responsibilities, and request flow.
- **[Terraform Deployment Guide](infrastructure/terraform/DEPLOYMENT.md)** — AWS setup, deployment, application access, and cleanup.
- **[Interview Guide](docs/INTERVIEW_GUIDE.md)** — Beginner-friendly technical explanations and project limitations.

## 🙏 Acknowledgements

Special thanks to **Ajit Sir** for the helpful YouTube explanation of AWS three-tier architecture, which supported my understanding of the concepts and inspired my hands-on implementation.

## 👨‍💻 Author

**Tanmay**

Computer Engineering Student | Aspiring Cloud / DevOps Engineer

- GitHub: [Tanmay1112004](https://github.com/Tanmay1112004)
- Project Repository: [Three-Tier Architecture on AWS](https://github.com/Tanmay1112004/Three-Tier-Architecture-on-AWS)

I believe in learning by building, troubleshooting real problems, and continuously improving my understanding of cloud technologies.

⭐ If you find this project useful for learning AWS and Terraform, consider giving the repository a star.

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
