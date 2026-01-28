/**
 * Module: Double-wishbone suspension knuckle
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../colors.scad>
include <../../parameters.scad>

use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>
use <../../placeholders/bolt.scad>
use <arm_mount.scad>
use <steering_arm_mount.scad>

color                  = cobalt_blue_metallic;
show_lower_tie_rod     = false;
show_upper_tie_rod     = false;
show_steering_tie_rod  = false;
show_shoulder_bolt     = false;
show_eye_bolt          = true;
show_steering_eye_bolt = true;
eye_bolt_h             = 14;

module knuckle_base(color=matte_black,
                    show_lower_tie_rod=false,
                    show_upper_tie_rod=false,
                    show_shoulder_bolt=false,
                    show_eye_bolt=true,
                    show_steering_eye_bolt=true,
                    show_steering_tie_rod=false,
                    eye_bolt_h=14) {

  maybe_color(color) {
    difference() {
      cylinder(h=knuckle_base_h, d=knuckle_base_d, $fn=200);
      translate([0, 0, -0.5]) {
        cylinder(d=knuckle_bearing_hole_d, h=knuckle_h + 1, $fn=300);
      }
    }
  }

  if (show_shoulder_bolt) {
    translate([0,
               0,
               -(wheel_shoulder_bolt_threaded_l + wheel_shoulder_bolt_unthreaded_l)
               + knuckle_base_h]) {

      bolt(d=wheel_shoulder_bolt_d,
           thread_starts=1,
           h=wheel_shoulder_bolt_threaded_l + wheel_shoulder_bolt_unthreaded_l,
           thread_len=wheel_shoulder_bolt_threaded_l,
           unthreaded=wheel_shoulder_bolt_unthreaded_l,
           unthreaded_d=wheel_bearing_bore_d,
           head_d=wheel_shoulder_bolt_head_d,
           head_type="hex",
           head_h=wheel_shoulder_bolt_head_h);
    }
  }

  knuckle_steering_arm_mount(show_eye_bolt=show_steering_eye_bolt,
                             show_tie_rod=show_steering_tie_rod,
                             color=color);

  arm_mount(parent_h=knuckle_base_h,
            show_tie_rod=show_lower_tie_rod,
            transition_h=wheel_shoulder_bolt_head_h / 2,
            show_eye_bolt=show_eye_bolt,
            eye_bolt_h=eye_bolt_h,
            color=color);
  rotate([0, 0, 180]) {
    arm_mount(parent_h=knuckle_base_h,
              show_tie_rod=show_upper_tie_rod,
              show_eye_bolt=show_eye_bolt,
              color=color,

              eye_bolt_h=eye_bolt_h,

              transition_h=wheel_shoulder_bolt_head_h / 2
              + knuckle_upper_arm_mount_extra_len);
  }
}

module knuckle_lower(color) {
  ring(outer_d1=knuckle_narrow_d,
       color=color,
       outer_d2=knuckle_base_d,
       d=knuckle_bearing_hole_d,
       h=knuckle_narrow_h,
       fn=250);
}

module knuckle(color=color,
               show_lower_tie_rod=show_lower_tie_rod,
               show_upper_tie_rod=show_upper_tie_rod,
               show_steering_tie_rod=show_steering_tie_rod,
               show_shoulder_bolt=show_shoulder_bolt,
               show_eye_bolt=show_eye_bolt,
               show_steering_eye_bolt=show_steering_eye_bolt,
               is_left=false,
               eye_bolt_h=14) {
  module _knuckle() {
    render() {
      union() {
        // knuckle_lower(color=color);
        translate([0, 0, knuckle_narrow_h]) {
          knuckle_base(color=color,
                       show_lower_tie_rod=show_lower_tie_rod,
                       show_upper_tie_rod=show_upper_tie_rod,
                       show_shoulder_bolt=show_shoulder_bolt,
                       show_eye_bolt=show_eye_bolt,
                       show_steering_eye_bolt=show_steering_eye_bolt,
                       show_steering_tie_rod=show_steering_tie_rod,
                       eye_bolt_h=eye_bolt_h);
        }
      }
    }
  }

  if (is_left) {
    mirror([1, 0, 0]) {
      _knuckle();
    }
  } else {
    _knuckle();
  }
}

knuckle();