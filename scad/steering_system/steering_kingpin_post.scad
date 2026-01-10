/**
 * Module: Detachable kingpin post.
 *
 * This file defines a detachable kingpin post. You should print two posts and
 * attach one to each side of the steering panel.
 *
 * The kingpin post consists of three stacked cylinders:
 *
 * 1. The lower mounting flange/cylinder, which is inserted into the side panel
 * and contains two bolt holes (diameter controlled by
 * `steering_kingpin_post_bolt_dia`).
 *
 * 2. The middle cylindrical boss, which matches the knuckle diameter.
 *
 * 3. The upper shaft for the knuckle bearing, which includes a
 * chamfered/tapered tip to seat the bearing.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../placeholders/bolt.scad>
use <bearing_shaft.scad>

kingpin_bolt_rad = steering_kingpin_post_bolt_dia / 2;

module steering_kingpin_post(color) {
  border_rad = (knuckle_dia - (steering_kingpin_post_border_w * 2)) / 2
    - 0.1;
  center_hole_extra_h = 1;

  color(color, alpha=1) {
    difference() {
      union() {
        difference() {
          cylinder(h=steering_rack_support_thickness,
                   r=border_rad,
                   center=false,
                   $fn=360);
          steering_kingpin_post_bolt_holes();
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
                 r=kingpin_bolt_rad,
                 center=false,
                 $fn=200);
      }
    }
  }
}

module steering_kingpin_post_bolt_holes(bolt_mode=false,
                                        bolt_h=knuckle_dia + 2,
                                        bolt_head_type=steering_kingpin_post_bolt_head_type) {
  mirror_copy([1, 0, 0]) {
    translate([kingpin_bolt_rad * 2 + 0.1,
               0,
               steering_rack_support_thickness / 2
               - kingpin_bolt_rad]) {
      extra_h = 1;
      bolt_rad = steering_kingpin_post_bolt_dia / 2;
      h = knuckle_dia + extra_h;

      seam_h = 0.4;
      seam_w = 0.4;

      if (bolt_mode) {
        translate([0, 0, bolt_rad]) {
          rotate([-90, 0, 0]) {
            bolt(d=steering_kingpin_post_bolt_dia,
                 h=bolt_h,
                 head_type=bolt_head_type);
          }
        }
      } else {
        translate([0, 0, bolt_rad]) {
          rotate([90, 0, 0]) {
            cylinder(h=h,
                     r=bolt_rad,
                     $fn=360,
                     center=true);
          }
        }

        translate([-seam_w / 2, -h / 2, steering_kingpin_post_bolt_dia - 0.2]) {
          cube([seam_w, h, seam_h]);
        }

        translate([-seam_w / 2, -h / 2, -seam_h + 0.2]) {
          cube([seam_w, h, seam_h]);
        }
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

steering_kingpin_post_print_plate();
