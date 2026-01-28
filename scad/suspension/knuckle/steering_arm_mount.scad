/**
 * Module: Steering arm mount
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../colors.scad>
include <../../parameters.scad>

use <../../lib/debug.scad>
use <../../lib/functions.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../lib/trapezoids.scad>
use <../../placeholders/tie_rod_end.scad>
use <arm_mount.scad>

module steering_arm_mount_base(angle=steering_angle_deg,
                               l=knuckle_steering_arm_mount_len,
                               thickness=knuckle_steering_arm_mount_thickness,
                               round_r=knuckle_steering_arm_mount_round_r,
                               eye_od=knuckle_steering_arm_mount_tie_rod_eye_od,
                               eye_h=knuckle_steering_arm_mount_tie_rod_eye_h,
                               shank_od=knuckle_steering_arm_mount_tie_rod_shank_od,
                               shank_bolt_d=knuckle_steering_arm_mount_tie_rod_shank_bolt_d,
                               neck_len=knuckle_steering_arm_mount_tie_rod_neck_len,
                               shank_len=knuckle_steering_arm_mount_tie_rod_shank_len,
                               bushing_od=knuckle_steering_arm_mount_tie_rod_bushing_od,
                               bushing_d=knuckle_steering_arm_mount_tie_rod_bushing_d,
                               bushing_h=knuckle_steering_arm_mount_tie_rod_bushing_h,
                               bushing_flat_d=knuckle_steering_arm_mount_tie_rod_bushing_flat_d,
                               color=cobalt_blue_metallic,
                               parent_h=knuckle_base_h,
                               debug=false,
                               show_tie_rod=false,
                               show_eye_bolt=true,
                               eye_bolt_h=12,
                               eye_bolt_through_h,
                               show_eye_bolt_nut=true,
                               eye_bolt_head_type="hex",
                               tie_rod_reverse=false) {
  full_l = l + eye_od;

  eye_h = with_default(eye_h, shank_od);
  shank_od = with_default(shank_od, eye_h);
  bushing_od = with_default(bushing_od, eye_od * 0.6);
  bushing_h = with_default(bushing_h, bushing_od * 0.98);
  bushing_d = with_default(bushing_d, bushing_od * 0.51);

  params = calc_rotated_bbox(full_l, parent_h, -angle);

  sx = params[2];
  sy = params[3];

  pts_main = [[sx + eye_od / 2 - bushing_d / 2, sy],
              [full_l, 0],
              [full_l, parent_h],
              [full_l * 0.87, sy + eye_od / 2],
              [full_l * 0.8, sy + eye_od * 0.3],
              [full_l * 0.67, sy + eye_od * 0.3],
              [full_l * 0.58, sy + eye_od / 2],
              [eye_od, sy + eye_od / 2],
              [eye_od / 2 + bushing_d, sy + eye_od],
              [sx + bushing_d / 2, sy + eye_od],
              [sx, sy + eye_od / 2 - bushing_d / 2]];

  module _base() {
    difference() {
      union() {
        if (debug) {
          debug_polygon(points=pts_main);
          difference() {
            polygon(points=pts_main);
            translate([full_l - round_r * 2 - full_l, 0, 0]) {
              square([full_l, params[0]]);
            }
          }
        } else {
          offset_vertices_2d(r=round_r) {
            polygon(points=pts_main);
          }
          difference() {
            polygon(points=pts_main);
            translate([full_l - round_r * 2 - full_l, 0, 0]) {
              square([full_l, params[0]]);
            }
          }
        }
      }
      translate([0, sy, 0]) {
        translate([eye_od / 2, eye_od / 2, 0]) {
          circle(r=bushing_d / 2, $fn=360);
        }
      }
    }
  }

  if (debug) {
    _base();
  } else {
    maybe_color(color) {
      linear_extrude(height=thickness, center=true) {
        _base();
      }
    }
  }

  if (show_tie_rod) {
    translate([eye_od / 2,
               sy + eye_od / 2,
               tie_rod_reverse ? -thickness - eye_h : 0]) {
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
                  direction="top",
                  show_eye_bolt=show_eye_bolt,
                  eye_bolt_h=eye_bolt_h,
                  eye_bolt_through_h=with_default(eye_bolt_through_h, thickness),
                  show_eye_bolt_nut=show_eye_bolt_nut,
                  eye_bolt_head_type=eye_bolt_head_type);
    }
  }
}

module knuckle_steering_arm_mount(is_left=true,
                                  angle=steering_angle_deg,
                                  l=knuckle_steering_arm_mount_len,
                                  eye_od=knuckle_steering_arm_mount_tie_rod_eye_od,
                                  bushing_d=knuckle_steering_arm_mount_tie_rod_bushing_d,
                                  thickness=knuckle_steering_arm_mount_thickness,
                                  round_r=knuckle_steering_arm_mount_round_r,
                                  eye_h=knuckle_steering_arm_mount_tie_rod_eye_h,
                                  shank_od=knuckle_steering_arm_mount_tie_rod_shank_od,
                                  shank_bolt_d=knuckle_steering_arm_mount_tie_rod_shank_bolt_d,
                                  neck_len=knuckle_steering_arm_mount_tie_rod_neck_len,
                                  shank_len=knuckle_steering_arm_mount_tie_rod_shank_len,
                                  bushing_od=knuckle_steering_arm_mount_tie_rod_bushing_od,
                                  bushing_h=knuckle_steering_arm_mount_tie_rod_bushing_h,
                                  bushing_flat_d=knuckle_steering_arm_mount_tie_rod_bushing_flat_d,
                                  color=cobalt_blue_metallic,
                                  debug=false,
                                  show_tie_rod=false,
                                  show_eye_bolt=true,
                                  eye_bolt_h=12,
                                  eye_bolt_through_h=2,
                                  show_eye_bolt_nut=true,
                                  eye_bolt_head_type="hex",
                                  parent_d=knuckle_base_d,
                                  parent_h=knuckle_base_h,
                                  tie_rod_reverse=false) {
  full_l = l + eye_od;

  notch_d = notch_depth(parent_d, thickness);

  module _arm() {
    steering_arm_mount_base(angle=angle,
                            l=l,
                            eye_od=eye_od,
                            thickness=thickness,
                            round_r=round_r,
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
                            parent_h=parent_h,
                            debug=debug,
                            tie_rod_reverse=tie_rod_reverse,
                            show_tie_rod=show_tie_rod,
                            show_eye_bolt=show_eye_bolt,
                            eye_bolt_h=eye_bolt_h,
                            eye_bolt_through_h=eye_bolt_through_h,
                            show_eye_bolt_nut=show_eye_bolt_nut,
                            eye_bolt_head_type=eye_bolt_head_type);
  }

  module _knuckle_arm_mount() {
    translate([-parent_d / 2 + notch_d / 2, 0, parent_h / 2]) {
      maybe_color(color) {
        cube([notch_d, thickness, parent_h], center=true);
      }
    }
    translate([-full_l - parent_d / 2, 0, 0]) {
      rotate([90, 0, 0]) {
        _arm();
      }
    }
  }

  if (is_left) {
    _knuckle_arm_mount();
  } else {
    mirror([1, 0, 0]) {
      _knuckle_arm_mount();
    }
  }
}

knuckle_steering_arm_mount(debug=false,
                           round_r=1.5,
                           is_left=true,
                           angle=steering_angle_deg,
                           tie_rod_reverse=false,
                           show_tie_rod=true);
