/**
 * Module: Gearmotor
 *
 * This module assembles a brushed motor and gearbox for a brushed RC motor in
 * the style of MN78/MN82es gearboxes.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../../../rc_params.scad>

use <../../../lib/plist.scad>
use <brushed_motor.scad>
use <gearbox.scad>

show_gearbox           = true;
show_motor             = true;
show_bearing           = true;
show_drive_shaft       = true;
show_mount_bolts       = true;
show_nuts              = true;
show_shaft_seeve       = true;
show_extra_drive_shaft = true;
parent_thickness       = 6;

/**
  ─────────────────────────────────────────────────────────────────────────────
  gearmotor
  ─────────────────────────────────────────────────────────────────────────────

  `gearmotor` assembles a brushed motor and gearbox for a brushed RC motor in
  the style of MN78/MN82es gearboxes.

  **Example**:
  ```scad
   gearmotor(plist=motor_plist);
  ```
  */
module gearmotor(plist,
                 show_gearbox=show_gearbox,
                 show_motor=show_motor,
                 show_bearing=show_bearing,
                 show_drive_shaft=show_drive_shaft,
                 show_mount_bolts=show_mount_bolts,
                 parent_thickness=parent_thickness,
                 show_nuts=show_nuts,
                 show_shaft_seeve=show_shaft_seeve,
                 show_extra_drive_shaft=show_extra_drive_shaft,
                 slot_mode) {
  gearbox_params = gearbox_compute_params(plist);
  pinion_gear_h = plist_get("pinion_gear_h", gearbox_params);
  motor_shaft_y = plist_get("motor_shaft_y", gearbox_params);
  motor_outer_shaft_x_spacing = plist_get("motor_outer_shaft_x_spacing",
                                          gearbox_params);

  translate([0, 0, parent_thickness]) {

    rotate([90, 0, 0]) {
      if (show_motor && !slot_mode) {
        translate([-motor_outer_shaft_x_spacing,
                   motor_shaft_y,
                   pinion_gear_h]) {
          rotate([0, 180, 0]) {
            brushed_motor(plist);
          }
        }
      }
      if (show_gearbox || slot_mode) {
        gearbox(plist,
                slot_mode=slot_mode,
                show_bearing=show_bearing,
                show_mount_bolts=show_mount_bolts,
                show_nuts=show_nuts,
                show_drive_shaft=show_drive_shaft,
                parent_thickness=parent_thickness,
                show_shaft_seeve=show_shaft_seeve,
                show_extra_drive_shaft=show_extra_drive_shaft);
      }
    }
  }
}

gearmotor(plist=motor_plist);
