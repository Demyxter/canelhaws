
resource "aws_acm_certificate" "certificate" {

  domain_name = var.website_url
  validation_method = "DNS"

}

resource "aws_route53_record" "validation" {
  for_each = {
  for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
    name   = dvo.resource_record_name
    record = dvo.resource_record_value
    type   = dvo.resource_record_type
  }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
}

resource "aws_s3_bucket" "bucket" {

  acl = "public-read"
  bucket = var.website_url

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

}


resource "aws_route53_record" "url" {

  name = var.website_url
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
    var.website_url]
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
    domain_name = aws_s3_bucket.bucket.website_endpoint
    origin_id = aws_s3_bucket.bucket.id
  }

  viewer_certificate {

    acm_certificate_arn = aws_acm_certificate.certificate.arn
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
    target_origin_id = aws_s3_bucket.bucket.id
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

  depends_on = [aws_route53_record.validation]

}
