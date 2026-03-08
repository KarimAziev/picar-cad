/**
  * Module: Bulkhead front housing
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>

use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../wishbone_arms/barrel_hinge.scad>
use <../wishbone_arms/lower_arm.scad>
use <front_bulkhead_chassis.scad>

module front_bulkhead_housing(color=cobalt_blue_metallic,
                              thickness=front_bulkhead_thickness,
                              barrel_w=front_bulkhead_barrel_hinge_w,
                              gearbox_bolt_d=front_bulkhead_gearbox_bolt_d,
                              gearbox_bolt_offset=front_bulkhead_gearbox_bolt_offset,
                              gearbox_bolt_cbore_d=front_bulkhead_gearbox_bolt_cbore_d,
                              barrel_thickness=front_bulkhead_h,
                              barrel_y_offset=front_bulkhead_barrel_y_offset,
                              center_hole_len=front_bulkhead_center_hole_len,
                              hinge_clearance=front_bulkhead_barrel_hinge_clearance,
                              center_y=false) {

  barrel_size = lower_arm_mount_cutout_size();
  barrel_len = barrel_size[1] - hinge_clearance;
  bolt_spacing_max_x = max(front_bulkhead_mount_bolt_spacing_1[0],
                           front_bulkhead_mount_bolt_spacing_2[0]);

  maybe_translate([0, center_y ? 0 : front_bulkhead_len / 2, 0]) {
    maybe_color(color) {
      render() {
        difference() {
          union() {
            difference() {
              cube_3d([front_bulkhead_w,
                       front_bulkhead_len,
                       barrel_thickness]);
              translate([0, thickness, thickness]) {
                linear_extrude(height=barrel_thickness + 0.1, center=false) {
                  rounded_rect([front_bulkhead_w - thickness * 2,
                                front_bulkhead_len],
                               side="bottom",
                               r_factor=0.15,
                               center=true);
                }
              }
              translate([0, thickness, -thickness]) {
                linear_extrude(height=barrel_thickness, center=false) {
                  rounded_rect([front_bulkhead_w + 0.1,
                                center_hole_len],
                               r_factor=0.15,
                               fn=$preview ? 40 : 360,
                               center=true);
                }
              }
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
                               d=lower_arm_hinge_barrel_hole_d,
                               distance=front_bulkhead_barrel_pin_hole_offset);
                }
              }
            }
            // gearbox_bolt_d
            let (size=[gearbox_bolt_d + thickness * 2,
                       gearbox_bolt_d + thickness + gearbox_bolt_offset]) {
              translate([0,
                         -front_bulkhead_len / 2 - size[1] / 2
                         + size[1],
                         0]) {
                linear_extrude(height=barrel_thickness, center=false) {
                  rounded_rect(size,
                               center=true,
                               side="top",
                               r_factor=0.5,
                               fn=$preview ? 16 : 360);
                }
              }
            }
          }
          translate([0,
                     -front_bulkhead_len / 2 + gearbox_bolt_d / 2
                     + gearbox_bolt_offset,
                     0]) {
            counterbore(h=barrel_thickness,
                        d=gearbox_bolt_d,
                        bore_d=gearbox_bolt_cbore_d,
                        bore_h=barrel_thickness / 2,
                        sink=true,
                        fn=100,
                        reverse=true);
          }
          front_bulkhead_chassis_mount_slots();

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

front_bulkhead_housing();