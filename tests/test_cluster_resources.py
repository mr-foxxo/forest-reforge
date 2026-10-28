"""Synthetic Node fixtures: these per-node sizes do not describe the real Den."""
import contextlib
import importlib.util
import io
import json
import pathlib
import subprocess
import tempfile
import unittest
from decimal import Decimal
from unittest import mock

import yaml

ROOT = pathlib.Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("cluster_resources", ROOT / "scripts/cluster-resources.py")
resources = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(resources)


def node(index, control_plane=False):
    return {
        "metadata": {"name": "private-node-" + str(index),
                     "annotations": {"private": "DO_NOT_PRINT_METADATA"},
                     "labels": {"node-role.kubernetes.io/control-plane": ""} if control_plane else {}},
        "spec": {},
        "status": {
            "addresses": [{"type": "InternalIP", "address": "203.0.113.21"}],
            "nodeInfo": {"kubeletVersion": "v1.36.4"},
            "conditions": [{"type": "Ready", "status": "True"}],
            "capacity": {"cpu": "2" if control_plane else "8", "memory": "8Gi" if control_plane else "15987Mi", "pods": "110"},
            "allocatable": {"cpu": "2" if control_plane else "8000m", "memory": "8Gi" if control_plane else "15884Mi", "pods": "110"},
        },
    }


def fixture():
    return {"kind": "NodeList", "items": [node(index, index < 5) for index in range(13)]}


class ClusterResources(unittest.TestCase):
    def setUp(self):
        self.expected = json.loads((ROOT / "examples/observed-platform.json").read_text())

    def test_cpu_memory_and_exponent_quantities(self):
        for value, expected in (("8", "8"), ("1500m", "1.5"), ("1000000u", "1"),
                                ("1000000000n", "1"), ("1Gi", "1073741824"),
                                ("1G", "1000000000"), ("1e3", "1000"), ("1E-3", "0.001")):
            with self.subTest(value=value):
                self.assertEqual(resources.quantity(value), Decimal(expected))
        for invalid in (None, "-1", "NaN", "1garbage", "", "Infinity"):
            with self.subTest(invalid=invalid), self.assertRaises(ValueError):
                resources.quantity(invalid)

    def test_worker_totals_exclude_control_planes_and_allow_dashboard_rounding(self):
        summary = resources.aggregate(fixture())
        self.assertEqual(summary["node_count"], 13)
        self.assertEqual(summary["roles"]["control_plane"]["count"], 5)
        workers = summary["roles"]["workers"]
        self.assertEqual(workers["count"], 8)
        self.assertEqual(workers["allocatable"]["cpu_cores"], 64)
        self.assertEqual(workers["allocatable"]["pods"], 880)
        self.assertAlmostEqual(workers["allocatable"]["memory_gib"], 124.09375)
        self.assertTrue(all(resources.checks(summary, self.expected).values()))

    def test_not_ready_version_and_resource_drift_fail_snapshot_comparison(self):
        document = fixture()
        document["items"][0]["status"]["conditions"][0]["status"] = "Unknown"
        document["items"][5]["status"]["nodeInfo"]["kubeletVersion"] = "v1.36.5"
        document["items"][6]["status"]["allocatable"]["memory"] = "8Gi"
        result = resources.checks(resources.aggregate(document), self.expected)
        self.assertFalse(result["all_nodes_ready"])
        self.assertFalse(result["expected_kubelet_version"])
        self.assertFalse(result["worker_memory_allocatable_within_display_rounding"])

    def test_incomplete_duplicate_and_nonintegral_node_data_are_rejected(self):
        documents = [fixture() for _ in range(3)]
        del documents[0]["items"][0]["status"]["allocatable"]["memory"]
        documents[1]["items"][1]["metadata"]["name"] = documents[1]["items"][0]["metadata"]["name"]
        documents[2]["items"][0]["status"]["capacity"]["pods"] = "1.5"
        for document in documents:
            with self.subTest(document_index=documents.index(document)), self.assertRaises((ValueError, KeyError)):
                resources.aggregate(document)

    def test_offline_cli_emits_no_private_node_metadata(self):
        with tempfile.TemporaryDirectory() as directory:
            path = pathlib.Path(directory) / "private-nodes.json"
            path.write_text(json.dumps(fixture()))
            output = io.StringIO()
            with contextlib.redirect_stdout(output):
                code = resources.main(["--nodes-json", str(path), "--expect", str(ROOT / "examples/observed-platform.json")])
            self.assertEqual(code, 0)
            report = output.getvalue()
            for value in ("private-node-", "DO_NOT_PRINT_METADATA", "203.0.113.21", str(path)):
                self.assertNotIn(value, report)
            self.assertEqual(json.loads(report)["source"], "offline-node-export")

    def test_live_mode_reads_nodes_only_in_explicit_context(self):
        response = subprocess.CompletedProcess([], 0, json.dumps(fixture()), "")
        with mock.patch.object(resources.subprocess, "run", return_value=response) as run:
            with contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(resources.main(["--context", "private-context"]), 0)
            self.assertEqual(run.call_args.args[0], ["kubectl", "--context", "private-context", "--request-timeout=30s", "get", "nodes", "-o", "json"])
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            resources.main(["--context", ""])

    def test_cli_does_not_disclose_raw_api_errors(self):
        error = subprocess.CalledProcessError(1, "kubectl", stderr="PRIVATE_ERROR_PAYLOAD")
        output, errors = io.StringIO(), io.StringIO()
        with mock.patch.object(resources.subprocess, "run", side_effect=error):
            with contextlib.redirect_stdout(output), contextlib.redirect_stderr(errors):
                self.assertEqual(resources.main(["--context", "private-context"]), 2)
        self.assertNotIn("PRIVATE_ERROR_PAYLOAD", output.getvalue() + errors.getvalue())

    def test_observed_inventory_separates_guest_nodes_and_infrastructure_hosts(self):
        inventory = yaml.safe_load((ROOT / "automation/ansible/inventory.observed.example.yml").read_text())["all"]
        groups = inventory["children"]
        burrows = groups["burrows"]["children"]
        self.assertEqual(set(burrows["kubernetes_hypervisors"]["hosts"]), {"hv01", "hv02"})
        self.assertEqual(set(burrows["infrastructure_only_hypervisors"]["hosts"]), {"hv03", "hv04"})
        canopy = groups["canopy"]["children"]
        self.assertEqual(len(canopy["control_plane"]["hosts"]), 5)
        self.assertEqual(len(canopy["workers"]["hosts"]), 8)
        guests = set(canopy["control_plane"]["hosts"]) | set(canopy["workers"]["hosts"])
        self.assertFalse(guests.intersection({"hv01", "hv02", "hv03", "hv04", "nas01"}))
        self.assertFalse(inventory["vars"]["reforge_inventory_reviewed"])
        included = {host["id"] for host in self.expected["hypervisors"] if host["kubernetes_guest_host"]}
        self.assertEqual(included, {"hv01", "hv02"})
        placements = self.expected["kubernetes"]["guest_placement"]["hosts"]
        self.assertEqual(set(placements), included)
        mapped = []
        for hypervisor, placement in placements.items():
            for role, group in (("control_plane", "control_plane"), ("workers", "workers")):
                for guest in placement[role]:
                    mapped.append(guest)
                    self.assertEqual(canopy[group]["hosts"][guest]["reforge_hypervisor"], hypervisor)
        self.assertEqual(set(mapped), guests)
        self.assertEqual(len(mapped), len(set(mapped)))
        self.assertEqual(len(placements["hv01"]["control_plane"]), 3)
        self.assertEqual(len(placements["hv02"]["control_plane"]), 2)


if __name__ == "__main__":
    unittest.main()
