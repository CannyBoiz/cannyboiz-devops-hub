# The read-write token lives in ../.env:
#   set -a; . ../.env; set +a; terraform plan
terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

provider "hcloud" {}
