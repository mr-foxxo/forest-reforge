"""Render all Ansible templates using synthetic identities and no network."""
import base64
import os
import pathlib
import subprocess
import tempfile
import unittest

_runtime = tempfile.TemporaryDirectory(prefix="reforge-ansible-")
unittest.addModuleCleanup(_runtime.cleanup)
os.environ.setdefault("ANSIBLE_LOCAL_TEMP", _runtime.name)

import yaml
from ansible.parsing.dataloader import DataLoader
from ansible.template import Templar, trust_as_template

ROOT = pathlib.Path(__file__).resolve().parents[1]
ANSIBLE = ROOT / "automation" / "ansible"


class Templates(unittest.TestCase):
    def variables(self, enabled=False):
        loader = DataLoader()
        variables = dict(loader.load_from_file(str(ANSIBLE / "site.example.yml")))
        variables.update(loader.load_from_file(str(ANSIBLE / "secrets.example.yml")))
        variables.update({
            "inventory_hostname": "core-cp01",
            "groups": {"control_plane": ["core-cp01", "core-cp02", "core-cp03"]},
            "hostvars": {"core-cp01": {"reforge_node_ip": "192.0.2.21"},
                         "core-cp02": {"reforge_node_ip": "192.0.2.22"},
                         "core-cp03": {"reforge_node_ip": "192.0.2.23"}},
            "reforge_node_ip": "192.0.2.21",
            "reforge_node_interface": "ens18",
            "reforge_vip_bootstrap": enabled,
            "reforge_kubernetes_minor": "v1.34",
            "reforge_kubernetes_version": "v1.34.1",
            "reforge_encryption_key": base64.b64encode(b"0" * 32).decode(),
            "reforge_argocd_sso": enabled,
            "reforge_acme_production": enabled,
            "reforge_backstage_database_ssl": enabled,
            "reforge_backstage_database_cidr": "192.0.2.40/32",
            "reforge_backstage_image_pull_secret": "ecr-pull" if enabled else "",
            "reforge_kube_vip_image": "registry.example.net/kube-vip@sha256:" + "0" * 64,
            "reforge_backstage_image": "registry.example.net/backstage@sha256:" + "0" * 64,
            "reforge_cloudflared_image": "registry.example.net/cloudflared@sha256:" + "0" * 64,
            "reforge_dns_listen": "192.0.2.53",
            "reforge_dns_upstreams": ["198.51.100.53"],
            "reforge_dns_records": [{"name": "api.k8s.den.int.example.net", "address": "192.0.2.30"}],
            "item": "apps",
        })
        return loader, variables

    def render(self, path, enabled=False):
        loader, variables = self.variables(enabled)
        # Ansible's playbook loader marks vars files as trusted template sources.
        # Direct DataLoader use needs that tagging explicitly under core 2.19.
        def trusted(value):
            if isinstance(value, str):
                return trust_as_template(value)
            if isinstance(value, list):
                return [trusted(item) for item in value]
            if isinstance(value, dict):
                return {key: trusted(item) for key, item in value.items()}
            return value
        variables = trusted(variables)
        return Templar(loader=loader, variables=variables).template(trust_as_template(path.read_text()))

    def test_all_templates_render_and_yaml_documents_parse_in_both_modes(self):
        for path in (ANSIBLE / "roles").glob("*/templates/*.j2"):
            for enabled in (False, True):
                with self.subTest(template=str(path.relative_to(ROOT)), enabled=enabled):
                    rendered = self.render(path, enabled)
                    self.assertNotIn("{{", rendered)
                    self.assertNotIn("{%", rendered)
                    if path.name.endswith(".yaml.j2"):
                        for document in yaml.safe_load_all(rendered):
                            self.assertIsInstance(document, dict)

    def test_all_yaml_files_parse(self):
        for path in (ROOT / "automation").rglob("*.yml"):
            with self.subTest(path=str(path.relative_to(ROOT))):
                list(yaml.safe_load_all(path.read_text()))

    def test_shell_syntax(self):
        paths = list((ROOT / "scripts").glob("*.sh")) + list((ROOT / "automation" / "drac5").glob("*.sh"))
        for path in paths:
            with self.subTest(path=path.name):
                result = subprocess.run(["bash", "-n", str(path)], text=True, capture_output=True)
                self.assertEqual(result.returncode, 0, result.stderr)

    def test_identity_and_boundary_contracts(self):
        argo = yaml.safe_load(self.render(ANSIBLE / "roles/trails/templates/values.yaml.j2", True))
        self.assertEqual(argo["configs"]["rbac"]["policy.default"], "role:reforge-no-access")
        portal = list(yaml.safe_load_all(self.render(ANSIBLE / "roles/backstage/templates/backstage.yaml.j2", True)))
        config = yaml.safe_load(portal[0]["data"]["app-config.production.yaml"])
        self.assertEqual(config["auth"]["providers"]["github"]["production"]["signIn"]["resolvers"],
                         [{"resolver": "userIdMatchingUserEntityAnnotation"}])
        self.assertTrue(config["backend"]["database"]["connection"]["ssl"]["rejectUnauthorized"])
        self.assertNotIn("guest", config["auth"]["providers"])
        edge = list(yaml.safe_load_all(self.render(ANSIBLE / "roles/edge/templates/cloudflared.yaml.j2")))[0]
        self.assertEqual(edge["spec"]["replicas"], 2)
        pod = edge["spec"]["template"]["spec"]
        self.assertFalse(pod["automountServiceAccountToken"])
        self.assertEqual(pod["containers"][0]["readinessProbe"]["httpGet"]["path"], "/ready")

    def test_encryption_rerun_guard_uses_the_original_key(self):
        loader, variables = self.variables()
        document = yaml.safe_load(self.render(ANSIBLE / "roles/canopy/templates/encryption.yaml.j2"))
        variables["reforge_stored_encryption"] = {
            "content": base64.b64encode(yaml.safe_dump(document).encode()).decode()
        }
        tasks = yaml.safe_load((ANSIBLE / "roles/canopy/tasks/main.yml").read_text())
        block = next(task["block"] for task in tasks if task["name"] == "Refuse implicit encryption key rotation")
        condition = block[1]["ansible.builtin.assert"]["that"]
        templar = Templar(loader=loader, variables=variables)
        expression = trust_as_template("{{ " + condition + " }}")
        self.assertTrue(templar.template(expression))
        variables["reforge_encryption_key"] = base64.b64encode(b"1" * 32).decode()
        self.assertFalse(Templar(loader=loader, variables=variables).template(expression))


if __name__ == "__main__":
    unittest.main()
