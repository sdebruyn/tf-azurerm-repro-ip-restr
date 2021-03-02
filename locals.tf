locals {
  whitelisted_subnets = [for s in azurerm_subnet.subs : s.id]
  whitelisted_ips     = [for i in range(var.ips) : "10.1.0.${i + 1}/32"]

  ip_restriction_subnets = [for v in local.whitelisted_subnets : {
    name                      = "whitelist subnet"
    ip_address                = null
    virtual_network_subnet_id = v
    subnet_id                 = v
    service_tag               = null
    priority                  = 2000
    action                    = "Allow"
  }]

  ip_restriction_ips = [for v in local.whitelisted_ips : {
    name                      = "whitelist IP"
    ip_address                = v
    virtual_network_subnet_id = null
    subnet_id                 = null
    service_tag               = null
    priority                  = 2000
    action                    = "Allow"
  }]

  ip_restriction_all = concat(local.ip_restriction_subnets, local.ip_restriction_ips)
}
