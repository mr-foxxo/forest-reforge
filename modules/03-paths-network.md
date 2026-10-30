# 03 · Paths — physical segmentation and WireGuard

[English (default)](03-paths-network.md) | [Português (Brasil)](../docs/pt-BR/modules/03-paths-network.md) | [Documentation index](../docs/README.md)

## Proposed canonical map

| BPi port | Zone | Example subnet | Connection |
|---|---|---|---|
| lan1 | clients | 172.16.1.0/24 | Office switch/media converter |
| lan2 | oob | 172.16.2.0/24 | BMC switch |
| lan3 | servers | 172.16.3.0/24 | Host and core node switch |
| lan4 | vms | 172.16.4.0/24 | Other VM/workload switch |
| WAN/LAN copper | infra | 172.16.5.0/24 | dns01 Raspberry Pi |
| SFP1/SFP2 | wan | ISP-specific | Independent WAN paths |
| wg0 | wg-admin | 172.16.250.0/24 | Human administrators |
| Separate WG interface | wg-paws-access | Private inventory value | Owner's highest-trust access |

Every physical-zone gateway is `.1`; DHCP is `.100–.150`. The paws subnet is not confirmed in the history; the site contract offers a clearly labeled new example. Validate actual OpenWrt logical-device mapping before applying changes: port labels are not guaranteed UCI names across firmware versions.

## Access matrix

| Source | Router-local management | dns01 172.16.5.53 | Platform/hosts | OOB |
|---|---|---|---|---|
| wg-paws-access | Allow | All services | Explicit owner policy | Explicit owner policy |
| wg-admin | Deny on ALL router IPs | DNS TCP/UDP 53; other grants explicit | Required admin ports/targets | Selected BMCs only |
| clients | Deny by default | DNS only where needed | Selected apps | Deny |
| workloads | Deny | DNS as required | Application dependencies | Deny |
| Cloudflare connector | Deny | DNS as required | Gateway 443 only + required external egress | Deny |
| WAN | No management | No resolver exposure | No origin HTTP DNAT | Deny |

WireGuard handshake traffic on the WAN is separate from management of OpenWrt through a tunnel. Denying wg-admin router input must not block the router's WAN WireGuard listener.

## Configure without locking yourself out

1. Establish an independent local/paws recovery session and back up network/firewall configuration privately.
2. Inspect `uci show network`, `uci show firewall`, `ip -br address`, `ip route` and the generated ruleset. Do not publish these outputs unredacted.
3. Map each logical interface to exactly its intended firewall zone. Remove unintended inter-zone bridges after checking the physical wiring.
4. Set conservative zone input/forward defaults, then explicit allow rules. Router-local INPUT and routed FORWARD are different paths.
5. Create paws input allowance and host-specific forwarding to dns01. Remove broad wg-admin→router ACCEPT rules. A router may be reachable at every zone address; blocking one IP is insufficient.
6. Give human peers only required AllowedIPs, DNS and destinations, and enforce the same scope in firewall rules. AllowedIPs alone is not application authorization.
7. Validate candidate firewall syntax (`fw4 check` where supported), inspect generated rules, commit/reload from the recovery session and retest from independent clients.
8. Confirm paws access still works and wg-admin fails to reach router SSH/LuCI on all router addresses. Test TCP and UDP DNS plus allowed service ports.
9. If any gate fails, restore the saved configuration through the recovery path before further edits.

No universal destructive UCI rewrite is included: actual section names, bridges and existing rule order were not supplied. [The UCI rule pattern](../examples/openwrt-rules.md) shows the narrow additions to adapt after inspection.

## Routing checks

Remote peers need routes for desired private subnets and a return route to their tunnel subnet. Private DNS must be configured on the peer and allowed in the firewall. Start with IP reachability, then DNS and TLS. Test PMTU if small requests work but larger transfers hang; do not guess a universal MTU.

Keep pod/service CIDRs disjoint from LAN, VPN and AWS networks. Decide whether AWS needs pod CIDR routes or observes node-SNAT traffic and write the corresponding return routes/security rules.
