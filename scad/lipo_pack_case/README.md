# Multi-pack power case and sliding lid

The case, rails, and lid share the `multi_lipo_packs_case` plist in
[`../steering_params.scad`](../steering_params.scad). Pack sizes and orientations
determine the cavity. Wall heights, lengths, and wiring cutouts determine the
supporting rim; the rails and matching lid follow those dimensions. An optional
removable plate adapts the lidar mounting pattern to accessible lid fasteners.

## Entry points

- `multi_lipo_pack_case.scad`: case with battery placeholders in the direct preview.
- `multi_lipo_pack_case_assembly.scad`: seated lid, batteries, and lidar.
- `multi_lipo_pack_lid.scad`: hardware-free lid in its roof-down print orientation.
- `multi_lipo_pack_adapter_printable.scad`: adapter underside on the bed, nut pockets up.
- `printable.scad`: case, lid, and enabled adapter separated on Z=0.
- `../suspension/rear_chassis/rear_power_case_printable.scad` and
  `../suspension/rear_chassis/rear_power_lid_printable.scad`: matched parts using
  the rear assembly's resolved floor thickness and mounting ears.
- `../suspension/rear_chassis/rear_power_adapter_printable.scad`: adapter matching
  the rear payload lid.

`multi_lipo_pack_case_assembly(slide=60)` shows sliding removal;
`multi_lipo_pack_case_assembly(lift=30)` gives an exploded view.
`show_packs`, `show_lid`, `show_adapter`, `show_lidar`, and `show_bolts` control the
preview. `show_bolts` includes the adapter fasteners as well as the rail locks.
Remove the transverse locking bolts before sliding the lid. Both slide ends
are open. The lidar and its mounting hardware move with the lid.

## Wall and cutout corners

Each wall (`front`, `rear`, `left`, `right`, or `inner`) accepts `corner_r`.
It rounds the two **top corners in the wall's length/height profile**; the
bottom corners remain square against the floor. It works with custom `l`,
`offset`, and `h`. Each entry in `cutouts` also accepts `corner_r`, rounding
only the **bottom corners of the opening** while keeping the top open.

```scad
"front", ["t", 2,
          "l", "90%",
          "corner_r", "20%"],
"right", ["t", 2,
          "h", "90%",
          "cutouts", [["offset", "30%",
                       "l", 12,
                       "h", 8,
                       "corner_r", 2]]]
```

Radii accept millimeters or percentage strings and default to `0` (square).
Percentages use the smaller of the retained wall's length and height, or the
cutout's own length and depth. For example, `"20%"` on a 40 × 20 mm wall gives
4 mm; `"25%"` on a 12 × 8 mm cutout gives 2 mm. Radii are capped at half the
smaller dimension, following the shared rounded-rectangle helper. Wall
thickness does not limit this side-profile radius.

The case-level `corner_r` still controls the footprint corners separately.
Rounding a cutout retains material at its lower corners, so check the wiring
clearance when increasing its radius. Adjacent walls still join as a union;
a perpendicular wall may fill a rounded corner where their material overlaps.

## Vent corners

Case walls accept `vent_corner_r` independently of their wall-top `corner_r`:

```scad
"front", ["t", 2,
          "corner_r", "20%",
          "vent_w", "20%",
          "vent_h", 2,
          "vent_pad", 5,
          "vent_corner_r", "40%"]
```

All four corners of each vent opening are rounded. Use a radius in mm, or a
percentage of the smaller **resolved vent width/height**. `"40%"` on a 2 mm
high, wider vent gives 0.8 mm; `"50%"` makes its ends semicircular. Larger
radii clamp to half the smaller dimension. The default is zero; grid spacing,
edge padding, and opening bounds are unchanged.

The dedicated `lid.vents` plist accepts the same `vent_corner_r` property and
also accepts `corner_r` as an alias. If both are present, `vent_corner_r` wins.
The current preset uses `"40%"` for case and lid vents.

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
  rail has support above footprint corners. The effective inset is at least
  the wall's resolved `corner_r`, keeping rails on the flat top after rounding.
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
        "corner_r", "5%",
        "adapter", ["t", 4,
                    "bolt_d", 3,
                    "corner_r", 3,
                    "standoff_h", 4],
        "side_t", 2,
        "headroom", 16.5,
        "color", blue_grey_carbon,
        "lidar", rplidar_c1_plist,
        "lidar_target_h", 17,
        "vents", ["vent_w", "12%",
                  "vent_h", 2.5,
                  "vent_col_gap", 5,
                  "vent_pad", 2]]
```

`t` is roof thickness. `corner_r` rounds the roof's XY outline and trims the
skirt tips to match. It accepts mm or percentages of the smaller roof dimension,
clamped at half that dimension; zero (the default) leaves square corners.
The current `"5%"` resolves to 2.98 mm. Roof thickness and the flat print face
stay constant; this is outline rounding, not a fillet on the upper/lower faces.

`side_t` is material around each channel. `headroom` is
clear space above the rail/channel before the roof. Vents use the case-wall
vent interface, within the skirt area above the dovetail channels.

The roof grows symmetrically to contain both the channel walls and the lidar
footprint plus `lidar_pad` (default 2 mm). It does not enlarge the battery cavity.
`lidar_offset=[x,y]` moves the sensor relative to the case center;
`lidar_orientation` is `"wlh"` or `"lwh"`. Hole spacing and countersinks derive
from the lidar plist. Omit `lidar` or set it to `undef` for an undrilled roof.
Hardware visibility does not change the printed part or its mounting height.

### Removable lidar adapter

Set `lid.adapter` to a plist to enable the plate; omit it or set
`["enabled", false]` for direct mounting. Omitting the lidar also disables the
adapter. The C1 preset uses a 55.6 × 55.6 × 4 mm plate with its actual
43 × 43 mm sensor pattern and a separate 43 × 27.95 mm lid pattern.
The lid receives only the adapter pattern when enabled; the original sensor
holes and countersinks move onto the adapter.

The adapter's automatic pattern follows the rail direction and keeps the
screw-head/tool paths clear of the skirts. It also leaves material between
its nut pockets and the sensor countersinks, including rotated/offset sensor
patterns. Both mounting patterns move with `lidar_offset`.

Adapter options:

- `t`: plate thickness (default 4 mm).
- `corner_r`: plate outline radius, mm or percent of its smaller dimension
  (default 3 mm), independent of the roof and vent radii.
- `bolt_d`: nominal lid-fastener diameter (default M3).
- `bolt_spacing`: optional `[x,y]` lid-side hole-center spacing in canonical
  case axes. The automatic spacing is preferred; unsafe overrides are rejected.
- `clearance`: diametral screw-hole allowance (default 0.3 mm).
- `nut_clearance`: allowance across the hex pocket flats (default 0.3 mm).
- `edge_pad`: minimum mounting-feature land/access margin (default 1.5 mm).
- `access_d`: diameter reserved for straight screw/tool access beneath the
  removed lid (default at least 6 mm and larger than the screw head).
- `standoff_h`: separate spacer height below the adapter (default zero; the
  current case preset uses 4 mm).
- `bolt_l`: countersunk screw's **total length including the head**. The
  default rounds roof plus spacer plus plate thickness up to the next even mm. Screws
  must engage the full nut and protrude at most 1.5 mm above the plate.

The current preset takes **four M3 × 12 mm countersunk screws and four M3 hex
nuts** for adapter-to-lid attachment. Hex pockets open from the **top** of the
adapter, leaving a solid shoulder underneath each nut so tightening clamps
the plate and its four spacers to the roof. Sensor mounting uses the existing M2.5 standoff interface
and underside countersinks on the adapter.

Assembly order:

1. Seat the M3 nuts in the adapter's top pockets. Temporarily retain loose nuts
   while handling the separate plate if needed.
2. Attach the lidar and its standoffs to the adapter, inserting their mounting
   screws through the adapter from below while that face is accessible.
3. Place the four printed spacers and sensor/adapter unit on the removed lid.
   Install its four M3 screws upward from the lid underside into the captured nuts.
4. Slide the complete lid onto the case and fit the transverse rail locks.

`lidar_target_h` remains the minimum sensor-base height **above the roof**.
The plate and adapter-spacer thicknesses are deducted before choosing sensor
standoffs. For the preset, 4 mm adapter spacers plus the 4 mm plate and 9 mm
sensor standoffs keep the sensor base 17 mm above the roof. Different dimensions can round up to the available standoff sizes.

The plain roof, adapter, and their hardware have separate visibility controls.
Standalone lid printing omits the adapter; print the adapter separately with
its underside on the bed and nut pockets up. The shared printable entry includes
the case, equipped lid, adapter, four spacers, button bracket, and the selected Wago cradles. Straight insertion checks supplement final-position
interference tests, addressing the original sensor holes' blocked access near
the channel skirts.

Legacy power-lid electronics openings are not enabled in this preset.

## Placement and resolved dimensions

`multi_lipo_pack_props()` returns the printed case envelope, including rails
and any mounting ears. `wall_size` describes the shell before rails;
`body_size` excludes mounting ears; `rail_props` supplies shared rail profiles,
segments, and locking-hole locations. The existing `wall_props` remains the
source of wall dimensions and cutout positions.

`multi_lipo_pack_lid_props()` returns the lid envelope and `mount_z`, measured
from the case floor underside to the bottom of the channels. Hardware is
excluded from that printed envelope, as is the separately printed adapter.
`adapter_props`, `adapter_h`, and `lidar_base_z` describe its interface and
the resolved sensor-base height in lid-local coordinates.

Use `multi_lipo_pack_lid_on_case()` with the same case `anchor` to assemble the
parts; it also handles mounting ears and whole-case orientation. Use
`multi_lipo_pack_lid()` for a standalone assembled-orientation lid, with its own
anchor. Its `slot_mode` emits the lidar and locking-hole cutters in that same
frame. `multi_lipo_pack_lid_printable()` turns the roof onto the bed and hides
all hardware. Pass the same pack clearances to matching case/lid modules when
overriding their 0.4 mm defaults.

## Optional Wago brackets on the lid

Add bracket specs to `lid.wago_mounts` for mounting holes on the existing roof.
Positions are canonical roof-center XY offsets, with independent Z rotations.
See [Wago bracket configuration and examples](../wago/README.md).

## Standalone power case

Open `standalone_assembly.scad` for the assembled case, `lid_example.scad`
for the equipped lid alone, or `standalone_printable.scad` for the complete
hardware-free print plate. The arrangement is configured directly in
`multi_lipo_packs_case` in `../steering_params.scad`, so the regular case assembly,
lid, and printable entry points use the same equipment and slots.
`standalone_parameters.scad` provides aliases for the example entry points;
it does not maintain a separate preset. To omit the equipment, override
`lid.equipment=[]` and `lid.fuse=undef` in a custom case plist.

The preset includes a concealed **ATM inline fuse holder**, a horizontal toggle
switch, two opposing Wago cradles for power and ground, and an optional centered
lidar adapter. Set `multi_lipo_lid_equipment_preset` in
[`steering_params.scad`](../steering_params.scad) to `"dual_wago"` (the default)
or `"meter"` (one Wago and meters in the remaining space). Both presets retain
the same switch clearance and concealed fuse mounting. The fuse lies flat beneath the roof, on two shallow bearing pads.
Two cable ties pass through four roof slots around its body, leaving the cap
accessible after sliding the lid off. The holder dimensions come from the ATM
placeholder; this preset does not represent the larger ATC/ATO holder.

`lid.equipment` is an ordered list of component plists:

```scad
["kind", "button",
 "component", toggle_switch_bracket_plist,
 "placement", "right",
 "rotation", 180]

["kind", "wago",
 "component", [],
 "placement", "left",
 "rotation", -90]

["kind", "voltmeter",
 "component", voltmeter_default_spec,
 "placement", "auto",
 "count", "fit"]
```

- `placement` accepts `auto`, `left`, `right`, `front`, or `rear`. These refer
  to canonical lid axes: left/right are −X/+X and rear/front are −Y/+Y.
  Placements rotate with the assembled case; they are not viewport directions.
- `pos=[x,y]` overrides automatic placement, relative to the roof center.
  It places the component's mounting datum, not the center of an asymmetric
  hardware envelope. `rotation` is applied about this datum before translation.
- `gap` is the minimum edge-to-edge clearance, default 1 mm.
- `enabled=false` omits both equipment and its holes.
- `count="fit"` repeats a component until no further copy fits. Put these
  entries last. The `meter` preset has room for one meter alongside the lidar.
  With `lid.lidar=undef`, the lidar and adapter holes disappear and meters
  repack around the fuse retaining ties. Omitting the fuse frees that area for
  additional meters. Omit `count` to require exactly one component.

The solver tests roof and obstacle boundaries in list order; it is a
conservative rectangular packing strategy, not an exhaustive nesting solver.
A requested placement that cannot fit reports an assertion. It checks the
rounded roof outline, component envelopes, and underside tool access between
rail skirts. The switch lever may overhang a roof edge, as in the illustration;
its sweep is still reserved against other equipment. Its base, terminals, and
wire opening stay on the roof. A Wago pair can explicitly allow a bounded
cradle overhang, while its mounting lands and shared opening stay on the roof.
Named-edge placements account for the rounded roof corners. All positions use component dimensions rather
than offsets derived from the battery's nominal size.

Mounting holes use underside countersinks. Wiring has separate passages beneath
the switch terminals, beneath each meter, and between the Wago's mounting ears.
The Wago passage is outside the connector's occupied tray. `wire_size` in the
button component changes its rectangular wiring opening. `terminal_extension`
reserves extra length for terminal attachments without changing the measured
switch placeholder or opening size. The current button mount sets it to one
terminal length (9.7 mm), allowing terminals and attachments totaling 19.4 mm.
This moves the bracket 9.7 mm away from its wiring opening along the bracket’s
local +Y axis while the opening retains its previous roof position. `wire_d` in a Wago
mount or meter component changes that component's round passage.

The `dual_wago` preset uses one compound equipment entry:

```scad
["kind", "wago_pair",
 "component", ["spacing", 2,
               "overhang", 7.9,
               "wire_pad", 1.5,
               "wire_r", 3],
 "placement", "right",
 "rotation", 0]
```

The cradles face opposite directions with their rear mounting ears inward.
`spacing` is the edge-to-edge gap between these ears. The shared rounded
opening fills the space between the ears and trays, less `wire_pad` on each
side. With the current hardware it is **16.7 × 19 mm**, with 3 mm corner radii.
All four underside countersinks remain separate from the opening. Both the
single-Wago passage and the pair opening extend 0.01 mm beyond each roof face.

`overhang` explicitly allows unsupported cradle length at each outer end;
it must leave at least two thirds of each tray length supported. The current
preset permits up to 7.9 mm and uses about 5.1 mm on each side of the unchanged
lid. The complete cradle envelope still reserves clearance from neighboring
equipment. Set `bracket` inside the pair's component plist to change the
connector or cradle; spacing, screw positions and the maximum opening then
follow those dimensions. Optional `wire_size=[width,length]` reduces the
opening, and `wire_r` sets its corner radius. The reusable
[`wago_pair.scad`](../wago/wago_pair.scad) module exposes matching solid and
slot modes and prints the two cradles separately, base-down.

`lid.fuse` accepts `holder` (the ATM hardware plist), `pos`, `rotation`,
`clearance` (default 1 mm), and `tie_size=[width,thickness]` (default `[3,1.2]`).
The holder must fit between the skirts and above the battery, and its tie slots
must clear mounting holes and roof equipment. Set `lid.fuse=undef` or
`enabled=false` to omit its slots and bearing pads. Retaining-tie heads should
sit below the lid, beside the holder. Route the internal wires with enough slack
for lid removal; the assembly preview shows hardware and passages, not a routed
wiring harness.

The adapter's `standoff_h` sets the height of four separate printed spacers.
The standalone preset uses 4 mm, with 12 mm M3 countersunk adapter screws;
spacer centers, bores, and screw lengths derive from the adapter's mounting
interface. The plate keeps its existing captive nuts. `lidar_target_h` measures
the sensor base height above the roof, including the spacers and adapter.
The print plate includes the case, equipped lid, adapter, four spacers, switch
bracket, and two Wago cradles: ten separate printed parts with `dual_wago`,
or nine with `meter`. The connectors, meter, and fuse holder are purchased hardware.

For example, swap the switch and paired Wagos in the default preset without
hand-positioning them:

```scad
swapped = [
  plist_merge(standalone_lid_equipment[0],
              ["placement", "right", "rotation", 180]),
  plist_merge(standalone_lid_equipment[1],
              ["placement", "left", "rotation", 0])
];
custom_case = plist_merge(standalone_lipo_case,
  ["lid", plist_merge(plist_get("lid", standalone_lipo_case),
                      ["equipment", swapped])]);
multi_lipo_pack_case_assembly(custom_case);
```

The switch bracket also exposes `button_bracket_props(pl)` with its printed
`size`, installed `bounds`, mounting holes, and wire opening. Its `slot_mode`
uses the same anchors and orientation as the solid and cuts downward through
`parent_thickness`. The standalone bracket print entry point is
`../components/button_bracket/printable.scad`.
