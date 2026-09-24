# Steering characterization: neutral closure first

This is an inspection tool, not a replacement steering assembly. No production
part, mounting position, installed rod length or `picar-x-racer` setting is changed.
The current output is **not a servo-to-wheel calibration or a verified Ackermann curve**.

## Reproduce

From the repository root:

```sh
python3 tests/steering_characterization.py
make tests-python
make tests
```

The audit writes evaluated points and its report to `build/steering-characterization/`:

- `datums.json`: named 3D points, evaluated by OpenSCAD from current parameters.
- `neutral-audit.json`: differences between displayed rod ends and mounting axes.
- `center-bar-only-sweep.csv`: an ideal-pin center-bar loop sweep, not wheel steering.

Open `neutral.scad` to inspect the overlay. `show_components`, `show_datums`,
`marker_d`, and `axis_h` have editable defaults. Cyan cylinders identify bolt axes;
orange spheres/lines identify displayed rod centers; magenta lines expose the
wheel rods' bellcrank-end mismatch in XY. Marker sizes do not alter hardware.

Coordinates are mm, with the origin halfway between the bellcranks on the chassis
top face. X is across the vehicle, Y forward, Z up. The normal whole-chassis frame
is recovered by adding `[0, -bellcrank_y_distance_from_bulkhead, front_chassis_thickness]`.
Negative/positive X labels avoid assuming left/right viewing conventions.

## Findings at current defaults

| Feature                                        | Nominal CAD result         | Interpretation                                                                         |
| ---------------------------------------------- | -------------------------- | -------------------------------------------------------------------------------------- |
| Bellcrank pivot spacing                        | 48.8 mm                    | Fixed chassis mounting pattern                                                         |
| Center-bar hole spacing                        | 48.7 mm                    | `steering_center_link_len - steering_center_link_boss_od`                              |
| Center-bar mounting radius                     | 12.15 mm                   | Actual lever hole center                                                               |
| Displayed bar's forward displacement           | 12.30 mm                   | Current assembly's placement formula                                                   |
| Bar-hole to lever-axis mismatch                | 0.158 mm at each end in XY | Not proof of physical interference; bores/clearance may accommodate it                 |
| Each wheel tie rod, ball-center spacing        | 39.7 mm                    | Not the 48.6 mm outside envelope returned by `steering_link_full_len()`                |
| Neutral knuckle-to-bellcrank mounting distance | 42.616 mm in XY            | A lower bound on 3D ball-center distance for the nearest knuckle hole                  |
| Displayed wheel rod to bellcrank axis          | 4.317 mm in XY             | Both sides; the current drawing does not close this connection                         |
| Displayed wheel rod to nearest knuckle hole    | 0.050 mm in XY             | Small difference in the helper and physical hole formulas                              |
| Servo rod, ball-center spacing                 | 59.18 mm                   | Derived from rod-end and shaft/nut geometry                                            |
| Displayed servo rod to nearest lever hole      | 0.050 mm in XY             | Matches the outermost servo-lever hole approximately; Z stack still needs confirmation |

The wheel rods would need at least about 2.916 mm more ball-center spacing to
reach the neutral mounting axes **at those positions**, even before a Z difference
is included. This is not an instruction to lengthen the hardware: check the installed
length, selected holes, static toe and CAD placements first. Pivoting the existing
rod cannot overcome a center distance larger than its length. Do not substitute
the outside envelope for the ball-center length to make the numbers agree.

### Traceability

`datums.scad` mirrors these existing transformations, using their parameters and helpers:

- `bellcrank/bellcrank_lever.scad`: actual two hole centers; outer radius 21.65 mm,
  inner radius 12.15 mm. `bellcrank/bellcrank_assembly.scad` rotates local -X forward.
- `bellcrank/center_link.scad`: hole pitch; the assembly separately supplies 12.30 mm Y.
- `knuckle/knuckle_steering_arm.scad`: polygon/row hole positions, including both
  connector translations. `knuckle/steering_link.scad` supplies a separate placement
  helper for the rod, so both are inspected independently.
- `knuckle/knuckle.scad` and `front_suspension_assembly.scad`: native-part transforms.
- `placeholders/tie_rod_end.scad`: eye/spherical bushing center height.
- `placeholders/dservo.scad`, `placeholders/servo.scad`,
  `steering_servo_bracket/steering_servo_bracket_assembly.scad`: servo output and rod transforms.

The audit currently accepts the default neutral pose only: no knuckle camber,
caster, steering, suspension displacement, tie-rod tilt or OpenSCAD animation.
The simplified export is rounded by OpenSCAD's echo precision; reported microns
are not measurement accuracy. Updating production placement code requires updating
this extractor and checking the overlay. Numerical regression tests alone cannot
prove correspondence to physical hardware.

## What the first sweep does—and does not do

The CSV solves only the two bellcrank pivots, equal 12.15 mm attachment radii,
and the 48.7 mm rigid center bar. It follows the branch nearest the parallel
assembly from zero toward each side, using fixed-length circle constraints.
At drive angle zero, the ideal-pin solution has an idler angle of about +0.4716°,
not exactly zero. The existing equal-angle animation implicitly uses the
48.8 mm parallelogram relationship. Real clearance can affect this small difference.

CSV angles are physical CCW **bellcrank** rotations, not servo commands, not wheel
angles, and not Ackermann error. The ±25° sampling interval is a diagnostic range,
not a demonstrated safe mechanical limit. The analytical revolute-rod solver
preserves 3D endpoint distance, returns both branches, and rejects unreachable
and degenerate constraints; it does not check solid collisions or ball articulation.

## Measurements needed before the complete steering sweep

1. Both installed front wheel tie rods: **ball center to ball center**, selected
   knuckle hole (outermost or nearer the wheel), and mounting side of each arm.
2. Servo link center distance, selected servo horn hole and bellcrank servo-lever
   hole, plus the corresponding neutral servo/encoder position.
3. Ball-center height above/below the mating lever face at each connection. A
   bolt hole identifies an axis, not the ball's position along that axis.
4. Straight-ahead static toe and normal ride-height pose. Confirm upper/lower
   knuckle ball centers for the physical steering axis; do not rotate the whole
   knuckle about the wheel-bearing origin just because the preview currently does.
5. Wheel centers/contact geometry and rear axle center for track and wheelbase.
   Overall chassis length is not wheelbase; do not reuse deprecated Ackermann presets.

Then solve servo → driven bellcrank → idler → both knuckles, follow continuous
branches, and compare projected wheel headings to the ideal turning geometry.
After the fixed-height sweep, check suspension travel for bump steer and joint
limits, then validate with hardware. Do not export app calibration before this.

For `picar-x-racer`, keep the eventual equivalent bicycle steering angle separate
from both servo rotation and the individual wheel angles. Its feedback table can
represent the measured mapping; the command side also needs the inverse mapping.
No settings in that repository have been changed by this audit.
