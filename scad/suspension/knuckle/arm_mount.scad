/**
 * Module: Upper and lower arms mount
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../colors.scad>
include <../../parameters.scad>

use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../lib/trapezoids.scad>
use <../../placeholders/tie_rod_end.scad>

module ball_joint_mount(thickness=suspension_tie_rod_mount_thickness,
                        border_w=suspension_tie_rod_border_w,
                        eye_od=suspension_tie_rod_eye_od,
                        eye_h=suspension_tie_rod_eye_h,
                        shank_od=suspension_tie_rod_shank_od,
                        shank_bolt_d=suspension_tie_rod_shank_bolt_d,
                        neck_len=suspension_tie_rod_neck_len,
                        shank_len=suspension_tie_rod_shank_len,
                        bushing_od=suspension_tie_rod_bushing_od,
                        bushing_d=suspension_tie_rod_bushing_d,
                        bushing_h=suspension_tie_rod_bushing_h,
                        bushing_flat_d=suspension_tie_rod_bushing_flat_d,
                        show_eye_bolt=false,
                        eye_bolt_h,
                        eye_bolt_through_h=2,
                        show_eye_bolt_nut=true,
                        eye_bolt_head_type="hex",
                        color=matte_black,
                        parent_d,
                        show_tie_rod=false,
                        tie_rod_end_rotation,
                        direction="bottom",
                        round_all,
                        center_y=true,
                        tolerance=0.4,
                        fn=200) {
  eye_h = with_default(eye_h, shank_od);
  shank_od = with_default(shank_od, eye_h);
  bushing_od = with_default(bushing_od, eye_od * 0.6);
  bushing_h = with_default(bushing_h, bushing_od * 0.98);
  bushing_d = with_default(bushing_d, bushing_od * 0.51);

  bushing_real_h = holed_sphere_height(d=bushing_d, od=bushing_od);
  tie_rod_h = max(shank_od, bushing_real_h, eye_h);
  // thickness + recess for ball joint
  full_h = thickness + tie_rod_h;

  is_bottom = direction == "bottom";
  is_top = direction == "top";
  is_left = direction == "left";
  is_right = direction == "right";
  housing_d = eye_od + border_w * 2;

  shank_recess_w = shank_od + tolerance;

  is_y_direction = is_bottom || is_top;
  is_x_direction = is_left || is_right;

  ratio = is_left || is_bottom ? -1 : 1;

  base_shank_translation = (housing_d / 2 - shank_recess_w / 2);
  shank_translation_y = is_y_direction ? ratio * base_shank_translation : 0;
  shank_translation_x = is_x_direction ? ratio * base_shank_translation : 0;
  module _main() {
    difference() {
      linear_extrude(height=full_h, center=false, convexity=2) {
        difference() {
          rounded_rect([housing_d, housing_d],
                       center=true,
                       fn=fn,
                       side=round_all ? "all" : direction,
                       r_factor=0.5);

          circle(d=bushing_d, $fn=fn);
        }
      }

      translate([0, 0, thickness]) {
        translate([shank_translation_x, shank_translation_y, 0]) {
          cube_3d(size=[shank_recess_w, shank_recess_w, tie_rod_h + 0.1]);
        }

        cylinder(d=eye_od + tolerance, h=tie_rod_h + 0.1, $fn=fn);
      }
    }
  }
  translate([0, center_y ? -full_h / 2 : 0, housing_d / 2]) {
    maybe_rotate([0, tie_rod_end_rotation, 0]) {
      rotate([-90, 0, 0]) {
        union() {
          maybe_color(color, alpha=1) {
            if (!is_undef(parent_d)) {
              intersection() {
                _main();
                translate([0, 0,  -parent_d / 2 + full_h]) {
                  rotate([90, 0, 0]) {
                    cylinder(d=parent_d, h=housing_d, $fn=fn, center=true);
                  }
                }
              }
            } else {
              _main();
            }
          }

          if (show_tie_rod) {
            translate([0, 0, thickness]) {
              tie_rod_end(eye_od=eye_od,
                          eye_h=eye_h,
                          shank_od=shank_od,
                          shank_bolt_d=shank_bolt_d,
                          neck_len=neck_len,
                          shank_len=shank_len,
                          bushing_od=bushing_od,
                          bushing_d=bushing_d,
                          bushing_h=bushing_h,
                          bushing_flat_d=bushing_flat_d,
                          direction=direction,
                          show_eye_bolt=show_eye_bolt,
                          eye_bolt_h=eye_bolt_h,
                          eye_bolt_through_h=with_default(eye_bolt_through_h,
                                                          thickness),
                          show_eye_bolt_nut=show_eye_bolt_nut,
                          eye_bolt_head_type=eye_bolt_head_type);
            }
          }
        }
      }
    }
  }
}

module arm_mount(thickness=suspension_tie_rod_mount_thickness,
                 border_w=suspension_tie_rod_border_w,
                 eye_od=suspension_tie_rod_eye_od,
                 eye_h=suspension_tie_rod_eye_h,
                 shank_od=suspension_tie_rod_shank_od,
                 shank_bolt_d=suspension_tie_rod_shank_bolt_d,
                 neck_len=suspension_tie_rod_neck_len,
                 shank_len=suspension_tie_rod_shank_len,
                 bushing_od=suspension_tie_rod_bushing_od,
                 bushing_d=suspension_tie_rod_bushing_d,
                 bushing_h=suspension_tie_rod_bushing_h,
                 bushing_flat_d=suspension_tie_rod_bushing_flat_d,
                 transition_h=0,
                 color=matte_black,
                 show_tie_rod=false,
                 direction="bottom",
                 parent_d=knuckle_base_d,
                 parent_h=knuckle_base_h,
                 show_eye_bolt=false,
                 eye_bolt_h,
                 eye_bolt_through_h=2,
                 show_eye_bolt_nut=true,
                 eye_bolt_head_type="hex",
                 tolerance=0.4,
                 fn=200) {
  eye_h = with_default(eye_h, shank_od);
  shank_od = with_default(shank_od, eye_h);
  bushing_od = with_default(bushing_od, eye_od * 0.6);
  bushing_h = with_default(bushing_h, bushing_od * 0.98);
  bushing_d = with_default(bushing_d, bushing_od * 0.51);

  bushing_real_h = holed_sphere_height(d=bushing_d, od=bushing_od);
  tie_rod_h = max(shank_od, bushing_real_h, eye_h);
  full_h = thickness + tie_rod_h;

  housing_d = eye_od + border_w * 2;

  // virtual diameter where two arm mounts can be fitted on each side
  parent_outer_d = parent_d + full_h * 2;

  union() {
    maybe_color(color) {
      difference() {
        hull() {
          cylinder(d=parent_d, h=parent_h, $fn=fn);
          translate([0, 0, parent_h]) {
            intersection() {
              cylinder(d=parent_outer_d, h=max(transition_h, 0.01) , $fn=fn);
              translate([0, parent_outer_d / 2 - full_h / 2, 0]) {
                cube_3d([housing_d, full_h, max(transition_h, 0.01)]);
              }
            }
          }
        }
        translate([0, 0, -0.01]) {
          cylinder(d=parent_d + 0.001,
                   h=parent_h + transition_h + 1,
                   $fn=fn);
        }
        translate([0, 0, parent_h]) {
          cube_3d([parent_outer_d, parent_d, transition_h + 1]);
        }
      }
    }
  }
  translate([0, parent_d / 2, parent_h + transition_h]) {

    ball_joint_mount(thickness=thickness,
                     border_w=border_w,
                     eye_od=eye_od,
                     eye_h=eye_h,
                     shank_od=shank_od,
                     shank_bolt_d=shank_bolt_d,
                     neck_len=neck_len,
                     shank_len=shank_len,
                     bushing_od=bushing_od,
                     bushing_d=bushing_d,
                     bushing_h=bushing_h,
                     bushing_flat_d=bushing_flat_d,
                     color=color,
                     show_tie_rod=show_tie_rod,
                     parent_d=parent_d + full_h * 2,
                     direction=direction,
                     center_y=false,
                     tolerance=tolerance,
                     show_eye_bolt=show_eye_bolt,
                     eye_bolt_h=eye_bolt_h,
                     eye_bolt_through_h=eye_bolt_through_h,
                     show_eye_bolt_nut=show_eye_bolt_nut,
                     eye_bolt_head_type=eye_bolt_head_type,
                     fn=fn);
  }
}
