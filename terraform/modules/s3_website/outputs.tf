output "distribution_domain" {
  value = aws_cloudfront_distribution.cloudfront.domain_name
}

output "distribution_zone" {
  value = aws_cloudfront_distribution.cloudfront.hosted_zone_id
}
