resource "aws_lb" "load_balancer" {
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = [var.public_subnet_1a_id, var.public_subnet_1c_id]

  tags = {
    Name = "${var.name}_load_balancer"
  }
}

resource "aws_lb_listener" "load_balancer_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Hello, world"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "load_balancer_listener_rule" {
  listener_arn = aws_lb_listener.load_balancer_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_lb_target_group" "target_group" {
  name                 = var.name
  target_type          = "ip"
  vpc_id               = var.vpc_id
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 300

  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  depends_on = [aws_lb.load_balancer]
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.name
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = var.name
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "public.ecr.aws/nginx/nginx:1.27"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "ecs_service" {
  name                              = var.name
  cluster                           = aws_ecs_cluster.ecs_cluster.arn
  task_definition                   = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0"
  health_check_grace_period_seconds = 30

  network_configuration {
    assign_public_ip = false
    security_groups  = [var.ecs_security_group_id]
    subnets          = [var.private_subnet_id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "nginx"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}
