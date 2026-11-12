/**
  * Module: The ring with steering arm mount
  *
  * This is not a separate printable detail, this is a part of the knuckle.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../parameters.scad>
include <../../rc_params.scad>

use <../../lib/debug.scad>
use <../../lib/placement.scad>
use <../../lib/shapes2d.scad>
use <../../lib/transforms.scad>
use <util.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  knuckle_arm_profile
  ─────────────────────────────────────────────────────────────────────────────
  Create the planar arm outline and its row of mounting holes in XY.
  **Parameters:**
  - `w_base`, `w_narrow`: Width at the ring and at the rounded mounting ear.
  - `l1`, `l2`: Angled segment length and ring connector length.
  - `angle`: Angled segment inclination in degrees from negative Y.
  - `ear_len`: Length of the mounting ear along negative Y.
  - `bolt_d`, `bolt_edge_offset`: Bore diameter and end-to-hole edge gap.
  - `holes_n`, `holes_gap`: Bore count (zero for a blank) and edge-to-edge gap.
  - `corner_r`: Maximum profile corner radius.
  - `lower_height`, `outer_bearing_seat_od`: Ring-side support dimensions.
  - `debug`: Label the construction polygon vertices.
  **Behavior:** The ring connection lies along positive Y; the ear extends
  toward positive X and negative Y. Extrude before assembly placement.
 */
module knuckle_arm_profile(w_base,
                           w_narrow,
                           l1,
                           l2,
                           angle,
                           ear_len,
                           bolt_d,
                           bolt_edge_offset,
                           holes_n,
                           holes_gap,
                           corner_r,
                           lower_height=0,
                           outer_bearing_seat_od=0,
                           debug=false) {
  planar_params = steering_arm_planar_params(arm_len=l1,
                                             arm_angle=angle,
                                             ear_len=ear_len,
                                             bolt_d=bolt_d,
                                             bolt_edge_offset=bolt_edge_offset);

  dx = planar_params[0];   // horizontal component
  dy = planar_params[1];   // vertical component (positive magnitude)

  ear_base_len = planar_params[2];

  orig_corner_r = corner_r;

  corner_r_max = min(l2 - 0.01,
                     w_narrow / 2,
                     ear_base_len / 2);
  corner_r = min(corner_r_max, corner_r);

  if (corner_r_max <= orig_corner_r) {
    echo(str("Received corner_r with value ",
             orig_corner_r,
             " which is too big, resetting to the max allowed value ",
             corner_r_max));
  }

  connector_l = l2 - corner_r;

  pts = [[0, 0],
         [dx, -dy - ear_base_len / 2],
         [dx, -ear_base_len - dy],
         [dx + w_narrow, -ear_base_len - dy],
         [dx + w_narrow, -dy],
         [w_base, 0],
         [w_base, l2],
         [-lower_height, outer_bearing_seat_od / 2]];

  pts2 = [[0, 0],
          [w_base, 0],
          [w_base, l2],
          [-lower_height, outer_bearing_seat_od / 2]];

  fn = $preview ? 30 : 360;

  module profile() {
    difference() {
      union() {
        polygon(pts2);
        offset_vertices_2d(r=corner_r) {
          polygon(pts);
        }

        translate([0, corner_r, 0]) {
          square([w_base, connector_l], center=false);
        }

        translate([dx, -dy - ear_len, 0]) {
          rounded_rect([w_narrow, ear_len - ear_base_len + corner_r],
                       side="bottom",
                       center=false,
                       r_factor=0.5);
        }
      }
      if (holes_n > 0) {
        translate([dx, -dy - ear_len, 0]) {
          translate([w_narrow / 2, bolt_edge_offset, 0]) {
            rows_children(rows=holes_n, w=bolt_d, gap=holes_gap) {
              circle(d=bolt_d, $fn=fn);
            }
          }
        }
      }
    }
  }

  profile();
  if (debug) {
    debug_polygon_text(pts, font_size=2);
  }
}

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
                            bearing_od=knuckle_outer_bearing_od,
                            bearing_shoulder_d=knuckle_inner_bearing_shoulder_d,
                            bearing_w=knuckle_outer_bearing_w,
                            bearing_z_clearance=knuckle_outer_bearing_z_clearance,
                            bearing_clearance=knuckle_outer_bearing_clearance,
                            knuckle_outer_housing_thickness=knuckle_outer_wall_thickness,
                            bearing_spacer_h=knuckle_bearing_spacer_h,
                            corner_r=knuckle_arm_corner_r,
                            ear_len=knuckle_arm_ear_len,
                            debug=false) {

  assert(angle < 90, "knuckle_steering_arm: Angle should be less than 90!");

  lower_params = knuckle_outer_bearing_params(bearing_od=bearing_od,
                                              bearing_w=bearing_w,
                                              bearing_z_clearance=bearing_z_clearance,
                                              bearing_clearance=bearing_clearance,
                                              spacer_h=bearing_spacer_h,
                                              wall_thickness=knuckle_outer_housing_thickness);

  outer_bearing_seat_od = lower_params[0];
  bearing_h = lower_params[2];

  lower_height = lower_params[3];

  corner_r = min(l2 - 0.01,
                 w_narrow / 2,
                 (ear_len - bolt_d - bolt_edge_offset) / 2,
                 corner_r);
  connector_l = l2 - corner_r;
  fn = $preview ? 30 : 360;

  module _ring() {
    hull() {
      rotate([0, 90, 0]) {
        cylinder(d2=outer_d,
                 d1=outer_d,
                 h=w_base,
                 $fn=fn);
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
                knuckle_arm_profile(w_base=w_base,
                                     w_narrow=w_narrow,
                                     l1=l1,
                                     l2=l2,
                                     angle=angle,
                                     ear_len=ear_len,
                                     bolt_d=bolt_d,
                                     bolt_edge_offset=bolt_edge_offset,
                                     holes_n=holes_n,
                                     holes_gap=holes_gap,
                                     corner_r=corner_r,
                                     lower_height=lower_height,
                                     outer_bearing_seat_od=outer_bearing_seat_od,
                                     debug=debug);
              }
            }
          }
        }
      }
      translate([-lower_height, 0, 0]) {
        rotate([0, 90, 0]) {
          cylinder(d2=outer_d,
                   d1=outer_bearing_seat_od,
                   h=lower_height,
                   $fn=fn);
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

knuckle_steering_arm(debug=false);
