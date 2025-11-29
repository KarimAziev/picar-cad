/**
 * Module: Detachable kingpin post.
 *
 * This file defines a detachable kingpin post. You should print two posts and
 * attach one to each side of the steering panel.
 *
 * The kingpin post consists of three stacked cylinders:
 *
 * 1. The lower mounting flange/cylinder, which is inserted into the side panel
 * and contains two screw holes (diameter controlled by
 * `steering_kingpin_post_screw_dia`).
 *
 * 2. The middle cylindrical boss, which matches the knuckle diameter.
 *
 * 3. The upper shaft for the knuckle bearing, which includes a
 * chamfered/tapered tip to seat the bearing.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>

use <bearing_shaft.scad>
use <../lib/transforms.scad>

steering_hinge_screw_rad = steering_panel_hinge_screw_dia / 2;

module steering_kingpin_post() {
  border_rad = (knuckle_dia - (steering_kingpin_post_border_w * 2)) / 2
    - 0.1;
  center_hole_extra_h = 1;

  difference() {
    union() {
      difference() {
        cylinder(h=steering_rack_support_thickness,
                 r=border_rad,
                 center=false,
                 $fn=360);
        steering_kingpin_post_screw_holes();
      }
      translate([0, 0, steering_rack_support_thickness]) {
        bearing_shaft_connector(lower_d=knuckle_dia,
                                lower_h=knuckle_pin_lower_height,
                                shaft_h=knuckle_pin_bearing_height,
                                shaft_d=knuckle_bearing_inner_dia,
                                chamfer_h=knuckle_pin_chamfer_height,
                                stopper_h=knuckle_pin_stopper_height);
      }
    }

    translate([0, 0, -center_hole_extra_h]) {
      cylinder(h=knuckle_pin_lower_height
               + steering_rack_support_thickness
               + center_hole_extra_h,
               r=steering_hinge_screw_rad,
               center=false,
               $fn=200);
    }
  }
}

module steering_kingpin_post_screw_holes() {
  mirror_copy([1, 0, 0]) {
    translate([steering_hinge_screw_rad * 2 + 0.1,
               0, steering_rack_support_thickness / 2
               - steering_hinge_screw_rad]) {
      extra_h = 1;
      screw_rad = steering_kingpin_post_screw_dia / 2;
      h = knuckle_dia + extra_h;
      seam_h = 0.8;
      translate([0, 0, screw_rad]) {
        rotate([90, 0, 0]) {
          cylinder(h=h,
                   r=screw_rad,
                   $fn=100,
                   center=true);
        }
      }
      translate([0, -h / 2, steering_kingpin_post_screw_dia - seam_h / 2]) {
        cube([0.4, h, seam_h]);
      }
    }
  }
}

module steering_kingpin_post_print_plate(space=2, vertical=false) {
  rad = knuckle_dia / 2;

  for (i = [-rad - space, rad + space]) {
    translate([vertical ? 0 : i, vertical ? i : 0, 0]) {
      steering_kingpin_post();
    }
  }
}

// steering_kingpin_post_print_plate();
steering_kingpin_post();