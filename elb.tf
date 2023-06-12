resource "aws_lb" "intuitive_alb" {
  name               = "intuitive-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.intuitive_sg.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_listener" "my_lb_listener" {
  load_balancer_arn = aws_lb.intuitive_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.intuitive_tg.arn
  }
}

resource "aws_lb_target_group" "intuitive_tg" {
  name     = "intuitive-tg"
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}

resource "aws_autoscaling_group" "intuitive_asg" {
  name                      = "intuitive_asg"
  max_size                  = 5
  min_size                  = 2
  health_check_type         = "ELB"    # optional
  desired_capacity          = 2
  target_group_arns = [aws_lb_target_group.intuitive_tg.arn]

  vpc_zone_identifier       = module.vpc.public_subnets

  launch_template {
    id      = aws_launch_template.intuitive_launch_template.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale_up"
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.intuitive_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"      # add one instance
  cooldown               = "300"    # cooldown period after scaling
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "scale-up-alarm"
  alarm_description   = "asg-scale-up-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "50"
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.intuitive_asg.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_up.arn]
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "asg-scale-down"
  autoscaling_group_name = aws_autoscaling_group.intuitive_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "asg-scale-down-alarm"
  alarm_description   = "asg-scale-down-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.intuitive_asg.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_down.arn]
}
