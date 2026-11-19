# Ansible owns Fleet setup and the Gateway deploy

Supersedes ADR 0001.

One Ansible playbook prepares every VPS in the Fleet and deploys the Gateway to them. GitHub Actions runs that playbook on push to `main`, in place of the old scp-and-ssh workflow that targeted a single `SERVER_IP`. The inventory comes from the Hetzner API, filtered by a Fleet label, so a new VPS is picked up without editing the workflow. The Gateway rolls out one VPS at a time and stops at the first failure, so a bad change breaks one VPS rather than the whole Fleet. Projects still deploy themselves.

## Considered Options

- **Keep scp and ssh, looping over VPSs in the workflow** (a matrix with `max-parallel: 1` and `fail-fast`). Rejected: it needs a hardcoded VPS list plus one IP secret per VPS, which duplicates an inventory Ansible already has.
