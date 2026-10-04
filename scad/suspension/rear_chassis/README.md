# Rear payload layouts

The rear frame is configured in
[`rear_chassis_params.scad`](rear_chassis_params.scad).
The default has one standalone control panel and one standalone fuse panel on
opposite sides of the motor, with the LiPo case and lidar above them.

```scad
rear_panel_specs = [
  ["type", "control",
  "side", "left",
  "orientation", "wlh"],
  ["type", "fuse",
  "side", "right",
  "orientation", "lwh"]
];
```

Each entry accepts:

- `type`: `control`, `fuse`, or `stack` (both panels vertically combined).
- `side`: `left`, `right`, or `auto`, in the rear plate's native coordinates.
  Auto selects the smaller occupied side. Later entries include previously
  placed panels in that decision; repeated sides are placed successively outward.
- `orientation`: `wlh` or `lwh` for a horizontal panel.
- `gap`: Optional edge-to-edge gap from occupied space; defaults to
  `panel_stack_side_x_dist_from_motor`.
- `outside_case`: Optional control-only override of `rear_control_outside_case`.
- `y_offset`: Optional displacement from the motor footprint center; defaults to
  `panel_stack_y_offset`.

Use `rear_panel_specs=[]` for no panels. Two combined stacks are simply two
entries with `type="stack"`. For the old single-stack API, call
`rear_chassis_layout(panels=undef, power_case=undef, side="auto")`.
The legacy `panel_*` result entries refer to the first panel; new consumers
should iterate the `panels` list.

## Connection to the front chassis

The flat edge of `rear_chassis_frame()` has a male tongue that fits the wide
female socket in `front_chassis_rear_frame()`. Both use
`front_chassis_body_joint()` in
[`front_chassis_joint.scad`](../front_chassis/front_chassis_joint.scad), a chassis
preset built on the reusable `plate_joint`. Width, bolt positions, and pin spacing
come from the same preset. The compact front joint also uses this shared geometry.

At the default 160.4 mm chassis width, the wide joint has pin centers at
X = ±40 mm and bolt centers at X = −75.7, −45.05, 0, 45.05, and 75.7 mm.
The outer bolts have 3 mm of material between the hole edge and both the
chassis side and the female socket. The inner bolts retain 2 mm of material
beside the pin passages. The fuse-wire outlet follows the pin spacing and
preserves a 2 mm land beside its passage.

Configure these dimensions with `suspension_chassis_joint_wide_bolt_pad`,
`suspension_chassis_joint_wide_pin_spacing`, and
`suspension_chassis_joint_wide_pin_bolt_land` in `scad/rc_params.scad`.
`front_chassis_body_joint()` applies the same dimensions to both mating halves.

The rear plate's original joining edge remains at native `min_y`. With
`anchor=[0, 1, 1]`, that edge is at Y=0 and the tongue projects along -Y.
The vehicle assembly rotates the rear chassis 180 degrees around Z and places
that edge at `front_chassis_y_joint_2_end`. The tongue occupies the existing
socket; it does not increase the assembled chassis length. The anchor reference
and `rear_chassis_size()` describe the original plate envelope, excluding the
tongue projection.

In [`rc_robot_assembly.scad`](../../rc_robot_assembly.scad),
leave `show_middle_chassis=false` for the direct connection. Set
`rear_suspension_joint_spacing=0` for the fitted position, or increase it to slide
the rear chassis rearward for inspection. The rear chassis also follows
`front_chassis_joint_spacing`. With the optional middle deck enabled, the
assembly selects `front_joint=false` to retain its existing flat rear interface.

For a geometry-only view, open
[`front_rear_chassis_joint.scad`](../../../tests/fixtures/front_rear_chassis_joint.scad)
and change `spacing` between 0 and 25 mm. Export
[`rear_chassis_frame_printable.scad`](rear_chassis_frame_printable.scad) to print
the rear frame with its top face and both male tongues facing the bed.
The adjoining suspension plate has its own
[`rear_suspension_mount_printable.scad`](../rear_suspension/rear_suspension_mount_printable.scad)
entry, positioned on Z=0.

### Reinforcing pins

All chassis reinforcing pins are 3 mm diameter.

| Joint | Pin length | Quantity |
| --- | ---: | ---: |
| Head plate to bulkhead plate | 23.8 mm | 2 |
| Bulkhead plate to steering-servo plate | 39.5 mm | 2 |
| Steering-servo plate to rear chassis | 39.5 mm | 2 |
| Rear chassis to rear suspension mount | 39.5 mm | 2 |

The three 39.5 mm pairs use 40 mm long, 3.1 mm sag-compensated passages,
providing 0.25 mm of axial clearance at each end. The front joints engage
each parent beyond the joint band by approximately 12.73 mm; the rear
suspension joint provides 14.75 mm. The head joint uses its dedicated
23.8 mm passage and offset described in the [front chassis guide](../front_chassis/README.md).

The pin audit in `tests/check_chassis_pin_clearance.py` checks all four joints
against equipment holes, joint bolts, wiring cutouts, and the assembled plates.
It also checks the chassis envelopes and the outer bolt lands.

## Raised battery and lidar

`rear_power_case_plist` selects the case; `undef` removes its supporting columns,
mounting holes and contribution to the frame envelope. The selected case's
`lid.lidar` setting selects the sensor; `undef` leaves a plain sliding lid.
`rear_chassis_layout(lidar_plist=undef)` also permits an explicit sensor-free variant. Disabling the case's `rail`
specification omits both the sliding lid and lidar, retaining the case and its
mounting hardware. Visibility toggles on `rear_chassis()`
and `front_chassis_assembly()` do not resize the configured layout.

The case, lid and lidar are centered on chassis X=0, independently of the
asymmetric motor bracket. The rear preset fixes `bolt_spacing` for the printed
case. Without an explicit spacing vector, four symmetric columns are placed
outside the motor and panel footprints. Rounded floor ears reach the outboard
columns without enlarging the battery cavity or shifting the battery. Screw
recess dimensions do not move explicitly configured mounting centers. Battery
and lidar hardware dimensions stay fixed.

The default control panel has one master switch, configured by
`control_panel_switch_button_specs` in `scad/parameters.scad`.
`rear_control_outside_case=true` moves standalone controls toward the suspension
on the existing full-width deck. When the whole panel cannot clear the cover,
the low panel can overlap the case: only the levers must clear the cover edge by
`rear_control_case_gap`. The default control orientation is `wlh` to keep its
shorter dimension along Y. Fuse panels and combined stacks stay beside the motor.
A control entry can override the default with `"outside_case", false`.
Setting `rear_control_outside_case=false` restores placement under the case.

Each control has separate clearance regions for its low panel/stems and each
lever, including both switch positions. `control_panel_clearance_regions()`
exposes them relative to the panel anchor; each resolved rear panel also exposes
`clearance_regions` in chassis coordinates. Only regions overlapping the overhead
case/lid contribute to its required height. If the existing deck is too short
to clear a lever, that lever still raises the case; relocation never silently
ignores interfering hardware or shortens the suspension taper.
The motor/gearbox/encoder remains a height candidate.
`rear_power_case_clearance` adds vertical clearance; available standoff lengths
round upward. `rear_power_standoff_clearance` separates columns and screw-head
recesses from neighboring components. `rear_power_case_y_offset` shifts the case
along Y relative to the motor center.

With the current single-button configuration, the supports are 47 mm tall
instead of 67 mm with the controls underneath. The low panel overlaps the case
by 4.95 mm, while the lever clears the cover by 3 mm. This needs no additional
chassis length: the plate is 177.8 × 159.69 × 6 mm, with the original taper.
These are computed results, not fixed dimensions. The corrected motor offset
remains -1.8 mm.

The resolved case floor has recessed hex nuts to retain the standoffs' top studs.
The nuts sit below the battery surface, with solid floor material beneath them.
The rear mount preserves the selected case's `top_clearance` and its complete
`lid` configuration. Set roof thickness, automatic or numeric headroom, lidar
hardware, and `lidar_target_h` in the shared case plist in `scad/rc_params.scad`.
There is no additional rear-only pack clearance or lidar-height preset. With the
default case, the rear and standalone lid entry points produce identical geometry.
The sliding lid uses the case's shared dovetail profiles and transverse locking
holes. It supports the lidar on its own standoffs with the hardware's fixed
mounting-hole spacing and underside screw-head recesses. The lid's footprint
and mounting height come from the case and rail properties; the rear layout
uses that actual footprint when keeping the control levers clear.

See [the multi-pack case interface](../../lipo_pack_case/README.md) for rail,
clearance, lid, and preview settings. Export `rear_power_case_printable.scad`
and `rear_power_lid_printable.scad` for the matched rear payload parts. The lid
prints with its roof on the bed and its channels facing upward.

The layout result's `power_case` plist exposes the adjusted case `plist`, `pos`,
`size` (including ears), `body_size` (oriented case envelope before mounting ears), `mount_holes`, `bolt_spacing`, `target_h`, `mount_z`, `standoff_h`, and
`clearance_height`. `mount_z` is the battery floor above the chassis underside;
`standoff_h` is the hardware body length above the chassis top.

For direct `multi_lipo_pack_case()` use, `target_h` is the desired case-bottom Z
including `parent_thickness`. A zero target keeps the original unraised case.
Hiding standoffs does not move the case, and raised-mode chassis cutters stay
at the chassis plane. Raised cases require a horizontal floor (`wlh` or `lwh`).

## Standalone panels and printing

`control_panel()` and `fuse_panel()` accept `anchor`, `orientation`,
`anchor_mode="size"|"bolts"`, and `slot_mode`/`slot_thickness`/`slot_bore_h`.
The canonical reference spans the mounting plane through the top panel; use the
`*_clearance_height()` helpers for installed hardware above that reference.
Existing explicit `center=true/false` calls remain supported; `anchor` takes
precedence. Without either argument, the default is `[1,1,1]`.

```scad
control_panel(anchor=[0,0,1], orientation="lwh");
control_panel(anchor=[0,0,1], orientation="lwh", slot_mode=true,
              slot_thickness=6);
```

Printable entries:

- `scad/panel_stack/control_panel_printable.scad`
- `scad/panel_stack/fuse_panel_printable.scad`
- `scad/suspension/rear_chassis/rear_power_case_printable.scad`

The rear case printable uses the layout-generated spacing and adjusted floor;
use it instead of the generic case when printing this rear configuration.

## Shared chassis width

`suspension_chassis_width()` in `scad/suspension/computed.scad` selects the widest
front/rear requirement and, when `include_middle=true`, the middle payload.
The assembly passes that width to all three frames and recalculates the front
joint holes and rails from it. Front and rear standalone defaults also agree.

`rear_suspension_layout(min_width=0)` exposes the rear's own width candidate.
Its default minimum includes the front hardware and `chassis_body_min_w`.
Use `min_width=resolved_width` for the final rear layout, and `width=resolved_width`
for the front and middle frame modules when writing another orchestrator.
The existing `chassis_body_min_w` remains a configured lower bound even when
the middle section is absent. Selecting a middle payload as a candidate is
conditional on its presence, independently of that lower bound.

## Optional Wago mounts

The rear layout accepts `wago_mounts`, defaulting to `rear_wago_mounts=[]`.
Automatic placement uses available space beneath the battery before adding a
row toward the flat joining edge. Existing battery mounting datums stay fixed.
See [Wago bracket configuration and examples](../../wago/README.md).

## Power-case wiring preview

The rear payload displays the shared power harness automatically when the
selected case has `wiring.enabled=true` and its lid or lidar is visible. The
harness uses the resolved rear case and lid settings, including floor thickness,
case orientation, lid thickness and raised mounting height.

`rear_power_payload(..., show_wiring=false)` hides the added harness.
For an internal inspection, use `show_lid=false, show_lidar=false,
show_wiring=true`; roof equipment and its wiring remain visible.
`report_wire_lengths=true` prints lengths for the actual rear configuration.
At the rear chassis level, the equivalent visibility option is
`rear_chassis(..., show_power_wiring=true)` (or false to hide it).
With the wiring option omitted, hiding both lid and lidar also hides the harness.
Slot mode always emits only chassis mounting cutters.

The wiring follows the shared enclosure settings; visibility does not enlarge
that space. The switched-positive route passes beside the concealed fuse holder.
The default case uses automatic headroom and the same local harness geometry
in the standalone and rear-mounted configurations. See the
[wiring settings](../../lipo_pack_case/README.md#routed-standalone-wiring).
