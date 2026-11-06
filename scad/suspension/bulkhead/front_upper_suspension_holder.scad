/**
  * Module: Front upper suspension holder with steering-plate lugs.
  *
  * The holder is centered on X, with its body at Z=0 through thickness.
  * Hinge-pin bores run along Z. Steering lugs extend toward negative Z;
  * their contact faces lie on Y=0 and their mounting bores run along Y.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../parameters.scad>
include <../../rc_params.scad>

use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../lib/trapezoids.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_upper_suspension_holder_steering_mounts
  ─────────────────────────────────────────────────────────────────────────────
  Return the steering-plate contact centers in the holder's local frame.
  **Parameters:**
  - `bolt_spacing`: X center-to-center spacing of the two holes.
  - `bolt_d`: Steering mounting hole diameter.
  - `mount_pad`: Radial material around each hole.
  **Returns:** Two [x, y, z] points on Y=0. The holes run along local Y;
  the lugs project toward negative Z from the holder body at Z=0.
 */
function front_upper_suspension_holder_steering_mounts(
  bolt_spacing=front_upper_suspension_holder_steering_bolt_spacing,
  bolt_d=front_upper_suspension_holder_steering_bolt_d,
  mount_pad=front_upper_suspension_holder_steering_mount_pad) =
  [for (side = [-1, 1])
    [side * bolt_spacing / 2, 0, -mount_pad - bolt_d / 2]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_upper_suspension_holder_steering_slots
  ─────────────────────────────────────────────────────────────────────────────
  Create the two steering mounting cutters in the holder's local frame.
  **Parameters:**
  - `w`: Lug depth along negative Y.
  - `bolt_d`: Through-hole diameter.
  - `mount_pad`: Radial material around the holes, setting their Z offset.
  - `bolt_spacing`: X center-to-center spacing.
 */
module front_upper_suspension_holder_steering_slots(
  w=front_upper_suspension_w,
  bolt_d=front_upper_suspension_holder_steering_bolt_d,
  mount_pad=front_upper_suspension_holder_steering_mount_pad,
  bolt_spacing=front_upper_suspension_holder_steering_bolt_spacing) {
  for (p = front_upper_suspension_holder_steering_mounts(
    bolt_spacing=bolt_spacing, bolt_d=bolt_d, mount_pad=mount_pad)) {
    translate(p + [0, 0.01, 0]) {
      rotate([90, 0, 0]) {
        cylinder(d=bolt_d, h=w + 0.02, $fn=$preview ? 48 : 120);
      }
    }
  }
}

module front_upper_suspension_holder(l=front_upper_suspension_holder_l,
                                     w=front_upper_suspension_w,
                                     thickness=front_upper_suspension_holder_thickness,
                                     color=cobalt_blue_metallic,
                                     center_cutout_w=front_upper_suspension_holder_rect_cutout_w,
                                     pin_hole_spacing=front_bulkhead_pin_spacing,
                                     pin_d=front_upper_arm_hinge_barrel_hole_d,
                                     grab_screw_d=front_upper_suspension_holder_grab_screw_d,
                                     bolt_d=front_upper_suspension_holder_bolt_d,
                                     bolt_spacing=front_upper_suspension_holder_bolt_spacing,
                                     bore_d=front_upper_suspension_holder_bolt_bore_d,
                                     bore_h=front_upper_suspension_holder_bolt_bore_h,
                                     round_cutout_y_offset=front_upper_suspension_holder_round_cutout_offset,
                                     round_cutout_d=front_upper_suspension_holder_round_cutout_d,
                                     pad=front_upper_suspension_holder_bolt_pad,
                                     barrel_d=front_upper_suspension_holder_pin_barrel_d,
                                     barrel_h=front_upper_suspension_holder_pin_barrel_h,
                                     bore_y_offset=front_upper_suspension_holder_bolt_y_offset,
                                     steering_mount_pad=front_upper_suspension_holder_steering_mount_pad,
                                     steering_bolt_d=front_upper_suspension_holder_steering_bolt_d,
                                     steering_bolt_spacing=front_upper_suspension_holder_steering_bolt_spacing) {

  barrel_border_w = (barrel_d - pin_d) / 2;

  steering_mount_d = steering_mount_pad * 2 + steering_bolt_d;
  assert(steering_mount_pad > 0 && steering_bolt_d > 0 && w > 0);
  assert(steering_bolt_spacing > steering_mount_d);
  assert(steering_bolt_spacing + steering_mount_d <= l,
         "Steering lugs must join the holder body");

  translate([0, 0, thickness]) {
    difference() {
      maybe_color(color) {
        translate([0, 0, -thickness]) {
          difference() {
            mirror_copy([1, 0, 0]) {
              translate([steering_bolt_spacing / 2, 0, 0]) {
                cuboid(size=[steering_mount_d, w, steering_mount_d],
                       r_factor=0.5,
                       axis="y",
                       side="bottom",
                       anchor=[0, -1, -1]);
              }
            }
            front_upper_suspension_holder_steering_slots(
              w=w,
              bolt_d=steering_bolt_d,
              mount_pad=steering_mount_pad,
              bolt_spacing=steering_bolt_spacing);
          }
          difference() {
            linear_extrude(height=thickness, center=false, convexity=3) {
              difference() {
                union() {
                  hull() {
                    mirror_copy([1, 0, 0]) {
                      translate([pin_hole_spacing / 2, pin_d / 2, 0]) {
                        circle(r=pin_d / 2, $fn=$preview ? 40 : 50);
                      }
                    }

                    translate([0, -w / 2, 0]) {
                      rounded_rect([l, w],
                                   center=true,
                                   fn=30,
                                   r_factor=0.2,
                                   side="bottom");
                    }

                    translate([0, -w - pad / 2, 0]) {
                      trapezoid_rounded_bottom(b=bolt_spacing + bore_d,
                                               t=bolt_spacing + bore_d * 2,
                                               h=pad,
                                               center=true);
                    }
                  }
                  mirror_copy([1, 0, 0]) {
                    translate([pin_hole_spacing / 2 - barrel_d / 2,
                               -barrel_border_w,
                               0]) {
                      // End the rectangular web before the barrel tangent.
                      square([barrel_d, barrel_d / 2 - 0.01]);
                    }
                  }
                }

                translate([0, pin_d / 2, 0]) {
                  rounded_rect([center_cutout_w, pin_d],
                               center=true,
                               side="bottom");
                }

                translate([0,
                           - round_cutout_d / 2
                           - bore_d / 2
                           - round_cutout_y_offset,
                           0]) {
                  circle(r=round_cutout_d / 2, $fn=$preview ? 16 : 360);
                }
              }
            }
            mirror_copy([1, 0, 0]) {
              translate([bolt_spacing / 2, -bore_d / 2 - bore_y_offset, 0]) {
                counterbore(d=bolt_d,
                            bore_d=bore_d,
                            h=thickness,
                            reverse=true,
                            bore_h=bore_h,
                            sink=true);
              }
            }
          }
        }
        mirror_copy([1, 0, 0]) {
          translate([pin_hole_spacing / 2,
                     pin_d / 2,
                     -thickness]) {
            cylinder(d=barrel_d, h=barrel_h, $fn=$preview ? 100 : 360);
          }
        }
      }
      mirror_copy([1, 0, 0]) {
        translate([pin_hole_spacing / 2, pin_d / 2, -thickness - 0.01]) {
          cylinder(d=pin_d, h=max(thickness, barrel_h) + 0.02,
                   $fn=$preview ? 100 : 360);
        }
        translate([pin_hole_spacing / 2,
                   0.1 + barrel_border_w,
                   -thickness / 2]) {
          rotate([90, 0, 0]) {
            teardrop(d=grab_screw_d,
                     h=w + pad + barrel_border_w + 0.2,
                     fn=$preview ? 30 : 100);
          }
        }
      }
    }
  }
}

front_upper_suspension_holder();
