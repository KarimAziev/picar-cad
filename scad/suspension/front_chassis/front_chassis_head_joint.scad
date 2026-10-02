/**
  * Module: Stepped head-frame joint retaining the complete camera ribbon bank.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <layout_params.scad>

use <../../components/plate_joint/plate_joint.scad>
use <../../lib/plist.scad>
use <../bulkhead/util.scad>
use <../bulkhead/front_bulkhead_chassis.scad>
use <front_chassis_head_slots.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_head_joint_params
  ─────────────────────────────────────────────────────────────────────────────
  Locate the joint within the existing head-to-bulkhead taper.
  **Returns:** Plist containing `root_y`, `end_y`, `w`, `l`, `tab_w`, and
  `pin_z`. The head owns the central tab and all three ribbon openings.
  The two pin passages are centered on `root_y`, rather than on the joint,
  to stop short of the bulkhead holes while entering both parent plates.
 */
function front_chassis_head_joint_params() =
  let (end_y = front_bulkhead_pad_distance_to_hinge() + bulkhead_size_y,
       root_y = end_y + bulkhead_transition_len,
       taper_y = front_bulkhead_pad_distance_to_hinge() + bulkhead_transition_len
           + front_bumper_bolt_y_offset + front_bumper_bolt_d,
       head_half_w = max(front_bumper_bolt_spacing_x / 2
                         + front_bumper_bolt_d / 2 + front_bumper_bolt_pad_x,
                         front_chassis_head_mount_size()[0] / 2
                         + front_chassis_head_side_slot_w + front_chassis_head_wire_land * 2),
       bulkhead_half_w = bulkhead_size_x / 2,
       half_w = bulkhead_half_w + (head_half_w - bulkhead_half_w)
           * (end_y - taper_y) / (root_y - taper_y),
       tab_w = front_chassis_head_ribbon_slot_w + front_chassis_head_wire_land * 2,
       bulkhead_front_y = front_bulkhead_chassis_mount_origin_y()
           + front_bulkhead_mount_bolt_spacing_1[1] + front_bulkhead_mount_bolt_d / 2
           + max(front_bulkhead_mount_bolt_d, front_bulkhead_mount_bolt_bore_d) / 2,
       pin_end_land = root_y - front_chassis_head_joint_pin_l / 2 - bulkhead_front_y)
  assert(end_y > taper_y && root_y > end_y,
         "Head joint must fit inside the existing taper")
  assert(front_chassis_head_joint_pin_l / 2 > bulkhead_transition_len + 3,
         "Head pins need at least 3 mm engagement beyond the chassis socket")
  assert(pin_end_land >= front_chassis_head_wire_land - 0.000001,
         "Head pins reach the bulkhead mounting keepout; use the 23.8 mm pair")
  assert(front_chassis_head_joint_pin_spacing / 2
         - front_chassis_head_joint_pin_d / 2
         - tab_w / 2 - front_chassis_joint_clearance >= 1.5,
         "Head pin passages need 1.5 mm wall beside the ribbon tab socket")
  ["root_y", root_y, "end_y", end_y,
   "w", half_w * 2, "l", root_y - end_y, "tab_w", tab_w,
   "pin_z", joint_base_h + (joint_base_h + joint_rail_h) / 2];

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_head_joint_pins
  ─────────────────────────────────────────────────────────────────────────────
  Emit the two 23.8 mm pin passages in front-chassis coordinates.
  **Parameters:**
  - `extra`: Radial and end allowance for clearance probes; zero cuts the holes.
 */
module front_chassis_head_joint_pins(extra=0) {
  p = front_chassis_head_joint_params();
  translate([0, plist_get("root_y", p), 0]) {
    plate_joint_pin_holes(d=front_chassis_head_joint_pin_d + extra * 2,
                          pin_l=front_chassis_head_joint_pin_l + extra * 2,
                          l=0,
                          spacing=front_chassis_head_joint_pin_spacing,
                          z=plist_get("pin_z", p),
                          use_pad=false);
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_head_joint
  ─────────────────────────────────────────────────────────────────────────────
  Build the head tongue or the receiving chassis cutters in chassis coordinates.
  **Parameters:**
  - `mode`: `"male"` for the head or `"female"` for the bulkhead frame.
  - `slot_mode`: Emit joint and pin cutters for subtraction from the parent.
  **Behavior:** The full-thickness central ribbon tab belongs to the head.
  Its female clearance is part of the socket. Both halves retain their original
  vehicle coordinates; assembled parts need no translation.
 */
module front_chassis_head_joint(mode="male", slot_mode=false) {
  p = front_chassis_head_joint_params();
  module _joint() {
    translate([0, plist_get("root_y", p), 0]) {
      plate_joint(plate_h=chassis_thickness,
                  bolt_d=front_chassis_joint_bolt_d,
                  w=plist_get("w", p), l=plist_get("l", p),
                  rail_w=front_chassis_head_joint_rail_w,
                  bolt_n_center=2,
                  clearance=front_chassis_joint_clearance,
                  boolean_overlap=front_chassis_joint_boolean_overlap,
                  include_pin_holes=false,
                  mode=mode, slot_mode=slot_mode);
    }
  }
  if (slot_mode) {
    _joint();
    front_chassis_head_joint_pins();
    if (mode == "female") {
      gap = front_chassis_joint_clearance;
      translate([-plist_get("tab_w", p) / 2 - gap,
                 plist_get("end_y", p) - gap, -gap]) {
        cube([plist_get("tab_w", p) + gap * 2,
              plist_get("l", p) + gap * 2, chassis_thickness + gap * 2]);
      }
    }
  } else {
    difference() {
      _joint();
      front_chassis_head_joint_pins();
    }
  }
}
