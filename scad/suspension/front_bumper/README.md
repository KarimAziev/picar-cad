# Front bumper

The bumper pairs a rigid, triangulated top retainer with a swept TPU 95A impact
body. Its silhouette takes inspiration from HSP 94122 parts 02009 and 02052;
its mounting interface fits this chassis. It is not a dimensioned replacement
for either commercial part. The head frame includes a 15 mm forward bumper
extension to provide clearance from the neutral camera head.

## Parts and mounting

| Feature                    | Default                                      |
| -------------------------- | -------------------------------------------- |
| TPU envelope               | 163 × 42 × 21 mm                             |
| Top plate footprint        | 110 × 30 mm                                  |
| Top plate thickness        | 3 mm                                         |
| Integral compression posts | Three, Ø8 × 21 mm                            |
| TPU post passages          | Ø8.6 mm                                      |
| Side mounting centers      | 38 mm apart                                  |
| Center mounting hole       | 7 mm forward of the side holes               |
| Fasteners                  | Three M3 × 35 socket-head screws and M3 nuts |

The posts pass through the TPU and seat on the head frame. Screws enter from
above the retainer and nuts bear against the frame underside. The rigid stack
is 30 mm tall with the default 6 mm chassis: 21 mm posts plus 3 mm plate plus
6 mm frame. A 35 mm screw leaves 5 mm below the chassis for a nut and thread
protrusion. The screw heads bear on the plate's solid circular pads.

The three centers come from `front_chassis_bumper_mount_positions()` in
`../front_chassis/front_frame_util.scad`. The mounting holes, bumper datums,
and hardware therefore share the same frame interface.
`front_chassis_bumper_extension` in `scad/rc_params.scad` controls the forward
nose extension independently of the head mounting position and chassis joints.
Its default is 15 mm; zero places the mounting lands directly ahead of the
head cable passage. The default frame nose is at vehicle Y = 130.825 mm.
The TPU projects about 23.4 mm forward of the frame nose with the default
configuration.

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
                  "bolt_l",         30]);

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

`tests/test_front_bumper.scad` checks the mounting datums and component sizes.
`tests/check_front_bumper_mesh.py` checks connected, watertight solids, anchor
agreement between bodies and slots, clear bolt passages, supported post feet,
print orientation, and intersections with the TPU, head frame, and neutral
head. It exercises the default stack and a shorter stack with wider posts,
checks a connected 15 mm frame extension with fixed rear/X/Z bounds, and tests
head tilt at -30 and +30 degrees with pan at zero.
These are geometric checks; they do not establish impact strength or fatigue
life, nor certify the head's complete pan/tilt swept volume.
