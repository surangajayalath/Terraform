resource "azurerm_resource_group" "my_resource_group" {
  name     = "my_resource_group"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "email_alert" {
  name                = "email-alert"
  resource_group_name = azurerm_resource_group.my_resource_group.name
  short_name          = "email"

   email_receiver {
    name                    = "sendtoadmin"
    email_address           = "surangajayalath299@gmail.com"
    use_common_alert_schema = true
  }
}

resource "azurerm_consumption_budget_resource_group" "mybudget" {
  name              = "mybudget"
  resource_group_id = azurerm_resource_group.my_resource_group.id

  amount     = 1 # in USD
  time_grain = "Monthly"

  time_period {
    start_date = "2022-06-01T00:00:00Z"
    end_date   = "2022-07-01T00:00:00Z"
  }

  notification {
    enabled        = true
    threshold      = 70.0
    operator       = "EqualTo"
    threshold_type = "Forecasted"

    contact_groups = [
      azurerm_monitor_action_group.email_alert.id
    ]

  }
}