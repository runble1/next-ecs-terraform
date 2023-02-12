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
  backend "s3" {
    profile = "terraform"
    region  = "ap-northeast-1"
    bucket  = "657885203613-tfstate"
    key     = "zenn-next/next"
    encrypt = true
  }
}
