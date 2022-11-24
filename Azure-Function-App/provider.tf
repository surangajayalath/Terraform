terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.32.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  subscription_id = "6df807e8-71ea-477c-ae68-9de1c9532ea7"
  client_id       = "f4f7739e-455b-4312-ba04-daf49ae608f1"
  client_secret   = ".UZ8Q~C71BoSmCMa-AeNrbe~xtCW30kUu26gQc1t"
  tenant_id       = "bff85237-7216-4a7e-9167-1df1e116474f"
  features {} 
}