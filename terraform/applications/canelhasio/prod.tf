terraform {

  backend "remote" {
    hostname = "app.terraform.io"
    organization = "canelhas"

    workspaces {
      name = "canelhasio"
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.10"

    }

  }


}

provider "aws" {
  profile = "default"
  region = "us-east-1"
}

locals {
  zone_id = "Z0888034268Y5H2AZ7G9U"
  certificate_id = "1e7cb229-a84b-4391-90d8-12ad05e250bb"
  website_url = "mateus.canelhas.io"
}

module "website-stage" {
  source = "./modules/s3_website"
  zone_id = local.zone_id
  website_url = local.website_url
}


