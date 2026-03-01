include <../colors.scad>
include <../parameters.scad>
include <../steering_params.scad>

use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/trapezoids.scad>
use <../placeholders/servo_arm.scad>

module bellcrank_arm(fn=30, h=bellcrank_arm_h, color=cobalt_blue_metallic) {

  color(color, alpha=1) {

    ring(outer_d=bellcrank_arm_dia, d=bellcrank_arm_dia -2, h=h, fn=fn);

    translate([0, 0, bellcrank_arm_z]) {

      rotate([0, 0, 90]) {
        servo_arm(arm_d=bellcrank_arm_dia,
                  arm_len=bellcrank_arm_len,
                  arm_base_h=bellcrank_arm_thickness,
                  arm_bolt_boss_h=pitman_arm_boss_h,
                  arm_bolt_boss_w=pitman_arm_boss_w,
                  bolt_n=2,
                  arm_bolt_boss_spacing=bellcrank_arm_bolt_gap,
                  arm_bolt_boss_padding=bellcrank_arm_bolt_padding,
                  arm_thickness=bellcrank_arm_thickness,
                  boss_inner_padding=pitman_arm_boss_inner_padding,
                  arm_w=bellcrank_arm_w,
                  bolt_d=bellcrank_arm_bolt_d,
                  arm_center_bolt_d=0);
      }
    }
  }
}

module pitman_arm() {
  bellcrank_arm(h=pitman_arm_h);
  translate([0, 0, bellcrank_pitman_arm_z]) {
    rotate([0, 0, 180]) {
      servo_arm(arm_d=bellcrank_arm_dia,
                arm_len=bellcrank_arm_len,
                arm_base_h=bellcrank_arm_thickness,
                arm_bolt_boss_h=pitman_arm_boss_h,
                arm_bolt_boss_w=pitman_arm_boss_w,
                bolt_n=pitman_arm_bolt_n,
                arm_bolt_boss_spacing=pitman_arm_bolt_boss_spacing,
                arm_bolt_boss_padding=pitman_arm_bolt_boss_padding,
                arm_thickness=bellcrank_arm_thickness,
                boss_inner_padding=pitman_arm_boss_inner_padding,
                arm_w=bellcrank_arm_w,
                bolt_d=pitman_arm_bolt_d,
                arm_center_bolt_d=0);
    }
  }
}

pitman_arm();