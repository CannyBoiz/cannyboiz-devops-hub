# cannyboiz-devops-hub

Infrastructure for the Fleet of VPSs we run and the Projects deployed onto them.

## Language

**VPS**:
A server we own that runs the Gateway and Project containers, known by one name everywhere (e.g. **alpha**).
_Avoid_: server, host, box, my-first-vps

**Fleet**:
Every VPS managed from this repo.
_Avoid_: cluster, servers, infra

**Project**:
An application, built in its own repo, that deploys onto exactly one VPS (e.g. respawn, ez-dk-citizen).
_Avoid_: app, service, site

**Project infra**:
Cloud resources owned by a single Project outside any VPS (e.g. ez-dk-citizen's S3 bucket and IAM roles).
_Avoid_: project terraform, application infra

**Gateway**:
The shared reverse proxy on a VPS. It routes traffic to Projects and holds no Project-specific routes. Every VPS runs the same Gateway.
_Avoid_: proxy, Caddy (as the concept)

**Site snippet**:
A Project's routing fragment that the Gateway loads.
_Avoid_: vhost, route file
