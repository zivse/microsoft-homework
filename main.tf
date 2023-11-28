terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.aks_subscription_id
  tenant_id       = var.aks_tenant_id
  client_id       = var.aks_service_principal_app_id
  client_secret   = var.aks_service_principal_client_secret
}

provider "kubernetes" {

  host                   = data.azurerm_kubernetes_cluster.k8s.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
}

provider "kubectl" {
  host                   = data.azurerm_kubernetes_cluster.k8s.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.k8s.kube_config.0.host
    client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
    client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
  }
}

####################################

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name
}


resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix
  tags                = {
    Environment = "microsoft-homework"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_DS2_v2"
    node_count = var.agent_count
  }
  service_principal {
    client_id     = var.aks_service_principal_app_id
    client_secret = var.aks_service_principal_client_secret
  }
}

resource "kubectl_manifest" "service-a" {
  yaml_body  = file("${path.module}/kubernetes_resources/service-a.yaml")
  depends_on = [azurerm_kubernetes_cluster.k8s]
}

resource "kubectl_manifest" "service-a-service" {
  yaml_body  = file("${path.module}/kubernetes_resources/service-a-service.yaml")
  depends_on = [azurerm_kubernetes_cluster.k8s]
}

resource "kubectl_manifest" "service-b" {
  yaml_body  = file("${path.module}/kubernetes_resources/service-b.yaml")
  depends_on = [azurerm_kubernetes_cluster.k8s]
}

resource "kubectl_manifest" "service-b-service" {
  yaml_body  = file("${path.module}/kubernetes_resources/service-b-service.yaml")
  depends_on = [azurerm_kubernetes_cluster.k8s]
}

resource "kubectl_manifest" "network-policy-deny-all" {
  yaml_body  = file("${path.module}/kubernetes_resources/network-policy-deny-all.yaml")
  depends_on = [azurerm_kubernetes_cluster.k8s]
}

resource "kubectl_manifest" "network-policy-b-to-a-allow" {
  yaml_body  = file("${path.module}/kubernetes_resources/network-policy-b-to-a-allow.yaml")
  depends_on = [azurerm_kubernetes_cluster.k8s]
}

resource "helm_release" "ingress" {
  name       = "ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.5.2"
  depends_on = [azurerm_kubernetes_cluster.k8s]
}

resource "kubectl_manifest" "ingress" {
  yaml_body  = file("${path.module}/kubernetes_resources/ingress.yaml")
  depends_on = [helm_release.ingress]
}
