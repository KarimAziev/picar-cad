"""Check that front-frame evaluation excludes unrelated steering hardware.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""

from pathlib import Path
import subprocess

from scad_test_support import OPENSCAD

ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    source = ROOT / "scad/suspension/front_chassis"
    output = ROOT / "build/skill-previews/front-frame-evaluation"
    output.mkdir(parents=True, exist_ok=True)
    cases = {
        "head": "head_frame/front_chassis_head_frame.scad",
        "suspension": "suspension_frame/front_chassis_suspension_frame.scad",
        "unsplit": "front_frame_util.scad",
        "recesses": "front_chassis_mount_recesses.scad",
    }
    for part, relative in cases.items():
        csg = output / f"{part}.csg"
        result = subprocess.run(
            [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--hardwarnings",
             "-o", str(csg), str(source / relative)],
            text=True, capture_output=True,
        )
        log = result.stdout + result.stderr
        assert result.returncode == 0, log
        assert "WARNING:" not in log and "ERROR:" not in log, log
        assert "Tie rod full length" not in log, log
        assert csg.stat().st_size > 0, part
        if part != "recesses":
            assert "projection(" not in csg.read_text(), f"{part} evaluates a hardware projection"
        print(f"PASS {part}: evaluates without tie-rod diagnostics", flush=True)
    print("PASS head and suspension frames: no projected hardware in the evaluated geometry")


if __name__ == "__main__":
    main()
