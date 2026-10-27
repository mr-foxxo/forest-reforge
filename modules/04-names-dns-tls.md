# 04 · Names — DNS and TLS

Automation: `names` configures dedicated DNS; `gatehouse` installs DNS-01 TLS and the shared HTTPS Gateway. See the [phase guide](../docs/automation.md).

## Namespace and authority

Use `den.int.example.net` for canonical platform names. Internal dns01 answers private addresses; public authoritative DNS supplies ACME TXT records and the published Backstage tunnel hostname. Split DNS should lead both internal and external browsers to the same application origin name with different network paths.

The source history began with Route 53 DNS-01 and later moved the public parent to Cloudflare. Pick the solver for the zone that is actually authoritative. Moving a website to Cloudflare does not automatically move authoritative DNS; verify delegation.

## Procedure

1. Create private A records for argocd, grafana, hubble and backstage to the example Gateway VIP `172.16.3.200`; create the API record to its distinct VIP.
2. Confirm queries from LAN, human VPN and paws VPN use dns01 and return the intended answers.
3. Inventory public records before a nameserver migration: MX, TXT, DKIM, DMARC, CAA, validation, delegated subdomains, aliases and DNSSEC/DS state. Coordinate DNSSEC changes with the registrar/provider and preserve a rollback export.
4. Install a pinned cert-manager release compatible with the cluster. Start with ACME staging and a scoped DNS API credential.
5. With Cloudflare, use a zone-limited token for DNS Edit / Zone Read. With Route 53, use a scoped IAM role/policy for the hosted zone and required record/change operations.
6. If delegating `_acme-challenge` via CNAME, configure cert-manager to follow that CNAME and grant credentials on the final target zone. Confirm public recursive resolution.
7. Issue a disposable staging certificate; inspect Orders/Challenges without exposing credentials. Fix authority/propagation before trying production.
8. Issue `*.den.int.example.net` in the Gateway namespace, then reference that TLS Secret from its HTTPS listener. Use your real domain in practice.
9. Verify normal hostname validation. Do not accept `curl -k` as proof.

```bash
dig @172.16.5.53 backstage.den.int.example.net A
kubectl get clusterissuer
kubectl -n gateway-system get certificate
kubectl get orders,challenges -A
curl --resolve backstage.den.int.example.net:443:172.16.3.200 \
  https://backstage.den.int.example.net/
```

Private split DNS can hide public challenge records from cert-manager's self-check. Diagnose using authoritative/public resolver queries; explicitly selected recursive resolvers may be needed. Never expose origin port 80 just to solve DNS-01.

## Wildcards and edge TLS

`*.den.int.example.net` does not cover `mgmt.hv01.den.int.example.net` or `api.k8s.den.int.example.net`. The Kubernetes API's kubeadm PKI is also distinct from the web Gateway certificate. Use separate certificates/SANs for OOB and trust management appropriate to old BMCs.

Cloudflare edge TLS and Gateway origin TLS are separate certificates. A deeply nested public hostname may require separate edge certificate coverage; verify the actual Cloudflare certificate and plan. Alternatively choose a public hostname covered by the edge certificate and align application base URL, callback and HTTPRoute accordingly. DNS-01 certificates may expose names in certificate transparency logs.

## ExternalDNS transition

The operational notes explicitly say ExternalDNS is not installed yet. Keep records manually managed until it is deliberately enabled. Use RFC2136 + TSIG restricted to the intended zone, a distinct TXT owner ID and an initial non-destructive/update policy. Verify dry-run output before letting it modify records. Then remove overlapping manual ownership. `sync` can delete records it owns; it is not a harmless default migration switch.

Upstream: [cert-manager DNS-01](https://cert-manager.io/docs/configuration/acme/dns01/) and its [Cloudflare](https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/) / [Route 53](https://cert-manager.io/docs/configuration/acme/dns01/route53/) providers.
