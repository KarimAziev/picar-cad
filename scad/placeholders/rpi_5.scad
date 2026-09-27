/**

 * Module: Raspberry Pi 5 model
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../colors.scad>
include <../parameters.scad>

use <../core/pcb_grid.scad>
use <../lib/functions.scad>
use <../lib/holes.scad>
use <../lib/placement.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <ai_hat.scad>
use <gpio_expansion_board.scad>
use <motor_driver_hat.scad>
use <pad_hole.scad>
use <rpi_5_grid.scad>
use <servo_driver_hat.scad>
use <standoff.scad>

show_standoffs              = true;
show_ai_hat                 = true;
show_motor_driver_hat       = true;
show_servo_driver_hat       = true;
show_gpio_expansion_board   = true;
show_camera_ribbon_slot     = true;

rpi_camera_ribbon_slot_size = [rpi_csi_size[1], 1.6];
rpi_camera_ribbon_slot_gap  = 1.4;
rpi_camera_ribbon_slot_rows = 3;

rpi_plugged_usb_a           = ["left", [1], "right", []];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rpi_5_size
  ─────────────────────────────────────────────────────────────────────────────
  Return the canonical reference box used to anchor the Raspberry Pi.
  **Parameters:**
  - `size`: PCB width, length and thickness.
  - `usb_a_y_offset`: USB/Ethernet overhang beyond the PCB's +Y edge.
  **Returns:** `[width, length + overhang, pcb_thickness]`.
  This is the placement reference, excluding standoffs, HATs and component height.
 */
function rpi_5_size(size=[rpi_width, rpi_len, rpi_thickness],
                    usb_a_y_offset=rpi_usb_y_offset) =
  [size[0], size[1] + usb_a_y_offset, size[2]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rpi_5_oriented_size
  ─────────────────────────────────────────────────────────────────────────────
  Return the Raspberry Pi's reference box in the requested orientation.
  **Parameters:**
  - `orientation`: One of the six `with_orientation` axis conventions.
  - `size`: Canonical PCB width, length and thickness.
  - `usb_a_y_offset`: USB/Ethernet overhang beyond the PCB's +Y edge.
  **Returns:** Oriented `[x, y, z]` reference size, excluding accessory envelopes.
  A `rotate_z_180` half-turn does not change this reference size.
 */
function rpi_5_oriented_size(orientation="wlh",
                             size=[rpi_width, rpi_len, rpi_thickness],
                             usb_a_y_offset=rpi_usb_y_offset) =
  orientation_size(orientation, rpi_5_size(size, usb_a_y_offset));

module rpi_standoffs(standoff_height=rpi_standoff_height,
                     bolt_visible_h,
                     bolt_spacing=rpi_bolt_spacing,
                     bolt_offset=rpi_bolts_offset) {
  show_bolt = !is_undef(bolt_visible_h);

  translate([bolt_offset, bolt_offset, -standoff_height]) {
    four_corner_children(size=bolt_spacing,
                         center=false) {

      standoffs_stack(d=m2_hole_dia,
                      min_h=standoff_height,
                      thread_at_top=true,
                      show_bolt=show_bolt,
                      bolt_visible_h=bolt_visible_h);
    }
  }
}

module rpi_camera_ribbon_slots(thickness, anchor=[1, 1, 1]) {
  with_anchor(anchor=[anchor[0], 1, anchor[2]], size=[0, 0, 0], centered=true) {
    rows_children(w=rpi_camera_ribbon_slot_size[1],
                  gap=rpi_camera_ribbon_slot_gap,
                  rows=rpi_camera_ribbon_slot_rows,
                  anchor=anchor) {
      rect_slot(h=thickness,
                size=rpi_camera_ribbon_slot_size,
                center=true);
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rpi_5
  ─────────────────────────────────────────────────────────────────────────────

  Raspberry Pi 5 placeholder with mounting cutters and optional HAT stack.

  The PCB starts at `[0, 0, 0]`; the placement reference includes the +Y port
  overhang, but excludes component height, inserted plugs and accessories.
  `anchor`, `orientation` and `rotate_z_180` apply equally to solid and slot
  modes. The grid contains the visible components, not the mounting interfaces.

  **Parameters:**
  - `size`: PCB `[width, length, thickness]`.
  - `bolt_spacing`, `corner_rad`: Hole-center spacing and PCB corner radius.
  - `slot_thickness`, `mount_dia`: Mounting cutter height and shaft diameter.
  - `placeholder_hole_dia`, `bolt_offset`: Visible PCB hole diameter and inset.
  - `header_height`, `header_width`, `pin_height`, `header_cols`, `header_rows`:
    GPIO housing dimensions, pitch and contact counts.
  - `show_standoffs`, `show_ai_hat`, `show_motor_driver_hat`,
    `show_servo_driver_hat`, `show_gpio_expansion_board`: Accessory toggles.
  - `pad_hole_specs`: Mounting pad rings as `[diameter, color]` pairs.
  - `usb_a_size`, `csi_size`, `io_size`, `wifi_bt_size`, `pci_size`,
    `ethernet_jack_size`: Component reference sizes for the default grid.
  - `usb_a_x_gap`, `usb_a_edge_gap`, `usb_a_y_offset`: USB stack gap, left
    margin and USB/Ethernet overhang beyond the +Y board edge.
  - `rpi_usb_a_n`: Number of USB-A stacks.
  - `standoff_height`, `bolt_visible_h`: Standoff and visible bolt heights.
  - `camera_ribbon_slot`, `show_camera_ribbon_slot`: Ribbon cutter footprint
    and whether to include these cutters in slot mode.
  - `plugged_usb_a`: Plist of plugged socket indices under `left` and `right`.
  - `anchor`: Placement of the reference box on each axis: `1` positive,
    `0` centered, `-1` negative.
  - `orientation`: Axis convention accepted by `with_orientation`.
  - `rotate_z_180`: Additional half-turn about Z after orientation.
  - `slot_mode`: Render mounting/ribbon cutters instead of the placeholder.
  - `component_grid`: Optional complete `pcb_grid` plist. `undef` builds
    `rpi_5_grid` from the component parameters above. A supplied grid controls
    visible components only; it does not change holes or accessory mounting.
  - `debug_grid`: Show the component grid's cell outlines and dimensions.

  **Examples:**
  ```scad
  rpi_5(anchor=[0, 0, 1], debug_grid=true);
  rpi_5(component_grid=rpi_5_grid(csi_n=0, button=[]));
  ```
 */
module rpi_5(size=[rpi_width, rpi_len, rpi_thickness],
             bolt_spacing=rpi_bolt_spacing,
             corner_rad=rpi_offset_rad,
             slot_thickness=chassis_thickness,
             mount_dia=rpi_bolt_hole_dia,
             placeholder_hole_dia=2.5,
             bolt_offset=rpi_bolts_offset,
             header_height=rpi_pin_header_height,
             header_width=rpi_pin_header_width,
             pin_height=rpi_pin_height,
             header_cols=rpi_pin_headers_cols,
             header_rows=rpi_pin_headers_rows,
             show_standoffs=show_standoffs,
             show_ai_hat=show_ai_hat,
             show_motor_driver_hat=show_motor_driver_hat,
             show_servo_driver_hat=show_servo_driver_hat,
             show_gpio_expansion_board=show_gpio_expansion_board,
             pad_hole_specs=rpi_pad_hole_specs,
             usb_a_size=rpi_usb_a_size,
             csi_size=rpi_csi_size,
             io_size=rpi_io_size,
             wifi_bt_size=rpi_wifi_bt_size,
             pci_size=rpi_pci_size,
             ethernet_jack_size=rpi_ethernet_jack_size,
             usb_a_x_gap=rpi_usb_a_gap,
             usb_a_edge_gap=rpi_usb_a_edge_gap,
             usb_a_y_offset=rpi_usb_y_offset,
             rpi_usb_a_n=rpi_usb_a_n,
             standoff_height=rpi_standoff_height,
             bolt_visible_h=chassis_thickness - chassis_counterbore_h,
             camera_ribbon_slot=rpi_camera_ribbon_slot_size,
             show_camera_ribbon_slot=show_camera_ribbon_slot,
             plugged_usb_a=rpi_plugged_usb_a,
             anchor=[1, 1, 1],
             orientation="wlh",
             rotate_z_180=false,
             slot_mode=false,
             component_grid,
             debug_grid=false) {

  w = size[0];
  length = size[1];
  h = size[2];

  max_size = rpi_5_size(size, usb_a_y_offset);

  grid = is_undef(component_grid)
    ? rpi_5_grid(size=size,
                 bolt_offset=bolt_offset,
                 header_height=header_height,
                 header_width=header_width,
                 pin_height=pin_height,
                 header_cols=header_cols,
                 header_rows=header_rows,
                 usb_a_size=usb_a_size,
                 csi_size=csi_size,
                 io_size=io_size,
                 wifi_bt_size=wifi_bt_size,
                 pci_size=pci_size,
                 ethernet_jack_size=ethernet_jack_size,
                 usb_a_x_gap=usb_a_x_gap,
                 usb_a_edge_gap=usb_a_edge_gap,
                 usb_a_y_offset=usb_a_y_offset,
                 usb_a_n=rpi_usb_a_n,
                 plugged_usb_a=plugged_usb_a)
    : component_grid;

  with_orientation(from="wlh",
                   to=orientation,
                   anchor=anchor,
                   size=max_size,
                   rotate_z_180=rotate_z_180) {
    with_anchor(anchor=[0, 0, 1],
                size=max_size,
                centered=false) {
      if (slot_mode) {
        union() {
          translate([bolt_offset, bolt_offset, 0]) {
            four_corner_children(bolt_spacing,
                                 center=false) {
              counterbore(d=mount_dia,
                          h=slot_thickness,
                          bore_h=chassis_counterbore_h,
                          bore_d=rpi_bolt_cbore_dia,
                          autoscale_step=0.1,
                          sink=true,
                          reverse=true);
            }
          }
          if (show_camera_ribbon_slot) {
            translate([rpi_csi_position_x,
                       length - camera_ribbon_slot[1] / 2 ,
                       0]) {
              rows_children(w=camera_ribbon_slot[1],
                            gap=rpi_camera_ribbon_slot_gap,
                            rows=rpi_camera_ribbon_slot_rows,
                            anchor=[-1, -1, 1]) {
                rect_slot(h=slot_thickness,
                          size=camera_ribbon_slot,
                          center=false);
              }
            }
          }
        }
      }
      else {
        translate([0,
                   0,
                   show_standoffs ? standoff_height + bolt_visible_h : 0]) {
          union() {
            union() {
              color(green_3, alpha=1) {
                linear_extrude(height=h, center=false) {
                  difference() {
                    rounded_rect([w, length], r=corner_rad);
                    translate([bolt_offset, bolt_offset, 0]) {
                      four_corner_holes_2d(size=bolt_spacing,
                                           center=false,
                                           d=placeholder_hole_dia);
                    }
                  }
                }
              }
              if (show_standoffs) {
                rpi_standoffs(standoff_height=standoff_height,
                              bolt_visible_h=bolt_visible_h,
                              bolt_spacing=bolt_spacing,
                              bolt_offset=bolt_offset);
              }

              // Pad rings share the mounting datum, independently of the grid.
              translate([bolt_offset, bolt_offset, h]) {
                color(yellow_3, alpha=1) {
                  four_corner_children(size=bolt_spacing, center=false) {
                    pad_hole(bolt_d=placeholder_hole_dia,
                             specs=pad_hole_specs,
                             thickness=0.1);
                  }
                }
              }
              translate([0, max_size[1], 0]) {
                pcb_grid(grid=grid,
                         thickness=h,
                         debug=debug_grid,
                         mode="placeholder");
              }
            }

            translate([0,
                       0,
                       header_height + (h / 2) +
                       (show_ai_hat
                        ? ai_hat_header_height : 0)]) {
              if (show_ai_hat) {
                ai_hat(center=false);
              }
              translate([0,
                         0,
                         (show_servo_driver_hat
                          ? servo_driver_hat_header_height
                          : 0)
                         + (show_ai_hat ? ai_hat_size[2]
                            : 0)]) {
                if (show_servo_driver_hat) {
                  servo_driver_hat(center=false);
                }

                translate([0,
                           0,
                           (show_motor_driver_hat
                            ? motor_driver_hat_lower_header_height
                            : 0) +
                           (show_servo_driver_hat
                            ? servo_driver_hat_size[2]
                            : 0)]) {

                  if (show_motor_driver_hat) {
                    motor_driver_hat(center=false,
                                     show_upper_pin_header=show_gpio_expansion_board,
                                     show_lower_pin_header=true,
                                     extra_standoff_h=motor_driver_hat_upper_header_height);
                  }
                  let (extra_upper_header_height = show_motor_driver_hat
                       ? motor_driver_hat_upper_header_height
                       + motor_driver_hat_size[2]
                       : 0) {
                    translate([0,
                               0,
                               (show_gpio_expansion_board
                                ? gpio_expansion_header_height
                                : 0) + extra_upper_header_height]) {
                      if (show_gpio_expansion_board) {
                        gpio_expansion_board(center=false,
                                             show_nut=true,
                                             extra_standoff_h=extra_upper_header_height);
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

rpi_5(anchor=[1, 1, 1]);
