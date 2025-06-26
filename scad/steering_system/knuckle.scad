/* knuckle.scad - Steering knuckles for the front wheels.
 *
 * This file defines printable modules for steering knuckles.
 * There are two primary modules: knuckle_right and knuckle_left.
 * Additionally, the knuckles_print_plate module combines both for convenient printing.
 *
 * Each knuckle mechanically connects the wheel to the tie rod and the steering links.
 *
 * Mounting:
 *   - The knuckle is attached to the wheel using R4120 rivets.
 *     (You can specify an alternate diameter by setting the variable
 *      'front_wheel_knuckle_dia' in ../parameters.scad.)
 *
 *   - The steering linkage is connected to the knuckles using R3065 rivets.
 *     (See the variable 'steering_knuckle_screws_dia' for details.)
 *
 */
include <../parameters.scad>
use <../util.scad>

//   Creates the knuckle section that connects to the wheel geometry.
module knuckle_wheel_connector(w=steering_knuckle_width,
                               h=steering_knuckle_lower_height,
                               thickness=steering_knuckle_thickness,
                               screws_dia=front_wheel_knuckle_dia) {
  linear_extrude(thickness) {
    union() {
      difference() {
        square(size = [w, h], center = true);
        circle(r = screws_dia * 0.5, $fn=360);
      }
      translate([-w * 0.5, steering_knuckle_upper_height * 0.5, 0]) {
        knuckle_upper_pan();
      }
    }
  }
}

// Creates the upper pan geometry for the knuckle.
module knuckle_upper_pan(w=steering_knuckle_width * 0.5,
                         h=steering_knuckle_upper_height,
                         fillet_r = 0.4) {
  pts = [[0, 0],
         [0, h * 0.8],
         [w * 0.05, h * 0.8],
         [w * 0.35, h],
         [w, h],
         [w, h * 0.5],
         [w, 0]];

  difference() {
    offset(r = fillet_r, chamfer = false) {
      offset(r = -fillet_r, chamfer = false) {
        polygon(points = pts);
      }
    }
  }
}

// Constructs a side piece for the knuckle with an integrated screw hole.
// The shape is a rounded rectangle with a circular cutout for the screw.
module knuckle_inner_side(w=steering_knuckle_side_width,
                          h=steering_knuckle_lower_height,
                          side_x_screw_offset=steering_knuckle_side_hole_offset,
                          side_y_screw_offset=0,
                          thickness=steering_knuckle_thickness) {
  linear_extrude(height = thickness) {
    difference() {
      rounded_rect(size = [w, h], r = h * 0.1, center = true);

      translate([side_x_screw_offset, side_y_screw_offset, 0]) {
        circle(r = steering_knuckle_screws_dia * 0.5, $fn=360);
      }
    }
  }
}

// Generates the left steering knuckle.
module knuckle_left() {
  rotate([180, 0, 0]) {
    union() {
      knuckle_wheel_connector();

      half_knuckle_w = steering_knuckle_width * 0.5;
      z_offset = -steering_knuckle_side_width * 0.5 + steering_knuckle_thickness;

      translate([half_knuckle_w, 0, z_offset]) {
        rotate([0, 90, 0]) {
          union() {
            knuckle_inner_side();
          }
        }
      }

      translate([-half_knuckle_w, steering_knuckle_upper_height * 0.5, z_offset]) {
        height = steering_knuckle_lower_height + steering_knuckle_upper_height;
        rotate([0, 90, 0]) {
          knuckle_inner_side(h=height, side_y_screw_offset=-height * 0.3);
        }
      }

      inner_h = steering_knuckle_upper_height * 0.9;
      translate([0, steering_knuckle_upper_height + steering_knuckle_upper_height * 0.1, z_offset]) {
        rotate([0, 90, 0]) {
          knuckle_inner_side(h=inner_h);
        }
      }
    }
  }
}
// Generates the right steering knuckle by mirroring the left knuckle.
module knuckle_right() {
  mirror([1, 0, 0]) {
    knuckle_left();
  }
}

// Produces a print plate that includes both left and right knuckles for
// simultaneous printing.
module knuckles_print_plate() {
  union() {
    translate([(-steering_knuckle_upper_height - steering_knuckle_lower_height) * 0.5, 0, 0]) {
      knuckle_left();
    }
    translate([(steering_knuckle_upper_height + steering_knuckle_lower_height) * 0.5, 0, 0]) {
      knuckle_right();
    }
  }
}

color("white") {
  knuckles_print_plate();
}
