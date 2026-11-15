# The read-write HCLOUD_TOKEN comes from the secrets repo and never touches disk:
#   just fleet terraform plan
terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

provider "hcloud" {}
