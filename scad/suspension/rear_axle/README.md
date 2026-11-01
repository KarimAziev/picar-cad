# Rear suspension

This feature models an HSP 94122-inspired rear-wheel-drive axle with a split
differential housing, lower arms, paired ball-socket hubs, shock tower, camber
links and metal drivetrain placeholders. The motor connection is a straight
4 mm-to-5 mm reducing sleeve on the differential input pinion.

**Status: dimensional prototype requiring hardware measurements before a fitted
suspension can be printed.** The reference arm is HSP 02149. Its documented
49 mm nominal length is supported by a 48.6–49 mm caliper measurement of the
reference arm. The HSP 02007 arm has a 69 mm envelope. Source photographs, manual
pages and measurement priorities are recorded in
[the HSP reference notes](../../../docs/hsp-94122-rear-reference.md).

## Measure the hardware

Open [rear_measurements.scad](rear_measurements.scad), select **Top** and
**Orthogonal** in the View menu, then **Zoom to Fit**. The `view` setting selects
`all`, `housing`, `hub_front`, `hub_side`, `hub_link`, `stud`, or `gear`.

The cards identify physical datums. Purple crosses indicate centers and
orange lines indicate physical reference faces. Dashed circles locate balls
inside the lower hub sockets. The silhouettes are locating sketches; their
proportions are not a source of measurements.

| Letter | Datum and measurement status |
| --- | --- |
| A | Housing mounting face to inner arm hinge-pin center: derived from the shared front housing, 3.95 mm. |
| B | Housing mounting face to input-pinion center: explicit installation datum in `rear_housing_spec`. |
| C | Lower hub ball-center line to wheel axle: measured 10 mm vertically. |
| D | Wheel axle to upper camber-link hole: measured 28–29 mm vertically; nominal 28.5 mm. |
| E | Inboard bearing-seat opening face to lower ball-center plane, parallel to the axle. Requires verification. |
| F | Arm end face to installed ball-stud center, along the stud. Requires verification. |
| G | Measured crown outside diameter 38 mm; axial thickness 4 mm. |
| H | Inboard bearing-seat opening face to upper camber-link hole center, parallel to the axle. Requires verification. |

A and B are installation references, not additional caliper requests. The shared
front housing determines A. C and D establish the carrier's vertical datums;
the approximately 33.4 mm width and 50.4 mm height determine its outer envelope.
The 21.4 mm lower-ball spacing is derived from the measured width and two 12 mm
socket bosses, rather than a direct center-spacing measurement.

For E and H, use the mouth of the larger, inboard bearing seat, not the recessed
bearing shoulder. Report whether the center lies toward the wheel or toward the
differential from that face. For F, measure from the arm end face to the far
edge of the ball and subtract half the ball diameter; preserve the stud's
installed screw-in depth. A hidden ball center must be established from the ball
or its spherical socket, not assumed to coincide with an exterior boss face.

## Inspect the assembly

Open [rear_axle_assembly.scad](rear_axle_assembly.scad), or the entry point
[rear_suspension_assembly.scad](../rear_suspension_assembly.scad).

The vehicle frame is +X right, +Y forward toward the motor, and +Z up. The
origin is the differential axis projected onto the mounting plane. The native
rear chassis has the opposite Y direction; its eight shared bulkhead mounting positions
are transformed into this frame. The assembly does not change chassis length.
The existing chassis motor installation is not repositioned by this feature.

Both [rc_robot_assembly.scad](../../rc_robot_assembly.scad) and
[rc_chassis.scad](../../rc_chassis.scad) display the axle with
`show_rear_suspension=true`. `rear_suspension_settings` supplies the complete
visibility/fit plist. `show_rear_wheels_preview` displays wheels seated on the
rear shaft hexes; `show_wheel_tires` controls their tires. The suspension follows
`rear_suspension_joint_spacing` when `split_rear_suspension` is enabled, and moves
with the rear chassis joint. Dimension annotations use the assembled axle's tire
centers, excluding exploded spacing.

The lid's rounded crown cover follows the differential's gear diameter, axial
thickness and position. `rear_housing_spec` in
[structure_params.scad](structure_params.scad) sets `crown_cover_wall=2` mm,
`crown_cover_edge_r=1` mm and radial `gear_clearance=0.6` mm. The cover fits
within the housing reference box; mounting holes and shaft datums are independent
of its wall thickness.

The housing floor has a motor-side relief derived from the raised chassis joint
shoulder, with explicit clearance. The joint and its pin-end lands retain their
full material.

The rear chassis owns its mounting plate, controlled by
`show_rear_suspension_mount`; the integrated axle's `show_mount` setting is forced
false to avoid duplicating that plate. In suspension mode the pinion-side sleeve
owns the coupling preview. The gearbox's additional output shaft and coupling
preview are shown only in packaging mode (`show_rear_suspension=false`). The
physical geared output shaft remains controlled by `show_drive_shaft`.

The component specifications are complete property lists:

- [arm_hub_params.scad](arm_hub_params.scad): arm profiles, hinge pins, outer M5
  studs, unequal hub bearings, threaded socket plugs and spherical bushings.
- [rear_camber_link_params.scad](rear_camber_link_params.scad): the steering-link
  rod ends, spherical bushings and threaded shaft, with shared hardware dimensions.
- [hardware_params.scad](hardware_params.scad): differential, pinion, dogbones,
  wheel shafts, reducing sleeve and shocks. Comments distinguish source
  dimensions from design estimates.
- [structure_params.scad](structure_params.scad): printed clearances, mounting
  fits, tower, rendering toggles and inspection settings.

Call `rear_axle_assembly()` with every component plist and a resolved
`rear_chassis_layout()`. Each visibility toggle is explicit in
`rear_axle_settings`. Set `show_lid=false` to inspect the crown cavity, or set
`lid_lift` for an exploded housing view. `show_mount` displays the existing
mounting plate in the axle frame. Individual component modules provide anchors
and slot geometry in their own documented coordinate frames.

## Measured differential

[`differential.scad`](../../placeholders/differential.scad) owns the measured
hardware preset, `differential_spec()`, and the reusable `differential()` model.
Its output axle runs along Z in positive bounds. Save this inspection example
at the repository root:

```scad
use <scad/placeholders/differential.scad>
differential(pl=differential_spec(), anchor=[1, 1, 1], slot_mode=false);
```

The rear drivetrain adapter
places that axle along vehicle X and aligns the cup slots with the dogbone pins.

| Feature | Millimeters |
| --- | ---: |
| Crown outside diameter × thickness | 38 × 4 |
| Rounded case bounding box, excluding crown | 25 × 20 × 12.6 |
| Crown-plus-case axial span | 16.6 |
| Each support journal diameter × length | 9.17 × 4.25 |
| Each cup outside diameter × length | 9.17 × 10 |
| Cup wall / derived inside diameter | 1.63 / 5.91 |
| Cup bore depth / slot depth | 10 / 8.3 |
| Slot width | 2.25 |
| Overall axial length | 45.1 |

The installation preset specifies 10 × 15 × 4 bearings seated against the
crown/case shoulders with `bearing_shoulder_gap=0`. The 9.17 mm measured journals
leave 0.83 mm diametral clearance inside those assumed 10 mm bores. The physical
bearing/journal interface needs identification before the bearing fit is treated
as verified. Journal length, bearing width and shoulder gap are independent
parameters. Cup geometry does not establish the installed dogbone ball depth;
`cup_ball_depth` remains an explicit installation estimate.

## Fit diagnostics

`rear_axle_fit()` reports required dogbone pin-center distance, selected hardware
length, signed length error and joint angle for the configured suspension pose.
These diagnostics describe estimated cup and hub datums. They do not establish
that a shorter shaft should be purchased. The full-length measured shaft is
displayed without scaling, and orange points identify requested wheel-cup
centers. `require_stock_fit=true` rejects a mismatch larger than `fit_tolerance`.

The carrier's main barrel OD is 18.3 mm and its lower socket boss OD is 12 mm.
Its inner bearing seat leaves 1.6 mm radial material. The dogbone has a measured
61.2 mm overall length, 5.8 mm balls, 3.8 mm shank and 9.82 × 2 mm pins.
These caliper dimensions are recorded in `rear_dogbone_spec` in
[hardware_params.scad](hardware_params.scad); its 55.4 mm pin-center spacing
is the overall length minus one ball diameter.

The most consequential measurements are the differential cup's installed
dogbone ball-center depth, wheel cup's ball-center offset from its bearing face,
lower-arm stud projection, upper camber-eye axial offset, and crown/pinion mesh
position. The 02175 shock's
actual compressed and extended eye distances must also be measured; the shock
preset describes a 55 mm eye-distance upgrade with estimated travel.

Physical assembly confirms that the motor shaft fits the direct reducing sleeve.
The integrated CAD motor-fit report exposes a **3.45 mm radial offset** between the
geared output shaft and the pinion/sleeve axis. With axes aligned, the current
axial overlap would be **7.05 mm**, versus the sleeve's configured **10 mm** motor
engagement target (a 2.95 mm difference). The target engagement is a design
assumption. The radial offset identifies an error in the estimated installation
geometry, not incompatible physical hardware. Housing and pinion datums require
verified shaft heights and gear dimensions. Exploded suspension spacing intentionally separates the sleeve
from the fixed motor; it is excluded from assembled-fit interpretation.

The upright reference pose derives `wheel_center_z` from the front tire
profile and solved front-wheel orientation, including camber. The rear arm
rotates around its housing hinge to put both axles on a common tire tangent; the hub, wheel shaft, shock attachment and dogbone endpoints
follow the articulated geometry. `hub_camber_angle=0` is explicit. This is a
ride-height inspection pose, not a solved equilibrium under spring and vehicle
loads. The fixed camber-link hardware can still miss its requested mounting
point; endpoint markers expose that separate closure constraint.

The nominal touring-wheel rim clears the measured main bearing barrel and lower
socket bosses. The upper camber eye's estimated axial location intersects the
rim. Measurement H locates that eye relative to the bearing opening. The
`wheel_hub_collision` fixture provides the fit-review solid. Seating a wheel on
its hex does not establish carrier clearance.

At the configured datums, the shock tower intersects the differential envelope.
Its placement requires a clearance review before fabrication.

The gear models are clearance envelopes. Tooth profiles, backlash, bearing
preload, strength and full suspension travel are not validated. The motor shaft
must be coaxial with the pinion; a rigid sleeve does not accommodate offset or
angular misalignment.

## Printed parts and fasteners

The lower housing and upper body reuse the front bulkhead envelope. Their
mating plane follows the shared lower housing height. Crown, rotating case,
bearings and pinion have individual clearance envelopes. The motor-input
support follows the explicit input-axis height and pinion bearing span.
The lower housing and chassis expose all eight shared mounting passages. Four
bolts in the outer mounting group pass upward through the chassis and both
housing parts into captive nuts in the upper tabs. The retained group is
explicit in `mount_fastener_indices`; the inner group has no upper nut pockets.
Nuts load from above with the housing exposed.
Four insert seats attach the shock tower to the shared bulkhead mounting face;
`tower_insert_d` and `tower_insert_l` must match the selected insert.
The tower carries the inner camber-link mounting holes. Shock spacers and bolts
are shown at their mounting faces to expose access and clearance.

The arm thickness follows the 7.5 mm front-arm preset, leaving clearance below
its hinge on the 7.9 mm housing. The arm has M5 pilot holes for tapping and an
inner 3 mm pin retained by clips.
The hub accepts 15×10×4 mm inner and 10×5×4 mm outer bearings, with shoulders
between them. Its paired lower sockets use independently printable bushings and
threaded plugs; print a thread/ball fit sample before producing loaded parts.
Gears, bearings, shafts, pins, fasteners, ball studs, camber links, reducing
sleeve and shocks are hardware placeholders, not printable substitutes.

The camber links use `tie_rod_end()` and `tie_rod_shaft()` with the steering-link
hardware preset. Their fully inserted eye-center spacing is **39.7 mm**.
Fixed hardware is displayed without length scaling; endpoint markers identify the required outer
eye center. Rod-end thread engagement is a physical adjustment, and must be
specified before using it to close a different mounting-center distance.

Separate bed-oriented entry files are in [printable/](printable/):

- `rear_bulkhead_lower_printable.scad`
- `rear_bulkhead_lid_printable.scad`
- `rear_lower_arm_printable.scad` — print two.
- `rear_hub_printable.scad` — one carrier, two plugs and two bushings; print twice.
- `rear_shock_tower_printable.scad`

For example, from the repository root:

```sh
mkdir -p build/export/stl
openscad --backend=Manifold --enable=textmetrics --hardwarnings \
  -o "$PWD/build/export/stl/rear_bulkhead_lower.stl" \
  scad/suspension/rear_axle/printable/rear_bulkhead_lower_printable.scad
```

## Validation

Run `make tests` for the repository suite. Focused checks are:

```sh
.venv/bin/python tests/check_rear_axle_hardware_mesh.py
.venv/bin/python tests/check_rear_axle_structure_mesh.py
```

The OpenSCAD assertion files `test_rear_axle.scad`, `test_rear_arm_hub.scad` and
`test_hsp_rear_hardware.scad` check shared datums and dimensions.
`test_rear_suspension_integration.scad` checks chassis placement, wheel hex
seating and dimension datums; `test_rear_motor_fit.scad` checks coupling
alignment and engagement diagnostics. Mesh checks
verify connected watertight housing parts, tower bolt support, open bores,
top-loading nut access, reference-pose part separation, bearing/gear-envelope
clearance, dogbone ball clearance inside individual cups and the stepped sleeve
bores. Integration checks verify chassis-to-axle clearance and wheel-to-shaft
clearance. The wheel-to-hub interference is an explicit fit-review result,
not a passing clearance check. Cup clearance checks seat each joint individually; they do not override
the full-shaft mismatch. Static clearance does not prove bump/droop clearance or
load capacity.
