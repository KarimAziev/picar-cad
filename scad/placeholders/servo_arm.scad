include <../colors.scad>
include <../steering_params.scad>

use <../lib/placement.scad>
use <../lib/shapes2d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>

module servo_arm(arm_d,
                 arm_len,
                 arm_w,
                 arm_base_h,
                 arm_bolt_boss_h,
                 arm_bolt_boss_w,
                 bolt_d,
                 boss_inner_padding=0,
                 arm_bolt_boss_padding,
                 arm_thickness,
                 arm_center_bolt_d=steering_servo_arm_center_bolt_d,
                 arm_center_bolt_bore_d=steering_servo_arm_center_bolt_bore_d,
                 arm_center_bolt_bore_h=steering_servo_arm_center_bolt_bore_h,
                 bolt_n=2,
                 arm_bolt_boss_spacing=1.45,
                 color=cobalt_blue_metallic,
                 reverse=false,
                 fn=30) {
  rows_params = calc_cols_params(cols=3, w=bolt_d, gap=arm_bolt_boss_spacing);
  total_y = rows_params[1] + boss_inner_padding * 2;
  total_len = arm_d + arm_len;
  extra_cyl_h = arm_base_h - arm_thickness;
  boss_h = arm_bolt_boss_h - arm_thickness;

  full_h = max(arm_base_h, arm_bolt_boss_h);
  y_angle = reverse ? 180 : 0;

  maybe_translate([0, 0, reverse ? full_h : 0]) {
    maybe_rotate([0, y_angle, 0]) {
      difference() {
        color(color, alpha=1) {
          linear_extrude(height=arm_thickness, center=false) {
            translate([-arm_w / 2, -arm_d / 2, 0]) {
              rounded_rect([arm_w, total_len], r_factor=0.5, center=false);
            }
            circle(d=arm_d, $fn=fn);
          }

          translate([0, 0, arm_thickness]) {
            cylinder(d=arm_d, h=extra_cyl_h, $fn=fn);
            linear_extrude(height=boss_h, center=false) {
              translate([-arm_bolt_boss_w / 2,
                         arm_d / 2 + arm_len - total_y - arm_bolt_boss_padding,
                         0]) {
                rounded_rect([arm_bolt_boss_w, total_y],
                             center=false,
                             r_factor=0.5,
                             fn=30);
              }
            }
          }
        }
        counterbore(h=arm_base_h,
                    d=arm_center_bolt_d,
                    bore_d=arm_center_bolt_bore_d,
                    bore_h=arm_center_bolt_bore_h,
                    sink=false,
                    fn=50,
                    reverse=false);
        translate([0,
                   arm_d / 2 + arm_len - total_y - bolt_d / 2
                   - arm_bolt_boss_padding - boss_inner_padding,
                   0]) {
          translate([0, total_y, 0]) {

            rotate([0, 0, 180]) {
              rows_children(rows=bolt_n,
                            w=bolt_d,
                            gap=arm_bolt_boss_spacing,
                            center=false) {
                translate([0, -bolt_d / 2, 0]) {

                  counterbore(d=bolt_d,
                              h=arm_bolt_boss_h,
                              sink=false,
                              fn=50,
                              reverse=false);
                }
              }
            }
          }
        }
      }
    }
  }
}

servo_arm(arm_d=steering_servo_arm_d,
          arm_len=steering_servo_arm_len,
          arm_base_h=steering_servo_arm_base_h,
          arm_bolt_boss_h=steering_servo_arm_bolt_boss_h,
          arm_bolt_boss_w=steering_servo_arm_bolt_boss_w,
          arm_bolt_boss_spacing=steering_servo_arm_bolt_boss_spacing,
          arm_bolt_boss_padding=steering_servo_arm_bolt_boss_padding,
          arm_thickness=steering_servo_arm_thickness,
          arm_w=steering_servo_arm_w,
          boss_inner_padding=steering_servo_arm_bolt_boss_inner_padding,
          bolt_d=steering_servo_arm_bolt_d,
          arm_center_bolt_d=steering_servo_arm_center_bolt_d,
          arm_center_bolt_bore_d=steering_servo_arm_center_bolt_bore_d,
          arm_center_bolt_bore_h=steering_servo_arm_center_bolt_bore_h,
          bolt_n=3);
