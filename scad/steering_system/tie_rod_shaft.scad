/**
 * Module: Tie Rod Shaft
 *
 * Tie Rod Shaft is inserted at one end into one of the
 * steering knuckle arms and at the other end, extending downward under the
 * chassis, into the tie rod.
 *
 * The Tie Rod Shaft has the shape of an elongated cylinder. One end has
 * threaded holes for fixation in the knuckle arm, and the other end has a
 * smaller-diameter cylinder onto which a bearing - fitted into the tie rod - is
 * mounted.
 *
 * Thus, the knuckle arms and the tie rod form an Ackermann steering trapezoid.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>
use <knuckle_shaft.scad>
use <bearing_shaft.scad>
use <tie_rod.scad>
use <../lib/trapezoids.scad>
use <../lib/transforms.scad>

function tie_rod_shaft_full_len() =
  tie_rod_shaft_bearing_pin_height
  + tie_rod_shaft_len;

module tie_rod_shaft(shaft_color="white",
                     show_tie_rod=false,
                     show_bearing=false,
                     shaft_rotation=-steering_alpha_deg) {
  union() {
    rotate([0, 0, 90]) {
      difference() {
        color(shaft_color, alpha=1) {
          translate([0, 0, tie_rod_shaft_bearing_pin_height]) {
            cylinder(h=tie_rod_shaft_len,
                     r=tie_rod_shaft_dia / 2,
                     center=false,
                     $fn=360);
            rotate([180, 0, 0]) {
              bearing_shaft(d=tie_rod_bearing_inner_dia,
                            h=tie_rod_shaft_bearing_pin_height,
                            chamfer_h=tie_rod_shaft_bearing_pin_chamfer_height,
                            stopper_h=0);
            }
          }
        }
        translate([0, 0,
                   tie_rod_shaft_full_len()
                   - tie_rod_shaft_bolt_offset]) {
          rotate([0, 0, 90]) {
            knuckle_bolts_slots(d=tie_rod_shaft_bolt_dia,
                                h=tie_rod_shaft_dia);
            translate([0,
                       0,
                       - tie_rod_shaft_bolt_dia
                       - tie_rod_shaft_bolt_distance]) {
              knuckle_bolts_slots(d=tie_rod_shaft_bolt_dia,
                                  h=tie_rod_shaft_dia);
            }
          }
        }
      }
    }

    if (show_tie_rod) {
      translate([0, 0,
                 tie_rod_shaft_bearing_pin_height
                 - tie_rod_thickness]) {
        rotate([0, 0, shaft_rotation]) {
          translate([-tie_rod_len / 2
                     + tie_rod_bearing_outer_dia / 2
                     + tie_rod_bearing_x_offset, 0, 0]) {
            tie_rod(show_bearing=show_bearing);
          }
        }
      }
    }
  }
}

module tie_rod_shafts_printable(spacing=2) {
  translate([0, 0, tie_rod_shaft_full_len()]) {
    rotate([0, 180, 0]) {
      mirror_copy([1, 0, 0]) {
        translate([-tie_rod_shaft_dia / 2 - spacing, 0, 0]) {
          tie_rod_shaft();
        }
      }
    }
  }
}

translate([0, 0, tie_rod_shaft_full_len()]) {
  rotate([0, 180, 0]) {
    tie_rod_shaft();
  }
}
