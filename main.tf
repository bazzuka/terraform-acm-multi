locals {
  zone_ids = { 
    for zone in data.aws_route53_zone.this :
      (trimsuffix(zone.name, ".")) => zone.id  
  }
  domain_2_certarn = {
    for cert in aws_acm_certificate.this :
      (cert.domain_name) => cert.arn
  }
  validation_certarn_2_fqdns = flatten([
    for cert in aws_acm_certificate.this :
      [ 
      for record in aws_route53_record.validation :
        { "certificate_arn" = cert.arn 
          "validation_record_fqdns" = [ record.fqdn ] }
        if contains(values(cert), join(".", slice(split(".", record.fqdn), 1, 4)))
      ]
  ])
  validation_domains = flatten([
     for opts in aws_acm_certificate.this.*.domain_validation_options : 
     [
      for value in opts :
        value
        if contains(values(value), replace(value["domain_name"], "*.", ""))
     ]
  ])
}

resource "aws_acm_certificate" "this" {
  count = var.create_certificate && var.validation_method == "DNS" ? length(var.domains_list) : 0

  domain_name               = var.domains_list[count.index]["domain_name"]
  subject_alternative_names = ["*.${var.domains_list[count.index]["domain_name"]}"]
  validation_method         = var.validation_method

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "this" {
  count = var.create_certificate && var.validation_method == "DNS" && var.validate_certificate ? length(var.domains_list) : 0
  
  name = var.domains_list[count.index]["zone_name"]
  private_zone = false
}

resource "aws_route53_record" "validation" {
  count = var.create_certificate && var.validation_method == "DNS" && var.validate_certificate ? length(local.validation_domains) : 0

  zone_id = local.zone_ids[local.validation_domains[count.index]["domain_name"]]
  name    = local.validation_domains[count.index]["resource_record_name"]
  type    = local.validation_domains[count.index]["resource_record_type"]
  ttl     = 60

  records = [
    local.validation_domains[count.index]["resource_record_value"]
  ]

  allow_overwrite = var.validation_allow_overwrite_records

  depends_on = [aws_acm_certificate.this]
}

resource "aws_acm_certificate_validation" "this" {
  count = var.create_certificate && var.validation_method == "DNS" && var.validate_certificate && var.wait_for_validation ? length(local.validation_certarn_2_fqdns) : 0

  certificate_arn = local.validation_certarn_2_fqdns[count.index]["certificate_arn"]

  validation_record_fqdns = local.validation_certarn_2_fqdns[count.index]["validation_record_fqdns"]
}