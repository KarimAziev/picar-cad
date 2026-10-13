# Front chassis plates

`front_chassis()` assembles the removable head plate, bulkhead/bellcrank plate,
and steering-servo plate at their existing vehicle coordinates. The complete
vehicle entry point is `../../rc_robot_assembly.scad`.

## Chassis split controls and printing

The shared controls in `scad/rc_params.scad` define four detachable boundaries.
All default to `true`.

| Control | Boundary |
| --- | --- |
| `split_head_chassis` | Head plate / front suspension plate |
| `split_front_chassis` | Front suspension plate / steering-servo plate |
| `split_rear_chassis` | Steering-servo plate / rear equipment deck |
| `split_rear_suspension` | Rear equipment deck / rear suspension mount |

Set a control to `false` to form continuous material across that boundary.
Joint tongues, sockets, retaining-pin passages and joint fastener holes are
omitted there. Equipment mounting holes, cable passages, suspension recesses
and the assembled chassis envelope remain fixed. Exploded spacing applies only
to detachable boundaries. Section visibility controls still select individual
regions for inspection; display every region in a merged group to see its full
shape.

Use `scad/suspension/chassis_printable.scad` to export a connected group. Its
`chassis_print_section` selector accepts any member of the group:

| Index | Section |
| --- | --- |
| 0 | Head |
| 1 | Front suspension |
| 2 | Steering servo |
| 3 | Rear equipment deck |
| 4 | Rear suspension |

For a single front suspension and steering plate:

```sh
openscad --backend=Manifold --enable=textmetrics --hardwarnings \
  -D split_front_chassis=false -D chassis_print_section=1 \
  -o build/front-suspension-steering.stl scad/suspension/chassis_printable.scad
```

For the front suspension, steering plate and rear deck as one part:

```sh
openscad --backend=Manifold --enable=textmetrics --hardwarnings \
  -D split_front_chassis=false -D split_rear_chassis=false \
  -D chassis_print_section=1 -o build/front-through-rear-deck.stl \
  scad/suspension/chassis_printable.scad
```

With all four controls false, every section selects the complete chassis.
With all four true, each index selects one plate. Group exports contain one
solid, sit on Z=0, and exclude hardware and annotations. Use this group entry
point for merged parts; component-local printable files emit their named region.

## Reference dimensions

Both `scad/rc_chassis.scad` and `scad/rc_robot_assembly.scad` provide these
preview toggles:

| Toggle | Measurement |
| --- | --- |
| `show_wheelbase` | Front-to-rear axle-center distance |
| `show_track_width` | Front and rear tire-center spacing across X |
| `show_ground_clearance` | Nominal tire ground plane to chassis underside |
| `show_overall_length` | Deck-and-tire envelope length, plus chassis-only length |
| `show_chassis_width` | Maximum chassis width, plus deck-and-tire envelope width |

Measurements use the assembled, unsteered reference pose, independently of
visibility, exploded spacing and articulated suspension settings. Track width
is center-to-center; overall width includes tire width. Overall dimensions cover
the deck and nominal upright tire envelopes, excluding elevated payloads and
accessories. Ground clearance is the chassis clearance with nominal tires; it
does not estimate loaded spring sag or clearance beneath protruding hardware.
The ground outline uses the lower of the front and rear upright tire tangents.
Rear axle position, track and height share the `rc_rear_wheel_preview_*` settings
with the wheel placeholders, so rear-dependent dimensions are packaging estimates.

Read horizontal dimensions from above and clearance from the right side. The
annotations appear only in preview and are excluded from STL and 3MF exports.

## Lowered suspension and steering

`suspension_chassis_mount_recess=2` sets the hardware mounting plane at Z=4 mm
above the chassis underside. Bulkhead, bellcranks, steering servo and rotary
encoder share that plane. The pocket between the bulkhead and bellcranks clears
the connecting arms. The suspension plate follows the HSP mounting footprint.
Servo and encoder pockets follow their bracket footprints with 0.2 mm clearance
per side, controlled by `suspension_chassis_mount_clearance`.
The servo case rim has an additional 0.25 mm relief, while its bracket feet sit
on Z=4 mm. Bellcrank dimensions, steering rod length and all suspension mounting
centers are fixed by their hardware interfaces.

The compact joint retains a full-height central spine around its pins at X=±6 mm.
Its rounded tip begins beyond the blind passage ends to preserve their material cover.
The wide joint also places its pins at X=±6 mm to clear the steering pockets
and equipment fasteners; its five bolts distribute clamping across the width.
The head joint and its pin passages sit beyond the suspension pocket. These
interfaces require matching mating plates. Joint regions and the main equipment
deck remain 6 mm thick.

Bulkhead and bellcrank screws use 1.95 mm deep countersinks from the underside;
servo and encoder screw seats are 2.05 mm deep. The remaining mounting material
is 2.05 mm and 1.95 mm respectively. A 3 mm recess would leave less than the
required 1.5 mm above these screw seats and is rejected. Use countersunk screws
at these seats.

`gearbox_bracket_thickness=8.5-suspension_chassis_mount_recess` gives a 6.5 mm
motor bracket. The complete vehicle places front and rear suspension references
2 mm lower relative to the chassis, increasing chassis ground clearance by
2 mm at the same suspension pose. Wheelbase and assembled chassis length are
independent of the recess depth.

`tests/check_chassis_mount_recesses.py` checks mounting surfaces, printable
solids and front hardware clearance at neutral, droop and steering poses.
At a +25° lower-arm angle, the arm placeholders intersect the HSP footprint
with both 6 mm and 4 mm mounting heights. The mesh check compares their overlap;
it does not establish clearance at that pose. Verify the actual suspension
travel on the fabricated hardware.
The measured rear mounting pattern defines the narrowed rear footprint; its
fabricated suspension's complete moving envelope is not modeled here.

## Removable head

The split sits beyond the lowered suspension footprint. It steps around a central tab so all three camera ribbon slots, their
retaining strips, and the rear supporting land stay on the head plate. The two
side rails use `plate_joint`; the receiving bulkhead frame has the matching
socket and clearance around the central tab.

Use **two 33.8 × 3 mm pins**. Passages are 3.1 mm and
sag compensated. The current configuration has:

| Dimension                                                    |            Value |
| ------------------------------------------------------------ | ---------------: |
| Joint band in native Y                                       | 48.5–55.8 mm |
| Pin center X positions                                       |  −16.5, +16.5 mm |
| Pin ends in native Y                                         | 45.5–79.3 mm |
| Engagement beyond the socket into the bulkhead plate         |           3 mm |
| Pin-end clearance to the mounting recess |             3 mm |
| Pin passage to ribbon opening, edge to edge                  |          4.95 mm |

The bulkhead-side pin ends are located from the mounting keepout plus the
configured wire land. Increasing pin length extends the passages toward the
head along +Y while preserving the bulkhead clearance and chassis engagement.
Each pin must engage at least 3 mm beyond both ends of the joint band.

The pin length, passage diameter, pin spacing, and rail width are configured in
`scad/rc_params.scad` under `front_chassis_head_joint_*`. Placement and
clearance checks live in `head_frame/head_joint.scad` and derive the taper
and mounting-hole limits from the existing hardware interfaces.

For an exploded view in the vehicle assembly, set
`head_chassis_joint_spacing=20`; zero is the fitted position. The head mechanism
moves with its plate. In the lighter `front_chassis()` assembly, use
`head_spacing=20`, and optionally select plates with `show_head_frame`,
`show_front_frame`, and `show_rear_frame`.

The head and suspension plates share their outline and hardware cuts through
`front_frame_util.scad`. Their component files live in `head_frame/` and
`suspension_frame/`; the steering-servo plate lives in `rear_frame/`.
Export the separate printable entries:

- `head_frame/head_frame_printable.scad`
- `suspension_frame/front_chassis_suspension_frame_printable.scad`
- `rear_frame/front_chassis_rear_frame_printable.scad`

Each sits on Z=0. The head plate prints top-face-down; the bulkhead and
steering-servo plates print underside-down with their mounting pockets upward.
Use local support beneath the bulkhead plate's raised male tongue; its main
underside is a connected first layer. The head-frame geometry and
pin clearances are checked by `tests/check_front_head_joint_mesh.py`.

## Joint fit and bolt recesses

The five chassis plates meet at four joints. `front_chassis_joint_clearance`
sets the female profile offset at all four interfaces; its default is 0.2 mm.
It affects X/Z fit, including the dovetail faces. It is a clearance fit, not a
specified interference fit. Pins and bolts provide the joint's retention.

`suspension_chassis_joint_layout_clearance=0.4` defines nominal rail sizing,
and `front_chassis_joint_axial_clearance=0.4` sets the male tongue's free-end
setback. Keep these datums fixed when fitting sockets to existing male parts.
Changing socket clearance does not move bolt or pin centers or resize the
nominal rail. A printed female socket retains its printed allowance; changing
the parameter only affects newly generated parts.

The wide front-to-rear interface uses fixed nominal male dimensions.
`tests/check_chassis_joint_bores.py` checks its nominal geometry at 0.4 mm clearance
against sockets generated with 0.2 mm clearance. Printer-dependent fit can be evaluated with
a small joint sample before printing a complete plate.

Set `suspension_chassis_joint_counterbores=false` for through holes only.
Enabled recesses use `chassis_counterbore_bore_d` and at most
`chassis_counterbore_h`, retaining `suspension_chassis_joint_bore_floor` beneath
the head and `suspension_chassis_joint_bore_wall` beside the bore. The defaults
are a 6 mm diameter, 1.5 mm floor, and 0.5 mm side wall.
`suspension_chassis_joint_bore_pin_land` reserves at least 1 mm beside pin passages.
Positions lacking this material retain through holes.

The compact front joint and head joint use a full counterbore when its depth
fits. Otherwise their female halves use `chassis_countersunk_bore_d` and
`chassis_countersunk_bore_h`: 6.1 mm diameter and 1.95 mm depth. These conical
seats take countersunk screws and retain at least 2.35 mm above the narrow end.
If neither full recess fits the configured walls and floor, the hole remains
a through hole.

The compact joint's outer bolts are at X=±23 mm, with a 37.8 mm rail and
12 mm pin-center spacing. The head joint has a 38.4 mm rail, outer bolt
centers at approximately X=±24.725 mm, and 33 mm pin-center spacing.
Its rail retains at least 0.60 mm beside the pin passages at the narrow neck.
Both mating parts share each bolt pattern and rail profile.

| Interface | Top recesses in male half | Underside recesses in female half |
| --- | --- | --- |
| Head / bulkhead plate | None | Both bolts countersunk, 1.95 mm deep |
| Bulkhead / steering-servo plate | Center bolt, 2.95 mm deep | Both outer bolts countersunk, 1.95 mm deep |
| Steering-servo plate / rear frame | Three middle bolts, 2.95 mm deep | Two outer bolts, 2.8 mm deep |
| Rear frame / rear suspension mount | Three middle bolts, 2.95 mm deep | Both outer bolts, 2.8 mm deep |

Top and underside refer to assembled vehicle coordinates. Cylindrical recesses are
0.35 or 0.5 mm shallower than the configured 3.3 mm recess depth. Head protrusion
depends on the screw's actual head height. Hole centers and nominal mating profiles are
independent of the recess toggle. Parts generated with the same bolt pattern
and nominal rail dimensions can mate with either recess setting.

## Upper steering bridge

The [upper steering plate](../upper_steering_plate.scad) ties the two stationary
bellcrank posts to the three existing bulkhead bosses. Its tapered outline,
scalloped rear edge and two rounded windows follow the wishbone styling. Hole
locations derive from the existing post spacing, bulkhead pattern and assembly
separation; the chassis and mounting parts are unchanged.

The default footprint is **59.8 × 38.5 mm**. The web is **3 mm** thick with
**6 mm** nominal ribs. Integral feet bring the overall height to **8.9 mm**:
5.9 mm at the posts and 5.1 mm at the bulkhead bosses. The web underside is
38.45 mm above the chassis top, calculated from the highest upper-holder barrel,
bellcrank housing, drive cap and servo lever, plus 0.6 mm running clearance.
The narrow post feet fit inside the modeled upper-bearing bores, contacting the
stationary posts without clamping the rotating housings.

- [Assembly preview](../upper_steering_plate_assembly.scad): change
  `lower_arm_angle` and `steering_angle`, or hide the bridge with `show_plate`.
- [Printable entry](../upper_steering_plate_printable.scad): top face on the bed,
  feet upward; no support is required by the modeled orientation.
- In `rc_robot_assembly.scad`, use `show_upper_steering_plate` and
  `show_upper_steering_plate_bolts`.
- Appearance and clearance parameters are grouped under “Upper steering panel”
  in `rc_params.scad`. The reusable part exposes `anchor`, `slot_mode`, `slot_h`
  and optional screw placeholders in the same coordinate system.

The placeholders use five M3 × 12 socket-head screws. The nominal engagement is
3.1 mm in the posts and 3.9 mm in the bulkhead, before any washers. Existing bore
models do not specify real thread engagement or inserts: confirm the actual
fasteners and thread form on the hardware. Check the small post-foot fit before
final tightening; no printer tolerance calibration or load test has been done.

Export from the repository root:

```sh
mkdir -p build/export/stl
openscad --backend=Manifold --enable=textmetrics --hardwarnings \
  -o build/export/stl/upper_steering_plate.stl \
  scad/suspension/upper_steering_plate_printable.scad
```

`tests/check_upper_steering_plate_mesh.py` checks a single watertight solid, five
bores and two windows, anchoring, print orientation, and zero-volume intersections
with the production suspension/bellcrank/servo assemblies at four sampled poses.
These checks do not certify strength or continuous clearance through every
possible motion and hardware configuration.
