resource "aws_route53_record" "url" {

  name = var.access_url
  type = "A"
  zone_id = var.zone_id

  alias {
    name = aws_cloudfront_distribution.cloudfront.domain_name
    zone_id = aws_cloudfront_distribution.cloudfront.hosted_zone_id
    evaluate_target_health = true
  }

}


resource "aws_cloudfront_distribution" "cloudfront" {

  http_version = "http2"
  is_ipv6_enabled = true
  enabled = true
  aliases = [
    var.access_url]
  wait_for_deployment = false

  origin {

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2"]
    }
    domain_name = aws_elastic_beanstalk_environment.environment.cname
    origin_id = aws_elastic_beanstalk_environment.environment.id
  }

  viewer_certificate {

    acm_certificate_arn = var.certificate_arn
    ssl_support_method = "sni-only"

  }

  default_cache_behavior {
    allowed_methods = [
      "POST",
      "HEAD",
      "PATCH",
      "DELETE",
      "PUT",
      "GET",
      "OPTIONS"]
    cached_methods = [
      "HEAD",
      "GET"]
    compress = true
    default_ttl = 1
    target_origin_id = aws_elastic_beanstalk_environment.environment.id
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      headers = [
        "*"]
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

}


resource "aws_elastic_beanstalk_environment" "environment" {
  name                = var.environment_name
  tier                = "WebServer"
  application         = var.application_name
  solution_stack_name = "64bit Amazon Linux 2 v3.2.2 running Docker"

  setting {
    namespace = "aws:ec2:instances"
    name      = "InstanceTypes"
    value     = var.instance_type
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }



}

