/**
 * Module: Tie Rod
 *
 * Tie Rod has the shape of a "stadium" (a rounded rectangle), with holes for
 * bearings at both ends. The bearings inserted into those holes are mounted
 * onto shafts fixed to the knuckle arms. Thus, the angled knuckle arms and the
 * Tie Rod form the Ackermann steering trapezoid.
 *
 * To give maximum stiffness I recommend printing with maximum infill and an
 * Infill Wall Overlap of 90%, or at least with six wall loops.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <../util.scad>
use <../placeholders/bearing.scad>
use <knuckle.scad>

module tie_rod(tie_rod_color="white", show_bearing=false) {
  color(tie_rod_color, alpha=1) {
    linear_extrude(height=tie_rod_thickness, center=false) {
      difference() {
        rounded_rect([tie_rod_len, tie_rod_outer_dia],
                     center=true,
                     fn=360,
                     r_factor=0.5);
        mirror_copy([1, 0, 0]) {
          translate([-tie_rod_len / 2
                     + tie_rod_bearing_outer_dia / 2
                     + tie_rod_bearing_x_offset,
                     0,
                     0]) {
            circle(r=tie_rod_bearing_outer_dia / 2, $fn=360);
          }
        }
      }
    }
  }

  if (show_bearing) {
    mirror_copy([1, 0, 0]) {
      translate([-tie_rod_len / 2 + tie_rod_bearing_outer_dia / 2
                 + tie_rod_bearing_x_offset, 0, 0]) {
        bearing(d=tie_rod_bearing_outer_dia,
                h=tie_rod_bearing_height,
                flanged_w=tie_rod_bearing_flanged_width,
                flanged_h=tie_rod_bearing_flanged_height,
                shaft_d=round(tie_rod_bearing_inner_dia),
                shaft_ring_w=1,
                outer_ring_w=0.5,
                outer_col=metalic_silver_3,
                rings=[[1, metalic_yellow_silver],
                       [0.5, onyx]]);
      }
    }
  }
}

tie_rod(show_bearing=false);