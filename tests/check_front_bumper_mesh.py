"""Module: Front bumper printability, mounting alignment and clearance checks.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""

import subprocess

import numpy as np

import check_suspension_mesh as checks


def main() -> None:
    checks.FIXTURE = checks.ROOT / "tests/fixtures/front_bumper.scad"
    checks.OUT = checks.ROOT / "build/skill-previews/front-bumper/mesh-checks"
    checks.OUT.mkdir(parents=True, exist_ok=True)
    for path in checks.OUT.glob("*.stl"):
        path.unlink()
    for variant in (False, True):
        for part in ("plate", "foam"):
            base = checks.one_solid(part, name=f"{part}-{variant}", variant=variant)
            expected = ([110, 30, 27.4 if variant else 22.4] if part == "plate"
                        else [163, 42, 21 if variant else 16])
            np.testing.assert_allclose(base.bounds[0], [0, 0, 0], atol=0.02)
            np.testing.assert_allclose(base.extents, expected, atol=0.02)
            # Every anchor must apply identically to the body and mounting cutters.
            slots = checks.export(part, name=f"{part}-slots-{variant}",
                                  slot=True, variant=variant)
            assert len(slots.split()) == 3
            for anchor in ([0, 0, 0], [-1, -1, -1]):
                suffix = f"{part}-{variant}-{anchor[0]}"
                moved = checks.one_solid(part, name=suffix, variant=variant,
                                         anchor=anchor)
                moved_slots = checks.export(part, name=f"{suffix}-slots",
                                             variant=variant, anchor=anchor, slot=True)
                shift = (np.asarray(anchor) - 1) * expected / 2
                np.testing.assert_allclose(moved.bounds - base.bounds,
                                           [shift, shift], atol=0.02)
                np.testing.assert_allclose(moved_slots.bounds - slots.bounds,
                                           [shift, shift], atol=1e-5)
                np.testing.assert_allclose(moved.volume, base.volume, atol=0.01)
        printable = checks.one_solid("print_plate", name=f"print-{variant}",
                                      variant=variant)
        np.testing.assert_allclose(printable.bounds[0], [0, 0, 0], atol=0.02)
        for part in ("mutual", "frame", "bores", "support", "head",
                     "nut_fit", "hardware_above", "hardware_frame"):
            checks.assert_no_interference(
                checks.export(part, name=f"{part}-{variant}", empty=True,
                              variant=variant), f"{part}-{variant}")
        print(f"PASS bumper variant={variant}: aligned clear bores, supported posts, "
              "recessed hardware, no overlap with TPU, frame or neutral head")
        pockets = checks.export("nut_pockets", name=f"nut-pockets-{variant}",
                                variant=variant)
        shells = pockets.split()
        assert len(shells) == 3
        for shell in shells:
            np.testing.assert_allclose(shell.extents,
                                       [5.75 / np.cos(np.pi / 6), 5.75, 2.49],
                                       atol=0.002)
        hardware = checks.export("hardware", name=f"hardware-{variant}",
                                 variant=variant)
        np.testing.assert_allclose(hardware.bounds[1][2],
                                   27.3 if variant else 22.3, atol=0.002)

    frame = checks.one_solid("head_frame", name="head-frame-extended",
                            front_chassis_bumper_extension=15)
    reference = checks.one_solid("head_frame", name="head-frame-zero-extension",
                                 front_chassis_bumper_extension=0)
    np.testing.assert_allclose(frame.bounds - reference.bounds,
                               [[0, 0, 0], [0, 15, 0]], atol=1e-5)
    assert frame.volume > reference.volume
    print("PASS head frame: connected 15 mm nose extension, fixed rear/X/Z bounds")
    for tilt in (-30, 30):
        checks.assert_no_interference(
            checks.export("head", name=f"head-tilt-{tilt}", empty=True,
                          head_tilt=tilt), f"head tilt {tilt}")
    print("PASS bumper clearance at head tilt -30 and +30 degrees, pan zero")
    for length, message in ((24, "fully engage the nut"),
                            (26, "stay below the top face")):
        result = subprocess.run(
            [checks.OPENSCAD, "--backend=Manifold", "--enable=textmetrics",
             "--hardwarnings", "-o", str(checks.OUT / f"invalid-{length}.csg"),
             "-D", f"test_bolt_l={length}", str(checks.FIXTURE)],
            capture_output=True, text=True)
        assert "ERROR: Assertion" in result.stderr and message in result.stderr, (
            length, result.stdout, result.stderr)
    print("PASS too-short and protruding bolts rejected")


if __name__ == "__main__":
    main()
