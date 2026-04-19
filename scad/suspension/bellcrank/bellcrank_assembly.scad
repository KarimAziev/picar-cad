include <../../steering_params.scad>

use <../../lib/transforms.scad>
use <bellcrank_drive.scad>
use <bellcrank_idler.scad>
use <center_link.scad>

show_bellcrank_drive             = true;
show_bellcrank_drive_idler_lever = true;
show_bellcrank_drive_servo_lever = true;
show_bellcrank_drive_upper_cap   = true;

show_bellcrank_idler             = true;
show_bellcrank_post              = true;
show_bellcrank_idler_lever       = true;

show_idler_upper_bearing         = true;
show_idler_lower_bearing         = true;
show_center_link                 = true;

bellcrank_z_angle                = 0;

module bellcrank_assembly(show_bellcrank_drive=show_bellcrank_drive,
                          show_bellcrank_drive_idler_lever=show_bellcrank_drive_idler_lever,
                          show_bellcrank_drive_servo_lever=show_bellcrank_drive_servo_lever,
                          show_bellcrank_drive_upper_cap=show_bellcrank_drive_upper_cap,
                          show_bellcrank_idler=show_bellcrank_idler,
                          show_bellcrank_post=show_bellcrank_post,
                          show_bellcrank_idler_lever=show_bellcrank_idler_lever,
                          show_idler_upper_bearing=show_idler_upper_bearing,
                          show_idler_lower_bearing=show_idler_lower_bearing,
                          show_center_link=show_center_link) {
  idle_angle = -abs(bellcrank_arm_angle);
  if (show_bellcrank_drive) {
    translate([-chassis_bellcrank_spacing / 2,
               0,
               0]) {
      rotate([0, 0, -90 + bellcrank_arm_angle]) {
        bellcrank_drive(show_insert_post=show_bellcrank_post,
                        show_upper_bearing=show_idler_upper_bearing,
                        show_lower_bearing=show_idler_lower_bearing,
                        show_idler_lever=show_bellcrank_drive_idler_lever,
                        show_servo_lever=show_bellcrank_drive_servo_lever,
                        show_upper_cap=show_bellcrank_drive_upper_cap);
      }
    }
  }
  if (show_bellcrank_idler) {
    translate([chassis_bellcrank_spacing / 2,
               0,
               0]) {
      maybe_rotate([0, 0, idle_angle]) {
        bellcrank_idler(z_angle=-90,
                        show_bellcrank_post=show_bellcrank_post,
                        show_upper_bearing=show_idler_upper_bearing,
                        show_lower_bearing=show_idler_lower_bearing,
                        show_idler_lever=show_bellcrank_idler_lever);
      }
    }
  }

  if (show_center_link) {

    center_link_y = bellcrank_arm_l
      - bellcrank_arm_bolt_edge_offset
      - (steering_center_link_boss_od - steering_center_link_hole_d) / 2
      - bellcrank_arm_bolt_spacing;

    translate([0,
               center_link_y,
               bellcrank_arm_z - steering_center_link_thickness]) {
      center_link();
    }
  }
}

bellcrank_assembly();