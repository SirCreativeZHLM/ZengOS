import importlib.machinery
import importlib.util
import json
import pathlib
import subprocess
import sys
import unittest

BACKEND = pathlib.Path(__file__).resolve().parents[1] / "backend" / "zeng-install-backend"
loader = importlib.machinery.SourceFileLoader("zeng_backend", str(BACKEND))
spec = importlib.util.spec_from_loader("zeng_backend", loader)
backend = importlib.util.module_from_spec(spec)
loader.exec_module(backend)

GOOD = {
    "edition": "normal", "addons": ["zengav"], "disk": "/dev/nvme0n1", "encrypt": True,
    "confirm_erase": True, "fullname": "Alex Rivera", "username": "alex",
    "password": "pw", "hostname": "zengos",
}


def run(cfg, *flags):
    p = subprocess.run([sys.executable, str(BACKEND), "--json", *flags], input=json.dumps(cfg),
                       capture_output=True, text=True)
    return p.returncode, [json.loads(l) for l in p.stdout.splitlines()]


class ValidationTests(unittest.TestCase):
    def test_refuses_without_erase_confirmation(self):
        code, out = run({**GOOD, "confirm_erase": False}, "--dry-run")
        self.assertEqual(code, 1)
        self.assertIn("error", out[-1])

    def test_refuses_bad_disk_path(self):
        for disk in ["", "/", "/dev/null", "/dev/sda; rm -rf /", "sda"]:
            code, out = run({**GOOD, "disk": disk}, "--dry-run")
            self.assertEqual(code, 1, disk)

    def test_refuses_bad_username(self):
        code, _ = run({**GOOD, "username": "Root User"}, "--dry-run")
        self.assertEqual(code, 1)

    def test_unknown_edition_and_addon(self):
        self.assertEqual(run({**GOOD, "edition": "x"}, "--dry-run")[0], 1)
        self.assertEqual(run({**GOOD, "addons": ["evil"]}, "--dry-run")[0], 1)

    def test_not_root_without_dry_run(self):
        if backend.os.geteuid() != 0:
            self.assertEqual(run(GOOD)[0], 1)


class PlanTests(unittest.TestCase):
    def test_partition_names(self):
        self.assertEqual(backend.part("/dev/nvme0n1", 2), "/dev/nvme0n1p2")
        self.assertEqual(backend.part("/dev/sda", 2), "/dev/sda2")

    def test_mini_has_no_apps_and_addons_are_optional(self):
        mini = backend.packages({"edition": "mini", "addons": []})
        self.assertNotIn("zengos-apps", mini)
        self.assertNotIn("zengav", mini)
        full = backend.packages({"edition": "normal", "addons": ["zengav", "zengsuite"]})
        self.assertIn("zengos-apps", full)
        self.assertIn("zengav", full)
        self.assertIn("zengsuite", full)

    def test_dry_run_plans_every_stage_and_ends_done(self):
        code, out = run(GOOD, "--dry-run")
        self.assertEqual(code, 0)
        self.assertTrue(out[-1].get("done"))
        steps = [o["message"] for o in out if "message" in o]
        for expected in ["Creating partitions", "Installing the base system", "Setting up the bootloader"]:
            self.assertIn(expected, steps)
        progress = [o["progress"] for o in out if "progress" in o]
        self.assertEqual(progress, sorted(progress))

    def test_password_never_in_dry_run_output(self):
        _, out = run({**GOOD, "password": "s3cr3t-pass"}, "--dry-run")
        self.assertNotIn("s3cr3t-pass", json.dumps(out))

    def test_encrypt_toggle_changes_plan(self):
        enc = json.dumps(run(GOOD, "--dry-run")[1])
        plain = json.dumps(run({**GOOD, "encrypt": False}, "--dry-run")[1])
        self.assertIn("cryptsetup", enc)
        self.assertNotIn("cryptsetup", plain)


if __name__ == "__main__":
    unittest.main()
