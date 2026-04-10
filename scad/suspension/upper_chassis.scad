include <../colors.scad>
include <../parameters.scad>
include <../steering_params.scad>

use <../lib/functions.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../lib/trapezoids.scad>
use <../placeholders/dservo.scad>
use <../placeholders/rpi_5.scad>
use <../power/power_case.scad>
use <bellcrank/bellcrank_drive.scad>
use <bellcrank/bellcrank_idler.scad>
use <bellcrank/center_link.scad>
use <bulkhead/front_bulkhead_chassis.scad>
use <bulkhead/front_bulkhead_housing.scad>
use <front_suspension_assembly.scad>
use <servo_mount.scad>

show_bellcrank_drive                        = true;
show_bellcrank_idler                        = true;
show_bellcrank_post                         = true;
show_bellcrank_idler_lever                  = true;

show_idler_upper_bearing                    = true;
show_idler_lower_bearing                    = true;
show_servo                                  = true;
show_steering_assembly                      = true;
show_front_lower_arm                        = true;
show_front_upper_arm                        = true;
show_knuckle_bushing                        = true;
show_knuckle_inner_bearing                  = true;
show_knuckle_outer_bearing                  = true;
show_knuckle_tie_rod                        = true;
show_front_bulkhead                         = true;
show_front_bulkhead_upper_suspension_holder = true;
show_front_shock_tower                      = true;
show_front_suspension_arm_pad               = true;
show_center_link                            = true;

module upper_chassis(show_bellcrank_drive=show_bellcrank_drive,
                     show_bellcrank_idler=show_bellcrank_idler,
                     show_servo=show_servo,
                     show_steering_assembly=show_steering_assembly,
                     show_front_lower_arm=show_front_lower_arm,
                     show_front_upper_arm=show_front_upper_arm,
                     show_knuckle_bushing=show_knuckle_bushing,
                     show_knuckle_inner_bearing=show_knuckle_inner_bearing,
                     show_knuckle_outer_bearing=show_knuckle_outer_bearing,
                     show_knuckle_tie_rod=show_knuckle_tie_rod,
                     show_front_bulkhead=show_front_bulkhead,
                     show_front_bulkhead_upper_suspension_holder=show_front_bulkhead_upper_suspension_holder,
                     show_front_shock_tower=show_front_shock_tower,
                     show_front_suspension_arm_pad=show_front_suspension_arm_pad,
                     show_center_link=show_center_link,
                     show_bellcrank_post=show_bellcrank_post,
                     show_idler_upper_bearing=show_idler_upper_bearing,
                     show_idler_lower_bearing=show_idler_lower_bearing) {
  idle_angle = -abs(bellcrank_arm_angle);
  bellcrank_arm_len = bellcrank_arm_l - bellcrank_arm_od;
  bellcrank_y = chassis_bellcrank_position_y;

  dservo_bb = dservo_tie_rod_bbox();
  shaft_len = dservo_bb[1] - dservo_bb[4];

  extra_len = shaft_len + bellcrank_arm_od / 2
    + steering_servo_tie_rod_eye_od / 2
    + ((dsservo_hat_w - dsservo_size[0]) / 2);

  servo_mount_x = -bellcrank_arm_len - bellcrank_arm_od / 2
    + dsservo_size[2]
    - steering_servo_tie_rod_eye_od / 2
    - bellcrank_arm_len;

  servo_mount_y = -bellcrank_y
    - shaft_len
    - bellcrank_arm_od / 2
    - bellcrank_arm_w / 2
    - steering_servo_tie_rod_eye_od / 2;

  bellcrank_mount_len = max(bellcrank_y,
                            chassis_bellcrank_mount_len)
    + max(upper_chassis_bellcrank_bolt_bore_d,
          bellcrank_arm_od);

  // let (v = bellcrank_mount_len) {
  //   translate([-(chassis_bellcrank_mount_w + dsservo_size[1]) / 2, -v, 0]) {
  //     #cube([chassis_bellcrank_mount_w + dsservo_size[1], v, v]);
  //   }
  // }

  module _servo_hole_probes() {

    let (n = ceil(abs(((steering_servo_tie_rod_body_len
                        - bellcrank_arm_od
                        - steering_servo_tie_rod_shank_len)
                       / (steering_servo_mount_bolt_bore_d + 2))))) {

      translate([0, servo_mount_y, 0]) {
        for (i = [0 : n]) {
          let (step = -i * (steering_servo_mount_bolt_bore_d + 2)) {

            translate([servo_mount_x,
                       step,
                       0]) {

              servo_mount(slot_mode=true);
            }
          }
        }
      }
    }
  }

  module _x_holes_probes(n=3, direction=1) {
    let (shift = (steering_servo_mount_bolt_bore_d + 1)) {
      translate([0, 0, 0]) {
        translate([0, 0, 0]) {
          for (i = [1 : n]) {
            let (step = direction * i * shift) {
              translate([step, 0, 0]) {
                _servo_hole_probes();
              }
            }
          }
        }
      }
    }
  }

  difference() {
    union() {
      front_bulkhead_chassis();
      linear_extrude(height=upper_chassis_t, center=false) {
        hull() {
          translate([-chassis_bellcrank_mount_w / 2, -bellcrank_mount_len, 0]) {
            union() {
              trapezoid(b=chassis_bellcrank_mount_w,
                        h=bellcrank_mount_len,
                        t=chassis_center_transition_w,
                        center=false);
            }
          }
          translate([0,
                     -bellcrank_y - upper_chassis_bellcrank_bolt_bore_d / 2,
                     0]) {
            four_corner_children(size=[chassis_bellcrank_spacing, 0],
                                 center=true) {
              circle(d=bellcrank_arm_od);
            }
          }
          translate([0, -extra_len / 2 - bellcrank_mount_len, 0]) {
            trapezoid_rounded_top(t=chassis_bellcrank_mount_w,
                                  b=chassis_bellcrank_mount_w + dsservo_size[1],
                                  h=extra_len,
                                  center=true,
                                  r=2);
          }
        }
      }
    }
    translate([0,
               -bellcrank_y - upper_chassis_bellcrank_bolt_bore_d / 2,
               0]) {
      four_corner_counterbores(d=upper_chassis_bellcrank_bolt_d,
                               h=upper_chassis_t,
                               bore_d=upper_chassis_bellcrank_bolt_bore_d,
                               bore_h=upper_chassis_bellcrank_bolt_bore_h,
                               size=[chassis_bellcrank_spacing, 0],
                               reverse=true,
                               center=true);
    }

    // _x_holes_probes(n=1, direction=-1);
    // _x_holes_probes(n=2, direction=1);
    _servo_hole_probes();
  }
  translate([0, 0, upper_chassis_t]) {
    if (show_steering_assembly) {
      front_suspension_assembly(show_front_lower_arm=show_front_lower_arm,
                                show_front_upper_arm=show_front_upper_arm,
                                show_knuckle_bushing=show_knuckle_bushing,
                                show_knuckle_inner_bearing=show_knuckle_inner_bearing,
                                show_knuckle_outer_bearing=show_knuckle_outer_bearing,
                                show_knuckle_tie_rod=show_knuckle_tie_rod,
                                show_front_bulkhead=show_front_bulkhead,
                                show_front_bulkhead_upper_suspension_holder=show_front_bulkhead_upper_suspension_holder,
                                show_front_shock_tower=show_front_shock_tower,
                                show_front_suspension_arm_pad=show_front_suspension_arm_pad);
    }
  }

  if (show_bellcrank_drive) {
    translate([-chassis_bellcrank_mount_w / 2 + bellcrank_arm_od /2,
               -bellcrank_y - upper_chassis_bellcrank_bolt_bore_d / 2,
               upper_chassis_t]) {
      maybe_rotate([0, 0, bellcrank_arm_angle]) {
        rotate([0, 0, -90]) {
          bellcrank_drive(show_insert_bush=show_bellcrank_post,
                          show_upper_bearing=show_idler_upper_bearing,
                          show_lower_bearing=show_idler_lower_bearing);
        }
      }
    }
  }
  if (show_bellcrank_idler) {
    translate([chassis_bellcrank_mount_w / 2 - bellcrank_arm_od /2,
               -bellcrank_y - upper_chassis_bellcrank_bolt_bore_d / 2,
               upper_chassis_t]) {
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
    ackermann_y = -bellcrank_y
      - upper_chassis_bellcrank_bolt_bore_d / 2
      + bellcrank_arm_len
      + bellcrank_arm_od / 2;

    translate([0,
               ackermann_y
               - steering_center_link_boss_od / 2
               - bellcrank_arm_bolt_edge_offset
               - bellcrank_arm_bolt_spacing
               + (steering_center_link_boss_od - bellcrank_arm_bolt_d)
               - steering_center_link_hole_d / 2

               ,
               upper_chassis_t + bellcrank_arm_z]) {
      center_link();
    }
  }
  if (show_servo) {
    translate([servo_mount_x,
               servo_mount_y,
               upper_chassis_t]) {

      servo_mount(show_servo=show_servo);
    }
  }
}

module upper_chassis_printable() {
  rotate([0, 180, 0]) {
    upper_chassis(show_bellcrank_drive = false,
                  show_bellcrank_idler = false,
                  show_servo = false,
                  show_steering_assembly = false,
                  show_front_lower_arm = false,
                  show_front_upper_arm = false,
                  show_knuckle_bushing = false,
                  show_knuckle_inner_bearing = false,
                  show_knuckle_outer_bearing = false,
                  show_knuckle_tie_rod = false,
                  show_front_bulkhead = false,
                  show_front_bulkhead_upper_suspension_holder = false,
                  show_front_shock_tower = false,
                  show_front_suspension_arm_pad = false,
                  show_center_link=false);
  }
}

upper_chassis();
// servo_mount(slot_mode=true);
// upper_chassis_printable();