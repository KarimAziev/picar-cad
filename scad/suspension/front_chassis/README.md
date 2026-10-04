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

Use **two 23.8 × 3 mm pins** from the four available. Passages are 3.1 mm and
sag compensated. The current configuration has:

| Dimension                                                    |            Value |
| ------------------------------------------------------------ | ---------------: |
| Joint band in native Y                                       | 39.025–46.325 mm |
| Pin center X positions                                       |  −16.5, +16.5 mm |
| Pin ends in native Y                                         | 34.425–58.225 mm |
| Engagement beyond the socket into the bulkhead plate         |           4.6 mm |
| Pin-end clearance to the front bulkhead countersink envelope |             3 mm |
| Pin passage to ribbon opening, edge to edge                  |          4.95 mm |

The pin passages are centered on the head-side root, not the middle of the
joint. This offset keeps their lower ends clear of the bulkhead holes.
The 33, 38, 39.5, and 43–44 mm stock pins are too long for this placement;
the component rejects lengths that enter the bulkhead mounting keepout.
No frame length, head position, or bulkhead hole position changes.

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
