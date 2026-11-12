# Caddy is the Gateway on every VPS, HTTP(S) only

Every VPS in the Fleet runs the same Gateway: Caddy, from the official image, handling HTTP and HTTPS only. The contract with Projects is a Caddyfile Site snippet dropped into `/opt/caddy/sites`, plus joining the `caddy_net` Docker network. That contract is where Caddy really locks us in, because switching Gateway tech (to Traefik, say) means rewriting every Project's Site snippet. The cost of that grows with each Project.

We accepted that trade-off because TCP is rare for our Projects. A Project that does need public TCP or UDP publishes its own port, with a matching firewall rule, and skips the Gateway. Plain TCP carries no hostname, so it needs one port per service whichever proxy we use. Internal services, such as a message broker, never get a public port. They're reachable only on a private Docker network.

## Considered Options

- **Traefik**, which has native TCP and UDP routers. Rejected for now: it only pays off for TLS-wrapped TCP, where SNI lets several services share one port, and no Project needs that.
- **Caddy with the `caddy-l4` plugin.** Rejected: it needs a custom-built image for a need we don't have.
- **A Gateway kind chosen per VPS.** Rejected: that's a second Gateway definition to maintain, with no VPS that needs it.

## Revisit when

Several Projects need TLS-wrapped TCP on shared ports, or a VPS needs something Caddy can't do.
