# Intuitive Lab

This lab sets up an EC2 ngnx scaling group running in high availability mode running in 2 or more availability zones

- [provider.tf](provider.tf) = Configures the AWS Provider
- [ec2.tf](ec2.tf) = ec2 template(s) and scale groups
- [elb.tf](elb.tf) = configure elastic load balancer
- [securitygroups.tf](securitygroups.tf) = security groups 
- [vpc.tf](vpc.tf) = vpc configuration