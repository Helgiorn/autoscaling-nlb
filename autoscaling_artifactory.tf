resource "aws_autoscaling_group" "artifactory" {
  availability_zones = ["eu-north-1a"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.artifactory_launch_template.id
    version = "$Latest"
  }
}
resource "aws_autoscaling_attachment" "artifactory" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  elb                    = aws_lb.artifactory_target_group.id
  lb_target_group_arn    = aws_lb_target_group.artifactory_target_group.arn
}

resource "aws_launch_template" "artifactory" {
  name                    = "artifactory-"
  instance_type           = "t2.micro"
  image_id                = "ami-test"
  ebs_optimized           = true
  disable_api_stop        = true
  disable_api_termination = true
  vpc_security_group_ids  = ["data"]
  instance_initiated_shutdown_behavior  = "terminate"

  block_device_mappings {
    device_name   = "/dev/sda1"

    ebs {
      volume_size = 30
      volume_type = standard
      encrypted   = true
    }
  }
  iam_instance_profile {
    name = "test"
  }

  monitoring {
    enabled = true
  }
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination = true 
    subnet_id = ""
    vpc_id = ""
    security_groups = ""
  }
  
  tag_specifications {
    resource_type = "instance"

    tags = {
      owner  = ""
      tenant = ""
      system = ""
    }
  }

  user_data = filebase64("${path.module}/example.sh")
}