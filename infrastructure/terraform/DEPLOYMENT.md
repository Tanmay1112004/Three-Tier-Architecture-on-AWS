# Deploy from PowerShell

This guide updates the existing Three-Tier Architecture on AWS project to run the Campus Help Desk Portal. Terraform creates the AWS infrastructure; the EC2 launch templates fetch the application files from the public Git repository in `app_repo_url`.

## Before you start

- AWS CLI v2 and Terraform 1.6 or newer must be installed.
- Your AWS CLI session must have permission to manage VPC, EC2, ELB, Auto Scaling, RDS, IAM, and Secrets Manager resources.
- The selected AWS region needs at least three available Availability Zones. The default is `us-east-1`.
- The application repository must be public so EC2 can clone it at startup. Do not put a GitHub token in Terraform variables or EC2 user data.

Check the AWS identity:

```powershell
aws sts get-caller-identity
aws configure get region
```

## Publish the application files

EC2 instances clone `app_repo_url`; they cannot see files that only exist on your computer. From the project root, check the Git remote and publish the project files to a repository you own:

```powershell
git remote -v
git status --short
git add README.md frontend backend database docs infrastructure
git commit -m "Build campus help desk portfolio app"
git push origin main
```

The Terraform defaults point to this repository. Keep it public so EC2 can clone it at startup. If you deploy from a different public repository, set `app_repo_url` in `infrastructure\terraform\terraform.tfvars` to that repository's URL.

## Review and apply Terraform

In PowerShell, from the project root:

```powershell
Set-Location .\infrastructure\terraform
if (-not (Test-Path .\terraform.tfvars)) {
    Copy-Item .\terraform.tfvars.example .\terraform.tfvars
}
```

Open `terraform.tfvars`. Confirm the repository URL and set a new `app_release` label, such as `v2`. Changing that label creates a new launch-template version and refreshes the EC2 instances so they download the published app files.

```hcl
aws_region = "us-east-1"
project_name = "hello-world-three-tier"
environment = "demo"
app_repo_url = "https://github.com/Tanmay1112004/Three-Tier-Architecture-on-AWS.git"
app_release = "v2"
```

The existing RDS database name remains `hello_world`, so this app update does not request database replacement. The SQL setup adds a `service_requests` table and sample rows without deleting the existing `messages` table.

Then initialize, review, and apply:

```powershell
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=deployment.tfplan
terraform apply deployment.tfplan
terraform output application_url
```

Review the plan before applying. Allow several minutes for the rolling instance refresh and health checks. Open the URL, submit a sample request, refresh the page, and confirm the request remains in the list.

## Cost and demo limits

- The default Auto Scaling desired capacity is one `t3.micro` instance in each EC2 tier to fit a small account quota. It does not give EC2 instance failover across all three Availability Zones.
- The database is private and Multi-AZ. The EC2 tiers use one NAT Gateway, which costs money and is a single-AZ dependency.
- The public load balancer uses HTTP. The demo has no login, so never enter personal or confidential information. A real service needs HTTPS, authentication, access controls, monitoring, backups, and request limits.
- Resources such as NAT Gateway, load balancers, EC2, RDS, and public IPv4 addresses incur charges while running.
- Terraform's local state contains the generated database password. Keep state private; do not commit `terraform.tfstate`, plan files, or `terraform.tfvars`. For a team or production setup, configure secured remote state with encryption, access controls, and locking.

When you are finished with the AWS demo, run this from `infrastructure\terraform`:

```powershell
terraform destroy
```

Destroying the stack deletes its RDS database. Export anything you want to keep first.
