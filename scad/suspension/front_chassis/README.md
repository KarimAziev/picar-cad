# Front chassis plates

`front_chassis()` assembles the removable head plate, bulkhead/bellcrank plate,
and steering-servo plate at their existing vehicle coordinates. The complete
vehicle entry point is `../../rc_robot_assembly.scad`.

## Removable head

The split follows the taper between outline points 3 (`head_rear_y`) and 4
(`y2`). It steps around a central tab so all three camera ribbon slots, their
retaining strips, and the rear supporting land stay on the head plate. The two
side rails use `plate_joint`; the receiving bulkhead frame has the matching
socket and clearance around the central tab.

Use **two 33.8 × 3 mm pins**. Passages are 3.1 mm and
sag compensated. The current configuration has:

| Dimension                                                    |            Value |
| ------------------------------------------------------------ | ---------------: |
| Joint band in native Y                                       | 39.025–46.325 mm |
| Pin center X positions                                       |  −16.5, +16.5 mm |
| Pin ends in native Y                                         | 34.425–68.225 mm |
| Engagement beyond the socket into the bulkhead plate         |           4.6 mm |
| Pin-end clearance to the front bulkhead countersink envelope |             3 mm |
| Pin passage to ribbon opening, edge to edge                  |          4.95 mm |

The bulkhead-side pin ends are located from the mounting keepout plus the
configured wire land. Increasing pin length extends the passages toward the
head along +Y while preserving the bulkhead clearance and chassis engagement.
Each pin must engage at least 3 mm beyond both ends of the joint band.

The pin length, passage diameter, pin spacing, and rail width are configured in
`scad/rc_params.scad` under `front_chassis_head_joint_*`. Placement and
clearance checks live in `front_chassis_head_joint.scad` and derive the taper
and mounting-hole limits from the existing hardware interfaces.

For an exploded view in the vehicle assembly, set
`head_chassis_joint_spacing=20`; zero is the fitted position. The head mechanism
moves with its plate. In the lighter `front_chassis()` assembly, use
`head_spacing=20`, and optionally select plates with `show_head_frame`,
`show_front_frame`, and `show_rear_frame`.

`front_chassis_head_frame()` and `front_chassis_front_frame()` are defined
together in `front_chassis_front_frame.scad` to share the original outline and
hardware cuts. Export the separate printable entries:

- `front_chassis_head_frame_printable.scad`
- `front_chassis_front_frame_printable.scad`
- `front_chassis_rear_frame_printable.scad`

Each sits on Z=0 with its top face on the bed. The head-frame geometry and
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

The rear frame has male interfaces at both ends. Its 0.4 mm configuration
mates with sockets generated at 0.2 mm using the same nominal dimensions.
`tests/check_chassis_joint_bores.py` checks those printed-interface dimensions
against the receiving sockets. Printer-dependent fit can be evaluated with
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
25.515 mm pin-center spacing. The head joint has a 38.4 mm rail, outer bolt
centers at approximately X=±22.991 mm, and 33 mm pin-center spacing.
Its rail retains at least 0.60 mm beside the pin passages at the narrow neck.
Both mating parts share each bolt pattern and rail profile.

| Interface | Top recesses in male half | Underside recesses in female half |
| --- | --- | --- |
| Head / bulkhead plate | None | Both bolts countersunk, 1.95 mm deep |
| Bulkhead / steering-servo plate | Center bolt, 2.95 mm deep | Both outer bolts countersunk, 1.95 mm deep |
| Steering-servo plate / rear frame | Center bolt, 2.95 mm deep | Two outer bolts, 2.8 mm deep |
| Rear frame / rear suspension mount | None | Both bolts, 2.8 mm deep |

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
