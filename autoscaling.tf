# Create launch configuration
resource "aws_launch_configuration" "asg-lc1" {
  name            = "asg-lc"
  image_id        = data.aws_ami.test-ami.id
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.test.key_name
  security_groups = [aws_security_group.asg-lc-sg.id]

  iam_instance_profile = aws_iam_instance_profile.instance_profile.id

  user_data = <<-EOF
              #!/bin/bash
              cd /tmp
              sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
              sudo systemctl enable amazon-ssm-agent
              sudo systemctl start amazon-ssm-agent
              sudo yum update -y
              sudo yum install httpd -y
              sudo service httpd start
              sudo chkconfig httpd on
              echo "My Home Assignment" > /var/www/html/index.html
              hostname -f >> /var/www/html/index.html
              sudo mkfs -t xfs /dev/xvdz
              sudo mount /dev/xvdz /var/log
              EOF

  ebs_block_device {
    device_name           = "/dev/xvdz"
    volume_type           = "gp2"
    volume_size           = "10"
    encrypted             = true
    delete_on_termination = true
  }
  root_block_device {
    volume_size = "10"
    volume_type = "gp2"
    encrypted   = true
  }

  lifecycle {
    create_before_destroy = true
  }
}


###############################################################
# Autoscaling
###############################################################

# Create autoscaling policy -> target at a 65% average CPU load
resource "aws_autoscaling_policy" "asg-policy" {
  count                  = 1 #length(var.subnet_cidrs_private)
  name                   = "asg-policy"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = element(aws_autoscaling_group.asg.*.name, count.index)

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 65.0
  }
}

# Create an autoscaling group
resource "aws_autoscaling_group" "asg" {
  #count                = 2#length(var.availability_zones)  
  name                 = "asg"
  launch_configuration = aws_launch_configuration.asg-lc1.id
  vpc_zone_identifier  = aws_subnet.private-subnet.*.id
  min_size             = 2
  max_size             = 3
  target_group_arns    = [aws_lb_target_group.test-tg.id]
  health_check_type    = "ELB"

  tag {
    key                 = "Name"
    value               = "Webserver"
    propagate_at_launch = true
  }
}


# Create security group that's applied the launch configuration
resource "aws_security_group" "asg-lc-sg" {
  name   = "asg-lc-sg"
  vpc_id = aws_vpc.test-vpc.id
  # Inbound HTTP from anywhere
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.elb-sg.id]
    #cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound internet access

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    #security_groups = [aws_security_group.elb-sg.id]
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}


