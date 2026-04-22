/**
  * Module: Front chassis joint components.
  *
  * Defines the dovetail rail joint and matching slot used to connect the front
  * and rear sections of the front chassis. It also includes bolt and
  * counterbore features for securing the connection.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>
include <computed_params.scad>

use <../../lib/slider.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>

module front_chassis_joint_base(color=cobalt_blue_light_3,
                                extra_h=0.0,
                                extra_w=0.0,
                                extra_l=0.0) {
  rail_h = joint_rail_h;
  base_h = joint_base_h + extra_h;
  base_w = joint_w + extra_w;

  module _main() {
    difference() {
      maybe_color(color) {
        linear_extrude(height=joint_l + extra_l,
                       center=false) {
          slider_dovetail_rail_2d(base_w=base_w,
                                  base_h=base_h,
                                  w=joint_rail_w,
                                  h=rail_h,
                                  angle=front_chassis_joint_rail_angle,
                                  r=front_chassis_joint_rail_corner_r,
                                  center_y=false,
                                  center_x=true,
                                  reverse=true,
                                  use_dovetail_rib=front_chassis_joint_use_dovetail_rib);
        }
      }

      translate([0, -0.1 + base_h, -1]) {
        linear_extrude(height=joint_l + extra_l + 1,
                       center=false) {

          dovetail_rib(w=joint_recess_w,
                       h=rail_h + 0.2,
                       angle=front_chassis_joint_rail_angle,
                       r_top=0,
                       r_bottom=front_chassis_joint_rail_corner_r,
                       center_y=false,
                       center_x=true);
        }
      }
    }
  }

  translate([0, -joint_l - extra_l / 2, front_chassis_thickness + extra_h]) {
    rotate([-90, 0, 0]) {
      _main();
    }
  }
}

module front_chassis_frame_joint(color=cobalt_blue_light_3) {
  render() {
    difference() {

      front_chassis_joint_base(color=color);

      translate([0, -joint_l / 2, 0]) {
        counterbore(d=front_chassis_joint_bolt_d,
                    h=front_chassis_thickness,
                    reverse=true);

        four_corner_counterbores(size=[joint_rail_w / 2 + joint_recess_w / 2, 0],
                                 d=front_chassis_joint_bolt_d,
                                 bore_d=front_chassis_joint_bolt_d * 2.1,
                                 bore_h=(joint_base_h + joint_rail_h) / 2,
                                 sink=true,
                                 h=front_chassis_thickness);

        translate([0, 0, front_chassis_thickness / 2]) {
          four_corner_counterbores(size=[front_chassis_joint_bolt_spacing, 0],
                                   d=front_chassis_joint_bolt_d,
                                   h=front_chassis_thickness / 2);
        }
      }
    }
  }
}

module front_chassis_joint_slot(color) {
  render() {
    difference() {
      translate([0, -joint_l, 0]) {
        difference() {
          translate([-joint_w / 2, 0, 0]) {
            maybe_color(color) {
              cube([joint_w, joint_l, front_chassis_thickness]);
            }
          }
          translate([0, joint_l, 0]) {
            front_chassis_joint_base(extra_h=1.5,
                                     extra_w=0.1,
                                     extra_l=0.1,
                                     color=undef);
          }
        }
      }
      translate([0, -joint_l / 2, 0]) {
        four_corner_counterbores(size=[joint_rail_w / 2 + joint_recess_w / 2, 0],
                                 d=front_chassis_joint_bolt_d,
                                 sink=true,
                                 h=front_chassis_thickness);
        counterbore(d=front_chassis_joint_bolt_d,
                    h=front_chassis_thickness,
                    bore_d=front_chassis_joint_bolt_d * 2.1,
                    bore_h=(joint_base_h + joint_rail_h) / 2,
                    reverse=true);
        four_corner_counterbores(size=[front_chassis_joint_bolt_spacing, 0],
                                 d=front_chassis_joint_bolt_d,
                                 h=front_chassis_thickness);
      }
    }
  }
}
