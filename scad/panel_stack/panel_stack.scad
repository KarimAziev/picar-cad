/**
 * Module: Buttons and fuses holder
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <control_panel.scad>
use <fuse_panel.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  panel_stack_size
  ─────────────────────────────────────────────────────────────────────────────

  Return the shared canonical panel footprint as `[width, length]`.
 */
function panel_stack_size() =
  let (fuses_size = fuse_panel_size(),
       buttons_size = control_panel_size())
  [max(fuses_size[0], buttons_size[0]),
   max(fuses_size[1], buttons_size[1])];

/**
  ─────────────────────────────────────────────────────────────────────────────
  panel_stack_bolt_spacing
  ─────────────────────────────────────────────────────────────────────────────

  Return the canonical mounting-hole center spacing as `[x, y]`.
 */
function panel_stack_bolt_spacing() =
  let (fuses_size = fuse_panel_bolt_spacing(),
       buttons_size = control_panel_bolt_size())
  [max(fuses_size[0], buttons_size[0]),
   max(fuses_size[1], buttons_size[1])];

/**
  ─────────────────────────────────────────────────────────────────────────────
  panel_stack_height
  ─────────────────────────────────────────────────────────────────────────────

  Return the height from the mounting plane to the highest panel's top face.

  **Parameters:**
  - `show_buttons_panel`: Include the controls panel.
  - `show_fuse_panel`: Include the fuse panel.
  - `show_standoff`: Include supporting and inter-panel standoffs.

  **Returns:** Structural height; zero when both panels are disabled.
  Switches, fuse holders, and fastener protrusions are outside this reference.
 */
function panel_stack_height(show_buttons_panel=true,
                            show_fuse_panel=true,
                            show_standoff=true) =
  (show_fuse_panel ? fuse_panel_height(show_standoff) : 0)
  + (show_buttons_panel ? control_panel_height(show_standoff) : 0)
  + (show_buttons_panel && show_fuse_panel && show_standoff
     ? fuse_panel_standoff_upper_height() : 0);

/**
  ─────────────────────────────────────────────────────────────────────────────
  panel_stack_oriented_size
  ─────────────────────────────────────────────────────────────────────────────

  Return the oriented structural reference size as `[x, y, z]`.

  **Parameters:**
  - `orientation`: `"wlh"`, `"whl"`, `"lwh"`, `"lhw"`, `"hlw"`, or `"hwl"`.
  - `show_buttons_panel`: Include the controls panel in the reference height.
  - `show_fuse_panel`: Include the fuse panel in the reference height.
  - `show_standoff`: Include standoffs in the reference height.

  The footprint remains shared even when a panel is hidden. Height follows
  `panel_stack_height()` and is independent of hardware visibility and slot depth.
 */
function panel_stack_oriented_size(orientation="wlh",
                                   show_buttons_panel=true,
                                   show_fuse_panel=true,
                                   show_standoff=true) =
  orientation_size(orientation,
                   concat(panel_stack_size(),
                          [panel_stack_height(show_buttons_panel,
                                              show_fuse_panel,
                                              show_standoff)]));

/**
  ─────────────────────────────────────────────────────────────────────────────
  panel_stack_oriented_bolt_spacing
  ─────────────────────────────────────────────────────────────────────────────

  Return the oriented mounting-hole center spans as `[x, y, z]`.

  **Parameters:**
  - `orientation`: One of the six `with_orientation` axis conventions.

  The zero component identifies the mounting-plane normal. This describes hole
  centers, excluding hole diameters and cutter depth.
 */
function panel_stack_oriented_bolt_spacing(orientation="wlh") =
  orientation_size(orientation, concat(panel_stack_bolt_spacing(), [0]));

/**
  ─────────────────────────────────────────────────────────────────────────────
  panel_stack
  ─────────────────────────────────────────────────────────────────────────────

  Render the controls/fuse stack or its matching chassis mounting slots.

  **Parameters:**
  - `show_fuses`: Show installed fuse holders.
  - `show_standoff`: Include supporting and inter-panel standoffs.
  - `show_buttons`: Show installed controls.
  - `show_buttons_panel`: Include the controls panel.
  - `show_fuse_panel`: Include the fuse panel.
  - `anchor`: Anchor in final oriented XYZ axes; defaults to `[1, 1, 1]`.
  - `show_cap`: Show fuse-holder caps.
  - `orientation`: `"wlh"`, `"whl"`, `"lwh"`, `"lhw"`, `"hlw"`, or `"hwl"`.
  - `panel_color`: Display color for panel geometry.
  - `slot_mode`: Render only mounting slots when true.
  - `slot_thickness`: Through-hole depth along canonical Z in slot mode.
  - `slot_bore_h`: Counterbore depth in slot mode.
  - `anchor_mode`: `"size"` for the structural box or `"bolts"` for hole centers.

  **Behavior:**
  Canonical geometry is centered on X/Y with its mounting plane at Z=0.
  Size mode uses the panel footprint and the height through the top panel;
  installed hardware and fastener protrusions may extend outside this box.
  Bolts mode uses `[bolt_spacing.x, bolt_spacing.y, 0]` at the mounting plane.
  Its zero-span axis stays on that plane for every anchor value.
  Solid and slot modes use the same reference, including panel/standoff flags;
  changing cutter depth never changes placement. Slots extend from the mounting
  plane along canonical +Z before orientation.

  **Examples:**
  ```scad
  panel_stack(orientation="lhw", anchor_mode="bolts", anchor=[1, -1, 1]);
  panel_stack(orientation="lhw", anchor_mode="bolts", anchor=[1, -1, 1],
              slot_mode=true);
  ```
 */
module panel_stack(show_fuses=true,
                   show_standoff=true,
                   show_buttons=true,
                   show_buttons_panel=true,
                   show_fuse_panel=true,
                   anchor=[1, 1, 1],
                   show_cap=true,
                   orientation="wlh",
                   panel_color=white_snow_1,
                   slot_mode=false,
                   slot_thickness=chassis_thickness,
                   slot_bore_h=chassis_counterbore_h,
                   anchor_mode="size") {
  assert(anchor_mode == "size" || anchor_mode == "bolts",
         "anchor_mode must be size or bolts");
  size = panel_stack_size();
  bolt_spacing = panel_stack_bolt_spacing();
  reference_size = anchor_mode == "bolts"
    ? concat(bolt_spacing, [0])
    : panel_stack_oriented_size("wlh",
                                show_buttons_panel,
                                show_fuse_panel,
                                show_standoff);

  with_orientation(from="wlh",
                   to=orientation,
                   size=reference_size,
                   anchor=anchor) {
    if (slot_mode) {
      four_corner_children(size=bolt_spacing, center=true) {
        counterbore(h=slot_thickness,
                    d=panel_stack_bolt_dia,
                    bore_d=panel_stack_bolt_cbore_dia,
                    bore_h=slot_bore_h);
      }
    } else if (show_buttons_panel && show_fuse_panel) {
      fuse_panel(show_fuses=show_fuses,
                 show_standoff=show_standoff,
                 bolt_spacing=bolt_spacing,
                 size=size,
                 panel_color=panel_color,
                 show_cap=show_cap,
                 show_bolt=true,
                 center=true) {
        control_panel(center=true,
                      show_buttons=show_buttons,
                      show_standoff=show_standoff,
                      panel_color=panel_color,
                      size=size,
                      bolt_spacing=bolt_spacing);
      }
    } else if (show_fuse_panel) {
      fuse_panel(show_fuses=show_fuses,
                 show_standoff=show_standoff,
                 bolt_spacing=bolt_spacing,
                 show_cap=show_cap,
                 show_nut=true,
                 show_bolt=true,
                 panel_color=panel_color,
                 center=true,
                 size=size);
    } else if (show_buttons_panel) {
      control_panel(show_buttons=show_buttons,
                    show_standoff=show_standoff,
                    bolt_spacing=bolt_spacing,
                    show_nut=true,
                    show_bolt=true,
                    center=true,
                    panel_color=panel_color,
                    size=size);
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  panel_stack_bolt_holes
  ─────────────────────────────────────────────────────────────────────────────

  Render four mounting counterbores using the same reference as `panel_stack`.

  **Parameters:**
  - `orientation`: One of the six `with_orientation` axis conventions.
  - `anchor`: Anchor in final oriented XYZ axes.
  - `slot_thickness`: Through-hole depth along canonical Z.
  - `slot_bore_h`: Counterbore depth.
  - `anchor_mode`: `"size"` or `"bolts"`; see `panel_stack`.
  - `show_buttons_panel`: Controls panel's contribution to the size reference.
  - `show_fuse_panel`: Fuse panel's contribution to the size reference.
  - `show_standoff`: Standoffs' contribution to the size reference.
 */
module panel_stack_bolt_holes(orientation="wlh",
                              anchor=[1, 1, 1],
                              slot_thickness=chassis_thickness,
                              slot_bore_h=chassis_counterbore_h,
                              anchor_mode="size",
                              show_buttons_panel=true,
                              show_fuse_panel=true,
                              show_standoff=true) {
  panel_stack(orientation=orientation,
              anchor=anchor,
              anchor_mode=anchor_mode,
              show_buttons_panel=show_buttons_panel,
              show_fuse_panel=show_fuse_panel,
              show_standoff=show_standoff,
              slot_mode=true,
              slot_thickness=slot_thickness,
              slot_bore_h=slot_bore_h);
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  panel_stack_print_plate
  ─────────────────────────────────────────────────────────────────────────────

  Lay the bare panels flat beside each other for printing.

  **Parameters:**
  - `show_buttons_panel`: Include the controls panel.
  - `show_fuse_panel`: Include the fuse panel.
  - `anchor`: Anchor of the combined layout; defaults to `[0, 0, 1]`.
  - `spacing`: Edge-to-edge gap between panels, in millimeters (nonnegative).

  Hardware and standoffs are omitted. Both panels start at Z=0; the reference
  height is the greater enabled panel thickness. With neither panel enabled,
  no geometry is emitted.
 */
module panel_stack_print_plate(show_buttons_panel=true,
                               show_fuse_panel=true,
                               anchor=[0, 0, 1],
                               spacing=2) {
  assert(is_num(spacing) && spacing >= 0, "spacing must be nonnegative");
  size = panel_stack_size();
  bolt_spacing = panel_stack_bolt_spacing();
  both = show_buttons_panel && show_fuse_panel;
  layout_size = [both ? 2 * size[0] + spacing : size[0], size[1],
                 max(show_buttons_panel ? control_panel_size()[2] : 0,
                     show_fuse_panel ? fuse_panel_size()[2] : 0)];

  with_anchor(size=layout_size, anchor=anchor, centered=true) {
    if (show_buttons_panel) {
      translate([both ? (size[0] + spacing) / 2 : 0, 0, 0]) {
        control_panel(show_buttons=false,
                      show_standoff=false,
                      bolt_spacing=bolt_spacing,
                      center=true,
                      size=size);
      }
    }
    if (show_fuse_panel) {
      translate([both ? -(size[0] + spacing) / 2 : 0, 0, 0]) {
        fuse_panel(show_fuses=false,
                   show_standoff=false,
                   bolt_spacing=bolt_spacing,
                   size=size,
                   center=true);
      }
    }
  }
}

panel_stack(orientation=panel_stack_orientation, anchor=[1, 1, 1]);
