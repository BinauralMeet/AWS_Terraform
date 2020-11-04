resource "aws_ecs_cluster" "ecs_cluster_web_app" {
  name = "jitsi-ecs"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jitsi-vpc"
  cidr = "10.0.0.0/16"

  azs                 = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  private_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets      = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

}

module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "jitsi-sg"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = ["http-80-tcp", "http-8080-tcp", "https-443-tcp", "https-8443-tcp", "ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "jitsi-udp" {
  type              = "ingress"
  from_port         = 10000
  to_port           = 10000
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.web_server_sg.this_security_group_id

}

module "ec2_cluster" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  name                   = "jitsi-meet"
  instance_count         = 1

  ami                    = "ami-07288201d2a68d471"
  instance_type          = "t2.micro"
  key_name               = "jinge"
  monitoring             = true
  vpc_security_group_ids = [module.web_server_sg.this_security_group_id]
  subnet_id              = "subnet-0596787995482cd7b"
  
  user_data = "${file("install_jitsi.sh")}"
}

resource "aws_ecs_service" "jitsi_service" {
  name            = "jitsi-service"
  cluster         = aws_ecs_cluster.ecs_cluster_web_app.id
  task_definition = "docker-jitsi-meet:17"
  desired_count   = 1

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
}


# ACM
data "aws_acm_certificate" "main" {
  domain = "*.haselab.net"
  statuses = ["ISSUED"]
}


module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name = "jitsi-alb"

  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [module.web_server_sg.this_security_group_id]

  target_groups = [
    {
      name_prefix      = "jitsi"
      backend_protocol = "HTTPS"
      backend_port     = 8443
      target_type      = "instance"
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = data.aws_acm_certificate.main.arn
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  tags = {
    Project     = "jitsi"
  }
}

