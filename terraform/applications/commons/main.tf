terraform {

  backend "remote" {
    hostname = "app.terraform.io"
    organization = "canelhas"

    workspaces {
      name = "commons"
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
  profile = "mateus"
  region = "us-east-1"
}


resource "aws_route53_zone" "canelhasio" {
  name = "canelhas.io"

  tags = {
    "name" = "Canelhas.io Zone"
    "owner" = "Shared"
    "resource" = "Zone"
    "service" = "Canelhas.io"
    "stack" = "Network"
    "stage" = "Production"
  }

}

resource "aws_acm_certificate" "canelhasio" {
  domain_name = "canelhas.io"
  validation_method = "DNS"
  subject_alternative_names = [
    "www.canelhas.io",
    "*.canelhas.io"]

  tags = {
    "name" = "Canelhas.io Certificate"
    "owner" = "Shared"
    "resource" = "Certificate"
    "service" = "Canelhas.io"
    "stack" = "Network"
    "stage" = "Production"
  }


}

resource "aws_route53_record" "certificate_validation" {
  name = "_640a284d3fa01ad48a364a0c7aa3bebd.canelhas.io."
  type = "CNAME"
  zone_id = aws_route53_zone.canelhasio.zone_id
  records = [
    "_31c1df5e8aea34583503577ea40f7d7a.rlltrpyzyf.acm-validations.aws."]
  ttl = 300
}