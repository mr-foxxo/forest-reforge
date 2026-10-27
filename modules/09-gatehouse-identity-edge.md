# 09 · Gatehouse — identity and external access

Automation: `gatehouse`, `trails`, `backstage` and `edge` configure TLS, separate identities and the Backstage-first tunnel. Follow the [integration prerequisites and rejection tests](../docs/automation.md).

## Baseline

GitHub organization membership supplies the human directory. Cloudflare Access gates the published application. Backstage signs users in through its own GitHub provider and maps them to catalog users. These are separate layers; a successful edge login is not sufficient application authorization.

Only Backstage is initially published. Argo CD, Grafana, Hubble, Kubernetes API, hypervisors and BMCs remain private. wg-admin cannot administer OpenWrt; paws retains the higher-trust path.

## External setup

1. Confirm the GitHub organization and teams. Use narrow membership-based policies and test with a member and a non-member.
2. Configure the GitHub identity provider in Cloudflare Access using the exact callback URL supplied by the service. Store secrets outside Git.
3. Create an Access application for the selected Backstage browser hostname before enabling public routing. Use explicit Allow policies; avoid public bypass.
4. Create a named, remotely managed Tunnel and keep its token in the bootstrap secret authority.
5. Configure only the Backstage public hostname to the private Gateway HTTPS origin, e.g. `https://172.16.3.200`.
6. Set origin TLS server name to the certificate hostname and the HTTP Host header to the HTTPRoute hostname as needed. Keep origin certificate verification enabled. An IP service URL does not mean the certificate must contain that IP if the origin server name is explicitly configured.
7. Verify edge certificate coverage for the chosen deep hostname independently of origin certificate coverage.

## Kubernetes connector

Ansible owns the bootstrap namespace/token Secret; Argo owns the connector Deployment and policy. Pin the image digest and fixed metrics endpoint. The source uses:

```text
cloudflared tunnel --no-autoupdate --loglevel info --metrics 0.0.0.0:2000 run
```

Supply `TUNNEL_TOKEN` from a Secret, never in Git or an echoed command. Use the selected image's documented readiness probe at the fixed endpoint. Restrict egress to DNS, required Cloudflare tunnel endpoints/port 7844 TCP/UDP, and Gateway TCP 443; add only justified control-plane dependencies for the selected configuration. Spread replicas across available failure domains.

Do not create a second Deployment definition under a recursively synced Argo path. A duplicate stale file can undo a manual fix. Commit the fix to the authoritative path, then verify the live args and rollout.

## Backstage identity

Build the app with the GitHub auth module and GitHub organization provider. Prefer `userIdMatchingUserEntityAnnotation` and ensure catalog users carry the matching immutable identity annotation. Import users/teams independently of login. Keep guest sign-in disabled in production and enable the permission framework for actual authorization.

Cloudflare identity headers must only be trusted when verified against the expected issuer/audience or by a configured validating component. Do not trust arbitrary client-supplied headers. Private access still requires application auth even when it bypasses the edge.

## Infrastructure SSO option

Keycloak/OIDC federation was discussed for Proxmox and broader mobile access; it is not a deployed prerequisite in the later baseline. If adopted, create a separate ADR covering provider account linking, immutable subject mapping, MFA, group→role mappings, logout/session behavior and recovery during identity-provider outage. GitHub OAuth is not automatically a generic OIDC provider for every service. Preserve independent local recovery credentials.

## Acceptance

From an external network: valid member reaches Backstage; outsider is denied; removed membership loses access after applicable refresh/session expiry; application permissions restrict write actions; direct private-origin access still needs app identity; unconfigured hostnames do not publish an app. Verify private admin services have no tunnel hostnames or WAN DNAT.

If registered tunnel connections coexist with pod restart loops, inspect probe binding and duplicate GitOps objects before rotating the token. A QUIC receive-buffer warning is not by itself proof of tunnel authentication failure.

References: [Cloudflare origin parameters](https://developers.cloudflare.com/tunnel/reference/origin-parameters/), [Backstage GitHub auth](https://backstage.io/docs/auth/github/provider/).
