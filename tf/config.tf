provider "aws" {
  version = ">= 2.28.0"
  region  = "ap-northeast-1"
}

terraform {
  required_version = ">= 0.12.8"

  backend "s3" {
    bucket  = "jitsi2020s3"
    key     = "terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = "true"
  }
}
