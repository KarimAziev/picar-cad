# Power-module enclosure

The enclosure holds two PCBs end to end, with a removable insert-fastened lid,
independent wall openings and vents, cable-tie bridges, and optional wiring
passages through its floor and the supporting plate. The default hardware preset
is a Pololu D24V90F5 regulator and an INA260 sensor. Hardware dimensions and
connector locations come from their placeholders; shell features and labels are
configured in `step_down_enclosure_plist` in `scad/parameters.scad`.

The construction frame is centered on XY with the underside at Z=0. The regulator
runs along X; its input faces −X. The sensor is rotated 90° so its terminal faces
the regulator and its header faces +X. Face names follow this local frame:
**left −X, right +X, rear −Y, front +Y**. Equipment and vehicle assembly rotations
apply afterward.

## Configuration and percentage references

Pass a partial plist to `step_down_voltage_enclosure` or
`step_down_enclosure_printable`. The `insert`, `insert_mount`, `mount`, `fit`, `lid`, `wall_vents`,
`header_slot`, `cable_tie`, and `parent_slots` groups merge by key. Each wall,
its vents, the lid vents, and the lid text style merge independently. Lists of
openings or texts replace their complete list; `[]` clears it. Use
`"vents", ["enabled", false]` to disable a vent grid.

Dimensions accept numbers in millimeters or percentage strings. Plain numbers
are always millimeters, including values smaller than one. Percentage positions
start at the minimum of their reference box, rather than the model origin.

| Setting                                         | Percentage reference                                       |
| ----------------------------------------------- | ---------------------------------------------------------- |
| `distance`                                      | Smaller of the two PCB lengths along the packing direction |
| `board_clearance`                               | Smaller XY dimension of the board group                    |
| `end_clearance`                                 | Board-group length along X                                 |
| `top_clearance`, `bottom_thickness`             | Populated board-group height                               |
| `inner_size=[x,y,z]`                            | Automatically padded board envelope, axis by axis          |
| `board_pos=[x,y]`                               | Free XY space after subtracting the board-group footprint  |
| Wall `t` or fallback `side_thickness`           | Inner dimension perpendicular to that wall                 |
| Wall cutout `l`, `offset`; slot X position/size | Inner span along that wall                                 |
| Wall cutout `h`, `bottom`; slot Z position/size | Inner height above the floor                               |
| Lid positions, slot sizes, vent sizes/gaps      | Outer lid XY dimensions                                    |
| Vent `margin=[left,right,bottom,top]`           | Corresponding panel span or height                         |
| Cutout/slot/vent `corner_r`                     | Smaller resolved opening dimension                         |
| `rim_chamfer`                                   | Smaller cutout dimension                                   |
| Vent `opening_gap`, opening `vent_gap`          | Smaller panel dimension                                    |
| Lid `t`, `lip_h`                                | Inner height                                               |
| Lid `lip_w`, `clearance`                        | Smaller inner XY dimension                                 |
| Lid `text_depth`                                | Lid thickness                                              |
| Text `size`                                     | Smaller lid XY dimension                                   |
| `mount.spacing`, `mount.pos`                    | Inner XY dimensions                                        |
| Tie `slot_size`, `bridge_w`, `end_dist`         | Corresponding inner XY dimension                           |
| Tie `recess_h`                                  | Floor thickness                                            |
| Parent slot `pos`, `size`, `margin`             | Inner XY dimensions                                        |
| Parent slot `min_width`                         | Inner dimension along the selected strip axis              |

The board layout determines the required cavity; the four wall thicknesses add
to it independently. Asymmetric walls move the cavity and its hardware together
inside the centered outer box. `board_pos=["50%","50%"]` centers the PCB group;
`[0,0]` seats its minimum corner at the cavity minimum. A position still needs
enough room for tie bridges and insert bosses.

```scad
step_down_voltage_enclosure(
  plist=["inner_size", ["110%", "120%", "130%"],
         "walls", ["left", ["t", 6],
                   "right", ["t", 3],
                   "front", ["t", 5],
                   "rear", ["t", 4]]],
  anchor=[0, 0, 1], exploded=18);
```

`step_down_enclosure_props(plist)` exposes resolved `inner_size`, `inner_min`,
`body_size`, `walls`, `panels`, `lid_panel`, connector-derived feature positions,
PCB mounts, insert bosses and the parent mounting interface. Impossible fits
produce an assertion: for example a boss intersecting a PCB, a tie path touching
a screw recess, or a screw bottoming in a blind insert pocket.

## Inserts, bosses and lid fit

`insert` is a hardware plist accepted by `heat_insert_nut_from_plist`:

```scad
step_down_voltage_enclosure(plist=[
  "insert", ["h", 5,
             "d", 3.2,
             "flang_d", 4,
             "flang_h", 1.6,
             "top_flang_h", 1.3,
             "bottom_flat_h", 1.6,
             "hole_d", 2]]);
```

The hardware body diameter is `d`; `flang_d` specifies the flange diameter and
`hole_d` specifies the nominal screw diameter. The placeholder owns its
`clearance`, `knurl_clearance`, `use_taper`, facet counts, color and
`bolt_head_type`. Its solid mode supplies the insert and lid screw; its slot
mode supplies the stepped or tapered pocket. Optional `bolt_l` and
`bolt_head_offset` arguments position a screw through a cover or in an exploded
view without moving the insert.

`insert_mount` contains the enclosure's material and assembly settings:
`wall`, `floor`, `depth_clearance`, `bolt_clearance`, and optional `bolt_l`.
The boss diameter is the larger of the hardware and cutter diameters plus twice
`wall`. Boss placement, vent keepouts and lid relief follow that dimension.
The pocket extends below the insert by `depth_clearance` plus the placeholder's
boolean overshoot. `floor` specifies material beneath the actual cutter bottom;
automatic enclosure height accommodates it.

For the default hardware and placeholder clearances, the pocket's shaft diameter
is **3.4 mm**, its maximum counterbore diameter is **4.6 mm**, and the bosses are
**7 mm** across. The insert is **5 mm** long and the pocket reaches **5.3 mm**
below the rim, including the 0.2 mm depth clearance and 0.1 mm cutter overshoot.
The lower flange intentionally intersects material before heat insertion;
this interference is confined to the flange, rather than treated as clearance
around the entire insert. `use_taper=true` adds the placeholder's taper.

The lid hole adds `insert_mount.bolt_clearance` to `insert.hole_d`.
`insert_mount.bolt_l` selects a stock screw length. If omitted, the modeled
length is lid thickness plus insert length; select a suitable stock length for
assembly. The screw must reach the insert without exceeding the pocket depth.

```scad
step_down_voltage_enclosure(
  plist=["inner_size", ["110%", "110%", "100%"],
         "insert", ["d", 4.6, "flang_d", 5.6, "h", 8, "hole_d", 3],
         "insert_mount", ["bolt_l", 10]]);
```

Insert diameter has no fixed maximum. A larger boss must still fit between the
PCB and the outer shell; increase `end_clearance` or `inner_size` when necessary.
The `fit` group separately controls PCB hole, head and nut-pocket clearances.
These are manufacturing allowances in millimeters, not board placement offsets.

The `lid` group controls `t`, `lip_h`, `lip_w`, and per-side `clearance`.
The lip follows the actual cavity, including asymmetric walls. Open-top wall
cutouts continue through the lip, with their resolved widths and rim chamfers.
`lip_h=0` omits the lip. The `header_slot` group controls connector access and
per-axis clearance around the sensor header's real footprint; `enabled=false`
omits that opening.

## Wall cutouts, slots and vents

Every face accepts `t`, `cutouts`, `slots` and `vents`. Each cutout is open at
the rim and has `l` along the wall, `offset` from its minimum span coordinate,
and either `h` down from the top or `bottom` above the interior floor. If both
height forms are present, `h` takes precedence. Default horizontal placement
centers the cutout. `corner_r` and `side` use the rounded-rectangle interface;
cutouts default to bottom-corner rounding. `rim_chamfer` opens the two rim edges.
These profiles are extruded through the thickness of their own face.

A slot is enclosed: `pos=[span,height]` gives its minimum corner and
`size=[length,height]` gives its dimensions. Slot rounding defaults to all four
corners. Walls may contain multiple cutouts and slots.

For hardware-aligned openings, `at` accepts `regulator`, `sensor`,
`sensor_terminal`, or `sensor_header`. It centers a cutout horizontally on the
projected connector/board center. On the lid it centers a slot in both axes.
These locations follow board placement and placeholder geometry.

```scad
step_down_voltage_enclosure(
  plist=["walls", [
    "front", ["t", 5,
              "cutouts", [["at", "sensor_terminal", "l", 11,
                           "bottom", "40%", "corner_r", "25%",
                           "rim_chamfer", 1]],
              "vents", ["opening_gap", 2, "opening_mode", "omit"]],
    "rear", ["slots", [["pos", ["40%", "35%"],
                         "size", ["20%", "20%"], "corner_r", 1]]]]]);
```

`wall_vents` supplies shared defaults; each face can override them. The lid has
its own `lid.vents` group. The grid uses `size`, edge-to-edge `gap`, four-edge
`margin`, and `corner_r`. Slots are centered in the remaining panel area. A grid
with no room for a complete slot emits no vents.

`opening_mode` controls interaction with openings and protected regions:

- `shorten`: shorten an intersecting vent below an opening; omit it if shorter
  than its width.
- `omit`: omit the entire intersecting vent.
- `clip`: trim the vent against the opening profile plus the specified gap.

`opening_gap` is the default solid separation; an individual opening can supply
`vent_gap`. Bosses are protected, and lid vent placement also accounts for the
actual measured and rotated text bounds.

```scad
step_down_voltage_enclosure(
  plist=["wall_vents", ["size", [2, "60%"], "gap", [3, 2]],
         "walls", ["rear", ["vents", ["enabled", false]]],
         "lid", ["vents", ["size", [4, 5], "gap", [3, 5]]]]);
```

## Labels

All label strings, positions and typography belong to `lid.texts` and
`lid.text_style`. Each text plist supplies `text_from_plist` typography and
rotation, plus `pos` or `at` for placement. `pos` is measured from the lid's minimum XY corner;
`at` follows a hardware reference. An optional numeric `translation` adds a
local XYZ adjustment. `text_depth` determines the engraving height and depth. The default
preset's electrical labels describe its regulated-output wiring arrangement.

```scad
step_down_voltage_enclosure(
  plist=["lid", ["texts", [["text", "POWER MODULE",
                            "pos", ["50%", "50%"], "size", 2.2]],
                  "text_style", ["font", "Liberation Sans:style=Bold"],
                  "text_depth", 0.4]]);
// A plain lid: plist=["lid", ["texts", []]].
```

## Tie bridges and parent wiring slots

`cable_tie.slot_size` gives each strap opening's XY dimensions. `bridge_w` is
the material between a pair; `recess_h` is the underside groove depth;
`path_clearance` widens that groove along X. `end_dist` locates the end pairs
inside the cavity. The optional `middle` pair follows the PCB gap. Use
`enabled=false` to omit all pairs. Paths must fit inside the cavity and leave
`bolt_clearance` around fasteners. The default slot size is 4.2 × 4 mm.

`parent_slots` is disabled by default. When enabled, the same wiring cutters
cross the enclosure floor and the plate below it. `slots="auto"` computes
open strips between projected keepout bands around PCB screw heads, chassis
nuts/heads, lid bosses and tie paths. Those bands continue across the floor so
mounts remain attached. `axis="x"` or `"y"` selects the strip direction;
`margin`, `bolt_clearance`, and `min_width` control the remaining material.

An explicit list of slot plists can restrict the cutout area. It uses the same
`pos`, `size`, and `corner_r` interface, relative to the cavity minimum. Explicit
openings are also clipped to the safe strips. A request with no free strip
produces no wiring opening. The resolved cutters are available through
`step_down_enclosure_parent_slots(p, parent_t)` for inspection.

```scad
step_down_voltage_enclosure(
  plist=["parent_slots", ["enabled", true, "slots", "auto"]]);

step_down_voltage_enclosure(
  plist=["parent_slots", ["enabled", true,
                          "slots", [["pos", ["10%", "20%"],
                                     "size", ["80%", "60%"],
                                     "corner_r", 1]]]]);
```

The default floor is 3.2 mm thick and holds captive M3 nuts. Chassis mounting
centers are `mount.spacing=[48.2,20.3]`; percentages are also accepted.
`mount.pos=["50%","50%"]` centers that pattern in the cavity, so it follows
asymmetric walls together with the boards. PCB
mounts and counterbores follow the placeholders. `slot_mode=true` emits these
parent mounting cutters and any enabled wiring slots through `parent_t` below
the shared mounting plane.

## Rear installation and printing

The preset's footprint is **84.2 × 29.3 mm**. The closed shell is **27.4 mm**
high; screw heads are included separately in the component's mounting envelope.
`rear_equipment_mixed` uses `kind="step_down_enclosure"`, `rotation=-90`, in the
native rear component's right corridor. That component rotates 180° in the
vehicle assembly. The regulator input therefore faces native chassis +Y.

The rear plate is **160.4 × 153.49 × 6 mm**; its overall bounds and power-case
mounting pattern are independent of enclosure customization. The battery
mounting height is 53 mm. A custom enclosure must fit the equipment solver's
available corridor and height; it cannot enlarge the chassis. See
[Rear-deck electronics](rear-equipment.md) for equipment placement.

Printable entry points:

- `scad/printable_parts/step_down_enclosure_base.scad`: upright tray on Z=0.
- `scad/printable_parts/step_down_enclosure_lid.scad`: outer lid face on Z=0.
- `scad/components/step_down_enclosure/printable.scad`: both separated parts.

The upright tray has counterbore shoulders, tie-groove ceilings, nut-pocket
edges and rounded vent tops. These can trigger slicer overhang detection.
Support decisions depend on the material, layer settings and bridge capability.
The lid prints with its locating lip upward. Preview hardware includes inserts,
lid screws, captive chassis nuts, PCB standoffs and PCB screws/nuts. Install
inserts and captive nuts before fitting boards and wiring.

The public assembly module supports `anchor`, `orientation`, `parent_t`,
`slot_mode`, `show_enclosure`, `show_hardware`, `show_lid`, `show_fasteners`,
`color_alpha`, `lid_color_alpha`, and `exploded`. The anchor uses the closed
reference envelope, including screw heads, even when the lid is exploded.
The file's `show_lid_at_the_side` control adds a separate lid view.

Cooling depends on electrical load, airflow and printing material. The
geometry does not establish a thermal rating.

## Validation

`tests/test_step_down_enclosure.scad` checks percentage equivalence, insert
sizing, independent panels, asymmetric walls, shared hardware datums, installed
rotation and fixed chassis/power-case interfaces.
`tests/check_step_down_enclosure_mesh.py` checks connected printable parts,
fit with hardware, counterbores, tool access, all four wall cutters and their
rounded corners, larger/longer inserts, independent vent patterns, safe parent
wiring slots, and all six orientations.
`tests/check_rear_equipment_mesh.py` checks the installed enclosure against the
motor, panels, battery case, columns and chassis mounting holes.
