provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      Env    = "dev"
      System = "nextjs"
    }
  }
}

terraform {
  required_version = ">= 1.3.8"
  required_providers {
    aws = "5.22.0"
  }
  backend "s3" {
    region  = "ap-northeast-1"
    bucket  = "runble1-tfstate"
    key     = "next-ecs-terraform/infra/terraform.tfstate"
    encrypt = true
  }
}
