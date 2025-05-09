terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.26.0"
    }
  }

  required_version = ">= 1.11.0"
}

provider "azurerm" {
  subscription_id = var.subscription_id

  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_service_plan" "plan" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"

  # free tier configuration
  sku_name                     = "F1"
  maximum_elastic_worker_count = 1
  per_site_scaling_enabled     = false
}

resource "azurerm_linux_web_app" "app" {
  name                = var.app_service_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id

  https_only = true

  logs {
    application_logs {
      file_system_level = "Information"
    }

    http_logs {
      file_system {
        retention_in_days = 2
        retention_in_mb   = 35
      }
    }

    detailed_error_messages = true
    failed_request_tracing  = true
  }

  site_config {
    always_on = false

    application_stack {
      docker_image_name   = "${var.docker_owner}/${var.docker_image}:${var.docker_tag}"
      docker_registry_url = "https://ghcr.io"
    }
  }

  app_settings = {
    DATABASE_URL        = var.database_url
    DATABASE_AUTH_TOKEN = var.database_auth_token
    KASSALAPP_API_KEY   = var.kassalapp_api_key
  }
}

resource "azurerm_app_service_custom_hostname_binding" "bitehabits_custom_domain" {
  hostname            = "bitehabits.com"
  app_service_name    = azurerm_linux_web_app.app.name
  resource_group_name = azurerm_linux_web_app.app.resource_group_name
}
