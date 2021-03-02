# Repro for [terraform-provider-azurerm issue 8768](https://github.com/terraform-providers/terraform-provider-azurerm/issues/8768)

## Steps

1. `terraform plan` - as expected, no issues
1. `terraform apply` - as expected, no issues
1. `terraform plan -var subs=4` - ⚠️ Terraform does not unset subnet (see below)
1. `terraform apply -var subs=4` - ❌ Error from Azure (see below)

## Incorrect plan

Output of `terraform plan -var subs=4 -out=plan && terraform show -json plan`

```json
{
    "action": "Allow",
    "ip_address": "10.1.0.1/32",
    "name": "whitelist IP",
    "priority": 2000,
    "service_tag": "",
    "subnet_id": "/subscriptions/REDACTED/resourceGroups/rg-repro-tf-ip-restr/providers/Microsoft.Network/virtualNetworks/vnet-repro-tf-ip-restr/subnets/sn-4-repro-tf-ip-restr",
    "virtual_network_subnet_id": "/subscriptions/REDACTED/resourceGroups/rg-repro-tf-ip-restr/providers/Microsoft.Network/virtualNetworks/vnet-repro-tf-ip-restr/subnets/sn-4-repro-tf-ip-restr"
}
```

The properties `subnet_id` and `virtual_network_subnet_id` should be empty here.

## Error message

```
Error: web.AppsClient#CreateOrUpdate: Failure sending request: StatusCode=0 -- Original Error: Code="BadRequest" Message="IpSecurityRestriction is invalid.  Only IpAddress or VnetSubnetResourceId property must be specified." Details=[{"Message":"IpSecurityRestriction is invalid.  Only IpAddress or VnetSubnetResourceId property must be specified."},{"Code":"BadRequest"},{"ErrorEntity":{"Code":"BadRequest","ExtendedCode":"51021","Message":"IpSecurityRestriction is invalid.  Only IpAddress or VnetSubnetResourceId property must be specified.","MessageTemplate":"{0} is invalid.  {1}","Parameters":["IpSecurityRestriction","Only IpAddress or VnetSubnetResourceId property must be specified."]}}]
```

````json
[
  {
    "Message": "IpSecurityRestriction is invalid.  Only IpAddress or VnetSubnetResourceId property must be specified."
  },
  {
    "Code": "BadRequest"
  },
  {
    "ErrorEntity": {
      "Code": "BadRequest",
      "ExtendedCode": "51021",
      "Message": "IpSecurityRestriction is invalid.  Only IpAddress or VnetSubnetResourceId property must be specified.",
      "MessageTemplate": "{0} is invalid.  {1}",
      "Parameters": [
        "IpSecurityRestriction",
        "Only IpAddress or VnetSubnetResourceId property must be specified."
      ]
    }
  }
]
````
