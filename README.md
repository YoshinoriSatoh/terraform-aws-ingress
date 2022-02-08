<!-- BEGIN_TF_DOCS -->
# Terraform AWS Ingress module

ALB/NLB とそれにルーティングするRoute53レコードを作成します。

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 3.74.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.74.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb.default](https://registry.terraform.io/providers/hashicorp/aws/3.74.0/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/3.74.0/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/3.74.0/docs/resources/lb_listener) | resource |
| [aws_route53_record.a_records](https://registry.terraform.io/providers/hashicorp/aws/3.74.0/docs/resources/route53_record) | resource |
| [aws_security_group.lb](https://registry.terraform.io/providers/hashicorp/aws/3.74.0/docs/resources/security_group) | resource |
| [aws_security_group_rule.ingresses](https://registry.terraform.io/providers/hashicorp/aws/3.74.0/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/3.74.0/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/3.74.0/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | n/a | `string` | n/a | yes |
| <a name="input_dns_records"></a> [dns\_records](#input\_dns\_records) | n/a | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_domain"></a> [domain](#input\_domain) | n/a | `string` | n/a | yes |
| <a name="input_hostedzone_id"></a> [hostedzone\_id](#input\_hostedzone\_id) | n/a | `string` | n/a | yes |
| <a name="input_ingresses"></a> [ingresses](#input\_ingresses) | n/a | <pre>list(object({<br>    description = string<br>    from_port   = number<br>    to_port     = number<br>    protocol    = string<br>    cidr_blocks = list(string)<br>  }))</pre> | <pre>[<br>  {<br>    "cidr_blocks": [<br>      "0.0.0.0/0"<br>    ],<br>    "description": "http (for redirect)",<br>    "from_port": 80,<br>    "protocol": "tcp",<br>    "to_port": 80<br>  },<br>  {<br>    "cidr_blocks": [<br>      "0.0.0.0/0"<br>    ],<br>    "description": "https production",<br>    "from_port": 443,<br>    "protocol": "tcp",<br>    "to_port": 443<br>  }<br>]</pre> | no |
| <a name="input_logging_bucket_id"></a> [logging\_bucket\_id](#input\_logging\_bucket\_id) | n/a | `string` | n/a | yes |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | n/a | `string` | `"ELBSecurityPolicy-FS-1-2-Res-2020-10"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | n/a | `list(string)` | n/a | yes |
| <a name="input_tf"></a> [tf](#input\_tf) | n/a | <pre>object({<br>    name          = string<br>    shortname     = string<br>    env           = string<br>    fullname      = string<br>    fullshortname = string<br>  })</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_listener"></a> [listener](#output\_listener) | n/a |
| <a name="output_security_group"></a> [security\_group](#output\_security\_group) | n/a |
<!-- END_TF_DOCS -->    