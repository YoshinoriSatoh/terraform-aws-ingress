variable "tf" {
  type = object({
    name          = string
    shortname     = string
    env           = string
    fullname      = string
    fullshortname = string
  })
}

variable "name" {
  type = string 
}

variable "in_development" {
  description = "開発モード. LBの強制保護を無効にします."
  type        = bool
  default     = false
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "internal" {
  type = bool
  default = false
}

variable "ingresses" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    security_group_id = string
  }))
  default = [
    {
      description = "http (for redirect)"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_group_id = ""
    },
    {
      description = "https production"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_group_id = ""
    }
  ]
}

variable "hostedzone_id" {
  type = string
}

variable "domain" {
  type = string
}

variable "dns_records" {
  type    = list(object({
    name = string
    health_check = object({
      path = string
      port = number
      type = string
    })
  }))
  default = []
}

variable "ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
}

variable "certificate_arn" {
  type = string
}

variable "logging_bucket_id" {
  type = string
}

variable "healthcheck_notification_topic_arn" {
  type = string
}
