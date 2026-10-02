/**
  * Module: Measured rear-suspension mounting and maintenance cutters.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../rc_params.scad>
include <computed_params.scad>

use <../../lib/plist.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../motor_brackets/rc/gearbox_bracket.scad>
use <../../panel_stack/panel_stack.scad>
use <../../wago/wago_mounts.scad>
use <../front_chassis/front_chassis_joint.scad>
use <../rear_suspension/rear_suspension_slots.scad>
use <rear_equipment.scad>
use <rear_payload.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_suspension_slots
  ─────────────────────────────────────────────────────────────────────────────
  Emit the measured bolt pattern, arm-pad slot and maintenance hole.
  **Parameters:**
  - `anchor`: Envelope anchor, or `undef` to retain native holder-row coordinates.
  - `layout`: Resolved rear layout shared with the plate and components.
  **Notes:** Body and cutters use the same envelope. Mounting recesses face -Z.
 */
module rear_chassis_slots(anchor=undef, layout=rear_chassis_layout()) {
  size = plist_get("size", layout);
  center_y = (plist_get("min_y", layout) + plist_get("max_y", layout)) / 2;

  maintenance_y = plist_get("maintenance_y", layout);

  with_anchor(is_undef(anchor) ? [0, 0, 1] : anchor, size, centered=true) {
    translate([0, is_undef(anchor) ? 0 : -center_y, 0]) {
      translate([0, plist_get("rect_y", layout), 0]) {
        rear_suspension_arm_pad_rect_slot();
      }

      translate([0, maintenance_y, 0]) {
        counterbore(h=chassis_thickness,
                    d=rear_chassis_maintenance_hole_d);
      }
      translate(plist_get("motor_pos", layout)) {
        rotate(plist_get("motor_rotation", layout)) {
          gearmotor_bracket(params=plist_get("bracket", layout),
                            anchor=plist_get("motor_anchor", layout),
                            chassis_thickness=chassis_thickness,
                            slot_mode=true);
        }
      }

      for (panel = plist_get("panels", layout)) {
        translate(plist_get("pos", panel)) {
          panel_component(type=plist_get("type", panel),
                          orientation=plist_get("orientation", panel),
                          slot_mode=true,
                          slot_thickness=chassis_thickness);
        }
      }
      wago_mounts(plist_get("wago_mounts", layout, []),
                  slot_mode=true,
                  parent_t=chassis_thickness);
      rear_power_payload(plist_get("power_case", layout), slot_mode=true);
      rear_equipment(layout, slot_mode=true);
    }
  }
}

rear_chassis_slots();
