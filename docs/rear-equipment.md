# Rear-deck electronics

The rear deck supports independent electronics in the free corridors beside the
motor. The corridors follow the **existing** plate edges, motor footprint and
start of the suspension taper. Panels, WAGO brackets and the four battery support
columns remain exclusion areas. Nothing in an equipment entry increases the
chassis width, length or battery height.

## Enable a loadout

In `scad/parameters.scad`, choose:

```scad
rear_equipment_specs = rear_equipment_mixed;
// Or: rear_equipment_meters, [], or a custom list.
```

The configuration initially uses `[]`, so selecting a loadout explicitly enables
its mounting holes. `rear_equipment_mixed` fits one voltmeter beside the fuse
panel, and a 20 × 80 mm perf board plus a rotated regulator on the opposite side.
`rear_equipment_meters` fits two voltmeters and one regulator.

Open `scad/suspension/rear_chassis/rear_equipment_example.scad` for the mixed
loadout with the case hidden and colored zones visible. It deliberately previews
the mixed preset independently of the production selection. To preview your
selection, replace its `equipment=rear_equipment_mixed` with
`equipment=rear_equipment_specs`.

The settings apply to `rear_chassis_frame.scad`, the chassis plate and their
assembly/printable callers through `rear_suspension_layout()`. A caller can
supply `rear_suspension_layout(equipment=...)` directly. Pass the same resolved
layout to the plate, hardware and cutters.

**Sides refer to chassis coordinates:** `left` is −X, `right` is +X. The annotated
September 30 screenshot looks in the opposite direction: its pictured left
(fuse-panel side) is `right`, and its pictured right is `left`.

## Entry options

| Key | Default | Meaning |
| --- | --- | --- |
| `kind` | Required | `voltmeter`, `step_down`, or `perf_board` |
| `component` | `[]` | The placeholder's hardware plist |
| `zone` | `"auto"` | `"left"`, `"right"`, or first available zone |
| `rotation` | `0` | Any Z rotation in degrees; 90/270 exchange width and length |
| `count` | `1` | Positive integer; repeated copies are placed independently |
| `position` | Automatic | Optional `[x,y]` fractions from 0 to 1 within the zone |

`position=[0,0]` aligns the rotated envelope to the minimum-X/minimum-Y corner;
`[1,1]` aligns to the maximum corner; `[0.5,0.5]` centers it. The envelope stays
inside the zone, and the placement must still clear obstacles. Native rear Y
increases from the flat joining edge toward the suspension. Thus `position` is
relative to geometry rather than a hardcoded chassis coordinate.

Automatic placement tries edge-aligned positions in list order. Put larger or
more constrained parts first. This is deterministic first-fit packing, not an
exhaustive packing optimizer: if an entry cannot be placed, change order,
rotation, zone or position. The solver does not silently rotate or omit a part.
Non-right-angle rotations use conservative axis-aligned envelopes.

```scad
rear_equipment_specs = [
  ["kind", "perf_board", "zone", "left", "rotation", 0],
  ["kind", "step_down", "zone", "left", "rotation", 90,
   "component", ["standoff_h", 8, "wire_d", 4]],
  ["kind", "voltmeter", "zone", "right", "rotation", 90,
   "component", ["text", "12.6"]]
];
```

`rear_equipment_gap` defaults to 3 mm between reserved envelopes, obstacles and
the battery floor. `rear_equipment_edge_margin` defaults to 3 mm and must be at
least the chassis corner radius. Fit includes mounting screw heads and actual
standoff heights. A populated perf board can reserve additional height via
`component_h`. Failed XY placement or height clearance produces an assertion
identifying the entry, dimensions, zone and rotation.

## Hardware and holes

- **Voltmeter:** existing `placeholder_size`, `slot_size`, `d`, `display`,
  `standoff_body_h`, `text`, etc. Its matching underside countersinks and central
  wiring passage are retained (`wire_d=4` by default).
- **Regulator:** existing `placeholder_size`, `bolt_spacing`, `d`, `standoff_h`,
  `vin` and `vout` terminal plists. The populated D24VXF5 model retains its
  physical PCB/component layout. Its deck mount uses four screw passages with
  underside counterbores; it does not copy the old lid's large terminal slots.
  `wire_d` optionally adds a center passage (default 0).
- **Perf board:** `size`, `slot_size` (mounting center spacing), `d`,
  `standoff_h`, `rows`, `cols`, copper-grid parameters and `component_h`.
  Defaults represent the existing 20 × 80 mm PCB, 16 × 76 mm mounting pattern,
  M2 mounting hardware and at least 2 mm requested standoff height (5 mm using
  the available hardware). Four underside counterbores are cut in the deck.
  `wire_d` optionally adds a center passage (default 0).

For a different physical perf board, set its real dimensions and mounting
pattern together. Adjust `rows` and `cols` when reducing its size, so the copper
grid stays on the PCB. `component_h` reserves clearance; it does not invent a
model of the components soldered to the board.

`rear_chassis(show_equipment=false)` hides electronics while preserving the
configured holes. `show_equipment_zones=true` shows corridors with occupied
areas removed. Hide the case/lid to inspect the deck. Selecting `equipment=[]`
removes both electronics and their additional cutouts.

## Add another component type

1. Give the hardware a `*_mount_props(pl)` function returning its centered-XY,
   Z-positive `size`, `bolt_spacing` and `bolt_d`. Include protruding terminals,
   mounting hardware and populated height in the envelope.
2. Give it a matching mount module accepting `pl`, `parent_t`, `anchor`,
   `slot_mode` and `show_hardware`. Z=0 is the deck top; slots extend down through
   `parent_t`. `pcb_mount_slots()` in `scad/lib/slots.scad` supplies ordinary
   corner mounts, or the component may supply its own cutouts.
3. Register its props and renderer in `scad/components/deck_component.scad`.
   The zone solver and chassis cutters need no type-specific changes.
4. Add an envelope and mounting-alignment case to the equipment tests.

Validation: `tests/test_rear_equipment.scad` checks placement and fixed dimensions;
`tests/check_rear_equipment_mesh.py` checks rendered envelopes, through-holes,
underside recesses, plate connectivity, hardware clearance and rejected inputs.
