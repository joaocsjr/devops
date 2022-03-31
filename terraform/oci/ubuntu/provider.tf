terraform {
  required_providers {
    oci = {
      source = "hashicorp/oci"
    }
  }
}

provider "oci" {
  region              = "sa-vinhedo-1"
  auth                = "SecurityToken"
  config_file_profile = "DEFAULT"
}
