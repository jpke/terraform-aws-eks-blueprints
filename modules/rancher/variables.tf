variable "name" {}

variable "domain" {}

variable "rancher_version" {
  default = "2.6.6"
}

variable "installRancher" {
  default = false
}

variable "bootstrapPassword" {
  default = "initialRancherAdminPassword"
}