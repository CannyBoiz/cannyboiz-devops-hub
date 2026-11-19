set shell := ["bash", "-cu"] # `fleet` needs bash's printf %q

# Absolute path to your local clone of the secrets repo, set in ~/.bashrc; deliberately no default, so this public repo never names it.
secrets_repo := env("SECRETS_REPO", "")
secrets_repo_help := "SECRETS_REPO is not set. Point it at your local clone of the secrets repo (the clone is made there if missing), then rerun:\n  echo 'export SECRETS_REPO=/absolute/path/to/your/secrets-repo-clone' >> ~/.bashrc && source ~/.bashrc\nOne command only: SECRETS_REPO=/absolute/path/to/your/secrets-repo-clone just <recipe>"

default:
  @just --list

# decrypt this repo's Secret files from the secrets repo into place (clones it on first run)
export-secret:
  #!/usr/bin/env bash
  set -euo pipefail
  repo={{quote(secrets_repo)}}
  [[ -n $repo ]] || { printf '%s\n' {{quote(secrets_repo_help)}} >&2; exit 1; }
  if [[ -d $repo/.git ]]; then
    git -C "$repo" pull --ff-only
  else
    # URL built at runtime from this repo's owner and the folder name, so it is never written in this public repo
    owner=$(git remote get-url origin | sed -E 's#.*[:/]([^/]+)/[^/]+$#\1#')
    git clone "git@github.com:$owner/$(basename "$repo").git" "$repo"
    just -f "$repo/justfile" setup
  fi
  restore() { just -f "$repo/justfile" restore "$1" "$2"; }
  restore cannyboiz-devops-hub/ssh/hcloud_alpha.enc {{quote(home_directory() / ".ssh/hcloud_alpha")}}
  restore cannyboiz-devops-hub/ssh/ci_cd_alpha.enc {{quote(home_directory() / ".ssh/ci_cd_alpha")}}

# run a command from the current directory with the Fleet's secrets in its environment only, e.g. `cd fleet/terraform && just fleet terraform plan`
[no-cd]
[positional-arguments]
fleet +cmd:
  @[[ -n {{quote(secrets_repo)}} ]] || { printf '%s\n' {{quote(secrets_repo_help)}} >&2; exit 1; }
  @sops exec-env {{quote(secrets_repo / "cannyboiz-devops-hub/fleet.sops.env")}} "$(printf '%q ' "$@")"
