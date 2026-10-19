resource "aws_iam_role" "backend" {
  name = "${var.project_name}-backend-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "backend_secret" {
  name = "read-database-secret"
  role = aws_iam_role.backend.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = aws_secretsmanager_secret.database.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "backend_ssm" {
  role       = aws_iam_role.backend.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "backend" {
  name = "${var.project_name}-backend-profile"
  role = aws_iam_role.backend.name
}

resource "aws_lb" "frontend" {
  name               = substr("${var.project_name}-web", 0, 32)
  internal           = false
  load_balancer_type = "application"
  subnets            = [for i in range(3) : aws_subnet.tier[i * 4].id]
  security_groups    = [aws_security_group.frontend_alb.id]
}

resource "aws_lb_target_group" "frontend" {
  name     = substr("${var.project_name}-web-tg", 0, 32)
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path    = "/"
    matcher = "200-399"
  }
}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb" "backend" {
  name               = substr("${var.project_name}-api", 0, 32)
  internal           = true
  load_balancer_type = "application"
  subnets            = [for i in range(3) : aws_subnet.tier[i * 4 + 2].id]
  security_groups    = [aws_security_group.backend_alb.id]
}

resource "aws_lb_target_group" "backend" {
  name     = substr("${var.project_name}-api-tg", 0, 32)
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path    = "/api/health.php"
    matcher = "200-399"
  }
}

resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.backend.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

resource "aws_launch_template" "frontend" {
  name_prefix            = "${var.project_name}-web-"
  image_id               = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.frontend_ec2.id]
  user_data = base64encode(templatefile("${path.module}/user_data_frontend.sh.tftpl", {
    app_repo_url = var.app_repo_url
    app_release  = var.app_release
    backend_dns  = aws_lb.backend.dns_name
  }))
  metadata_options { http_tokens = "required" }
  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.project_name}-frontend" }
  }
}

resource "aws_launch_template" "backend" {
  name_prefix            = "${var.project_name}-api-"
  image_id               = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.backend_ec2.id]
  iam_instance_profile { name = aws_iam_instance_profile.backend.name }
  user_data = base64encode(templatefile("${path.module}/user_data_backend.sh.tftpl", {
    app_repo_url = var.app_repo_url
    app_release  = var.app_release
    db_host      = aws_db_instance.main.address
    secret_arn   = aws_secretsmanager_secret.database.arn
    aws_region   = var.aws_region
  }))
  metadata_options { http_tokens = "required" }
  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.project_name}-backend" }
  }
}

resource "aws_autoscaling_group" "frontend" {
  name                = "${var.project_name}-frontend"
  min_size            = var.frontend_min_size
  desired_capacity    = var.frontend_desired_capacity
  max_size            = var.frontend_max_size
  vpc_zone_identifier = [for i in range(3) : aws_subnet.tier[i * 4 + 1].id]
  target_group_arns   = [aws_lb_target_group.frontend.arn]
  health_check_type   = "ELB"
  launch_template {
    id      = aws_launch_template.frontend.id
    version = aws_launch_template.frontend.latest_version
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
      instance_warmup        = 300
      auto_rollback          = true
    }
  }
  depends_on = [aws_lb_listener.frontend]
}

resource "aws_autoscaling_group" "backend" {
  name                = "${var.project_name}-backend"
  min_size            = var.backend_min_size
  desired_capacity    = var.backend_desired_capacity
  max_size            = var.backend_max_size
  vpc_zone_identifier = [for i in range(3) : aws_subnet.tier[i * 4 + 2].id]
  target_group_arns   = [aws_lb_target_group.backend.arn]
  health_check_type   = "ELB"
  launch_template {
    id      = aws_launch_template.backend.id
    version = aws_launch_template.backend.latest_version
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
      instance_warmup        = 300
      auto_rollback          = true
    }
  }
  depends_on = [aws_lb_listener.backend, aws_db_instance.main]
}
