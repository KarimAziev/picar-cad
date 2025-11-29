/**
 * Module: Knuckle Shaft
 *
 * This file defines modules for a removable bent (curved) axle shaft that connects
 * the steering knuckle to the wheel hub in a vehicle's steering assembly.
 *
 * The shaft is composed of vertical and horizontal cylindrical segments arranged
 * in an "elbow" configuration, forming a rigid connection. It is designed to be
 * secured in place via a single mounting screw.
 *
 * Main module:
 * - knuckle_shaft:
 *     Entry-point module. Forms the complete bent shaft assembly and optionally
 *     displays the front wheel attached at the end.
 *
 * Auxiliary modules:
 * - knuckle_bent_shaft:
 *     Builds the full bent shaft geometry from vertical and horizontal cylinders
 *     and elbow joints using circular extrusions.
 *
 * - knuckle_bent:
 *     Utility module that creates a curved bend via rotate_extrude().
 *
 * - knuckle_screws_slots:
 *     Cuts a slot for a screw that fixes the shaft in place.
 *
 * - knuckle_shaft_print_plate:
 *     Optional helper that places and mirrors the shaft for 3D printing layout.
 *
 * Parameters:
 * - show_wheel (bool): When true, shows attached animated front wheel.
 * - knuckle_shaft_color (color): Color used for visualizing the shaft.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>

use <../wheels/front_wheel.scad>

module knuckle_shaft(show_wheel=false,
                     knuckle_shaft_color="white") {
  difference() {
    translate([0, 0, knuckle_shaft_dia / 2]) {
      knuckle_bent_shaft(show_wheel=show_wheel,
                         knuckle_shaft_color=knuckle_shaft_color);
    }

    translate([0,
               0,
               -knuckle_shaft_screws_offset]) {
      rotate([0, 0, 90]) {
        knuckle_screws_slots(d=knuckle_shaft_screw_dia);
        translate([0,
                   0,
                   - knuckle_shaft_screw_dia
                   - knuckle_shaft_screws_distance]) {
          knuckle_screws_slots(d=knuckle_shaft_screw_dia);
        }
      }
    }
  }
}

module knuckle_bent(angle, r, fn=360, bent_color=matte_black) {
  color(bent_color) {
    rotate_extrude(angle=angle) {
      translate([r, 0, 0]) {
        circle(r=r, $fn=fn);
      }
    }
  }
}

module knuckle_bent_shaft(show_wheel=false,
                          knuckle_shaft_color=matte_black) {
  d = knuckle_shaft_dia;
  knuckle_rad = knuckle_dia / 2;
  r = d / 2;
  union() {
    translate([0,
               0,
               -knuckle_shaft_vertical_len - r]) {
      color(knuckle_shaft_color) {
        cylinder(h=knuckle_shaft_vertical_len, r=r, center=false, $fn=360);
      }

      translate([0, r, 0]) {
        rotate([-0, 90, 0]) {
          knuckle_bent(angle=-90, r=r, bent_color=knuckle_shaft_color);
        }
        translate([0, 0, -r]) {
          rotate([-90, 0, 0]) {
            color(knuckle_shaft_color) {
              cylinder(h=knuckle_shaft_connector_extra_len
                       + knuckle_rad
                       + knuckle_shaft_extra_len,
                       r=r,
                       center=false,
                       $fn=360);
            }
          }
          translate([-r,
                     knuckle_shaft_connector_extra_len
                     + knuckle_rad +
                     knuckle_shaft_extra_len,
                     0]) {
            knuckle_bent(angle=90, r=r, bent_color=knuckle_shaft_color);

            translate([0, r, 0]) {
              rotate([0, -90, 0]) {
                color(knuckle_shaft_color) {
                  cylinder(h=knuckle_shaft_lower_horiz_len,
                           r=r,
                           center=false,
                           $fn=360);
                }

                if (show_wheel) {
                  translate([0, 0, wheel_center_offset]) {
                    front_wheel_animated();
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

module knuckle_screws_slots(d=knuckle_shaft_screw_dia,
                            h=knuckle_shaft_dia + 1,
                            fn=360) {
  translate([0, 0, -d / 2]) {
    rotate([90, 0, 0]) {
      cylinder(h=h, r=d / 2, center=true, $fn=fn);
    }
  }
}

module knuckle_shaft_print_plate() {
  offst = knuckle_dia;
  z = knuckle_shaft_vertical_len + knuckle_shaft_dia;
  translate([offst / 2 + knuckle_shaft_lower_horiz_len, 0, z]) {
    knuckle_shaft();
  }
  translate([-offst / 2 - knuckle_shaft_lower_horiz_len, 0, z]) {
    mirror([1, 0, 0]) {
      knuckle_shaft();
    }
  }
}

knuckle_shaft_print_plate();
