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
use <bellcrank/ackermann_plate.scad>
use <bellcrank/bellcrank_drive.scad>
use <bellcrank/bellcrank_idler.scad>
use <bulkhead/front_bulkhead_chassis.scad>
use <bulkhead/front_bulkhead_housing.scad>
use <front_suspension_assembly.scad>
use <servo_mount.scad>

show_bellcrank_drive                        = true;
show_bellcrank_idler                        = true;
show_idler_insert_bush                      = true;
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
show_ackermann_plate                        = true;

module bellcrank_mount(h=upper_chassis_t,
                       top_w=chassis_center_transition_w,
                       bottom_w=chassis_bellcrank_mount_w,
                       length=chassis_bellcrank_mount_len,
                       bellcrank_y=chassis_bellcrank_position_y,
                       bolt_spacing=chassis_bellcrank_spacing,
                       d=upper_chassis_bellcrank_bolt_d,
                       bore_d=upper_chassis_bellcrank_bolt_bore_d,
                       bore_h=upper_chassis_bellcrank_bolt_bore_h,
                       arm_d=bellcrank_arm_od,
                       pitman_angle=bellcrank_arm_angle,
                       idle_angle,
                       show_bellcrank_drive=true,
                       show_bellcrank_idler=true,
                       show_idler_insert_bush=show_idler_insert_bush,
                       show_idler_upper_bearing=show_idler_upper_bearing,
                       show_idler_lower_bearing=show_idler_lower_bearing) {
  idle_angle = with_default(idle_angle, -abs(pitman_angle));

  effective_len = max(bellcrank_y, length) + max(bore_d, arm_d);

  difference() {
    linear_extrude(height=h, center=false) {
      translate([-bottom_w / 2, -effective_len, 0]) {
        hull() {
          trapezoid(b=bottom_w, h=effective_len, t=top_w, center=false);
          rounded_rect([bottom_w, arm_d],
                       r_factor=0.5,
                       center=false,
                       side="top");
        }
      }
    }
    translate([0, -bellcrank_y - bore_d / 2, 0]) {
      four_corner_counterbores(d=d,
                               h=h,
                               bore_d=bore_d,
                               bore_h=bore_h,
                               size=[bolt_spacing, 0],
                               reverse=true,
                               center=true);
    }
  }

  if (show_bellcrank_drive) {
    translate([-bottom_w / 2 + bellcrank_arm_od /2,
               -bellcrank_y - bore_d / 2,
               h]) {
      maybe_rotate([0, 0, pitman_angle]) {
        rotate([0, 0, -90]) {
          bellcrank_drive(show_insert_bush=show_idler_insert_bush,
                          show_upper_bearing=show_idler_upper_bearing,
                          show_lower_bearing=show_idler_lower_bearing);
        }
      }
    }
  }
  if (show_bellcrank_idler) {
    translate([bottom_w / 2 - bellcrank_arm_od /2,
               -bellcrank_y - bore_d / 2,
               h]) {
      maybe_rotate([0, 0, idle_angle]) {
        bellcrank_idler(z_angle=-90,
                        show_insert_bush=show_idler_insert_bush,
                        show_upper_bearing=show_idler_upper_bearing,
                        show_lower_bearing=show_idler_lower_bearing);
      }
    }
  }
}

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
                     show_idler_insert_bush=show_idler_insert_bush,
                     show_idler_upper_bearing=show_idler_upper_bearing,
                     show_idler_lower_bearing=show_idler_lower_bearing) {

  bellcrank_arm_len = bellcrank_arm_l - bellcrank_arm_od;

  dservo_bb = dservo_tie_rod_bbox();
  shaft_len = dservo_bb[1] - dservo_bb[4];

  extra_len = shaft_len + bellcrank_arm_od / 2
    + steering_servo_tie_rod_eye_od / 2
    + ((dsservo_hat_w - dsservo_size[0]) / 2);

  servo_mount_x = -bellcrank_arm_len - bellcrank_arm_od / 2
    + dsservo_size[2]
    - steering_servo_tie_rod_eye_od / 2
    - bellcrank_arm_len;

  servo_mount_y = -chassis_bellcrank_position_y
    - shaft_len
    + bellcrank_arm_od / 2
    + bellcrank_arm_w / 2
    + steering_servo_tie_rod_eye_od / 2;

  echo("servo_mount_y",
       servo_mount_y,
       "bellcrank_mount_len",
       bellcrank_mount_len);

  bellcrank_mount_len = max(chassis_bellcrank_position_y,
                            chassis_bellcrank_mount_len)
    + max(upper_chassis_bellcrank_bolt_bore_d,
          bellcrank_arm_od);

  module _servo_hole_probes() {
    let (n = ceil(((steering_servo_tie_rod_body_len
                    - bellcrank_arm_od
                    - steering_servo_tie_rod_shank_len)
                   / (steering_servo_mount_bolt_bore_d + 2)))) {

      translate([0, servo_mount_y, 0]) {
        for (i = [0 : n]) {
          let (step = i * (steering_servo_mount_bolt_bore_d + 2)) {
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
      bellcrank_mount(show_bellcrank_drive=show_bellcrank_drive,
                      show_bellcrank_idler=show_bellcrank_idler,
                      show_idler_insert_bush=show_idler_insert_bush,
                      show_idler_upper_bearing=show_idler_upper_bearing,
                      show_idler_lower_bearing=show_idler_lower_bearing);
      translate([0, -extra_len / 2 - bellcrank_mount_len, 0]) {
        linear_extrude(height=upper_chassis_t, center=false) {
          trapezoid_rounded_top(t=chassis_bellcrank_mount_w + dsservo_size[1],
                                b=chassis_bellcrank_mount_w + dsservo_size[1],
                                h=extra_len,
                                center=true,
                                r=2);
        }
      }
    }
    mirror_copy([1, 0, 0]) {
      translate([-(chassis_bellcrank_mount_w + dsservo_size[1]) / 2,
                 -bellcrank_mount_len - 10,
                 -0.5]) {
        rotate([0, 0, 60]) {
          cube(size=[20, 50, upper_chassis_t + 1],
               center=false);
        }
      }
    }

    _x_holes_probes(n=1, direction=-1);
    _x_holes_probes(n=2, direction=1);
    // _x_holes_probes(n=3, direction=1);
    // let (n = 3,
    //      shift = (steering_servo_mount_bolt_bore_d + 2)) {
    //   translate([-shift * n, 0, 0]) {
    //     translate([0, 0, 0]) {
    //       for (i = [0 : n - 1]) {
    //         let (step = i * shift) {
    //           translate([step, 0, 0]) {
    //             _servo_hole_probes();
    //           }
    //         }
    //       }
    //     }
    //   }
    // }

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

  if (show_ackermann_plate) {

    ackermann_y = -chassis_bellcrank_position_y
      - upper_chassis_bellcrank_bolt_bore_d / 2
      + bellcrank_arm_len
      + bellcrank_arm_od / 2;

    translate([0,
               ackermann_y
               - ackermann_plate_boss_od / 2
               - bellcrank_arm_bolt_edge_offset
               - bellcrank_arm_bolt_spacing
               + (ackermann_plate_boss_od - bellcrank_arm_bolt_d)
               - ackermann_plate_hole_d / 2

               ,
               upper_chassis_t + bellcrank_arm_z]) {
      ackermann_plate();
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
                  show_front_suspension_arm_pad = false);
  }
}

upper_chassis();