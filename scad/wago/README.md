# Wago 221 mounting bracket

`wago_bracket.scad` is a reusable cradle for the measured five-conductor connector
in `scad/placeholders/wago/wago_221.scad`. The defaults use **36.5 × 21.1 × 9.8 mm**
for the connector body. Wire-hole and lever details remain visual approximations;
they do not determine the cradle cavity.

The cradle has two releasable side clips, low end guides, an open wire face, a
solid supporting floor, rounded mounting ears, and two M3 clearance holes. The
front stops and retaining lips stay within the outer shoulders inferred from
the measured total width and the 6.9 mm conductor pitch. No latch recess or
unmeasured housing groove is assumed.

![Installed bracket](../../demo/wago/bracket.png)

[Roof placement preview](../../demo/wago/lid.png) ·
[Rear deck preview](../../demo/wago/rear-open.png)

## Start here

Open `demo/wago/placements.scad` and select `view`:

- `"bracket"`: installed five-conductor connector and mounting screws.
- `"variants"`: compact rear ears, side ears, and an illustrative smaller connector.
- `"rear"`: battery assembly with one automatic deck mount, one after-case mount,
  and two lid mounts.
- `"rear_open"`: the same deck with the battery and lid hidden for inspection.
- `"lid"`: the two lid brackets beside the lidar, facing opposite directions.

Open `scad/printable_parts/wago_bracket_printable.scad` to print the default
bracket. It is base-down at Z=0 and contains no placeholder hardware. The shared
`scad/printable.scad` plate also has a `show_wago_bracket` toggle.

```sh
make build/export/stl/wago_bracket_printable.stl
make build/export/3mf/wago_bracket_printable.3mf
```

## Component interface

```scad
use <scad/wago/wago_bracket.scad>

wago_bracket(
  pl=["clearance", 0.25,
      "mount_side", "rear",
      "clip_overlap", 0.5],
  anchor=[0, 0, 1],
  show_wago=true,
  show_bolts=true);
```

Paths above are relative to a file at the repository root. Use `use`, rather
than `include`, when importing the component's modules without its demo geometry.

| Property         |       Default | Meaning                                                   |
| ---------------- | ------------: | --------------------------------------------------------- |
| `wago`           |          `[]` | Hardware plist; shared measured defaults when omitted     |
| `clearance`      |       0.25 mm | Additional cavity clearance on each X/Y side              |
| `top_clearance`  |       0.25 mm | Space between housing top and lip underside               |
| `base_t`         |        2.4 mm | Flat floor and mounting-ear thickness                     |
| `wall_t`         |        1.6 mm | Side-wall and clip thickness                              |
| `clip_l`         |          8 mm | Length of each central clip along Y                       |
| `clip_overlap`   |        0.5 mm | Lip reach over the measured housing shoulder              |
| `clip_rise`      |        0.8 mm | Height of the sloped insertion face                       |
| `flex_gap`       |        0.8 mm | Gap between clip and low side guides                      |
| `stop_h`         |        2.5 mm | Front shoulder stops and rear stop height above the floor |
| `bolt_d`         |          3 mm | Nominal bolt size                                         |
| `bolt_clearance` |        0.3 mm | Diametral hole allowance; default hole Ø3.3 mm            |
| `ear_d`          |         10 mm | Mounting-ear diameter                                     |
| `mount_side`     |      `"rear"` | `"rear"` or `"sides"`; rear keeps the footprint compact   |
| `color`          | `"SlateGray"` | Preview color                                             |

Default rear-ear envelope: **40.2 × 34.8 × 13.25 mm**. Its mounting-hole centers
are `[5, 29.8]` and `[35.2, 29.8]` in canonical coordinates, a **30.2 mm** pitch.
The side-ear envelope is **60.2 × 24.8 × 13.25 mm**.

The wire face points toward **−Y**. The default `[1,1,1]` anchor places the full
printed envelope in positive X/Y/Z. `[0,0,1]` centers the footprint, with its
bottom at zero. The connector is offset within this envelope because the rear
ears occupy additional length. `wago_bracket_props(pl)` provides `size`,
`wago_pos`, `wago_size`, and `mount_holes` so consumers can use the same datums.

`slot_mode=true` emits only the mounting holes, starting at the bracket's base;
`slot_h` sets their depth. It preserves the printed body's anchor reference.
`show_bracket`, `show_wago`, and `show_bolts` control the independent preview
parts. `bolt_l` controls preview screw length, measured below the head.

For another connector, supply its measured width explicitly:

```scad
// 22.7 is an illustrative value: replace it with your measurement.
wago_bracket(pl=["wago", ["n", 3,
                          "conductor_size", [6.9, 21.1, 9.8],
                          "total_w", 22.7]]);
```

The optional placeholder detail keys are `hole_size_xz`, `lid_l`, `lid_t`, and
`thickness`. Changing these does not resize the cradle. Explicit `total_w=undef`
uses `n * conductor_size[0]`, leaving no shoulder; use `clip_overlap=0` for that
plain cradle. The component rejects lips that exceed the measured shoulder.
A narrow connector may require side ears to separate the two screws.

## Rear chassis placement

Configure `rear_wago_mounts` in
`scad/suspension/rear_suspension/rear_suspension_params.scad`, or pass the list to
`rear_suspension_layout(wago_mounts=...)`. The shipped list is empty, so existing
assemblies keep their current geometry until mounts are enabled.

```scad
rear_wago_mounts = [
  ["placement", "auto", "rotation", 270],
  ["placement", "after", "rotation", 180]
];
```

Each entry accepts:

- `placement`: `"auto"`, `"under"`, or `"after"`.
- `rotation`: any Z angle in degrees, about the bracket's footprint center.
- `bracket`: the complete bracket plist above.
- `gap`: minimum reserved margin around the footprint, default 3 mm.
- `service_h`: additional headroom above the clips, default 12 mm. Increase it
  for your actual lever sweep, fingers, or tools.
- `pos`: optional XY center in **native chassis coordinates**, used to request
  a particular under-case location. Use `placement="under"` to require it;
  auto may fall back when it does not fit.

Auto searches a conservative 2 mm grid within the case envelope. It checks the
motor, panels, support columns, maintenance opening, other brackets, and the
available height. It does not move the battery, motor, or panel holes, and does
not raise the case. A grid search can miss a very tight feasible position;
provide an explicit under-case `pos` when necessary.

If under-case placement is unavailable, `"auto"` uses `"after"`: a new row
beyond the existing components toward native **−Y**, at the flat joining edge.
This can lengthen the chassis plate and shift its joining-edge anchor relative
to the unchanged native hardware pattern. Multiple after-case mounts form
successive rows. Explicit `"under"` fails with a useful assertion if it cannot
fit. Hole cutters and brackets use the same resolved placement, including
rotation. Visibility toggles never remove the holes.

With the current project defaults, a bracket at 270° fits beneath the case,
with its wire face pointing outward toward −X.
See the example for the resolved layout and the after-case alternative.

## Multi-LiPo lid placement

Put a list under `lid.wago_mounts` in the case plist:

```scad
lid_spec = plist_merge(plist_get("lid", multi_lipo_packs_case),
  ["wago_mounts", [["pos", [-54, 0]],
                   ["pos", [54, 0], "rotation", 180]]]);
case_spec = plist_merge(multi_lipo_packs_case, ["lid", lid_spec]);

multi_lipo_pack_lid(case_spec,
                    show_wago_brackets=true,
                    show_lidar=true,
                    show_adapter=true);
```

Positions are XY offsets from the **canonical roof center**, before the case's
orientation is applied. Bracket rotations are local Z angles. Every entry can
also specify `bracket` and `gap` (2 mm by default). The validator rejects bracket
footprints outside the roof, overlaps with another bracket, and overlaps with
the lidar/adapter envelope. The existing lid size, rails, and lidar holes stay
fixed. The example positions fit the current roof dimensions.

`multi_lipo_pack_lid_on_case()` displays configured brackets by default;
`multi_lipo_pack_lid()` defaults to hiding them for a pure printed lid. Both
accept `show_wago_brackets` and `show_wagos`. Lid printable mode keeps the holes
and omits brackets and hardware. Print the brackets separately and bolt them on.

The mounting layout reserves envelopes, not routed wires or a measured lever
sweep. Route wires away from the lidar cable, ensure the lidar view remains
clear, and leave clearance for lid sliding with your actual wiring installed.

## Fit and verification

Print one bracket as a fit sample before making an entire set. The housing's
outer dimensions are measured, but the actual shoulder shape, lever travel,
printer compensation, and clip flex have not been physically validated. Insert
the connector from above and spread the side clips outward to remove it. Tune
`clearance`, `top_clearance`, `clip_overlap`, and `wall_t` for your printer and
material. A plain cradle (`clip_overlap=0`) does not provide vertical retention.

Mounting uses through bolts with nuts on the underside of the parent surface.
Check that the screw length covers bracket base + parent thickness + nut.
`wago_mounts()` previews an even-mm length with a 3 mm nut allowance, or accepts
`bolt_l` per mount; underside nut clearance still depends on the installation.

`tests/test_wago_bracket.scad` checks dimensions, orientations, layout fallback,
unchanged existing datums, and lid fit. `tests/check_wago_bracket_mesh.py` checks
connected solids, printing datum, placeholder/hardware clearance, positive clip
retention, hole alignment under arbitrary Z rotation, lid/chassis integration,
and rejection of invalid fits. Run `make tests` for the repository suite.
