# Steering inspection: articulated assembly and legacy reference

## Articulated wheel linkages

Open `articulated.scad` to inspect the front suspension with rigid joint
constraints. `lower_arm_angle` prescribes the lower wishbone angle: positive
angles lower the wheel; `10` degrees is an illustrative drooped pose, not a
measurement inferred from photographs. `bellcrank_angle` sets the displayed
bellcrank angle. `steering_hole` selects the knuckle attachment (0 is the ear-tip
hole). `show_suspension=false` exposes the rods, and `show_joint_centers=true`
adds markers. `solve_linkage=false` shows the old independently placed assembly.

The RC vehicle entry `scad/rc_robot_assembly.scad` enables `solve_front_linkage`
by default, with `front_lower_arm_angle=0` as a reference pose and
`front_steering_hole=0`. Change the arm angle to inspect travel. Standalone
`front_suspension_assembly()` callers retain the old placement unless they pass
`solve_linkage=true`, so the legacy datum overlay remains reproducible.

`front_linkage.scad` resolves the following without resizing any hardware:

1. Lower-arm ball center follows a circle about its actual fixed hinge axis.
2. Upper-arm radius and the knuckle's ball-seat spacing determine the upper
   ball center. The two arms can have different angles; the upright can tilt.
3. The knuckle rotates around the line through those two balls until the
   selected steering attachment reaches the fixed-length wheel tie rod.
4. The rod follows the resulting endpoints, and its spherical bushings align
   with the two mounting-hole axes independently.

The model uses both rod ends below their mounting faces, with the modeled
bushing half-height setting the ball-center offset. This mounting convention
matches the supplied hardware photographs; exact installed heights still need
physical confirmation. Knuckle seats follow the spherical cavities of the
modeled bushings. The two fixed hinge axes retain their modeled Y offset.

At zero displayed bellcrank angle and 10 degrees lower-arm droop, the existing
39.7 mm rods connect with approximately 3.9 degrees of outward wheel heading
on each side. At a horizontal lower arm, the solution is approximately 4.5
degrees outward. These are **CAD kinematic results**, not measured toe settings
or an assertion that the physical car has those exact angles. Vertical droop
alone is insufficient to explain the previous mismatch; upright rotation is
also involved. Keeping the same physical dimensions does not require keeping
all assembly angles zero.

The solver chooses the outboard upper-arm intersection and the steering branch
nearest straight ahead; unreachable poses assert instead of stretching a rod.
It replaces the independent legacy `knuckle_angles` / `knuckle_z_shift` controls
for this mode, which must remain zero. Input ranges are diagnostic, not verified
joint limits. There is no spring/load equilibrium, shock travel, collision or
ball-articulation validation here. The existing servo and center-bar display
remain separate; this is **not a verified servo-to-wheel calibration or
Ackermann curve**.

Validation:

```sh
make tests
.venv/bin/python tests/check_front_linkage_assembly.py
```

The SCAD test checks four rigid lengths and rotation invariants across 24 poses.
The Python assembly check inserts markers into temporary source copies at the
actual spheres and hole cutters, then reads evaluated CSG transforms. It checks
four suspension balls against their actual sockets, both rod lengths and
attachment centers, bushing-axis alignment, and stationary hinge axes across
four poses including both steering holes. This is independent of the solver's
own reported endpoint residuals. It does not test material strength or collision.

## Legacy unlinked reference audit

`neutral.scad` and `tests/steering_characterization.py` inspect the old pose with
horizontal arms and independently positioned, zero-angle knuckles. This is
useful for diagnosing placement formulas; its mismatch is **not a failure of
the new articulated RC assembly or proof that the physical rod is too short**.
The audit includes the legacy rod's default 6-degree tilt and compares all
knuckle holes when reporting the shortest mounting-axis distance. No
`picar-x-racer` settings are changed.

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

## Findings in the legacy reference pose

| Feature                                        | Nominal CAD result         | Interpretation                                                                         |
| ---------------------------------------------- | -------------------------- | -------------------------------------------------------------------------------------- |
| Bellcrank pivot spacing                        | 48.8 mm                    | Fixed chassis mounting pattern                                                         |
| Center-bar hole spacing                        | 48.7 mm                    | `steering_center_link_len - steering_center_link_boss_od`                              |
| Center-bar mounting radius                     | 12.15 mm                   | Actual lever hole center                                                               |
| Displayed bar's forward displacement           | 12.30 mm                   | Current assembly's placement formula                                                   |
| Bar-hole to lever-axis mismatch                | 0.158 mm at each end in XY | Not proof of physical interference; bores/clearance may accommodate it                 |
| Each wheel tie rod, ball-center spacing        | 39.7 mm                    | Not the 48.6 mm outside envelope returned by `steering_link_full_len()`                |
| Neutral knuckle-to-bellcrank mounting distance | 42.537 mm in XY            | A lower bound on 3D ball-center distance for the nearest of both knuckle holes                  |
| Displayed wheel rod to bellcrank axis          | 4.409 mm in XY             | Both sides; the current drawing does not close this connection                         |
| Displayed wheel rod to nearest knuckle hole    | 0.093 mm in XY             | Legacy helper offset plus rotation about its display origin                              |
| Servo rod, ball-center spacing                 | 59.18 mm                   | Derived from rod-end and shaft/nut geometry                                            |
| Displayed servo rod to nearest lever hole      | 0.050 mm in XY             | Matches the outermost servo-lever hole approximately; Z stack still needs confirmation |

With those fixed legacy mounting positions, the wheel rods would need at least about 2.837 mm more ball-center spacing to
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
caster, steering, suspension displacement or OpenSCAD animation. The rod
display angles follow `knuckle_tie_rod_angles` (default `[0,6,0]`).
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
