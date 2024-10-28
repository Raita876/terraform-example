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

# resource "aws_lb_listener_rule" "load_balancer_listener_rule" {
#   listener_arn = aws_lb_listener.load_balancer_listener.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.target_group.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/*"]
#     }
#   }
# }

# resource "aws_lb_target_group" "target_group" {
#   name                 = var.name
#   target_type          = "ip"
#   vpc_id               = var.vpc_id
#   port                 = 80
#   protocol             = "HTTP"
#   deregistration_delay = 300

#   health_check {
#     path                = "/"
#     healthy_threshold   = 5
#     unhealthy_threshold = 2
#     timeout             = 5
#     interval            = 30
#     matcher             = 200
#     port                = "traffic-port"
#     protocol            = "HTTP"
#   }

#   depends_on = [aws_lb.load_balancer]
# }
