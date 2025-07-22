/* Module: Robot Head & Neck Mount Assembly

   Description:
   This module defines and assembles the mounting components for a robot's head
   and neck. It utilizes two servos:
   - A pan servo (lower) for horizontal rotation.
   - A tilt servo (upper) for vertical movement.
   The head is attached to the tilt servo, and the assembly ensures proper alignment
   and mounting for both servos.

   Components:
   + head_neck_pan_mount:
   Generates the mounting base for the pan servo.

   + head_neck_tilt_mount:
   Creates the mount for the tilt servo.

   + head_neck_mount:
   Integrates the pan and tilt mounts into a single assembly.

   head_neck_assembly:
   Final assembly that combines the mounting plate and placeholder servo
   modules.

   Example:
   // To render the complete head and neck assembly:
   head_neck_assembly();

   Author: Karim Aziiev <karim.aziiev@gmail.com>
   License: GPL-3.0-or-later
*/

include <../parameters.scad>
include <../colors.scad>
use <../util.scad>
use <../placeholders/servo.scad>

module head_neck_pan_mount(size=[cam_pan_servo_slot_width,
                                 cam_pan_servo_slot_height],
                           screws_dia=cam_pan_servo_screw_dia,
                           screws_offset=cam_pan_servo_screws_offset,
                           thickness=cam_pan_servo_slot_thickness,
                           extra_w=2,
                           extra_h=2) {

  w = size[0] + (screws_offset * 2 + screws_dia * 2) + extra_w;
  h = size[1] + extra_h;

  linear_extrude(height=thickness, center=true) {
    difference() {
      rounded_rect_two(size = [w, h], r = h * 0.1, center = true);
      servo_slot_2d(size=size,
                    screws_dia=screws_dia,
                    screws_offset=screws_offset);
    }
  }
}

module head_neck_tilt_mount(size=[cam_tilt_servo_slot_width,
                                  cam_tilt_servo_slot_height],
                            screws_dia=cam_tilt_servo_screw_dia,
                            screws_offset=cam_tilt_servo_screws_offset,
                            servo_height=cam_pan_servo_height,
                            thickness=cam_tilt_servo_slot_thickness,
                            extra_w=2,
                            extra_h=2) {

  w = size[0] + (screws_offset * 2 + screws_dia * 2) + extra_w;
  h = size[1] + extra_h;

  linear_extrude(height=thickness, center=true) {
    union() {
      square(size = [w, servo_height], center=true);
      translate([0, servo_height * 0.5 + h * 0.5, 0]) {
        difference() {
          rounded_rect_two(size = [w, h], r = h * 0.1, center = true);
          servo_slot_2d(size=size,
                        screws_dia=screws_dia,
                        screws_offset=screws_offset);
        }
      }
    }
  }
}

module head_neck_mount(pan_servo_size=[cam_pan_servo_slot_width,
                                       cam_pan_servo_slot_height],
                       pan_screws_dia=cam_pan_servo_screw_dia,
                       pan_screws_offset=cam_pan_servo_screws_offset,
                       pan_thickness=cam_pan_servo_slot_thickness,
                       pan_servo_height=cam_pan_servo_height,
                       pan_servo_extra_w=pan_servo_extra_w,
                       pan_servo_extra_h=pan_servo_extra_h,
                       tilt_servo_size=[cam_tilt_servo_slot_width,
                                        cam_tilt_servo_slot_height],
                       tilt_screws_dia=cam_tilt_servo_screw_dia,
                       tilt_screws_offset=cam_tilt_servo_screws_offset,
                       tilt_thickness=cam_tilt_servo_slot_thickness,
                       tilt_servo_extra_w=cam_tilt_servo_extra_w,
                       tilt_servo_extra_h=cam_tilt_servo_extra_h,
                       neck_color="white") {

  color(neck_color) {
    union() {
      rotate([180, 0, 0]) {
        extra_h = pan_servo_extra_h + tilt_thickness + pan_thickness;
        head_neck_pan_mount(size=pan_servo_size,
                            screws_dia=pan_screws_dia,
                            screws_offset=pan_screws_offset,
                            thickness=pan_thickness,
                            extra_w=pan_servo_extra_w,
                            extra_h=extra_h);
      }
      total_h = tilt_servo_size[1] + tilt_servo_extra_h;
      total_w = pan_servo_size[0] + pan_servo_extra_w;

      y_offst = pan_servo_size[1] * 0.5
        + pan_servo_extra_h * 0.5
        + tilt_thickness * 0.5;

      z_offst = pan_servo_size[0] * 0.5 - tilt_thickness;

      translate([0, y_offst, z_offst]) {
        rotate([90, 0, 0]) {
          head_neck_tilt_mount(size=[tilt_servo_size[0], tilt_servo_size[1]],
                               screws_dia=tilt_screws_dia,
                               screws_offset=tilt_screws_offset,
                               thickness=tilt_thickness,
                               servo_height=pan_servo_height,
                               extra_w=tilt_servo_extra_w,
                               extra_h=tilt_servo_extra_h);
        }
      }
    }
  }
}

module head_neck_assembly(pan_servo_size=[cam_pan_servo_slot_width,
                                          cam_pan_servo_slot_height],
                          pan_screws_dia=cam_pan_servo_screw_dia,
                          pan_screws_offset=cam_pan_servo_screws_offset,
                          pan_thickness=cam_pan_servo_slot_thickness,
                          pan_servo_height=cam_pan_servo_height,
                          pan_servo_extra_w=pan_servo_extra_w,
                          pan_servo_extra_h=pan_servo_extra_h,
                          tilt_servo_size=[cam_tilt_servo_slot_width,
                                           cam_tilt_servo_slot_height],
                          tilt_screws_dia=cam_tilt_servo_screw_dia,
                          tilt_screws_offset=cam_tilt_servo_screws_offset,
                          tilt_thickness=cam_tilt_servo_slot_thickness,
                          tilt_servo_extra_w=cam_tilt_servo_extra_w,
                          tilt_servo_extra_h=cam_tilt_servo_extra_h,
                          tilt_servo_height=cam_tilt_servo_height,
                          neck_color="white",
                          pan_servo_color=jet_black,
                          tilt_servo_color=jet_black) {
  union() {
    union() {
      head_neck_mount(pan_servo_size=pan_servo_size,
                      pan_screws_dia=pan_screws_dia,
                      pan_screws_offset=pan_screws_offset,
                      pan_thickness=pan_thickness,
                      pan_servo_height=pan_servo_height,
                      pan_servo_extra_w=pan_servo_extra_w,
                      pan_servo_extra_h=pan_servo_extra_h,
                      tilt_servo_size=tilt_servo_size,
                      tilt_screws_dia=tilt_screws_dia,
                      tilt_screws_offset=tilt_screws_offset,
                      tilt_thickness=tilt_thickness,
                      tilt_servo_extra_w=tilt_servo_extra_w,
                      tilt_servo_extra_h=tilt_servo_extra_h,
                      neck_color=neck_color);
      translate([0, 0, pan_servo_height * 0.5 - pan_servo_height * 0.1]) {
        servo(size=[pan_servo_size[0], pan_servo_size[1], pan_servo_height],
              servo_offset=pan_screws_offset,
              servo_color=pan_servo_color);
      }
    }

    translate([0,
               -tilt_servo_size[1] * 0.5 + pan_servo_extra_h,
               pan_servo_height + tilt_servo_size[1] * 0.5]) {
      rotate([90, 0, 0]) {
        servo(size=[tilt_servo_size[0], tilt_servo_size[1], tilt_servo_height],
              servo_offset=tilt_screws_offset,
              servo_color=tilt_servo_color);
      }
    }
  }
}

head_neck_mount();