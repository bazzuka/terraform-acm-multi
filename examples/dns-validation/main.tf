locals {
    ssl_domains = [
        { domain_name = "dev.domain.com", zone_name = "dev.domain.com" },
        { domain_name = "preview.domain.com", zone_name = "preview.domain.com" }
    ]
    tags = {
      Terraform = true
    }
}

module "acm-multi" {
  source  = "../../"

  domains_list = local.ssl_domains
  create_certificate  = true
  wait_for_validation = true

  tags = local.tags
}