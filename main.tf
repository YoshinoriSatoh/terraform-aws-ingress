/**
 * # Terraform AWS Ingress module
 *
 * ALB/NLB とそれにルーティングするRoute53レコードを作成します。
 */
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  lb_name = "${var.tf.fullname}-${var.name}"
}

resource "aws_lb" "default" {
  name                       = local.lb_name
  internal                   = var.internal
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.lb.id]
  subnets                    = var.subnet_ids
  enable_deletion_protection = !var.in_development

  access_logs {
    bucket  = var.logging_bucket_id
    prefix  = local.lb_name
    enabled = true
  }
}

resource "aws_security_group" "lb" {
  name        = "${local.lb_name}-alb"
  description = local.lb_name
  vpc_id      = var.vpc_id
  tags = {
    Name = local.lb_name
  }

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
      security_group_id = ingress.security_group_id
    }
  }
  type              = "ingress"
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = length(each.value.cidr_blocks) > 0 ? each.value.cidr_blocks : null
  source_security_group_id = each.value.security_group_id != "" ? each.value.security_group_id : null
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
    for key, dns_record in var.dns_records : key => {
      name = dns_record.name
    }
  }
  zone_id = var.hostedzone_id
  name    = each.value.name == "" ? var.domain : "${each.value.name}.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.default.dns_name
    zone_id                = aws_lb.default.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_health_check" "healthcheck" {
  for_each = {
    for key, dns_record in var.dns_records : key => {
      name = dns_record.name
      health_check_path = dns_record.health_check_path
      health_check_port = dns_record.health_check.port
    }
  }
  fqdn                    = each.value.name == "" ? var.domain : "${each.value.name}.${var.domain}"
  port                    = each.value.health_check.port
  type                    = each.value.health_check.type
  resource_path           = each.value.health_check_path
  failure_threshold       = "5"
  request_interval        = "30"
  cloudwatch_alarm_name   = "${var.tf.fullname}-${each.value.name}-healthcheck"
  cloudwatch_alarm_region = "us-east-1"
  tags = {
    Name = "${var.tf.fullname}-${each.value.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "healthcheck" {
  for_each = {
    for key, dns_record in var.dns_records : key => {
      name = dns_record.name
    }
  }
  provider            = aws.useast1
  alarm_name          = "${var.tf.fullname}-${each.value.name}-healthcheck"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  alarm_description   = "This metric monitor ${var.tf.fullname} ${each.value.name} url healthcheck"
  alarm_actions       = [var.healthcheck_notification_topic_arn]
  ok_actions          = [var.healthcheck_notification_topic_arn]
  dimensions = {
    HealthCheckId = aws_route53_health_check.healthcheck[each.key].id
  }
}