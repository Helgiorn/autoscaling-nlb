resource "aws_lb" "artifactory" {
  name               = "artifactory"
  internal           = false
  load_balancer_type = "network"
  subnets            = ""

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "test-lb"
    enabled = true
  }

  subnet_mapping {
    subnet_id     = aws_subnet.example1.id
    allocation_id = aws_eip.example1.id
  }
  tags = {
    owner  = ""
    tenant = ""
    system = ""
  }
}

resource "aws_lb_listener" "artifactory" {
  load_balancer_arn = aws_lb.artifactory.arn
  port              = "80"
  protocol          = "tcp"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.artifactory.arn
  }
}

resource "aws_lb_target_group" "artifactory" {
  name        = "artifactory"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
  health_check = {
    enabled             = true
    interval            = 30
    path                = "/artifactory/api/system/ping"
    port                = "8082"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 6
  }
}
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

}

