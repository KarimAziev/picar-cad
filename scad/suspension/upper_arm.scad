include <../colors.scad>
include <../steering_params.scad>

use <../lib/debug.scad>
use <../lib/functions.scad>
use <../lib/shapes2d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>

module upper_arm(color=cobalt_blue_metallic) {
  cut_h = upper_arm_h - upper_arm_pin_mount_h * 2;
  cut_y_offset = upper_arm_h / 2 - cut_h / 2;
  full_h = upper_arm_h + upper_arm_joint_mount_top_offset;

  module upper_arm_hole() {

    polygon([[0, 0],
             [0, cut_h],
             [upper_arm_length
              - upper_arm_joint_mount_len
              - upper_arm_pin_mount_w
              - upper_arm_side_w,
              cut_h + upper_arm_joint_mount_top_offset],
             [upper_arm_length
              - upper_arm_joint_mount_len
              - upper_arm_pin_mount_w,
              cut_h],
             [upper_arm_length
              - upper_arm_joint_mount_len
              - upper_arm_pin_mount_w,
              cut_h]]);
  }

  module base_shape() {
    polygon([[0, 0],
             [0, upper_arm_h],
             [upper_arm_length - upper_arm_joint_mount_len,
              upper_arm_h + upper_arm_joint_mount_top_offset],
             [upper_arm_length, full_h],
             [upper_arm_length, full_h - upper_arm_joint_mount_h],
             [upper_arm_pin_mount_w, 0]]);
  }

  module _main() {
    difference() {
      offset_vertices_2d(r=upper_arm_corner_rad, $fn=24) {
        base_shape();
      }

      translate([upper_arm_pin_mount_w
                 + upper_arm_side_w,
                 cut_y_offset
                 + upper_arm_joint_mount_top_offset / 2,
                 0]) {
        offset_vertices_2d(r=upper_arm_hole_corner_r) {
          upper_arm_hole();
        }
      }

      translate([-1, cut_y_offset, 0]) {
        rounded_rect(size=[upper_arm_pin_mount_w + 1,
                           cut_h],
                     fn=$preview ? 20 : 40,
                     side="right",
                     center=false);
      }
    }
  }

  render() {
    difference() {
      maybe_color(color) {
        linear_extrude(height=upper_arm_thickness, center=false) {
          _main();
        }
      }
      translate([0, 0, upper_arm_thickness / 2]) {
        translate([upper_arm_pin_mount_w / 2, 0, 0]) {
          rotate([-90, 0, 0]) {
            cylinder(d=upper_arm_pin_d, h=upper_arm_h + 1, $fn=40);
          }
        }

        translate([upper_arm_length,
                   + upper_arm_joint_mount_top_offset
                   + upper_arm_h
                   - upper_arm_joint_mount_h / 2,
                   0]) {
          rotate([-90, 0, 90]) {
            counterbore(h=upper_arm_ball_stud_hole_depth,
                        d=heat_insert_nut_hole_d,
                        bore_d=heat_insert_nut_flange_d + 0.4,
                        bore_h= + 1.0,
                        sink=true,
                        fn=300,
                        reverse=true);
          }
        }
      }
    }
  }
}

upper_arm();
