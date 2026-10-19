variable "aws_region" {
  description = "AWS region. The region must have at least three available Availability Zones."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "hello-world-three-tier"
}

variable "environment" {
  type    = string
  default = "demo"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type for both tiers."
  type        = string
  default     = "t3.micro"
}

variable "frontend_min_size" {
  type    = number
  default = 1
}

variable "frontend_desired_capacity" {
  type    = number
  default = 1
}

variable "frontend_max_size" {
  type    = number
  default = 2
}

variable "backend_min_size" {
  type    = number
  default = 1
}

variable "backend_desired_capacity" {
  type    = number
  default = 1
}

variable "backend_max_size" {
  type    = number
  default = 2
}

variable "db_instance_class" {
  description = "RDS instance class; adjust for your workload and budget."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "app_repo_url" {
  description = "Public Git URL cloned by EC2 user data at instance launch."
  type        = string
  default     = "https://github.com/ajitinamdar-tech/three-tier-architecture-aws.git"
}

variable "app_release" {
  description = "Release label changed for each app deployment so Auto Scaling refreshes instances."
  type        = string
  default     = "v1"
}

