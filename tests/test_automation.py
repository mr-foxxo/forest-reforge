"""Offline contracts: no host, cluster or cloud connection is made."""
import json
import os
import pathlib
import shutil
import subprocess
import tempfile
import tarfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]


class Helpers(unittest.TestCase):
    def run_helper(self, name, *arguments, env=None):
        return subprocess.run(
            ["bash", str(ROOT / "scripts" / name), *arguments],
            text=True, capture_output=True, env=env,
        )

    def test_every_mutating_helper_has_nonmutating_help(self):
        for name in ("reforge.sh", "etcd-backup.sh", "gpu-driver.sh", "vgpu-attach.sh",
                     "eks-register.sh", "eks-access.sh", "ecr-refresh.sh", "drac5.sh",
                     "proxmox-vm.sh", "gpu-diagnose.sh", "kernel-gate.sh", "secret-file.sh",
                     "package-release.sh", "cluster-troubleshoot.sh", "spellwork-build.sh"):
            with self.subTest(helper=name):
                result = self.run_helper(name, "--help")
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn("Usage:", result.stdout)

    def test_missing_and_invalid_arguments_do_not_deploy(self):
        for name in ("reforge.sh", "etcd-backup.sh", "gpu-driver.sh", "vgpu-attach.sh",
                     "eks-register.sh", "eks-access.sh", "ecr-refresh.sh", "drac5.sh",
                     "proxmox-vm.sh", "gpu-diagnose.sh", "kernel-gate.sh", "secret-file.sh",
                     "package-release.sh", "cluster-troubleshoot.sh", "spellwork-build.sh"):
            with self.subTest(helper=name):
                self.assertNotEqual(self.run_helper(name).returncode, 0)

    def test_reforge_plan_preserves_paths_and_does_not_add_diff(self):
        with tempfile.TemporaryDirectory(prefix="reforge test ") as directory:
            folder = pathlib.Path(directory)
            for name in ("inventory.yml", "site.yml"):
                (folder / name).write_text("{}\n")
            output = folder / "args.json"
            fake = folder / "ansible-playbook"
            fake.write_text("#!/bin/sh\nprintf '%s\\n' \"$@\" > \"$TEST_ARGS\"\n")
            fake.chmod(0o700)
            env = dict(os.environ, PATH=str(folder) + os.pathsep + os.environ["PATH"], TEST_ARGS=str(output))
            result = self.run_helper("reforge.sh", "plan", "roots", str(folder / "inventory.yml"), str(folder / "site.yml"), env=env)
            self.assertEqual(result.returncode, 0, result.stderr)
            arguments = output.read_text().splitlines()
            self.assertIn("--check", arguments)
            self.assertNotIn("--diff", arguments)
            self.assertIn(str(folder / "inventory.yml"), arguments)
            self.assertIn("@" + str(folder / "site.yml"), arguments)

    def test_ecr_plan_does_not_contact_cloud(self):
        result = self.run_helper("ecr-refresh.sh", "plan", "core", "operator", "us-east-1",
                                 "123456789012.dkr.ecr.us-east-1.amazonaws.com", "backstage")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_ecr_rejects_region_mismatch(self):
        result = self.run_helper("ecr-refresh.sh", "plan", "core", "operator", "us-east-2",
                                 "123456789012.dkr.ecr.us-east-1.amazonaws.com", "backstage")
        self.assertNotEqual(result.returncode, 0)

    def test_driver_rejects_checksum_before_extraction(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = pathlib.Path(directory)
            installer = folder / "driver.run"
            marker = folder / "executed"
            installer.write_text("#!/bin/sh\ntouch '" + str(marker) + "'\n")
            result = self.run_helper("gpu-driver.sh", str(installer), "0" * 64, str(folder / "extract"))
            self.assertNotEqual(result.returncode, 0)
            self.assertFalse(marker.exists())
            self.assertFalse((folder / "extract").exists())

    def test_aws_examples_are_json(self):
        for path in (ROOT / "automation" / "aws").glob("*.json"):
            with self.subTest(path=path.name):
                self.assertEqual(json.loads(path.read_text())["Version"], "2012-10-17")

    def test_release_omits_source_runtime_and_environment_files(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = pathlib.Path(directory)
            for name in ("assets", "docs", "examples", "modules", "scripts", "automation", "tests"):
                (folder / name).mkdir()
            for name in ("README.md", "CONTRIBUTING.md", "RELEASE.md", "LICENSE", ".gitignore"):
                (folder / name).write_text("public\n")
            script = folder / "scripts/package-release.sh"
            script.write_text((ROOT / "scripts/package-release.sh").read_text())
            for name in ("reference/integration_onprem/vault.yml", "local/secrets.yml",
                         "reference/den-evidences/nodes.png", "local/den-evidence/record.json",
                         "automation/drac5/private/runtime/vkvm.jnlp", "automation/drac5/.env"):
                path = folder / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text("PRIVATE_SENTINEL")
            archive = folder / "release.tar.gz"
            result = subprocess.run(["bash", str(script), str(archive)], text=True, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            with tarfile.open(archive) as package:
                self.assertEqual(package.extractfile("forest-reforge/LICENSE").read(), (folder / "LICENSE").read_bytes())
                for member in package.getmembers():
                    if member.isfile():
                        self.assertNotIn(b"PRIVATE_SENTINEL", package.extractfile(member).read())
            self.assertNotEqual(subprocess.run(["bash", str(script), str(archive)], capture_output=True).returncode, 0)

    @unittest.skipUnless(shutil.which("jq"), "jq is required for the AWS helper checks")
    def test_eks_registration_uses_scoped_namespaces_and_verified_tls(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = pathlib.Path(directory)
            fixture = folder / "cluster.json"
            fixture.write_text(json.dumps({"cluster": {"status": "ACTIVE", "endpoint": "https://eks.example.net",
                                                        "certificateAuthority": {"data": "VEVTVA=="}}}))
            fake = folder / "aws"
            fake.write_text('#!/bin/sh\ncat "$TEST_CLUSTER"\n')
            fake.chmod(0o700)
            kubectl = folder / "kubectl"
            kubectl.write_text('#!/bin/sh\nexit 99\n')
            kubectl.chmod(0o700)
            env = dict(os.environ, PATH=str(folder) + os.pathsep + os.environ["PATH"], TEST_CLUSTER=str(fixture))
            role = "arn:aws:iam::123456789012:role/argocd-forest-dev-deployer"
            result = self.run_helper("eks-register.sh", "plan", "core", "operator", "us-east-1", "forest-dev", role, "apps,backstage", env=env)
            self.assertEqual(result.returncode, 0, result.stderr)
            registration = json.loads(result.stdout.split("\n", 1)[1])
            self.assertEqual(registration["stringData"]["namespaces"], "apps,backstage")
            self.assertEqual(registration["stringData"]["clusterResources"], "false")
            config = json.loads(registration["stringData"]["config"])
            self.assertFalse(config["tlsClientConfig"]["insecure"])
            self.assertEqual(config["execProviderConfig"]["args"][-1], role)

    @unittest.skipUnless(shutil.which("jq"), "jq is required for the AWS helper checks")
    def test_ecr_apply_hides_credentials_and_uses_explicit_context(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = pathlib.Path(directory)
            fake = folder / "aws"
            fake.write_text('#!/bin/sh\nprintf "%s\\n" "TEST_PRIVATE_ECR_PASSWORD"\n')
            fake.chmod(0o700)
            kubectl = folder / "kubectl"
            kubectl.write_text('''#!/bin/sh
printf '%s\\n' "$@" >> "$TEST_CALLS"
case " $* " in
  *" create secret "*)
    for item in "$@"; do
      case "$item" in --from-file=.dockerconfigjson=*) config=${item#--from-file=.dockerconfigjson=} ;; esac
    done
    jq -n --rawfile config "$config" '{apiVersion:"v1",kind:"Secret",data:{".dockerconfigjson":($config|@base64)}}'
    ;;
  *" apply "*)
    while [ "$#" -gt 0 ]; do
      if [ "$1" = -f ]; then shift; cp "$1" "$TEST_RESULT"; break; fi
      shift
    done
    printf 'secret updated\\n'
    ;;
  *) exit 98 ;;
esac
''')
            kubectl.chmod(0o700)
            calls, saved = folder / "calls", folder / "secret.json"
            env = dict(os.environ, PATH=str(folder) + os.pathsep + os.environ["PATH"], TEST_CALLS=str(calls), TEST_RESULT=str(saved))
            result = self.run_helper("ecr-refresh.sh", "apply", "core", "operator", "us-east-1",
                                     "123456789012.dkr.ecr.us-east-1.amazonaws.com", "backstage", env=env)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn("TEST_PRIVATE_ECR_PASSWORD", result.stdout + result.stderr + calls.read_text())
            self.assertIn("--context\ncore\n", calls.read_text())
            self.assertIn(".dockerconfigjson", json.loads(saved.read_text())["data"])


if __name__ == "__main__":
    unittest.main()
