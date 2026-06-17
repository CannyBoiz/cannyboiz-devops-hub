terraform {
  required_providers {
    # Hetzner Cloud provider for managing Hetzner resources
    hetzner = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
    #Cloudflare provider for managing Cloudflare resources
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# ---------- Hetzner Configs ----------

# SSH key for manually accessing the server, you can generate this with `ssh-keygen` and then add the public key here
resource "hcloud_ssh_key" "main" {
  name = "main-ssh-key"
  public_key = file("~/.ssh/hetzner_first_cx23.pub")
}

# CI/CD public key 
resource "hcloud_ssh_key" "ci_cd" {
  name = "ci-cd-ssh-key"
  public_key = file("~/.ssh/github_key.pub")
}

# Firewall to allow necessary ports
resource "hcloud_firewall" "myfirewall" {
    name = "my-firewall"

    # RabbitMQ (5672)
    rule {
      direction = "in"
      protocol = "tcp"
      port = "5672"
      source_ips = ["0.0.0.0/0", "::/0"]
    }

    # SSH (22)
    rule {
      direction = "in"
      protocol = "tcp"
      port = "22"
      source_ips = ["0.0.0.0/0", "::/0"]
    }

    # HTTP (80)
    rule {
      direction = "in"
      protocol = "tcp"
      port = "80"
      source_ips = ["0.0.0.0/0", "::/0"]
    }

    # HTTPS (443)
    rule {
      direction = "in"
      protocol = "tcp"
      port = "443"
      source_ips = ["0.0.0.0/0", "::/0"]
    }
}

resource "hcloud_server" "myfirstvps" {
  name        = "my-first-vps"
  image       = "ubuntu-22.04"
  server_type = "cx23"
  location    = "nbg1"
  ssh_keys    = [hcloud_ssh_key.main.id, hcloud_ssh_key.ci_cd.id]
  firewall_ids = [hcloud_firewall.myfirewall.id]
}