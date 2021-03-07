###############################################################
# ELB
###############################################################
# Create the ELB
resource "aws_lb" "test-lb" {
  name               = "test-lb"
  security_groups    = [aws_security_group.elb-sg.id]
  load_balancer_type = "application"
  subnets            = aws_subnet.public-subnet.*.id
}

# Create security group that's applied to the ELB
resource "aws_security_group" "elb-sg" {
  name   = "elb-sg"
  vpc_id = aws_vpc.test-vpc.id
  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound HTTP from anywhere
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "test-tg" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.test-vpc.id
  health_check {
    path                = "/index.html"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 5
    port                = var.server_port
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.test-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test-tg.arn
  }
}