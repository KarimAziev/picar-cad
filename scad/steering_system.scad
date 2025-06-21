/* steering_system.scad - Front Wheels’ Steering System Modules
 *
 * This file defines models for the front steering system of a vehicle.
 * The included components are:
 *
 * - Mounting holes on the steering knuckles - for attaching components using
 *   R3065 rivets (the screw diameter is controlled by
 *   steering_wheel_screws_dia).
 *
 * - Lower detachable steering link - a 2D profile is defined and then extruded
 *   to generate a 3D part. This link acts as a rigid beam joining both steering
 *   knuckles. Although it connects them, it is not directly responsible for
 *   control (i.e. it is not connected to any servo).
 *
 * - Upper chassis steering link - integrated directly into the chassis. This
 *   module extrudes a modified version of the lower link (with an additional
 *   rectangular cut-out) and adds support cylinders on both extremes.
 *
 * - Steering tie rod - a fixed trapezoidal component which connects the two
 *   rotating knuckles. Its central opening is designed for a servo horn, while
 *   the side openings align with the mounting holes to transfer the servo turn
 *   to a movement in the knuckles.
 *
 * Note:
 *   - Custom parameters are imported from parameters.scad.
 */

include <parameters.scad>
use <util.scad>;

//  Creates the two mounting holes used for attaching the steering knuckle components.
//  Two pairs of circular holes are generated with an X-offset relative to the wheel distance,
//  based on a screw_offset and the defined screw diameter.
module steering_knuckle_mount_holes() {
  line_w = 2;
  screw_offset = 4;

  for (x_offsets = [[-wheels_distance/2 + screw_offset,
                     steering_wheel_screws_dia + line_w],
                    [wheels_distance/2 - screw_offset,
                     -steering_wheel_screws_dia - line_w]]) {
    x1 = x_offsets[0];
    x2 = x_offsets[1];
    translate([x1, 0, 0]) {
      circle(d=steering_wheel_screws_dia, $fn=360);
      translate([x2, 0, 0]) {
        circle(d=steering_wheel_screws_dia, $fn=360);
      }
    }
  }
}

//  Generates a 2D shape of the lower detachable steering link.
module steering_lower_link_detachable_2d() {
  difference() {
    rounded_rect([wheels_distance, bottom_wheel_plate_width], r=bottom_wheel_plate_width/2, center=true);

    neckline_width=wheels_distance / 1.8;
    neckline_height=bottom_wheel_plate_width;

    translate([0, -bottom_wheel_plate_width * 0.75, 0]) {
      rounded_rect([neckline_width, neckline_height], center=true);
    }

    translate([0, bottom_wheel_plate_width * 0.2, 0]) {
      rounded_rect([wheels_distance * 0.5, bottom_wheel_plate_width * 0.13], r=1, center=true);
    }

    steering_knuckle_mount_holes();

    step = 10;
    amount = floor(bottom_wheel_plate_width / step);
    cutoff_w = wheels_distance * 0.65;

    for (i = [0:amount-1]) {
      translate([0, 0 + -i * step]) {
        rounded_rect([cutoff_w, 4], r=2, center=true);
      }
    }

    translate([0, 9]) {
      rounded_rect([cutoff_w, 4], r=2, center=true);
    }
  }
}

//  A 3D shape of the upper detachable steering link.
module steering_lower_link_detachable(height=2) {
  linear_extrude(height) {
    steering_lower_link_detachable_2d();
  }
}

// Models the integrated upper steering link that is mounted to the chassis.
module steering_upper_chassis_link(height=steering_upper_chassis_link_thickness) {
  union() {
    linear_extrude(height) {
      difference() {
        steering_lower_link_detachable_2d();
        square([70, 20], center = true);
      }
    }
    translate([-35, 0, 0]) {
      cylinder(height, r1=bottom_wheel_plate_width/2, r2=bottom_wheel_plate_width/2);
    }
    translate([35, 0, 0]) {
      cylinder(height, r1=bottom_wheel_plate_width/2, r2=bottom_wheel_plate_width/2);
    }
  }
}

// Creates the rigid trapezoidal tie rod that links the two pivoting knuckles.
// A central opening is provided for the servo horn, and mounting holes (on the sides)
// align with the knuckle attachments. The servo rotates the horn, which then actuates
// the tie rod to steer both wheels.
module steering_tie_rod(size=[wheels_distance, steering_tie_rod_width], height=2) {
  difference() {
    linear_extrude(height) {
      difference() {
        rounded_rect(size=size, r=steering_tie_rod_width / 2, center=true);
        steering_knuckle_mount_holes();
      }
    }
    cylinder(h = 10, r = steering_tie_rod_center_screw_d / 2, center = true, $fn=360);
  }
}

color("white") {
  steering_lower_link_detachable();
  translate([0, bottom_wheel_plate_width, 0]) {
    steering_tie_rod();
  }
}
