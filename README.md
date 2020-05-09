# AWS Certificate Manager (ACM) Terraform module for multiple domains

Terraform module which creates ACM certificates and validates them using Route53 DNS (recommended) or e-mail.
This module can create wildcard certificates for multiple domains in different hosted zones. 

## Terraform versions

Terraform 0.12. 

## Usage with Route53 DNS validation (recommended)

```hcl
module "acm-multi1" {
  source  = "bazzuka/multi/acm"
  version = "1.0.0"

  domains_list = [{ domain_name = "dev.domain.com", zone_name = "dev.domain.com" },
                  { domain_name = "preview.domain.com", zone_name = "preview.domain.com" }]
  create_certificate  = true
  wait_for_validation = true

  tags = {
    Terraform = true
  }
}
```

## Examples

* [ Example with DNS validation (recommended)](https://github.com/bazzuka/terraform-acm-multi/tree/master/examples/dns-validation)

## Conditional creation and validation

Sometimes you need to have a way to create ACM certificate conditionally but Terraform does not allow to use `count` inside `module` block, so the solution is to specify argument `create_certificate`.

```hcl
module "acm-multi1" {
  source  = "bazzuka/multi/acm"
  version = "1.0.0"

  create_certificate = false
  # ... omitted
}
```

Similarly, to disable DNS validation of ACM certificate:

```hcl
module "acm-multi1" {
  source  = "bazzuka/multi/acm"
  version = "1.0.0"

  validate_certificate = false
  # ... omitted
}
```

## Notes

* For use in an automated pipeline consider setting the `wait_for_validation = false` to avoid waiting for validation to complete or error after a 45 minute timeout.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| create\_certificate | Whether to create ACM certificate | bool | `"true"` | no |
| domains\_list | List of maps with domains and zone ids  | list | `[]` | no |
| tags | A mapping of tags to assign to the resource | map(string) | `{}` | no |
| validate\_certificate | Whether to validate certificate by creating Route53 record | bool | `"true"` | no |
| validation\_allow\_overwrite\_records | Whether to allow overwrite of Route53 records | bool | `"true"` | no |
| validation\_method | Which method to use for validation. DNS or EMAIL are valid, NONE can be used for certificates that were imported into ACM and then into Terraform. | string | `"DNS"` | no |
| wait\_for\_validation | Whether to wait for the validation to complete | bool | `"true"` | no |

## Outputs

| Name | Description |
|------|-------------|
| certificate\_arns | The ARN of the certificates mapped to domains |

