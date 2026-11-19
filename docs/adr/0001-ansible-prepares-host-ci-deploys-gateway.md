# Ansible prepares the VPS; CI deploys the Gateway

Status: superseded by ADR 0002

Ansible (`alpha/ansible/`) owns host setup on a VPS: system packages, Docker, the shared `caddy_net` network, and the `/opt/caddy`, `/opt/caddy/sites` and `/opt/<project>` directories. Deploying the Gateway stays with the existing GitHub Actions workflow (copy files to `/opt/caddy`, run `deploy.sh`), and each Project keeps deploying itself. We kept the split because the pipeline already works and Project repos depend on its paths. Moving Gateway deploys into Ansible would replace a working pipeline for no gain while Ansible is still run by hand from a laptop.

## Consequences

- `deploy.sh` keeps its own `mkdir -p sites` and `docker network create`, so it still works on a host Ansible hasn't touched. The overlap is deliberate.
- If CI later runs Ansible, revisit whether the Gateway deploy should move into it.
