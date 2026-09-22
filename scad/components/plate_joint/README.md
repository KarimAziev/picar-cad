# Plate joint

Start with [example.scad](example.scad): two real plates, one shared
`common_plate_joint()` configuration. The first plate adds a male tongue; the
second subtracts the matching female socket. Both subtract the full pin passages
at parent scope. Set `plates_assembly_spacing=0` to assemble, or increase it to
slide the second plate away for inspection.

All geometry is in [plate_joint.scad](plate_joint.scad), in this order: public
entry point, numeric base, bolt and pin cutters, male/female halves, shared
placement helpers. [plate_joint_parameters.scad](plate_joint_parameters.scad)
contains only dimension resolution. Import with `use <plate_joint.scad>`.

## Common wrapper

Required inputs are `plate_h`, `bolt_d`, and `l`, in millimeters. Width `w` may be omitted. Optional
arguments can be forwarded as `undef`; they use their normal defaults, including
flags, `mode`, and `anchor`.

```scad
module common_plate_joint(mode, slot_mode, show_bolts, anchor, flip) {
  plate_joint(plate_h=6, bolt_d=3.2, w=140, l=26,
              pin_d=3.1, pin_l=30, include_pin_holes=true,
              mode=mode, slot_mode=slot_mode,
              show_bolts=show_bolts, anchor=anchor, flip=flip);
}
```

| Call | Result |
| --- | --- |
| `mode="male"` | Male tongue with bolt and optional pin holes |
| `mode="male", slot_mode=true` | Bolt and pin cutters for the parent plate |
| `mode="female"` | Female joint body |
| `mode="female", slot_mode=true` | Socket, bolt and optional pin cutters for the parent plate |

A subtraction inside the tongue cannot drill a plate unioned outside it. The
example therefore subtracts male cutters from the complete first plate, and
female cutters from the complete second plate. Both calls use the same origin.

## Placement

The reference is the same nominal plate envelope used by the front-chassis joint.
The default anchor `[0,-1,1]`, also used for `anchor=undef`, places it at:

- X: `-w/2 .. w/2`
- Y: `-l .. 0`
- Z: `0 .. plate_h`

Anchor components select minimum (`1`), center (`0`), or maximum (`-1`) of that
envelope. Individual undef components use the corresponding default component.
Thus `[0,1,1]` places the joint at Y=0..l; `[1,0,1]` places it at
X=0..w, Y=-l/2..l/2, Z=0..plate_h. Clearance and root overlap do not move this
reference envelope.

In the example, plate A is at Y=0..90, plate B at Y=-120..0, and the tongue/socket
at Y=-26..0. No extra translation is needed to attach the tongue at their common
edge Y=0. The male root is Y=0 by default, the female root Y=-l.
`root_side` can explicitly select either edge (`1` or `-1`).

`flip=true` reflects all geometry with `z -> plate_h-z` before anchoring. X/Y and
the nominal envelope placement remain unchanged, including with `[1,0,1]`.
Pass the same flip/anchor to bodies and their cutters. Pin heights are specified
in the unflipped coordinate frame.

## Defaults from the working front joint

Fit dimensions are fixed millimeters; they do not scale with bolt diameter.

| Parameter | Default | Source |
| --- | --- | --- |
| `clearance` | 0.4 mm | `front_chassis_joint_clearance` |
| `axial_clearance` | resolved `clearance` | male free-tip setback |
| `boolean_overlap` | 0.02 mm | `front_chassis_joint_boolean_overlap` |
| `pin_compensation` | 0.4 mm | `sag_compensated_hole()` used by the front joint |
| `bolt_cut_overlap` | 0.1 mm | `counterbore()` cutter extension |
| `angle` | 20 degrees | `front_chassis_joint_rail_angle` |
| `rail_corner_r` | 0.4 mm | `front_chassis_joint_rail_corner_r` |
| `pin_d`, `pin_l` | 3.1 mm, 41 mm | front reinforcing pin |
| `pin_pad_l`, `pin_pad_w` | 5.5 mm, 2.5 mm | front pin flat |
| `pin_spacing` | `rail_w/2 + rail_w*0.35/2` | front pin spacing and recess proportion |
| `edge_land` | 0.45 mm | front relief land |
| `relief_depth` | 0 (disabled) | ordinary front joint calls do not enable relief |

The rail defaults to half the plate thickness, with the remaining thickness
split equally between base and bottom skin. The pin height is the center of the
combined base and rail: `plate_h-(base_h+rail_h)/2` (3.75 mm for a 6 mm plate).
Pins are enabled with `include_pin_holes=true`. Set `pin_l` to the actual pin
length: in the example, 30 mm through a 26 mm joint leaves 2 mm in each parent.
`pin_center=true` centers this length across the joint; `pin_direction=-1` points
along -Y. End flats are enabled with `pin_use_pad=true`.

The automatic rail targets **70% of `w`**. The outer bolt centers are
`x = ±(w+rail_w)/4`, at the centers of the remaining side strips. With `w=140`
this gives a 98 mm rail, two 21 mm strips and bolt centers at ±59.5 mm.
`bolt_spacing_center` is the total outer-center span `(w+rail_w)/2`.
Explicit span/count values continue to override the automatic layout.

If 70% leaves too little room for the side holes, automatic rail width decreases.
Each nominal side strip reserves `hole_d + 2*wall + 2*clearance`, so the
socket-side ligament retains `wall` (default 2 mm) after the proven 0.4 mm fit
clearance. The hole footprint includes the counterbore when enabled. If a narrow
explicit width cannot support side bolts and the rail, the automatic count falls
back to a center bolt. Explicit rail widths are never silently reduced.

With `w=undef`, the resolver finds width from the rail, pin cross section and side
bolt space while preserving the target rail proportion. For example:

```scad
plate_joint(plate_h=6, bolt_d=3.2, l=26, pin_l=30,
            include_pin_holes=true, show_sizes=true);
// w = 53.333 mm, rail_w = 37.333 mm
```

Pins run along **Y**: their length does not define the perpendicular X width.
The X calculation uses their diameter, spacing and the rail neck. `l` remains
explicit; `pin_l=30` with `l=26` still gives 2 mm engagement into each parent.
Increasing pin length does not artificially widen the component.

## Size diagnostics

`show_sizes=true` draws a text table beside the component using `text_rows()`
from `scad/lib/text.scad`. In the real two-plate example, toggle
`show_joint_sizes=true`. The table is preview-only, does not become printed
geometry, and is suppressed for slot calls to avoid duplicate annotations.

It includes overall dimensions, rail width/height, base skin, female floor after
clearance, side strips, bolt-edge/socket ligaments, and pin cover/engagement.
Remaining material below `sizes_min_wall=1.6` **millimeters** is marked `! THIN`
and colored red when not overridden by a parent `color()`; the THIN text remains
visible under parent coloring. Use `sizes_min_wall=16` if a 1.6 cm threshold is intended.
This parameter only changes diagnostics; it does not alter the part or reject a
configuration. `sizes_text_size` (default 3 mm) and `sizes_offset` (XYZ vector)
control readability and placement. The text stays upright with `flip=true` and
reports the reflected pin axis inside the nominal envelope.

For the current 6 mm plate with 3.1 mm pins, the report flags the 1.5 mm base,
1.1 mm female floor after fit, and approximately 0.5/0.45 mm cover above/below the
pin. Pin cover includes the sag-compensation envelope. The lateral pin-cover
entry uses the narrowest rail section as a conservative bound; these are
dimensional diagnostics, not a strength certification.

## Bolts and counterbores

**No counterbores by default:** `bolt_no_bore=true`. Thin plates get through holes
only. To request a recess, set `bolt_no_bore=false`. Its automatic diameter and
depth come from the selected `bolt_head_type` in the repository bolt library;
`bolt_bore_d` and `bolt_bore_h` override them. The default head type is `"socket"`.
Male recesses enter from the top and female recesses from the bottom.

`show_bolts=true` uses the repository's bolt placeholder, including its head
geometry. Without a recess the head rests on the top face; with a recess the
bolt is lowered by the resolved bore depth. Hardware is preview-only and follows
`flip`. It is not emitted by slot calls or included in printed exports.

## Explicit percentages

Optional dimensions still accept exact numbers or percentage strings, with or
without `%`. Omission/undef selects the defaults above; a percentage is an
explicit request to scale, not the default fitting rule.

| Percentage reference | Parameters |
| --- | --- |
| `w` | `rail_w`, `bolt_spacing_center` |
| `plate_h` | `rail_h`, `base_h`, `bolt_bore_h`, `boolean_overlap`, `bolt_cut_overlap`, `pin_z` |
| `rail_h` | `rail_corner_r`, `edge_land`, `relief_depth`, `pin_d` |
| `bolt_d` | `wall`, `clearance`, `bolt_bore_d` |
| `l` | `axial_clearance`, `pin_l` |
| `rail_w` | `pin_spacing` |
| `pin_l` | `pin_pad_l` |
| `pin_d` | `pin_pad_w`, `pin_compensation` |

`plate_joint_parameters()` exposes resolved dimensions as a property list for
lower-level calls. Its public arguments are documented in source. The geometric
helpers remain numeric. Validation covers malformed dimensions, missing required
sizes, collapsed profiles and invalid selectors; it does not impose a chosen
bolt/pin layout on explicit inputs.

## Verification

Run `make tests` and `uv run tests/check_plate_joint_mesh.py` from the repository
root. Checks include the real two-plate example, parent pin passages, forwarding
undef through a common wrapper, anchors/flip, default through-hole cutters, and
bidirectional mesh subtraction against the original front joint's rails, pins
and fit. The front comparison excludes bolt cutters because the new default
intentionally disables counterbores.
