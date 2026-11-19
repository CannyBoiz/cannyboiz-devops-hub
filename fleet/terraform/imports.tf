# State is local and Git-ignored, so a fresh checkout starts with none. These
# blocks adopt the live resources instead of recreating them; they are no-ops
# once the resources are in state. IDs from `hcloud ssh-key list`,
# `hcloud firewall list` and `hcloud server list`.

import {
  to = hcloud_ssh_key.main
  id = "132540841"
}

import {
  to = hcloud_ssh_key.ci_cd
  id = "132540840"
}

import {
  to = hcloud_firewall.fleet
  id = "10920842"
}

import {
  to = hcloud_server.vps["alpha"]
  id = "128869349"
}
