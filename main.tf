// Tags
locals {
  tags = {
    owner       = var.tag_department
    region      = var.tag_region
    environment = var.environment
  }
}

// Existing Resources

/// Subscription ID

data "azurerm_subscription" "current" {
}

// Random Suffix Generator

resource "random_integer" "deployment_id_suffix" {
  min = 100
  max = 999
}

// Resource Group

resource "azurerm_resource_group" "rg" {
  name     = "${var.class_name}-${var.student_name}-${var.environment}-${random_integer.deployment_id_suffix.result}-rg"
  location = var.location

  tags = local.tags
}


// Storage Account

resource "azurerm_storage_account" "storage" {
  name                     = "${var.class_name}${var.student_name}${var.environment}${random_integer.deployment_id_suffix.result}st"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.tags
}

// CosmosDB

resource "azurerm_cosmosdb_account" "db" {
  name                = "${var.class_name}${var.student_name}$${var.environment}${random_integer.deployment_id_suffix.result}-db"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  offer_type          = "Standard"
  kind                = "MongoDB"
}

// TODO: Machine Learning Workspace

resource "azurerm_application_insights" "insights" {
  name                = "${var.class_name}${var.student_name}$${var.environment}${random_integer.deployment_id_suffix.result}-insights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

resource "azurerm_key_vault" "kv" {
  name                = "${var.class_name}${var.student_name}$${var.environment}${random_integer.deployment_id_suffix.result}-kv"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_subscription.current.tenant_id
  sku_name            = "premium"
}

resource "azure_machine_learning_workspace" "ml" {
  name                    = "${var.class_name}${var.student_name}$${var.environment}${random_integer.deployment_id_suffix.result}-ml"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  application_insights_id = azurerm_application_insights.insights.name
  key_vault_id            = azurerm_key_vault.kv.name
  storage_account_id      = azurerm_storage_account.storage.name

  identity {
    type = "SystemAssigned"
  }
}

// Maps Account

resource "azurerm_maps_account" "map" {
  name                = "${var.class_name}${var.student_name}$${var.environment}${random_integer.deployment_id_suffix.result}-map"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Map1"

  tags = local.tags
}

// Public IP Address

resource "azurerm_public_ip" "pip" {
  name                = "${var.class_name}${var.student_name}$${var.environment}${random_integer.deployment_id_suffix.result}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"

  tags = local.tags
}