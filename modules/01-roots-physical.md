# 01 · Roots — physical datacenter

[English (default)](01-roots-physical.md) | [Português (Brasil)](../docs/pt-BR/modules/01-roots-physical.md) | [Documentation index](../docs/README.md)

**Status:** topology and hardware families are source-reported; rack construction details are a proposed reproducible procedure. No dimensions, cutting list, photographs, breaker ratings or measured loads were supplied.

## Before building the rack

Inventory chassis dimensions and mass, rail part numbers and supported depth, shelf ratings, front/rear service clearance, intake/exhaust direction, room temperature, cable bend radius, and access to the isolation switch. A 19-inch equipment width does not establish usable rack depth or load capacity.

For a custom frame, document material, joints, bracing, anti-tip anchoring, static/dynamic load rating and earth bonding with a competent fabricator/electrician. Do not invent a timber cut list or reuse an unrated shelf for a heavy rack server. Keep batteries and the heaviest equipment low. Check doorways and floor loading before assembly.

## Assembly procedure

1. Photograph the empty location and mark service clearances. Record rack units and usable depth.
2. Level and secure the rack according to its manufacturer or engineered design.
3. Fit rated rails/shelves. Test locks and support before inserting the chassis; use adequate lifting help.
4. Place UPS/PDU and heavy hosts low, network patching where accessible, and preserve access to BMC and PSU connectors.
5. Fit blanking panels where necessary to stop hot-air recirculation. Keep exhaust away from intake and room obstructions.
6. Label both ends of every power/network cable before bundling. Use reusable cable ties without crushing cable jackets.
7. Verify protective earth, circuit and PDU suitability with qualified local assistance. Do not open PSUs or improvise mains wiring.
8. Power on one system at a time. Record idle, boot and representative-load power and room/inlet temperatures.
9. Test controlled shutdown and recovery with a disposable workload before relying on the rack.

## Power budget

Nameplate PSU capacity is not measured consumption. Redundant R710 870 W supplies do not imply a constant 1740 W draw. Record wall measurements including losses. Check both W and VA/UPS power factor limits, inrush, circuit derating and battery aging against the selected equipment and local electrical rules.

For planning only: monthly energy in kWh = average wall watts × operating hours / 1000. Use measured idle/load duty cycles. Compare total acquisition, electricity, cooling, maintenance and license cost against replacement hardware. Reuse is a hypothesis to measure, not an automatic efficiency claim.

With redundant supplies, either surviving feed must carry the required load. A/B cables on the same PDU share a failure domain. Document that honestly.

## Passive accelerators

Tesla server cards expect chassis airflow. A desktop fan somewhere nearby is not proof of cooling. Verify the card-specific intake path, duct fit, heatsink cleanliness, fan failure behavior and temperature under a real workload. Preserve chassis pressure and retention. Do not run stress tests unattended until the cooling path has been qualified.

Use the exact board manual for auxiliary power. Similar-looking connectors can have different wiring; never assume a CPU/EPS lead is a GPU lead. P4's lack of auxiliary power does not remove the requirement to verify slot/riser power capacity.

## Physical network

Use one switch per trust segment in the initial design. Label each cable `source-port → destination-port / zone`. Separate the BMC, host management and VM workload paths. Trace cables rather than trusting color alone. Do not join two zone switches to create accidental L2 transit.

Record fiber module compatibility, link speed, power requirements and WAN failover behavior separately. The source map reports two SFP WAN uplinks; no optics/ISP credentials or tested failover timings are supplied.

## Acceptance and rollback

Record load temperatures, throttling flags, wall power, UPS runtime/shutdown results, link errors and acoustic impact. On overheating, instability or power overload, stop the workload and return to the last safe configuration. Complete [the physical worksheet](../examples/physical-build-record.md) before claiming this module reproduced.
