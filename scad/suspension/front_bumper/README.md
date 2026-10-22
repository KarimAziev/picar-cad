# Front bumper

The bumper pairs a rigid, triangulated top retainer with a swept TPU 95A impact
body. Its silhouette takes inspiration from HSP 94122 parts 02009 and 02052;
its mounting interface fits this chassis. It is not a dimensioned replacement
for either commercial part. The head frame's forward extension provides space
between the bumper and the camera head's motion envelope.

## Parts and mounting

| Feature                    | Default                                      |
| -------------------------- | -------------------------------------------- |
| TPU envelope               | 163 × 42 × 16 mm                             |
| Top plate footprint        | 110 × 30 mm                                  |
| Top plate thickness        | 6.4 mm                                       |
| Integral compression posts | Three, Ø8 × 16 mm                            |
| TPU post passages          | Ø8.6 mm                                      |
| Side mounting centers      | 38 mm apart                                  |
| Center mounting hole       | 7 mm forward of the side holes               |
| Fasteners                  | Three M3 × 25 socket-head screws and M3 nuts |

The posts pass through the TPU and seat on the head frame. The rigid stack
is 28.4 mm tall with the configured 6 mm chassis: 16 mm posts plus 6.4 mm plate
plus 6 mm frame. Screw heads seat in the underside counterbores and nuts bear
in recessed hexagonal pockets. `front_bumper_bolt_params()` derives screw
engagement and tip clearance from the complete mounting stack.

Hardware direction is controlled by `front_bumper_reverse_bolts` in
`scad/rc_params.scad`. It defaults to true when both chassis counterbore dimensions
are positive. Set it to false for screw heads above the retainer and nuts beneath
the chassis. The plate and assembly also accept `reverse_bolts` for a per-call
preview override. The retainer has recessed nut pockets when screws point upward
and a flat top when screw heads sit above it.

The three centers come from `front_chassis_bumper_mount_positions()` in
`../front_chassis/front_frame_util.scad`. The mounting holes, bumper datums,
and hardware therefore share the same frame interface.
`front_chassis_bumper_extension` in `scad/rc_params.scad` controls the forward
nose extension independently of the head mounting position and chassis joints.
Zero places the mounting lands directly ahead of the head cable passage.
The TPU projects about 23.4 mm forward of the frame nose with the default
configuration.

## Head motion clearance

`front_chassis_bumper_extension = "auto"` derives the forward extension from
head travel and the bumper's rounded rear contours. A numeric value specifies
a fixed extension. The settings in `scad/rc_params.scad` are:

```scad
front_chassis_bumper_head_clearance = 2;
front_chassis_bumper_tilt_range = "auto";
```

The neck upright blocks downward tilt when the camera plate reaches its near
edge. `head_neck_lower_tilt_stop()` derives that angle from the tilt-axis position,
plate thickness and bracket dimensions: approximately 32.887° for this head.
Installed fasteners can require an earlier servo limit. Requested downward
travel is capped at that structural stop when calculating bumper clearance.
The bumper clears a complete pan turn throughout the configured tilt interval.

`front_chassis_bumper_min_extension()` returns approximately **13.990 mm** with
2 mm clearance and the configured hardware. The calculation uses the side-panel
outline, separate camera envelopes, and fastener allowances from
`head_neck_bounds`. It checks continuous tilt, including extrema between sampled
poses. Preview rotations, visibility toggles and `$t` do not affect the result.

The foam, retainer rails, mounting pads and hardware are checked at their own
heights. Their rear contours come from the same profile helpers used to build
the parts. The clearance expands the swept pan radius and each checked height
interval. The result is the minimum for these component envelopes and rounded
profiles; small hardware boxes and omitted cutouts remain conservative relative
to the meshes.

Use `front_bumper_plist` for vehicle-wide bumper changes. A per-call override can
be measured with `front_chassis_bumper_min_extension(pl)`; it does not alter the
frame's shared configuration. Verify head-to-chassis clearance separately when
selecting joint travel limits.

For visual inspection, open `front_bumper_assembly.scad`, enable `show_head`,
`show_top_plate` and `show_bolts`, and set tilt to 32.887° to inspect the lower
structural stop. Panning near neutral tilt checks the retainer-pad clearance.

## Open and print

- `front_bumper_assembly.scad`: bumper installed on the removable head frame.
- `top_plate_printable.scad`: rigid retainer with its top face on the bed and
  posts pointing upward; no hardware is included.
- `foam_printable.scad`: TPU body with its bottom face on the bed.

The parts have separate printable entry points because they use different
materials. Both accept a `bumper_pl` property list, including through the CLI's
`-D` option. Use the same overrides for both parts. The TPU mesh is a closed
envelope; wall count, top/bottom skins, and infill are controlled in the slicer.
TPU 95A is not specified here as a
mechanical equivalent to the reference foam. Establish compliance with a
printed sample and physical compression tests before relying on impact
performance. Check post fit and screw/nut access during the first assembly;
`post_clearance` is a diametral adjustment for the TPU passages.

Example exports from the repository root:

```sh
openscad --backend=Manifold --enable=textmetrics --hardwarnings \
  -o build/front_bumper_top_plate.stl \
  scad/suspension/front_bumper/top_plate_printable.scad
openscad --backend=Manifold --enable=textmetrics --hardwarnings \
  -o build/front_bumper_foam.stl \
  scad/suspension/front_bumper/foam_printable.scad
```

## Component interface

All components use width along X, forward along +Y, and height along Z.
Their default anchors are `[1, 1, 1]`, with reference bounds starting at zero.
The top plate's reference height includes its posts. Solid and slot modes use
the same reference box, including when `slot_h` extends the cutters.

The complete, commented configuration is `front_bumper_plist` in
[`scad/rc_params.scad`](../../rc_params.scad). It controls both parts, their
printable entries, the vehicle assembly and bumper-aware chassis measurements.

`front_bumper_params(pl)` validates the configuration and merges any per-call
overrides with that shared plist. Pass the same property list to the plate,
TPU body, placement helper and assembly. For example:

```scad
include <../../rc_params.scad>

use <../../lib/plist.scad>
use <common.scad>
use <front_bumper_assembly.scad>

pl = plist_merge(front_bumper_plist,
                 ["foam_h",          16,
                  "post_d",          9,
                  "post_clearance",  0.6,
                  "bolt_l",         25]);

translate(front_bumper_position(pl)) {
  front_bumper_assembly(pl, show_bolts=true);
}
```

`front_bumper_size(pl, part)` exposes reference dimensions, and
`front_bumper_mount_positions(pl, part)` returns the local bolt centers.
`part` is `"plate"`, `"foam"`, or `"assembly"`. The foam's slot mode emits post
passages; the plate's slot mode emits bolt passages.

The vehicle entry points `scad/rc_chassis.scad` and
`scad/rc_robot_assembly.scad` expose `show_front_bumper_top_plate`,
`show_front_bumper_foam`, and `show_front_bumper_bolts`. The bumper follows
`head_chassis_joint_spacing` when the head frame is separated for inspection.

## Verification

`tests/test_front_bumper.scad` checks mounting datums, component sizes, automatic
placement and the effects of travel, clearance, post diameter and bumper height.
`tests/test_head_neck.scad` checks the continuous sweep against analytic reference
shapes and dense tilt samples, including height-plane intersections.
`tests/check_head_neck_mesh.py` verifies the populated meshes stay inside the
envelopes and checks camera-plate contact immediately before and after the
calculated bracket stop.
`tests/check_front_bumper_mesh.py` checks connected, watertight solids, anchor
agreement between bodies and slots, clear bolt passages, supported post feet,
print orientation, and intersections with the TPU, head frame, and neutral
head. It exercises the configured stack and a variant with wider posts,
checks the nose extension with fixed rear/X/Z bounds, and tests
head tilt at -30 and +30 degrees with pan at zero. At the computed extension,
it checks six pan/tilt combinations for each of two bumper configurations,
including the bracket stop and near-neutral pad tangencies, with the bumper
displaced rearward by 2 mm to verify clearance.
These geometric checks do not establish impact strength or fatigue life.
