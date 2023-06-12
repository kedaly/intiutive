terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket = "kevin-env-2"
    key    = "environment/tfstate"
    region = "us-east-1"
  }
}