/* ackermann.scad - Ackermann Steering Mechanism Components
 *
 * This file defines the modules used to generate the parts for an
 * Ackermann-style steering system. The components defined in this file
 * include various linkage pieces, brackets, mounting holes, and connectors,
 * which together form the complete steering assembly.
 *
 * The key modules include:
 *   - ackermann_steering_linkage_short: A short linkage piece with three screw holes.
 *   - ackermann_steering_linkage_long: A long linkage piece.
 *   - ackermann_linkage_connector_right and ackermann_linkage_connector_left:
 *       Create the right and left connectors for the Ackermann linkage.
 *   - ackermann_print_plate: Arranges all parts onto a print plate for simultaneous printing.
 *
 * Note: All parameters (e.g., dimensions, screw diameters, and extrusion thicknesses)
 *       are defined in the external file ../parameters.scad.
 *       Utility functions (e.g., rounded_rect) are included from ../util.scad.
 */

include <../parameters.scad>

use <../util.scad>
use <steering_lower_link_detachable.scad>

//   Creates a rounded thin rectangular piece with three screw holes:
//     - One central hole intended for the servo horn,
//     - Two side holes that connect to the long linkage, forming the trapezoid
//       of the Ackermann steering linkage.
module ackermann_steering_linkage_short(size=[steering_short_linkage_len,
                                              steering_tie_rod_width],
                                        center_screw_dia=steering_tie_rod_center_screw_d,
                                        thickness=2) {
  linear_extrude(thickness, center=true) {
    difference() {
      rounded_rect(size=size, r=size[1] / 2, center=true);
      steering_knuckle_mount_holes(w=size[0]);
      circle(r=center_screw_dia / 2, $fn=360);
    }
  }
}

//   Creates a long linkage piece for the Ackermann steering mechanism,
//   featuring a rounded rectangular shape with mounting holes.
module ackermann_steering_linkage_long(size=[steering_long_linkage_len,
                                             steering_tie_rod_width],
                                       thickness=2) {
  linear_extrude(thickness, center=true) {
    difference() {
      rounded_rect(size=size, r=size[1] / 2, center=true);
      steering_knuckle_mount_holes(w=size[0]);
    }
  }
}

// Creates a bracket shape consisting of a rounded rectangle with two screw holes.
module bracket_shape(w, h, screws_dia) {
  translate([w/2, h/2]) {
    difference() {
      rounded_rect(size = [w, h], r = h/2, center = true);
      for (x = [-w/2 + screws_dia, w/2 - screws_dia]) {
        translate([x, 0, 0]) {
          circle(r = screws_dia * 0.5, $fn=360);
        }
      }
    }
  }
}

// Creates the right-side connector for the Ackermann linkage.
// The connector consists of a rounded rectangle with a bracket inserted at one end.
module ackermann_linkage_connector_right(size=[steering_linkage_connector_len,
                                               steering_linkage_connector_height],
                                         bracket_width=steering_linkage_connector_bracket_len,
                                         thickness=2,
                                         screws_dia=steering_knuckle_screws_dia,
                                         angle=steering_ackernmann_connector_angle) {
  w = size[0];
  h = size[1];
  half_w = w * 0.5;

  linear_extrude(height = thickness, center=true) {
    difference() {
      union() {
        rounded_rect(size = [w, h], r = h / 2, center = true);
        anchor = [-half_w + h, 0];

        translate(anchor) {
          rotate(angle) {
            bracket_shape(bracket_width, h, screws_dia);
          }
        }
      }
      for (x = [-half_w + screws_dia, half_w - screws_dia]) {
        translate([x, 0, 0]) {
          circle(r = screws_dia * 0.5, $fn=360);
        }
      }
    }
  }
}

// Creates the left-side connector for the Ackermann linkage.
// The connector consists of a rounded rectangle with a bracket inserted at one end.
module ackermann_linkage_connector_left(size=[steering_linkage_connector_len,
                                              steering_linkage_connector_height],
                                        bracket_width=steering_linkage_connector_bracket_len,
                                        thickness=2,
                                        screws_dia=steering_knuckle_screws_dia,
                                        angle=steering_ackernmann_connector_angle) {
  mirror([1, 0, 0]) {
    ackermann_linkage_connector_right(size=size,
                                      bracket_width=bracket_width,
                                      thickness=thickness,
                                      screws_dia=screws_dia,
                                      angle=angle);
  }
}

// Arranges the various Ackermann linkage components onto a print plate,
// allowing for simultaneous printing. The assembly includes the lower
// detachable link, both short and long linkages, and the left/right connectors.
module ackermann_print_plate() {
  steering_lower_link_detachable();
  offst = steering_link_width + 4;
  translate([0, offst, 0]) {
    ackermann_steering_linkage_short();
    translate([0, offst, 0]) {
      ackermann_steering_linkage_long();
    }

    translate([0, offst, 0]) {
      union() {
        base_x_offsts = [steering_long_linkage_len * 0.5,
                         steering_linkage_connector_len * 0.5];
        translate([base_x_offsts[0] + base_x_offsts[1], -offst, 0]) {
          ackermann_linkage_connector_left();
        }

        translate([-base_x_offsts[0] - base_x_offsts[1], -offst, 0]) {
          ackermann_linkage_connector_right();
        }
      }
    }
  }
}

color("white") {
  ackermann_print_plate();
}
