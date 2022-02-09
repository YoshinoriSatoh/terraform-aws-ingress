/**
 * # Terraform AWS Ingress module
 *
 * ALB/NLB とそれにルーティングするRoute53レコードを作成します。
 */
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  lb_name = var.tf.fullname
}

resource "aws_lb" "default" {
  name                       = local.lb_name
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.lb.id]
  subnets                    = var.subnet_ids
  enable_deletion_protection = false

  access_logs {
    bucket  = var.logging_bucket_id
    prefix  = local.lb_name
    enabled = true
  }
}

resource "aws_security_group" "lb" {
  name        = local.lb_name
  description = local.lb_name
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ingresses" {
  for_each = {
    for key, ingress in var.ingresses : key => {
      description = ingress.description
      from_port   = ingress.from_port
      to_port     = ingress.to_port
      protocol    = ingress.protocol
      cidr_blocks = ingress.cidr_blocks
    }
  }
  type              = "ingress"
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  security_group_id = aws_security_group.lb.id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.default.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.default.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_route53_record" "a_records" {
  for_each = {
    for key, value in var.dns_records : key => value
  }
  zone_id = var.hostedzone_id
  name    = each.value == "" ? var.domain : "${each.value}.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.default.dns_name
    zone_id                = aws_lb.default.zone_id
    evaluate_target_health = true
  }
}
