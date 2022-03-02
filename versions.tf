terraform {
  required_version = ">= 1.1.6"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">=4.2.0"
      configuration_aliases = [aws.useast1]
    }
  }
}
