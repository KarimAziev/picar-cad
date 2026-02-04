/**
 * Module: Double-wishbone suspension knuckle
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../colors.scad>
include <../../parameters.scad>

use <../../lib/placement.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>
use <../../placeholders/bolt.scad>
use <../../wheels/front_wheel.scad>
use <../../wheels/wheel_hub_new.scad>
use <arm_mount.scad>
use <knuckle_lower.scad>
use <steering_arm_mount.scad>

color                  = cobalt_blue_metallic;
show_lower_tie_rod     = false;
show_upper_tie_rod     = false;
show_steering_tie_rod  = false;
show_shoulder_bolt     = false;
show_eye_bolt          = false;
show_steering_eye_bolt = false;
show_wheel             = false;
show_bearing           = false;
show_upper_hub         = false;
show_extra_lower_hub   = false;
show_extra_bearing     = false;
show_extra_upper_hub   = false;
show_tire              = false;
show_shoulder_bolt_nut = false;
eye_bolt_h             = 14;

module knuckle_base(color=matte_black,
                    show_lower_tie_rod=false,
                    show_upper_tie_rod=false,
                    show_shoulder_bolt=false,
                    show_eye_bolt=false,
                    show_steering_eye_bolt=false,
                    show_steering_tie_rod=false,
                    show_shoulder_bolt_nut=false,
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
               -(wheel_shoulder_bolt_threaded_l
                 + wheel_shoulder_bolt_unthreaded_l)
               + knuckle_base_h]) {

      bolt(d=wheel_shoulder_bolt_d,
           thread_starts=1,
           h=wheel_shoulder_bolt_threaded_l + wheel_shoulder_bolt_unthreaded_l,
           thread_len=wheel_shoulder_bolt_threaded_l,
           unthreaded=wheel_shoulder_bolt_unthreaded_l,
           unthreaded_d=wheel_bearing_bore_d,
           head_d=wheel_shoulder_bolt_head_d,
           show_nut=show_shoulder_bolt_nut,
           lock_nut=true,
           head_type="socket",
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
            reverse=true,
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

module knuckle(color=color,
               show_lower_tie_rod=show_lower_tie_rod,
               show_upper_tie_rod=show_upper_tie_rod,
               show_steering_tie_rod=show_steering_tie_rod,
               show_shoulder_bolt=show_shoulder_bolt,
               show_eye_bolt=show_eye_bolt,
               show_steering_eye_bolt=show_steering_eye_bolt,
               show_wheel=show_wheel,
               show_tire=show_tire,
               show_bearing=show_bearing,
               show_upper_hub=show_upper_hub,
               show_extra_lower_hub=show_extra_lower_hub,
               show_extra_upper_hub=show_extra_upper_hub,
               show_shoulder_bolt_nut=show_shoulder_bolt_nut,
               show_extra_bearing=show_extra_bearing,
               is_left=false,
               eye_bolt_h=14) {
  module _knuckle() {
    render() {
      union() {
        knuckle_lower(color=color);
        translate([0, 0, knuckle_narrow_h]) {
          knuckle_base(color=color,
                       show_lower_tie_rod=show_lower_tie_rod,
                       show_upper_tie_rod=show_upper_tie_rod,
                       show_shoulder_bolt=show_shoulder_bolt,
                       show_eye_bolt=show_eye_bolt,
                       show_steering_eye_bolt=show_steering_eye_bolt,
                       show_steering_tie_rod=show_steering_tie_rod,
                       show_shoulder_bolt_nut=show_shoulder_bolt_nut,
                       eye_bolt_h=eye_bolt_h);
        }
      }
    }
  }

  if (show_wheel) {
    translate([0, 0, -wheel_w / 2]) {
      rotate([180, 0, 0]) {
        front_wheel(show_bearing=show_bearing,
                    show_tire=show_tire,
                    show_upper_hub=show_upper_hub,
                    show_extra_lower_hub=show_extra_lower_hub,
                    show_extra_bearing=show_extra_bearing,
                    show_extra_upper_hub=show_extra_upper_hub);
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

module knuckles(distance=120) {
  mirror_copy([1, 0, 0]) {
    translate([-distance, 0, 0]) {
      rotate([90, 0, 0]) {
        rotate([180, 0, 0]) {
          rotate([0, 90, 0]) {
            knuckle(is_left=true);
          }
        }
      }
    }
  }
}

knuckles();
