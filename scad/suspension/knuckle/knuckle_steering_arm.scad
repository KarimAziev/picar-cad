/**
  * Module: The ring with steering arm
  *
  * This is not a separate printable detail.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>

use <../../lib/placement.scad>
use <../../lib/shapes2d.scad>
use <../../lib/transforms.scad>

module knuckle_steering_arm(w_base=knuckle_arm_base_w,
                            w_narrow=knuckle_arm_narrow_w,
                            l1=knuckle_arm_base_len,
                            l2=knuckle_arm_ring_connector_l,
                            outer_d=knuckle_arm_ring_outer_d,
                            bolt_d=knuckle_arm_bolt_d,
                            bolt_edge_offset=knuckle_arm_bolt_hole_offset,
                            angle=knuckle_arm_angle,
                            holes_n=knuckle_arm_holes_n,
                            holes_gap=knuckle_arm_holes_gap,
                            thickness=knuckle_arm_thickness,
                            bearing_od=knuckle_inner_bearing_seat_d,
                            bearing_shoulder_d=knuckle_inner_bearing_shoulder_d,
                            bearing_h=knuckle_outer_bearing_w
                            + knuckle_outer_bearing_z_clearance,
                            corner_r=knuckle_arm_corner_r,
                            ear_len=knuckle_arm_ear_len) {

  assert(angle < 90, "knuckle_steering_arm: Angle should be less than 90!");

  x2 = l1 * sin(angle);   // horizontal component
  y2 = l1 * cos(angle);   // vertical component (positive magnitude)

  ear_base_len = ear_len - bolt_d - bolt_edge_offset;

  connector_l = l2 - corner_r;

  pts = [[0, 0],
         [x2, -y2],
         [x2, -ear_base_len -y2],
         [x2 + w_narrow, -ear_base_len -y2],
         [x2 + w_narrow, -y2],
         [w_base, 0],
         [w_base, l2],
         [0, l2]];

  fn = $preview ? 30 : 360;

  module _base_shape() {
    difference() {
      union() {
        offset_vertices_2d(r=corner_r) {
          polygon(pts);
        }

        translate([0, corner_r, 0]) {
          square([w_base, connector_l], center=false);
        }

        translate([x2, -y2 - ear_len, 0]) {
          rounded_rect([w_narrow, ear_len - ear_base_len
                        + corner_r],
                       side="bottom",
                       center=false,
                       r_factor=0.5);
        }
      }
      translate([x2, -y2 - ear_len, 0]) {
        translate([w_narrow / 2,
                   bolt_edge_offset,
                   0]) {
          rows_children(rows=holes_n, w=bolt_d, gap=holes_gap) {
            circle(d=bolt_d, $fn=fn);
          }
        }
      }
    }
  }

  module _ring() {
    hull() {
      rotate([0, 90, 0]) {
        cylinder(d2=outer_d,
                 d1=outer_d,
                 h=w_base,
                 $fn=300);
      }
      translate([0, -thickness / 2, thickness + l2]) {
        rotate([-90, 0, 0]) {
          linear_extrude(height=thickness, center=false) {
            translate([0, -connector_l / 2, 0]) {
              square([w_base, connector_l / 2], center=false);
            }
          }
        }
      }
    }
  }

  module _main() {
    difference() {
      union() {
        _ring();
        translate([0, -thickness / 2, thickness + l2]) {
          rotate([-90, 0, 0]) {
            linear_extrude(height=thickness, center=false) {
              translate([0, -l2, 0]) {
                _base_shape();
              }
            }
          }
        }
      }
      rotate([0, 90, 0]) {
        translate([0, 0, -1]) {
          cylinder(d=bearing_shoulder_d,
                   h=w_base + 1,
                   $fn=fn);
        }
        translate([0, 0, bearing_h + 1]) {
          cylinder(d=bearing_od,
                   h=bearing_h + 0.8,
                   $fn=fn);
        }
      }
    }
  }
  render() {
    _main();
  }
}

knuckle_steering_arm();