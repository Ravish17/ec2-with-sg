terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    tls = {
      source = "hashicorp/tls"
      version = "4.0.2"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
