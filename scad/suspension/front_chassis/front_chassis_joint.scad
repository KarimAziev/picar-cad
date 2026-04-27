/**
  * Module: Front chassis joint components.
  *
  * Defines the dovetail rail joint and matching slot used to connect the front
  * and rear sections of the front chassis.
  *
  * In addition to bolt holes for securing the connection, it also includes two
  * through-holes for metal pins. These pins should be slightly longer than the
  * joint so that they also extend into the connected parts (the front and rear
  * sections of the front chassis).
  *
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>
include <computed_params.scad>

use <../../lib/shapes3d.scad>
use <../../lib/slider.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../placeholders/suspension_arm_pin.scad>

module front_chassis_joint_base(color=cobalt_blue_light_3,
                                extra_h=0.0,
                                extra_w=0.0,
                                extra_l=0.0,
                                edge_land,
                                relief_depth) {

  base_h = joint_base_h + extra_h;
  base_w = joint_w + extra_w;

  translate([0, -joint_l - extra_l / 2, front_chassis_thickness + extra_h]) {
    rotate([-90, 0, 0]) {
      maybe_color(color) {
        linear_extrude(height=joint_l + extra_l,
                       center=false) {
          slider_dovetail_rail_2d(base_w=base_w,
                                  base_h=base_h,
                                  w=joint_rail_w,
                                  h=joint_rail_h,
                                  angle=front_chassis_joint_rail_angle,
                                  r=front_chassis_joint_rail_corner_r,
                                  center_y=false,
                                  center_x=true,
                                  reverse=true,
                                  use_dovetail_rib=front_chassis_joint_use_dovetail_rib,
                                  edge_land=front_chassis_joint_use_dovetail_rib
                                  ? edge_land : undef,
                                  relief_depth=relief_depth);
        }
      }
    }
  }
}

module front_chassis_joint_male(color=cobalt_blue_light_3) {
  render() {
    difference() {
      front_chassis_joint_base(color=color,
                               extra_w=-front_chassis_joint_clearance);
      front_chassis_pin_joint_holes(use_pad=false, direction=-1);

      translate([0, -joint_l / 2, 0]) {
        counterbore(d=front_chassis_joint_bolt_d,
                    h=front_chassis_thickness,
                    reverse=true);
        translate([0, 0, front_chassis_thickness / 2]) {
          four_corner_counterbores(size=[front_chassis_joint_bolt_spacing, 0],
                                   d=front_chassis_joint_bolt_d,
                                   h=front_chassis_thickness / 2);
        }
      }
    }
  }
}

module front_chassis_joint_female(color) {
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
            front_chassis_joint_base(extra_h=1,
                                     extra_w=0.1,
                                     extra_l=1.0,
                                     color=undef,
                                     edge_land=front_chassis_joint_edge_land,
                                     relief_depth=front_chassis_joint_relief_depth);
          }
        }
      }
      translate([0, -joint_l / 2, 0]) {
        counterbore(d=front_chassis_joint_bolt_d,
                    h=front_chassis_thickness,
                    reverse=true);
        four_corner_counterbores(size=[front_chassis_joint_bolt_spacing, 0],
                                 d=front_chassis_joint_bolt_d,
                                 h=front_chassis_thickness);
      }
    }
  }
}

module front_chassis_pin_joint_hole(direction=-1,
                                    use_pad=false,
                                    pad_side="bottom") {
  fn = $preview ? 16 : 100;
  rotate([direction == 1 ? -90 : 90, 0, 0]) {
    if (use_pad) {
      let (groove_side = (pad_side == "bottom") == (direction == -1)
           ? "bottom"
           : "top") {
        suspension_arm_pin(d=front_chassis_joint_pin_d,
                           l=front_chassis_joint_pin_l,
                           pad_l=front_chassis_joint_pin_pad_l,
                           pad_w=front_chassis_joint_pin_pad_w,
                           color=undef,
                           fn=fn,
                           groove_side=groove_side,
                           show_e_clip=false);
      }
    } else {
      hull() {
        translate([0, 0, front_chassis_joint_pin_l / 2]) {
          cube([0.4, front_chassis_joint_pin_d + 0.4, front_chassis_joint_pin_l],
               center=true);
        }
        cylinder(d=front_chassis_joint_pin_d,
                 h=front_chassis_joint_pin_l,
                 $fn=fn);
      }
    }
  }
}

module front_chassis_pin_joint_holes(direction=-1,
                                     use_pad=false,
                                     center=true,
                                     pad_side="bottom") {
  spacing = joint_rail_w / 2 + joint_recess_w / 2;

  depth = (front_chassis_joint_pin_l - joint_l) / 2;
  y = center ? (depth * -direction) : 0;
  jz = joint_base_h + (joint_base_h + joint_rail_h) / 2;

  mirror_copy([1, 0, 0]) {
    translate([spacing / 2, y, jz]) {
      front_chassis_pin_joint_hole(direction=direction,
                                   pad_side=pad_side,
                                   use_pad=use_pad);
    }
  }
}

union() {
  %front_chassis_joint_male();
  translate([0, -joint_l, 0]) {
    front_chassis_joint_female();
  }
}
