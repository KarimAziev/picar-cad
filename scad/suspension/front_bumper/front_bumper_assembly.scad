/**
  * Module: Front bumper assembly and head-frame fit preview.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../rc_params.scad>

use <../../head/head_neck.scad>
use <../../lib/transforms.scad>
use <../front_chassis/front_frame_util.scad>
use <../front_chassis/head_frame/front_chassis_head_frame.scad>
use <common.scad>
use <front_bumper_foam.scad>
use <front_bumper_top_plate.scad>

show_foam                   = true;
show_top_plate              = false;
show_bolts                  = false;
foam_alpha                  = 0.4; // [0:0.1:1]
foam_z_offset               = 0; // [-200:1:200]
top_plate_z_offset          = 0; // [-200:1:200]

/* [Head] */
show_head                   = false;
tilt_servo_rotation         = 0; // [-90:90]
pan_servo_rotation          = 0; // [-179:179]

show_camera                 = true;
show_camera_bolts           = true;
show_camera_nuts            = true;

show_pan_servo              = true;
show_pan_servo_horn         = true;
show_pan_servo_bolts        = true;
show_pan_servo_nuts         = true;

show_tilt_servo             = true;
show_tilt_servo_horn_screws = true;
show_tilt_servo_horn_bolt   = true;
head_servo_horn_screw_side  = "horizontal"; // [vertical, horizontal]
show_tilt_servo_horn        = true;
show_tilt_servo_bolts       = true;
show_tilt_servo_nuts        = true;

show_ir_case                = true;
show_ir_case_bolts          = true;
show_ir_case_nuts           = true;
show_ir_led                 = true;
show_ir_case_rail           = true;
show_ir_case_rail_bolts     = true;
show_ir_case_rail_nuts      = true;

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_bumper_assembly
  ─────────────────────────────────────────────────────────────────────────────
  Assemble the top retainer and TPU body in a canonical positive reference box.
  **Parameters:**
  - `pl`: Shared bumper dimension overrides.
  - `anchor`: Anchor for the complete assembly, excluding hardware.
  - `show_top_plate`: Show the rigid retainer and posts.
  - `show_foam`: Show the TPU body.
  - `show_bolts`: Show screws and nuts when the retainer is visible.
  - `foam_z_offset`: Vertical preview separation of the TPU body.
  - `foam_alpha`: TPU preview opacity, from 0 to 1.
  - `top_plate_z_offset`: Vertical preview separation of the retainer and hardware.
  - `reverse_bolts`: Put screw heads underneath the chassis and nuts on the plate.
    Defaults to the counterbore-driven `front_bumper_reverse_bolts` setting.
  **Behavior:** Use `front_bumper_position(pl)` to place the default anchor
  on the chassis. The bumper follows the head frame's +Y assembly separation.
 */
module front_bumper_assembly(pl=front_bumper_plist,
                             anchor=[1, 1, 1],
                             show_top_plate=show_top_plate,
                             show_foam=show_foam,
                             show_bolts=show_bolts,
                             foam_z_offset=foam_z_offset,
                             foam_alpha=foam_alpha,
                             top_plate_z_offset=top_plate_z_offset,
                             reverse_bolts=front_bumper_reverse_bolts) {
  size = front_bumper_size(pl);
  plate_size = front_bumper_size(pl, "plate");
  with_anchor(size=size, anchor=anchor) {
    if (show_foam) {
      translate([0, 0, foam_z_offset]) {
        color([0.18, 0.20, 0.23], alpha=foam_alpha) {
          front_bumper_foam(pl);
        }
      }
    }
    if (show_top_plate) {
      translate([(size[0] - plate_size[0]) / 2, 0, top_plate_z_offset]) {
        front_bumper_top_plate(pl,
                               show_bolts=show_bolts,
                               reverse_bolts=reverse_bolts,
                               color=[0.14, 0.52, 0.72]);
      }
    }
  }
}

module front_chassis_bumper_frame_assembly(show_foam=show_foam,
                                           show_top_plate=show_top_plate,
                                           show_bolts=show_bolts,
                                           foam_alpha=foam_alpha,
                                           foam_z_offset=foam_z_offset,
                                           top_plate_z_offset=top_plate_z_offset,
                                           show_head=show_head,
                                           tilt_servo_rotation=tilt_servo_rotation,
                                           pan_servo_rotation=pan_servo_rotation,
                                           show_camera=show_camera,
                                           show_camera_bolts=show_camera_bolts,
                                           show_camera_nuts=show_camera_nuts,
                                           show_pan_servo=show_pan_servo,
                                           show_pan_servo_horn=show_pan_servo_horn,
                                           show_pan_servo_bolts=show_pan_servo_bolts,
                                           show_pan_servo_nuts=show_pan_servo_nuts,
                                           show_tilt_servo=show_tilt_servo,
                                           show_tilt_servo_horn_screws=show_tilt_servo_horn_screws,
                                           show_tilt_servo_horn_bolt=show_tilt_servo_horn_bolt,
                                           head_servo_horn_screw_side=head_servo_horn_screw_side,
                                           show_tilt_servo_horn=show_tilt_servo_horn,
                                           show_tilt_servo_bolts=show_tilt_servo_bolts,
                                           show_tilt_servo_nuts=show_tilt_servo_nuts,
                                           show_ir_case=show_ir_case,
                                           show_ir_case_bolts=show_ir_case_bolts,
                                           show_ir_case_nuts=show_ir_case_nuts,
                                           show_ir_led=show_ir_led,
                                           show_ir_case_rail=show_ir_case_rail,
                                           show_ir_case_rail_bolts=show_ir_case_rail_bolts,
                                           show_ir_case_rail_nuts=show_ir_case_rail_nuts) {
  bumper_pl = front_bumper_plist;
  front_chassis_head_frame();
  translate(front_bumper_position(bumper_pl)) {
    front_bumper_assembly(bumper_pl,
                          show_top_plate=show_top_plate,
                          show_bolts=show_bolts,
                          show_foam=show_foam,
                          foam_z_offset=foam_z_offset,
                          foam_alpha=foam_alpha,
                          top_plate_z_offset=top_plate_z_offset,
                          reverse_bolts=front_bumper_reverse_bolts);
  }

  if (show_head) {
    translate([0, front_chassis_head_center_y(), front_chassis_head_mount_z()]) {
      head_neck(center_pan_servo_slot=true,
                show_head=show_head,
                pan_servo_rotation=pan_servo_rotation,
                tilt_servo_rotation=tilt_servo_rotation,
                show_camera=show_camera,
                show_camera_bolts=show_camera_bolts,
                show_camera_nuts=show_camera_nuts,
                show_pan_servo=show_pan_servo,
                show_pan_servo_horn=show_pan_servo_horn,
                show_pan_servo_bolts=show_pan_servo_bolts,
                show_pan_servo_nuts=show_pan_servo_nuts,
                show_tilt_servo=show_tilt_servo,
                show_tilt_servo_horn_screws=show_tilt_servo_horn_screws,
                show_tilt_servo_horn_bolt=show_tilt_servo_horn_bolt,
                head_servo_horn_screw_side=head_servo_horn_screw_side,
                show_tilt_servo_horn=show_tilt_servo_horn,
                show_tilt_servo_bolts=show_tilt_servo_bolts,
                show_tilt_servo_nuts=show_tilt_servo_nuts,
                show_ir_case=show_ir_case,
                show_ir_case_bolts=show_ir_case_bolts,
                show_ir_case_nuts=show_ir_case_nuts,
                show_ir_led=show_ir_led,
                show_ir_case_rail=show_ir_case_rail,
                show_ir_case_rail_bolts=show_ir_case_rail_bolts,
                show_ir_case_rail_nuts=show_ir_case_rail_nuts);
    }
  }
}

front_chassis_bumper_frame_assembly();
