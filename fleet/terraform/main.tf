locals {
  # One entry per VPS in the Fleet. Changing image on a live VPS forces a rebuild.
  fleet = {
    alpha = {
      server_type = "cx23"
      location    = "nbg1"
      image       = "ubuntu-26.04"
    }
  }
}

# Operator key for manual SSH access
resource "hcloud_ssh_key" "main" {
  name       = "main-ssh-key"
  public_key = file("~/.ssh/hcloud_alpha.pub")
}

# Fleet CI key (the SSH_PRIVATE_KEY secret)
resource "hcloud_ssh_key" "ci_cd" {
  name       = "ci-cd-ssh-key"
  public_key = file("~/.ssh/ci_cd_alpha.pub")
}

resource "hcloud_firewall" "fleet" {
  name = "firewall-1"

  # SSH (22)
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # HTTP (80)
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # HTTPS (443)
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_server" "vps" {
  for_each = local.fleet

  name         = each.key
  server_type  = each.value.server_type
  location     = each.value.location
  image        = each.value.image
  ssh_keys     = [hcloud_ssh_key.main.id, hcloud_ssh_key.ci_cd.id]
  firewall_ids = [hcloud_firewall.fleet.id]

  # The Ansible inventory selects the Fleet by this label
  labels = {
    fleet = "cannyboiz"
  }

  lifecycle {
    # Keys only apply at create/rebuild, and import can't read them back, so a diff here would force a rebuild
    ignore_changes = [ssh_keys]
  }
}
