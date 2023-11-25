variable "agent_count" {
  default = 2
}

variable "aks_service_principal_app_id" {
  default = "239a5b23-xxx"
}

variable "aks_service_principal_client_secret" {
  default = "dVC8Q~-xxx"
}

variable "aks_subscription_id" {
  default = "71ec7bc8-xxx"
}

variable "aks_tenant_id" {
  default = "dda06b3e-xxx"
}

variable "admin_username" {
  default = "demo"
}

variable "cluster_name" {
  default = "demok8s"
}

variable "dns_prefix" {
  default = "demok8s"
}

variable "resource_group_location" {
  default     = "israelcentral"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  default     = "myResourceGroup"
  description = "Resource group name that is unique in your Azure subscription."
}
