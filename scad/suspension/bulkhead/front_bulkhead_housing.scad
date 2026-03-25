/**
  * Module: Bulkhead front housing.
  *
  * This is the lower part of the front bulkhead, which contains the barrel
  * hinge for the wishbone arms and the mounting holes for the chassis.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>

use <../../lib/functions.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../wishbone_arms/barrel_hinge.scad>
use <../wishbone_arms/lower_arm.scad>
use <front_bulkhead_chassis.scad>

module front_bulkhead_housing(color=cobalt_blue_metallic,
                              barrel_w=front_bulkhead_barrel_hinge_w,
                              rear_hole_bolt_d=front_bulkhead_rear_bolt_d,
                              rear_hole_bolt_offset=front_bulkhead_rear_bolt_offset,
                              rear_hole_bolt_cbore_d=front_bulkhead_rear_bolt_cbore_d,
                              barrel_thickness=front_bulkhead_housing_h,
                              barrel_y_offset=front_bulkhead_barrel_y_offset,
                              hinge_clearance=front_bulkhead_barrel_hinge_clearance,
                              pin_hole_offset=front_bulkhead_barrel_pin_hole_offset,
                              center_y=false,
                              center_by_hinges=false) {

  barrel_size = lower_arm_mount_cutout_size();
  barrel_len = barrel_size[1] - hinge_clearance;
  bolt_spacing_max_x = max(front_bulkhead_mount_bolt_spacing_1[0],
                           front_bulkhead_mount_bolt_spacing_2[0]);

  bolt_spacing_max_y = max(front_bulkhead_mount_bolt_spacing_1[1],
                           front_bulkhead_mount_bolt_spacing_2[1]);

  full_bolt_spacing_y = bolt_spacing_max_y + front_bulkhead_mount_bolt_d;

  maybe_translate([0, center_by_hinges
                   ? ((front_bulkhead_len / 2)
                      -
                      (front_bulkhead_len - barrel_y_offset - barrel_len)
                      - barrel_len / 2)
                   : center_y
                   ? 0
                   : front_bulkhead_len / 2,
                   0]) {
    maybe_color(color) {
      render() {
        difference() {
          union() {
            difference() {
              cube_3d([front_bulkhead_w,
                       front_bulkhead_len,
                       barrel_thickness]);
            }
            mirror_copy([1, 0, 0]) {
              translate([-front_bulkhead_w / 2 - barrel_w,
                         front_bulkhead_len / 2
                         - barrel_len - barrel_y_offset,
                         0]) {
                difference() {
                  barrel_hinge(size=[barrel_w,
                                     barrel_len,
                                     barrel_thickness],
                               d=front_lower_arm_hinge_barrel_hole_d,
                               distance=pin_hole_offset);
                }
              }
            }
          }
          translate([0,
                     -front_bulkhead_len / 2 + rear_hole_bolt_d / 2
                     + rear_hole_bolt_offset,
                     0]) {
            counterbore(h=barrel_thickness,
                        d=rear_hole_bolt_d,
                        bore_d=rear_hole_bolt_cbore_d,
                        bore_h=barrel_thickness / 2,
                        sink=true,
                        fn=100,
                        reverse=true);
          }
          translate([0,
                     front_bulkhead_len / 2
                     - full_bolt_spacing_y
                     - barrel_y_offset
                     - barrel_len / 2 + full_bolt_spacing_y / 2
                     ,
                     0]) {
            front_bulkhead_chassis_mount_slots(center_y=false);
          }

          mirror_copy([1, 0, 0]) {
            let (dia = barrel_len * front_bulkhead_hinge_cutout_d_factor) {
              translate([bolt_spacing_max_x / 2 + dia / 2
                         + front_bulkhead_mount_bolt_d / 2
                         + front_bulkhead_hinge_cutout_bolt_offset,
                         front_bulkhead_len / 2
                         - barrel_len / 2
                         - barrel_y_offset,
                         0]) {
                cylinder(d=dia, h=barrel_w, $fn=$preview ? 40 : 360);
              }
            }
          }
        }
      }
    }
  }
}

front_bulkhead_housing(center_by_hinges=true);
