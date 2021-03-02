provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  location = var.region
  name     = "rg-${var.name}"
}

resource "azurerm_virtual_network" "vnet" {
  address_space       = ["10.0.0.0/16"]
  location            = var.region
  name                = "vnet-${var.name}"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subs" {
  count                = var.subs
  name                 = "sn-${count.index}-${var.name}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  service_endpoints    = ["Microsoft.Web"]
  address_prefixes     = ["10.0.${count.index}.0/24"]
}

resource "azurerm_app_service_plan" "asp" {
  location            = var.region
  name                = "asp-${var.name}"
  resource_group_name = azurerm_resource_group.rg.name
  reserved            = true
  kind                = "Linux"
  sku {
    size = "B1"
    tier = "Basic"
  }
}

resource "azurerm_app_service" "app" {
  name                = "as-${var.name}"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.asp.id

  site_config {
    app_command_line            = ""
    linux_fx_version            = "DOCKER|appsvcsample/python-helloworld:latest"
    scm_use_main_ip_restriction = true

    dynamic "ip_restriction" {
      for_each = local.ip_restriction_all != null ? local.ip_restriction_all : []
      content {
        name                      = ip_restriction.value["name"]
        priority                  = ip_restriction.value["priority"]
        virtual_network_subnet_id = ip_restriction.value["subnet_id"]
        ip_address                = ip_restriction.value["ip_address"]
        action                    = ip_restriction.value["action"]
      }
    }
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = "https://index.docker.io"
  }
}
