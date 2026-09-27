# Multi-pack power case and sliding lid

The case, rails, and lid share the `multi_lipo_packs_case` plist in
[`../steering_params.scad`](../steering_params.scad). Pack sizes and orientations
determine the cavity. Wall heights, lengths, and wiring cutouts determine the
supporting rim; the rails and matching lid follow those dimensions.

## Entry points

- `multi_lipo_pack_case.scad`: case with battery placeholders in the direct preview.
- `multi_lipo_pack_case_assembly.scad`: seated lid, batteries, and lidar.
- `multi_lipo_pack_lid.scad`: hardware-free lid in its roof-down print orientation.
- `printable.scad`: case and lid separated for inspection/export, both on Z=0.
- `../suspension/rear_chassis/rear_power_case_printable.scad` and
  `../suspension/rear_chassis/rear_power_lid_printable.scad`: matched parts using
  the rear assembly's resolved floor thickness and mounting ears.

`multi_lipo_pack_case_assembly(slide=60)` shows sliding removal;
`multi_lipo_pack_case_assembly(lift=30)` gives an exploded view.
`show_packs`, `show_lid`, `show_lidar`, and `show_bolts` control the preview.
Remove the transverse locking bolts before sliding the lid. Both slide ends
are open. The lidar and its mounting hardware move with the lid.

## Rails

Omitting `rail`, or setting `"rail", ["enabled", false]`, preserves the case
without rails. The current preset enables:

```scad
"rail", ["axis", "auto",
         "h", 4,
         "angle", 12,
         "clearance", 0.2,
         "bolt_d", m2_hole_dia]
```

- `axis`: `"x"` puts rails on the rear/front walls; `"y"` uses left/right.
  `"auto"` selects the tallest opposing pair, choosing the longer pair on ties.
  Both walls must be at the highest outer-wall height. Axes and wall names are
  canonical, before the whole case's `orientation` transform.
- `h`: rail height above the wall, in mm. Rail width follows wall thickness.
- `angle`: profile taper angle in degrees. The shared profile is the existing
  `dovetail_rib()` helper from `lib/slider.scad`.
- `clearance`: outward offset of the female profile, in mm per face. It must
  retain an undercut; invalid combinations of clearance, height, width, and
  angle are rejected. The default is a starting print-fit allowance.
- `end_pad`: inset at both ends of each retained wall segment, in mm or a
  percentage of wall length. Defaults to the exterior corner radius so the
  rail has support above rounded corners.
- `bolt_d`: transverse clearance-hole diameter; zero omits locking holes.
- `bolt_pad`: distance from each end of the longest continuous rail segment
  to a locking-hole center, in mm or percent; default `"20%"`.

Rails stop over top-open wall cutouts. Their channels run continuously through
the lid so it can slide across those interruptions. Locking holes remain in a
continuous supported segment. The cavity and floor mounting pattern do not
change when rails are enabled.

## Lid

```scad
"lid", ["t", 3,
        "side_t", 2,
        "headroom", 10,
        "color", blue_grey_carbon,
        "lidar", rplidar_c1_plist,
        "lidar_target_h", 13,
        "vents", ["vent_w", "12%",
                  "vent_h", 2.5,
                  "vent_col_gap", 5,
                  "vent_pad", 2]]
```

`t` is roof thickness. `side_t` is material around each channel. `headroom` is
clear space above the rail/channel before the roof. Vents use the case-wall
vent interface, within the skirt area above the dovetail channels.

The roof grows symmetrically to contain both the channel walls and the lidar
footprint plus `lidar_pad` (default 2 mm). It does not enlarge the battery cavity.
`lidar_offset=[x,y]` moves the sensor relative to the case center;
`lidar_orientation` is `"wlh"` or `"lwh"`. Hole spacing and countersinks derive
from the lidar plist. Omit `lidar` or set it to `undef` for an undrilled roof.
Hardware visibility does not change the printed part or its mounting height.

Legacy power-lid electronics openings are not enabled in this preset.

## Placement and resolved dimensions

`multi_lipo_pack_props()` returns the printed case envelope, including rails
and any mounting ears. `wall_size` describes the shell before rails;
`body_size` excludes mounting ears; `rail_props` supplies shared rail profiles,
segments, and locking-hole locations. The existing `wall_props` remains the
source of wall dimensions and cutout positions.

`multi_lipo_pack_lid_props()` returns the lid envelope and `mount_z`, measured
from the case floor underside to the bottom of the channels. Hardware is
excluded from that printed envelope.

Use `multi_lipo_pack_lid_on_case()` with the same case `anchor` to assemble the
parts; it also handles mounting ears and whole-case orientation. Use
`multi_lipo_pack_lid()` for a standalone assembled-orientation lid, with its own
anchor. Its `slot_mode` emits the lidar and locking-hole cutters in that same
frame. `multi_lipo_pack_lid_printable()` turns the roof onto the bed and hides
all hardware. Pass the same pack clearances to matching case/lid modules when
overriding their 0.4 mm defaults.
