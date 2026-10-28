#!/usr/bin/env python3
"""Read-only aggregate Node evidence; never emit node identities or API addresses."""
import argparse
import json
import re
import subprocess
import sys
from datetime import datetime, timezone
from decimal import Decimal, DecimalException
from pathlib import Path

FACTORS = {"": Decimal(1), "n": Decimal("1e-9"), "u": Decimal("1e-6"),
           "m": Decimal("1e-3"), "k": Decimal(1000), "K": Decimal(1000)}
for power, unit in enumerate("MGTPE", 2):
    FACTORS[unit] = Decimal(1000) ** power
for power, unit in enumerate("KMGTPE", 1):
    FACTORS[unit + "i"] = Decimal(1024) ** power
QUANTITY = re.compile(r"([+]?(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+))([a-zA-Z]*|[eE][+-]?[0-9]+)")
VERSION = re.compile(r"v[0-9]+\.[0-9]+\.[0-9]+(?:[-+][a-zA-Z0-9._-]+)?")
GIB = Decimal(1024) ** 3


def quantity(value):
    match = QUANTITY.fullmatch(str(value))
    if not match:
        raise ValueError("Invalid or negative Kubernetes resource quantity")
    number, suffix = match.groups()
    factor = FACTORS.get(suffix)
    if factor is None:
        if not re.fullmatch(r"[eE][+-]?[0-9]+", suffix):
            raise ValueError("Unknown Kubernetes resource suffix")
        factor = Decimal(10) ** int(suffix[1:])
    result = Decimal(number) * factor
    if not result.is_finite():
        raise ValueError("Non-finite Kubernetes resource quantity")
    return result


def aggregate(document):
    if document.get("kind") not in ("NodeList", "List") or not isinstance(document.get("items"), list) or not document["items"]:
        raise ValueError("Expected a non-empty Kubernetes Node list")
    roles = {role: {"count": 0, "ready": 0, "unschedulable": 0,
                    "capacity": {key: Decimal(0) for key in ("cpu", "memory", "pods")},
                    "allocatable": {key: Decimal(0) for key in ("cpu", "memory", "pods")}}
             for role in ("control_plane", "workers")}
    versions, identities = {}, set()
    for node in document["items"]:
        identity = node["metadata"]["name"]
        if not isinstance(identity, str) or not identity or identity in identities:
            raise ValueError("Missing or duplicate Node identity")
        identities.add(identity)
        labels = node["metadata"].get("labels", {})
        role = "control_plane" if any(key in labels for key in ("node-role.kubernetes.io/control-plane", "node-role.kubernetes.io/master")) else "workers"
        entry = roles[role]
        entry["count"] += 1
        entry["ready"] += any(item.get("type") == "Ready" and item.get("status") == "True" for item in node["status"].get("conditions", []))
        entry["unschedulable"] += bool(node.get("spec", {}).get("unschedulable", False))
        version = node["status"]["nodeInfo"]["kubeletVersion"]
        if not isinstance(version, str) or not VERSION.fullmatch(version):
            raise ValueError("Missing or invalid kubelet version")
        versions[version] = versions.get(version, 0) + 1
        for scope in ("capacity", "allocatable"):
            for key in ("cpu", "memory", "pods"):
                value = quantity(node["status"][scope][key])
                if key == "pods" and value != value.to_integral_value():
                    raise ValueError("Pod capacity must be an integer")
                entry[scope][key] += value
    result = {"node_count": len(identities), "kubelet_versions": versions, "roles": {}}
    for role, entry in roles.items():
        output = {key: entry[key] for key in ("count", "ready", "unschedulable")}
        for scope in ("capacity", "allocatable"):
            output[scope] = {"cpu_cores": float(entry[scope]["cpu"]),
                             "memory_gib": float(entry[scope]["memory"] / GIB),
                             "pods": int(entry[scope]["pods"])}
        result["roles"][role] = output
    return result


def checks(summary, expected=None):
    result = {"all_nodes_ready": all(role["ready"] == role["count"] for role in summary["roles"].values())}
    if expected is None:
        return result
    target = expected["kubernetes"]
    result["expected_node_count"] = summary["node_count"] == target["node_count"]
    result["expected_control_plane_count"] = summary["roles"]["control_plane"]["count"] == target["control_plane_count"]
    result["expected_worker_count"] = summary["roles"]["workers"]["count"] == target["worker_count"]
    result["expected_kubelet_version"] = summary["kubelet_versions"] == {target["kubelet_version"]: summary["node_count"]}
    workers, resources = summary["roles"]["workers"], target["worker_resources"]
    tolerance = Decimal(str(resources["memory_display_tolerance_gib"]))
    for scope in ("capacity", "allocatable"):
        result[f"worker_cpu_{scope}"] = Decimal(str(workers[scope]["cpu_cores"])) == Decimal(str(resources["cpu_cores"][scope]))
        result[f"worker_memory_{scope}_within_display_rounding"] = abs(Decimal(str(workers[scope]["memory_gib"])) - Decimal(str(resources["memory_gib"][scope]))) <= tolerance
        result[f"worker_pod_{scope}"] = workers[scope]["pods"] == resources["pods"][scope]
    return result


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--context", help="Explicit kubectl context; reads Nodes only")
    source.add_argument("--nodes-json", type=Path, help="Private offline kubectl get nodes -o json export")
    parser.add_argument("--expect", type=Path, help="Compare inventory/resources with a reviewed snapshot; does not certify deployment acceptance")
    args = parser.parse_args(argv)
    if args.context is not None and not args.context.strip():
        parser.error("--context must name an explicit context")
    try:
        if args.nodes_json:
            document = json.loads(args.nodes_json.read_text())
        else:
            response = subprocess.run(["kubectl", "--context", args.context, "--request-timeout=30s", "get", "nodes", "-o", "json"],
                                      text=True, capture_output=True, check=True, timeout=45)
            document = json.loads(response.stdout)
        summary = aggregate(document)
        summary["checks"] = checks(summary, json.loads(args.expect.read_text()) if args.expect else None)
        summary["report_generated_at"] = datetime.now(timezone.utc).isoformat()
        summary["source"] = "offline-node-export" if args.nodes_json else "kubernetes-node-api"
        summary["scope_note"] = "Node inventory and capacity only; no Pod requests/limits, metrics, guest placement or acceptance certification."
        print(json.dumps(summary, indent=2, sort_keys=True))
        return 0 if all(summary["checks"].values()) else 1
    except (OSError, ValueError, KeyError, TypeError, AttributeError, DecimalException, subprocess.SubprocessError):
        print("Unable to read complete Node evidence. Check the input schema, selected context, RBAC and kubectl availability; raw data/errors were not printed.", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
