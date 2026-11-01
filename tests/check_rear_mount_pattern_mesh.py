"""Module: Shared housing pattern support on the fixed rear chassis plate.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""

import check_suspension_mesh as checks


def main() -> None:
    checks.FIXTURE = checks.ROOT / "tests/fixtures/rear_mount_pattern.scad"
    checks.OUT = checks.ROOT / "build/skill-previews/rear-mount-pattern-checks"
    checks.OUT.mkdir(parents=True, exist_ok=True)
    checks.one_solid("plate")
    for part in ("blocked_passages", "missing_top_lands", "outside_head_support"):
        checks.assert_no_interference(checks.export(part, empty=True), part)
        print(f"PASS {part}: eight shared housing holes fit the fixed plate")


if __name__ == "__main__":
    main()
