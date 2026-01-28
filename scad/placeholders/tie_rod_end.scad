/**
 * Module: Tie-rod / rod-end (ball-joint style)
 *
 * Renders a common RC-style rod end with a spherical "eye" and a shank
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
- * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <bolt.scad>

function holed_sphere_height(od, d) =
  (d >= od) ? 0 : sqrt(od * od - d * d);

module tie_rod_spherical_bushing(od,
                                 d,
                                 h,
                                 flat_d,
                                 $fn=60,
                                 color) {
  module base_sphere() {
    maybe_color(color) {
      difference() {
        sphere(r=od / 2, $fn=$fn);
        cylinder(d=d, h=od + 1, center=true, $fn=$fn);
      }
    }
  }
  if (is_undef(h) || od == h) {
    base_sphere();
  } else if (h <= od) {
    intersection() {
      base_sphere();
      cube([od, od, h], center=true);
    }
  } else {
    assert(!is_undef(flat_d),
           str("Flat diameter shouldn't be undef, when height > outer diameter. ",
               "Received height: ",
               h,
               ", outer diameter: ",
               od));
    union() {
      base_sphere();
      if (flat_d > 0 && flat_d > d) {
        translate([0, 0, -h / 2]) {
          ring(d=d, outer_d=flat_d, h=h, fn=$fn, color=metallic_silver_9);
        }
      }
    }
  }
}

module tie_rod_end(eye_od=11.2,
                   eye_h=5.10,
                   eye_flat_d,
                   bushing_od,
                   bushing_d,
                   bushing_h,
                   bushing_flat_d,
                   bushing_color=metallic_silver_9,
                   color=cobalt_blue_metallic,
                   shank_od,
                   direction="bottom",
                   shank_len,
                   shank_bolt_d,
                   neck_len,
                   neck_h,
                   fn=100,
                   show_eye_bolt=false,
                   eye_bolt_h,
                   eye_bolt_through_h=2,
                   show_eye_bolt_nut=true,
                   eye_bolt_head_type="hex",
                   center_z=false) {
  eye_h = with_default(eye_h, shank_od);
  shank_od = with_default(shank_od, eye_h);
  bushing_od = with_default(bushing_od, eye_od * 0.6);
  bushing_h = with_default(bushing_h, bushing_od * 0.98);
  bushing_d = with_default(bushing_d, bushing_od * 0.51);

  bushing_real_h = holed_sphere_height(d=bushing_d, od=bushing_od);
  neck_h = with_default(neck_h, eye_h);

  notch_w = calc_notch_width(max(eye_od, shank_od),
                             min(eye_od, shank_od));

  is_bottom = direction == "bottom";
  is_top = direction == "top";
  is_left = direction == "left";
  is_right = direction == "right";
  is_y_direction = is_bottom || is_top;
  is_x_direction = is_left || is_right;

  ratio = is_left || is_bottom ? -1 : 1;

  shank_rotation_y = is_x_direction ? ratio * 90 : 0;
  shank_rotation_x = is_y_direction ? ratio * 90 : 0;

  base_shank_translation = (eye_od / 2 + shank_len / 2 - notch_w / 2);

  shank_translation_y = is_y_direction ? ratio * base_shank_translation : 0;
  shank_translation_x = is_x_direction ? ratio * base_shank_translation : 0;
  max_h = max(shank_od, bushing_real_h, eye_h);

  maybe_translate([0, 0, center_z ? 0 : max_h / 2]) {
    union() {
      tie_rod_spherical_bushing(h=eye_h,
                                d=bushing_od,
                                od=eye_od,
                                color=color,
                                flat_d=eye_flat_d,
                                $fn=fn);
      tie_rod_spherical_bushing(h=bushing_h,
                                d=bushing_d,
                                od=bushing_od,
                                color=bushing_color,
                                flat_d=bushing_flat_d,
                                $fn=fn);

      if (show_eye_bolt && !is_undef(eye_bolt_h)) {
        nut_head_distance = max_h + eye_bolt_through_h;
        translate([0, 0, -eye_bolt_h + max_h / 2]) {
          bolt(d=bushing_d,
               h=eye_bolt_h,
               head_type=eye_bolt_head_type,
               show_nut=show_eye_bolt_nut,
               nut_head_distance=nut_head_distance);
        }
      }
      if (shank_len > 0) {
        render() {
          maybe_color(color) {
            difference() {
              translate([shank_translation_x, shank_translation_y, 0]) {
                rotate([shank_rotation_x, shank_rotation_y, 0]) {
                  translate([0, 0, -shank_len / 2 - notch_w / 2]) {
                    ring(outer_d=shank_od,
                         d=shank_bolt_d,
                         h=shank_len + notch_w,
                         fn=fn);
                  }
                }
              }
              if (!is_undef(neck_len)) {
                cube_x = max(eye_od, shank_od) + neck_len + notch_w;
                cutted_len = (shank_od - neck_h) / 2 + 0.01;
                mirror_copy([0, 0, 1]) {
                  translate([0, 0, shank_od / 2 - cutted_len / 2]) {
                    cube([cube_x, cube_x, cutted_len], center=true);
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

tie_rod_end(eye_od=suspension_tie_rod_eye_od,
            eye_h=suspension_tie_rod_eye_h,
            shank_od=suspension_tie_rod_shank_od,
            shank_bolt_d=suspension_tie_rod_shank_bolt_d,
            neck_len=suspension_tie_rod_neck_len,
            shank_len=suspension_tie_rod_shank_len,
            bushing_od=suspension_tie_rod_bushing_od,
            bushing_d=suspension_tie_rod_bushing_d,
            bushing_h=suspension_tie_rod_bushing_h,
            bushing_flat_d=suspension_tie_rod_bushing_flat_d,
            neck_h=suspension_tie_rod_neck_h,
            bushing_color=suspension_tie_rod_bushing_color,
            show_eye_bolt=false,
            eye_bolt_through_h=1,
            eye_bolt_h=20,
            center_z=true,
            color=suspension_tie_rod_color);
