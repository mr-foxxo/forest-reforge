# OpenWrt rule patterns — inspect and adapt first

These are UCI section patterns, not an executable migration. Replace zone names with inspected names. `wg-paws-access` is a conceptual access plane, not necessarily the zone's literal identifier. The router's paws zone needs input ACCEPT or narrowly enumerated router management services. The human admin zone needs input REJECT except deliberately required router-local functions.

```uci
config rule 'paws_to_dns_host'
    option name 'Paws all services on DNS host'
    option src 'paws'
    option dest 'infra'
    option dest_ip '172.16.5.53'
    option proto 'all'
    option target 'ACCEPT'

config rule 'admin_to_dns'
    option name 'Admin DNS on independent resolver'
    option src 'wgadmin'
    option dest 'infra'
    option dest_ip '172.16.5.53'
    option dest_port '53'
    option proto 'tcp udp'
    option target 'ACCEPT'
```

A blanket `paws → infra` forwarding is broader than the requirement. The first rule intentionally grants every protocol/service to one host. Audit IPv6 separately: equivalent IPv6 reachability needs equally deliberate rules. Ensure preceding broad ACCEPT rules do not defeat the intended wg-admin input restriction.

After adapting and validating rules, run the access matrix in Module 03. A firewall rule's presence does not prove the effective policy.
