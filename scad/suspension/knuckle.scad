/**
 * Module: Double-wishbone suspension knuckle with ball joints.
 *
 */
include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/l_bracket.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../placeholders/bolt.scad>
use <../wheels/front_wheel.scad>
use <../wheels/wheel_hub_new.scad>
use <knuckle_arm_mount.scad>

assembled_hub_h                = wheel_hub_full_h() * 2;

washer_thickness               = 1.6;
washer_outer_d                 = 11;
washer_inner_d                 = 6;
spacer_h                       = wheel_hub_inner_rim_h;

knuckle_h                      = wheel_shoulder_bolt_unthreaded_l - (assembled_hub_h * 2);
knuckle_h2                     = 8;

knuckle_d1                     = wheel_bearing_shoulder_d;

knuckle_d2                     = knuckle_d1 + 2;

knuckle_upper_arm_thickness    = 3;
knuckle_upper_arm_d            = m3_hole_dia;
knuckle_upper_arm_lengths      = [3, 5, 8, 10];
knuckle_upper_arm_angle1       = 30;
knuckle_upper_arm_angle2       = 50;

knuckle_lower_arm_thickness    = 3;
knuckle_lower_arm_d            = m3_hole_dia;
knuckle_lower_arm_lengths      = [1, 5, 8, 10];
knuckle_lower_arm_angle1       = 30;
knuckle_lower_arm_angle2       = 50;

knuckle_steering_arm_thickness = 3;
knuckle_steering_arm_d         = m3_hole_dia;

knuckle_steering_arm_lengths   = [10, 8, 10, 15];
knuckle_steering_arm_angle1    = 30;
knuckle_steering_arm_angle2    = 50;

module knuckle_base(offset_r=1, w, upper_arm_l) {

  recess_outer_d = knuckle_d1 - 1;
  knuckle_base_h = knuckle_h - offset_r * 2;
  difference() {
    hull() {
      translate([0, 0, offset_r]) {
        offset_3d(r=offset_r) {
          union() {
            translate([0, 0, knuckle_h - knuckle_h2]) {
              cylinder(d=knuckle_d2 - offset_r * 2,
                       h=knuckle_h2 - offset_r * 2,
                       $fn=150);
            }
          }
        }
        translate([0,
                   knuckle_d1 / 2 + upper_arm_l / 2,
                   knuckle_h - knuckle_upper_arm_thickness]) {
          linear_extrude(height=knuckle_upper_arm_thickness, center=false) {
            rounded_rect([w, upper_arm_l],
                         r_factor=0.5,
                         side="top",
                         fn=40,
                         center=true);
          }
        }
      }
      translate([0, 0, offset_r]) {
        offset_3d(r=offset_r) {
          cylinder(d=knuckle_d1 - offset_r * 2,
                   h=knuckle_base_h,
                   $fn=150);
        }
      }
    }

    translate([0, 0, -0.5]) {
      ring(d2=recess_outer_d - 2,
           d1=recess_outer_d - 1,
           h=1,
           outer_d1=recess_outer_d - 0.5,
           outer_d2=recess_outer_d,
           $fn=140);
      cylinder(d=wheel_bearing_bore_d, h=knuckle_h + 1, $fn=200);
    }
  }
}

module knuckle(offset_r=0, w, d=m3_hole_dia, color=cobalt_blue_metallic) {
  w = with_default(w, d * 2.5);
  color(color, alpha=1) {
    difference() {
      union() {
        knuckle_base(offset_r=offset_r,
                     upper_arm_l=knuckle_upper_arm_lengths[0],
                     w=w);
        translate([0, 0, -offset_r]) {

          translate([0, 0, knuckle_h - knuckle_upper_arm_thickness]) {
            knuckle_arm_mount(d=knuckle_upper_arm_d,
                              w=w,
                              offset_r=offset_r,
                              knuckle_d=knuckle_d2,
                              thickness=knuckle_upper_arm_thickness,
                              l1=knuckle_upper_arm_lengths[0],
                              l2=knuckle_upper_arm_lengths[1],
                              l3=knuckle_upper_arm_lengths[2],
                              l4=knuckle_upper_arm_lengths[3]);
          }
          translate([0, 0, knuckle_h - knuckle_lower_arm_thickness]) {
            rotate([0, 0, 180]) {
              knuckle_arm_mount(d=knuckle_lower_arm_d,
                                w=w,
                                offset_r=offset_r,
                                knuckle_d=knuckle_d2,
                                thickness=knuckle_lower_arm_thickness,
                                l1=knuckle_lower_arm_lengths[0],
                                l2=knuckle_lower_arm_lengths[1],
                                l3=knuckle_lower_arm_lengths[2],
                                l4=knuckle_lower_arm_lengths[3]);
            }
          }
          translate([0, 0, knuckle_h - knuckle_steering_arm_thickness]) {
            rotate([steering_angle_deg, 0, -90]) {

              translate([0, knuckle_tie_rod_shaft_arm_len + knuckle_d2 / 2, 0]) {

                linear_extrude(height=knuckle_steering_arm_thickness,
                               center=true) {
                  difference() {
                    rounded_rect([w, knuckle_tie_rod_shaft_arm_len + knuckle_d2],
                                 r_factor=0.5,
                                 side="top",
                                 center=true);
                    translate([0,
                               (knuckle_tie_rod_shaft_arm_len + knuckle_d2) / 2
                               - knuckle_steering_arm_d / 2 - 2,
                               0]) {
                      circle(d=knuckle_steering_arm_d, $fn=200);
                    }
                  }
                }
              }
            }
            // rotate([0, 0, -90]) {
            //   knuckle_arm_mount(d=knuckle_steering_arm_d,
            //                     w=w,
            //                     offset_r=offset_r,
            //                     knuckle_d=knuckle_d2,
            //                     angle1=steering_angle_deg,
            //                     angle2=steering_angle_deg,
            //                     thickness=knuckle_steering_arm_thickness,
            //                     l1=knuckle_steering_arm_lengths[0],
            //                     l2=knuckle_steering_arm_lengths[1],
            //                     l3=knuckle_steering_arm_lengths[2],
            //                     l4=knuckle_steering_arm_lengths[3]);
            // }
          }
        }
      }
      translate([0, 0, -0.5]) {
        cylinder(d=wheel_bearing_bore_d, h=knuckle_h + 10, $fn=200);
      }
    }
  }
}

// translate([20, 0, 0]) {
//   hull() {
//     cylinder(d=knuckle_d1, h=knuckle_h, $fn=150);
//     translate([0, 0, knuckle_h - knuckle_h2]) {
//       cylinder(d=knuckle_d2, h=knuckle_h2, $fn=150);
//     }
//   }
// }

module shoulder_bolt() {
  bolt(d=wheel_shoulder_bolt_d,
       thread_starts=1,
       h=wheel_shoulder_bolt_threaded_l + wheel_shoulder_bolt_unthreaded_l,
       thread_len=wheel_shoulder_bolt_threaded_l,
       unthreaded=wheel_shoulder_bolt_unthreaded_l,
       head_d=wheel_shoulder_bolt_head_d,
       head_type="hex",
       head_h=wheel_shoulder_bolt_head_h);
}

module knuckle_assembly(show_upper_hub=true,
                        show_lower_hub=true,
                        show_extra_upper_hub=true,
                        show_bearing=true,
                        show_wheel=true,
                        show_washer=true,
                        show_shoulder_bolt=true) {
  union() {
    if (show_wheel) {
      front_wheel(show_upper_hub=show_upper_hub,
                  show_extra_lower_hub=show_lower_hub,
                  show_extra_upper_hub=show_extra_upper_hub,
                  show_bearing=show_bearing);
    }

    if (show_washer) {
      translate([0, 0, 0]) {
        ring(h=washer_thickness,
             d=washer_inner_d,
             outer_d=washer_outer_d,
             fn=40,
             color=metallic_silver_8);
      }
    }
    if (show_shoulder_bolt) {
      translate([0,
                 0,
                 wheel_shoulder_bolt_threaded_l
                 + wheel_shoulder_bolt_unthreaded_l]) {

        rotate([180, 0, 0]) {
          shoulder_bolt();
        }
      }
    }

    translate([0, 0, ((assembled_hub_h - spacer_h) * 2) + washer_thickness]) {
      knuckle();
    }
  }
}

// rotate([90, 0, 0]) {
//   knuckle_assembly(show_shoulder_bolt=true, show_wheel=true);
// }
// knuckle_upper_arm_mount();

// knuckle_upper_arm_mount();
knuckle();