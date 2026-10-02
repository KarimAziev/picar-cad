# RC gearmotor bracket and shaft encoder

The assembly uses five printed parts: the main motor base, a removable encoder
bracket, a shaft magnet sleeve, and separate front/rear gearbox supports. Open
[`gearbox_bracket.scad`](gearbox_bracket.scad) for the assembled view and
[`printable.scad`](printable.scad) for all five parts separated on Z=0.

The hardware preset and fit allowances live in
[`steering_params.scad`](../../steering_params.scad). The default hardware preset
uses a 61.10 mm shaft, a 13 mm drive-side extension, 7.2 mm end flats, a 3.95 mm
shaft diameter, a 3 mm single-flat thickness, and 2.1 mm cross-holes. The bracket
base is 6.5 mm thick. These measured values belong to the hardware plist; the
printed parts derive their interfaces from it.

## Coordinates and measurements

The bracket retains its native assembly frame: the shaft axis is X=0, the
mounting surface is Z=0, and the gearbox/motor reference plane is Y=0. The motor
and encoder extend toward +Y; the drive coupling extends toward -Y.

The bare shaft and magnet sleeve use a local +Z axis. Their default anchor
`[0, 0, 1]` preserves the shaft axis at X=Y=0 and the bottom at Z=0. Their anchors
refer to the circular envelope, even when the profile has a flat. A single flat
faces +Y. `flat_d` is the remaining thickness from the cylinder's -Y tangent to
the flat, **not** a radius or the depth removed. With two flats it is the distance
between them. `hole_edge_dist` is the gap from the shaft end to the nearest edge
of the cross-hole; add half the hole diameter to obtain the center offset.

The encoder sleeve opens toward the gearbox and covers the unused shaft's end
flat. Its assembly rotation `[90, 0, 180]` maps local +Z to assembly +Y and keeps
the single flat aligned with the shaft's +Z flat. `gearmotor_encoder_params()`
returns this rotation and the placement datum; consumers should reuse them.

## Sleeve and encoder calculations

[`driveshaft_magnet_sleeve.scad`](driveshaft_magnet_sleeve.scad) owns the sleeve's
resolved dimensions. It contains a shaft cup, a widening transition, an open
magnet pocket, and a retaining lip. Diametral clearance is added **before** adding
two wall thicknesses, so changing clearance does not consume the specified wall.

In local sleeve coordinates:

```text
shaft_tip_z     = pad_l
cross_hole_z    = pad_l - hole_edge_dist - hole_d/2
cup_h          = pad_l + sleeve_h_clearance
magnet_bottom  = cup_h
magnet_face    = magnet_bottom + magnet_h
printed_height = magnet_bottom + magnet_h + magnet_h_clearance
```

`motor_encoder_magnet_h_clearance` controls the lip only. A negative value exposes
the magnet face; a positive value recesses it. The magnet always sits on the
annular shoulder around the open shaft bore. No separating wall or membrane
bridges the bore. A recessed lip must leave a positive gap to the sensor.
`motor_encoder_sleeve_h_clearance` leaves space between the shaft tip and the
magnet pocket shoulder; it does not change cross-hole alignment.

The corresponding assembly calculations are:

```text
shaft_tip_y   = shaft_l - gearbox_thickness - shaft_rear_l
axis_z        = bracket_thickness + outer_shaft_y_center
sleeve_y      = shaft_tip_y - pad_l
magnet_face_y = sleeve_y + magnet_face_z
sensor_face_y = magnet_face_y + magnet_distance
pcb_back_y    = sensor_face_y + sensor_ic_height + pcb_thickness
```

The default resolved dimensions are:

| Dimension or datum                             |    Value (mm) |
| ---------------------------------------------- | ------------: |
| Shaft bore diameter / remaining flat thickness |   4.05 / 3.10 |
| Shaft cup outer diameter                       |          6.05 |
| Magnet pocket diameter / outer diameter        |   5.10 / 7.50 |
| Shaft tip to magnet pocket shoulder            |          0.20 |
| Printed sleeve height / magnet protrusion      |   9.10 / 0.30 |
| Sleeve cross-hole center above open end        |          2.25 |
| Assembly sleeve origin Y / shaft tip Y         | 22.90 / 30.10 |
| Assembly shaft and sensor axis Z               |         17.15 |
| Assembly cross-hole center Y                   |         25.15 |
| Magnet face Y / sensor face Y                  | 32.30 / 32.80 |
| PCB back Y                                     |         35.38 |

`gearmotor_bracket_compute_params()` in [`util.scad`](util.scad) includes the
encoder mount in the bracket's bounds and parent mounting-surface requirements.
The rear chassis consumes the same result. Set `motor_encoder_plist=undef` to
omit the encoder bracket, magnet and sleeve together. Assembly display toggles
`show_encoder_bracket`, `show_encoder`, `show_encoder_sleeve`, and
`show_encoder_magnet` independently control the four visible components.

For an alternative sleeve, pass a resolved `sleeve_params` to
`gearmotor_encoder_params()`. That specification also owns magnet dimensions.
Changing pad length moves the sleeve's open end while preserving the seated
magnet's distance from the shaft tip. Changing axial shaft clearance moves the magnet
and PCB together while retaining the configured face-to-face sensor gap.

## Removable supports

[`gearbox_boss.scad`](gearbox_boss.scad) provides a support and its locating socket.
The default front/rear support heights are 10.93 / 12.43 mm, including 2 mm of
engagement below the top of the base. Their diameter is 6 mm with a 3.2 mm bore.
The default socket diameter is 8 mm: `gearbox_bracket_boss_pocket_clearance=2`
is a **diametral** allowance, or 1 mm per side. The mounting bolt locates the
support within that socket.

The top faces sit 0.1 / 0.2 mm below the front/rear gearbox ears. A local relief
clears the gearbox bearing housing by 0.1 mm radially. Both the assembled support
and its printable version use this relief. Socket depth, support heights, motor
cradle relief and bounds resolve together in `gearmotor_bracket_compute_params()`;
passing `params` to a renderer preserves those resolved dimensions.

Load the encoder foot's captive nuts from below before attaching the main base
to the chassis. Seat the two supports in their sockets and install the gearbox
fasteners. Fit the sleeve with its flat and cross-hole aligned, retain it using
hardware appropriate for the shaft's cross-hole, then seat and secure the
magnet. The modeled clearances describe CAD fit; retention and printer fit still
need checking on the physical parts.

## Printing and validation

The feature has its own plate and individual entry files; it is not part of the
legacy two-motor plate in `scad/simple_robot/printable.scad`. All entries omit hardware and
place the printed parts on Z=0:

- `printable.scad`: all five parts with separation derived from their dimensions.
- `gearbox_bracket_printable.scad`: base only, with sockets but no loose supports.
- `gearmotor_encoder_printable.scad`: encoder bracket with its feet on the bed.
- `driveshaft_magnet_sleeve_printable.scad`: sleeve with its open cup on the bed.
- `gearbox_bosses_printable.scad`: both supports with socket ends on the bed.

From the repository root:

```sh
mkdir -p build/export/stl
openscad --backend=Manifold --enable=textmetrics --hardwarnings \
  -o "$PWD/build/export/stl/rc_gearmotor_parts.stl" \
  scad/motor_brackets/rc/printable.scad
make tests
```

The encoder mesh checks verify shaft/sleeve, magnet/shoulder, cross-hole, support,
electronics and fastener clearances. The sleeve checks also cover changed shaft
hardware, one/two flats, a recessed magnet, an outer flat, alternate anchors,
single-ended pin flats and all five printable components. Exported solids must
be watertight, consistently wound and free of duplicate or degenerate triangles;
a through-bore probe checks that no membrane closes the sleeve. Logic tests check
independent measured datums and propagation to the encoder and chassis.
