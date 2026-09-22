/**
  * Module: Middle chassis.
  *
  * Provides a lightweight lattice deck for the paired power cases, Raspberry
  * Pi, and motor carrier. Both ends carry wide male joints so the frame can be
  * printed with its upper face on the bed. The central volume remains available
  * for a future lidar tower above the electronics.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>
include <../front_chassis/computed_params.scad>

use <../../lib/placement.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>
use <../../lipo_pack_case/multi_lipo_pack_case.scad>
use <../../placeholders/lipo_pack.scad>

show_middle_chassis            = true;
show_middle_chassis_components = true;
show_middle_chassis_power_case = true;
show_middle_chassis_lipo_packs = true;

// /**
//   ─────────────────────────────────────────────────────────────────────────────
//   middle_chassis
//   ─────────────────────────────────────────────────────────────────────────────

//   Build the anchored middle chassis with component slots and wide joints.

//   **Parameters:**
//   - color: Chassis display color.
//   - show_power_case_slots: Cut the paired power-case mounting slots.
//   - show_rpi_slots: Cut the Raspberry Pi mounting slots.
//   - show_motor_slots: Cut the relocated motor-carrier mounting slots.
//   - show_camera_slots: Cut three rectangular CSI ribbon passages.
//   - anchor: Anchor vector for the complete chassis envelope.
//  */
// module middle_chassis(color=white_smoke_1,
//                       show_power_case_slots=show_middle_chassis_power_case_slots,
//                       show_rpi_slots=show_middle_chassis_rpi_slots,
//                       show_motor_slots=show_middle_chassis_motor_slots,
//                       show_camera_slots=show_middle_chassis_camera_slots,
//                       anchor=[0, 0, 1]) {
//   size = middle_chassis_size();
//   rear_joint_y = -size[1] / 2 + joint_l;

//   with_anchor(anchor=anchor, size=size, centered=true) {
//     union() {
//       difference() {
//         _middle_chassis_lattice(color=color);
//         middle_chassis_component_layout(slot_mode=true,
//                                         show_power_cases=show_power_case_slots,
//                                         show_rpi=show_rpi_slots);
//         if (show_motor_slots) {
//           translate([0, -size[1] / 2 + joint_l, 0]) {
//             rear_chassis_motor_bolt_slots();
//           }
//         }
//         if (show_camera_slots) {
//           middle_chassis_camera_slots();
//         }
//         for (y = [size[1] / 2, rear_joint_y]) {
//           translate([0, y, 0]) {
//             front_chassis_pin_joint_holes(//               rail_w=middle_chassis_joint_rail_w(),
//               pin_spacing=middle_chassis_joint_pin_spacing());
//           }
//         }
//       }

//       translate([0, size[1] / 2, 0]) {
//         front_chassis_joint_male(color=color,
//                                  w=middle_chassis_joint_w(),
//                                  rail_w=middle_chassis_joint_rail_w(),
//                                  bolt_xs=middle_chassis_joint_bolt_xs(),
//                                  pin_spacing=middle_chassis_joint_pin_spacing(),
//                                  root_side=-1);
//       }

//       translate([0, rear_joint_y, 0]) {
//         front_chassis_joint_male(color=color,
//                                    w=middle_chassis_joint_w(),
//                                    rail_w=middle_chassis_joint_rail_w(),
//                                    bolt_xs=middle_chassis_joint_bolt_xs(),
//                                    pin_spacing=middle_chassis_joint_pin_spacing());
//       }
//     }
//   }
// }

// /**
//   ─────────────────────────────────────────────────────────────────────────────
//   middle_chassis_printable
//   ─────────────────────────────────────────────────────────────────────────────

//   Place the deck and both male-joint top faces on Z=0 for printing.
//  */

module middle_chassis() {
}

// /**
//   ─────────────────────────────────────────────────────────────────────────────
//   middle_chassis_assembly
//   ─────────────────────────────────────────────────────────────────────────────

//   Assemble the anchored middle chassis and its current electronics.

//   **Parameters:**
//   - show_middle_chassis: Render the middle lattice frame.
//   - show_middle_chassis_components: Render current middle-chassis components.
//   - show_middle_chassis_power_case: Render the power cases.
//   - `anchor`: Anchor for the complete middle chassis envelope.
//  */

module middle_chassis_assembly(show_middle_chassis=show_middle_chassis,
                               show_middle_chassis_components=show_middle_chassis_components,
                               show_middle_chassis_power_case=show_middle_chassis_power_case,
                               show_middle_chassis_lipo_packs=show_middle_chassis_lipo_packs,
                               power_case_plist=multi_lipo_packs_case) {

  if (show_middle_chassis) {
  }

  if (show_middle_chassis_components) {
    translate([0, 0, front_chassis_thickness]) {
      if (show_middle_chassis_power_case) {
        multi_lipo_pack_case(power_case_plist,
                             anchor=[0, -1, 1],
                             show_packs=show_middle_chassis_lipo_packs);
      }
    }
  }
}

middle_chassis_assembly();
