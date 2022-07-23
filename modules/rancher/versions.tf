terraform {
  required_version = ">= 1.0.0"

  required_providers {
    rancher2 = {
      source = "rancher/rancher2"
      version = "1.24.0"
    }
  }
}