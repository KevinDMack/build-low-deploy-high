terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.34"
    }
  }
}

provider "azurerm" {
  features {}
  environment = "usgovernment"
  use_cli     = true
}
