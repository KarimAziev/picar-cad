/**
  * Module: Suspension middle chassis.
  *
  * Provides a lightweight lattice deck for the paired power cases, Raspberry
  * Pi, and controls. Both ends carry wide male joints so the frame can be
  * printed with its upper face on the bed. The central volume remains available
  * for a future lidar tower above the electronics.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>
include <computed_params.scad>

use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>
use <../../panel_stack/panel_stack.scad>
use <../../placeholders/rpi_5.scad>
use <../../power/power_case_assembly.scad>
use <../front_chassis/front_chassis_joint.scad>

show_middle_chassis                   = true;
show_middle_chassis_components        = true;
show_middle_chassis_power_cases       = true;
show_middle_chassis_rpi               = true;
show_middle_chassis_panel_stack       = true;
show_middle_chassis_power_case_slots  = true;
show_middle_chassis_rpi_slots         = true;
show_middle_chassis_panel_stack_slots = true;

/**
  ─────────────────────────────────────────────────────────────────────────────
  middle_chassis_component_layout
  ─────────────────────────────────────────────────────────────────────────────

  Place all current middle-chassis components or their exact mounting slots.

  The heavy power cases occupy the outer, lowest lanes. The Raspberry Pi and
  control/fuse stack occupy the protected central lane. This leaves the center
  axis suitable for a future tower whose lidar can sit above every current
  component.

  **Parameters:**
  - slot_mode: Render mounting slots instead of component geometry.
  - show_power_cases: Show or cut the paired power-case mounts.
  - show_rpi: Show or cut the Raspberry Pi mount.
  - show_panel_stack: Show or cut the controls and fuse-panel mount.
  - anchor: Anchor vector for the complete middle-chassis envelope.
 */
module middle_chassis_component_layout(slot_mode=false,
                                       show_power_cases=show_middle_chassis_power_cases,
                                       show_rpi=show_middle_chassis_rpi,
                                       show_panel_stack=show_middle_chassis_panel_stack,
                                       anchor=[0, 0, 1]) {
  size = middle_chassis_size();
  front_y = middle_chassis_component_front_y();
  component_z = slot_mode ? 0 : middle_chassis_thickness;

  with_anchor(anchor=anchor, size=size, centered=true) {
    translate([0, 0, component_z]) {
      if (show_rpi) {
        translate([0, front_y, 0]) {
          rpi_5(show_standoffs=true,
                show_ai_hat=true,
                slot_mode=slot_mode,
                slot_thickness=middle_chassis_thickness,
                anchor=[0, -1, 1]);
        }
      }

      if (show_panel_stack) {
        translate([0, middle_chassis_panel_center_y(), 0]) {
          panel_stack(show_buttons=true,
                      show_standoff=true,
                      y_axle=false,
                      center=true,
                      slot_mode=slot_mode,
                      slot_thickness=middle_chassis_thickness);
        }
      }

      if (show_power_cases) {
        for (side = [-1, 1]) {
          translate([middle_chassis_power_case_center_x(side), front_y, 0]) {
            power_case_assembly(slot_mode=slot_mode,
                                slot_thickness=middle_chassis_thickness,
                                show_socket_case=false,
                                anchor=[0, -1, 1]);
          }
        }
      }
    }
  }
}

module _middle_chassis_lattice(color=white_smoke_1) {
  body_size = middle_chassis_body_size();
  w = body_size[0];
  l = body_size[1] - joint_l;
  h = body_size[2];
  rail_w = middle_chassis_rail_w();
  body_center_y = 0;
  center_rail_xs = concat(middle_chassis_center_rail_xs(),
                          [for (side = [-1, 1], bolt_side = [-1, 1])
                              middle_chassis_power_case_center_x(side)
                              + bolt_side * power_case_bottom_bolt_spacing[0] / 2],
                          [for (column = [0, 1])
                              -rpi_width / 2 + rpi_bolts_offset
                              + column * rpi_bolt_spacing[0]]);
  cross_rail_ys = middle_chassis_cross_rail_ys();

  maybe_color(color) {
    intersection() {
      cuboid([w, l, h], r=middle_chassis_corner_r);
      union() {
        mirror_copy([1, 0, 0]) {
          translate([w / 2 - middle_chassis_edge_rail_w / 2, body_center_y, 0]) {
            cuboid([middle_chassis_edge_rail_w, l, h]);
          }
        }

        for (x = center_rail_xs) {
          translate([x, body_center_y, 0]) {
            cuboid([rail_w, l, h]);
          }
        }

        for (y = cross_rail_ys) {
          translate([0, y, 0]) {
            cuboid([w, rail_w, h]);
          }
        }

        // Full-width crossmembers join every longitudinal rail to both tongues.
        for (side = [-1, 1]) {
          translate([0, side * (l - rail_w) / 2, 0]) {
            cuboid([w, rail_w, h]);
          }
        }

        // Diagonal webs brace the open grid against in-plane racking.
        for (side = [-1, 1]) {
          hull() {
            translate([side * (w / 2 - middle_chassis_edge_rail_w),
                       (l - rail_w) / 2, 0]) {
              cuboid([middle_chassis_diagonal_w, rail_w, h]);
            }
            translate([0, -(l - rail_w) / 2, 0]) {
              cuboid([middle_chassis_diagonal_w, rail_w, h]);
            }
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  middle_chassis
  ─────────────────────────────────────────────────────────────────────────────

  Build the anchored middle chassis with component slots and wide joints.

  **Parameters:**
  - color: Chassis display color.
  - show_power_case_slots: Cut the paired power-case mounting slots.
  - show_rpi_slots: Cut the Raspberry Pi mounting slots.
  - show_panel_stack_slots: Cut the controls and fuse-panel mounting slots.
  - anchor: Anchor vector for the complete chassis envelope.
 */
module middle_chassis(color=white_smoke_1,
                      show_power_case_slots=show_middle_chassis_power_case_slots,
                      show_rpi_slots=show_middle_chassis_rpi_slots,
                      show_panel_stack_slots=show_middle_chassis_panel_stack_slots,
                      anchor=[0, 0, 1]) {
  size = middle_chassis_size();
  rear_joint_y = -size[1] / 2 + joint_l;

  with_anchor(anchor=anchor, size=size, centered=true) {
    union() {
      difference() {
        _middle_chassis_lattice(color=color);
        middle_chassis_component_layout(slot_mode=true,
                                        show_power_cases=show_power_case_slots,
                                        show_rpi=show_rpi_slots,
                                        show_panel_stack=show_panel_stack_slots);
        for (y = [size[1] / 2, rear_joint_y]) {
          translate([0, y, 0]) {
            front_chassis_pin_joint_holes(
              rail_w=middle_chassis_joint_rail_w(),
              pin_spacing=middle_chassis_joint_pin_spacing());
          }
        }
      }

      translate([0, size[1] / 2, 0]) {
        front_chassis_joint_male(color=color,
                                 w=middle_chassis_joint_w(),
                                 rail_w=middle_chassis_joint_rail_w(),
                                 bolt_xs=middle_chassis_joint_bolt_xs(),
                                 pin_spacing=middle_chassis_joint_pin_spacing(),
                                 root_side=-1);
      }

      translate([0, rear_joint_y, 0]) {
        front_chassis_joint_male(color=color,
                                   w=middle_chassis_joint_w(),
                                   rail_w=middle_chassis_joint_rail_w(),
                                   bolt_xs=middle_chassis_joint_bolt_xs(),
                                   pin_spacing=middle_chassis_joint_pin_spacing());
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  middle_chassis_printable
  ─────────────────────────────────────────────────────────────────────────────

  Place the deck and both male-joint top faces on Z=0 for printing.
 */
module middle_chassis_printable() {
  translate([0, 0, middle_chassis_thickness]) {
    rotate([180, 0, 0]) {
      middle_chassis();
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  middle_chassis_assembly
  ─────────────────────────────────────────────────────────────────────────────

  Assemble the anchored middle chassis and its current electronics.

  The complete vehicle is composed by `front_chassis_assembly.scad`.

  **Parameters:**
  - show_middle_chassis: Render the middle lattice frame.
  - show_middle_chassis_components: Render current middle-chassis components.
  - show_middle_chassis_power_cases: Render the paired power cases.
  - show_middle_chassis_rpi: Render the Raspberry Pi stack.
  - show_middle_chassis_panel_stack: Render the controls and fuse-panel stack.
  - show_middle_chassis_power_case_slots: Cut the power-case mounting slots.
  - show_middle_chassis_rpi_slots: Cut the Raspberry Pi mounting slots.
  - show_middle_chassis_panel_stack_slots: Cut the panel-stack mounting slots.
  - `anchor`: Anchor for the complete middle chassis envelope.
 */
module middle_chassis_assembly(show_middle_chassis=show_middle_chassis,
                               show_middle_chassis_components=show_middle_chassis_components,
                               show_middle_chassis_power_cases=show_middle_chassis_power_cases,
                               show_middle_chassis_rpi=show_middle_chassis_rpi,
                               show_middle_chassis_panel_stack=show_middle_chassis_panel_stack,
                               show_middle_chassis_power_case_slots=show_middle_chassis_power_case_slots,
                               show_middle_chassis_rpi_slots=show_middle_chassis_rpi_slots,
                               show_middle_chassis_panel_stack_slots=show_middle_chassis_panel_stack_slots,
                               anchor=[0, 0, 1]) {
  if (show_middle_chassis) {
    middle_chassis(show_power_case_slots=show_middle_chassis_power_case_slots,
                   show_rpi_slots=show_middle_chassis_rpi_slots,
                   show_panel_stack_slots=show_middle_chassis_panel_stack_slots,
                   anchor=anchor);
  }
  if (show_middle_chassis_components) {
    middle_chassis_component_layout(show_power_cases=show_middle_chassis_power_cases,
                                    show_rpi=show_middle_chassis_rpi,
                                    show_panel_stack=show_middle_chassis_panel_stack,
                                    anchor=anchor);
  }
}

middle_chassis_assembly();
