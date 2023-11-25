data "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.rg.name
}