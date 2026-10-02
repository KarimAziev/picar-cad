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
The 33, 38, 39.5, 43–44, and 54 mm stock pins are too long for this placement;
the component rejects lengths that enter the bulkhead mounting keepout.
No frame length, head position, or bulkhead hole position changes.

The pin length, passage diameter, pin spacing, and rail width are configured in
`scad/steering_params.scad` under `front_chassis_head_joint_*`. Placement and
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

Both sit on Z=0 with their top faces on the bed. The head-frame geometry and
pin clearances are checked by `tests/check_front_head_joint_mesh.py`.
