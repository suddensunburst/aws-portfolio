# provider aws
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# tokyo region
provider "aws" {
  region = "ap-northeast-1"
}

# osaka region
provider "aws" {
  alias  = "osaka"
  region = "ap-northeast-3"
}