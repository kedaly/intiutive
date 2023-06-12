resource "aws_launch_template" "my_launch_template" {

  name = "my_launch_template"

  image_id = "ami-06878d265978313ca"
  instance_type = "t2.micro"
  #key_name = "ubuntu"

  user_data = filebase64("${path.module}/server.sh")

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 8
      volume_type = "gp2"
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.my_sg.id]
  }
}

