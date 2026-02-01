/**
 * Module: Double-wishbone suspension knuckle
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../colors.scad>
include <../../parameters.scad>

use <../../lib/placement.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>
use <../../placeholders/bolt.scad>
use <../../wheels/front_wheel.scad>
use <../../wheels/wheel_hub_new.scad>
use <arm_mount.scad>
use <knuckle_lower.scad>
use <steering_arm_mount.scad>

color                  = cobalt_blue_metallic;
show_lower_tie_rod     = true;
show_upper_tie_rod     = true;
show_steering_tie_rod  = true;
show_shoulder_bolt     = false;
show_eye_bolt          = true;
show_steering_eye_bolt = true;
eye_bolt_h             = 14;

module knuckle_base(color=matte_black,
                    show_lower_tie_rod=false,
                    show_upper_tie_rod=false,
                    show_shoulder_bolt=false,
                    show_eye_bolt=true,
                    show_steering_eye_bolt=true,
                    show_steering_tie_rod=false,
                    eye_bolt_h=14) {

  maybe_color(color) {
    difference() {
      cylinder(h=knuckle_base_h, d=knuckle_base_d, $fn=200);
      translate([0, 0, -0.5]) {
        cylinder(d=knuckle_bearing_hole_d, h=knuckle_h + 1, $fn=300);
      }
    }
  }

  if (show_shoulder_bolt) {
    translate([0,
               0,
               -(wheel_shoulder_bolt_threaded_l + wheel_shoulder_bolt_unthreaded_l)
               + knuckle_base_h]) {

      bolt(d=wheel_shoulder_bolt_d,
           thread_starts=1,
           h=wheel_shoulder_bolt_threaded_l + wheel_shoulder_bolt_unthreaded_l,
           thread_len=wheel_shoulder_bolt_threaded_l,
           unthreaded=wheel_shoulder_bolt_unthreaded_l,
           unthreaded_d=wheel_bearing_bore_d,
           head_d=wheel_shoulder_bolt_head_d,
           head_type="hex",
           head_h=wheel_shoulder_bolt_head_h);
    }
  }

  knuckle_steering_arm_mount(show_eye_bolt=show_steering_eye_bolt,
                             show_tie_rod=show_steering_tie_rod,
                             color=color);

  arm_mount(parent_h=knuckle_base_h,
            show_tie_rod=show_lower_tie_rod,
            transition_h=wheel_shoulder_bolt_head_h / 2,
            show_eye_bolt=show_eye_bolt,
            eye_bolt_h=eye_bolt_h,
            reverse=true,
            color=color);

  rotate([0, 0, 180]) {
    arm_mount(parent_h=knuckle_base_h,
              show_tie_rod=show_upper_tie_rod,
              show_eye_bolt=show_eye_bolt,
              color=color,
              eye_bolt_h=eye_bolt_h,
              transition_h=wheel_shoulder_bolt_head_h / 2
              + knuckle_upper_arm_mount_extra_len);
  }
}

// module knuckle_lower(color) {

//   dimple_h = knuckle_narrow_h * 0.4;
//   dimple_h2 = knuckle_narrow_h * 0.13;
//   dimple_depth = 0.5;
//   dimple_z = knuckle_narrow_h * 0.5 - dimple_h / 2;

//   dimple_z2 = 0.5;

//   dimple_dias = diameters_at_z(d1=knuckle_narrow_d,
//                                d2=knuckle_base_d,
//                                h=knuckle_narrow_h,
//                                z=dimple_z,
//                                t=dimple_h);

//   dimple_dias2 = diameters_at_z(d1=knuckle_narrow_d,
//                                 d2=knuckle_base_d,
//                                 h=knuckle_narrow_h,
//                                 z=dimple_z2,
//                                 t=dimple_h);

//   dimple_l = dimple_dias[1] * 0.2;
//   angle = taper_angle_from_axis(d1=knuckle_narrow_d,
//                                 d2=knuckle_base_d,
//                                 h=knuckle_narrow_h);
//   margin = 1;
//   hole_circle_r = (diameter_at_z(d1=dimple_dias[0],
//                                  d2=dimple_dias[1],
//                                  h=knuckle_narrow_h,
//                                  z=dimple_z) / 2) - margin;

//   hole_d = 0.5;

//   ring_w = (knuckle_narrow_d - knuckle_bearing_hole_d) / 2;

//   echo("dimple_z2", dimple_z2);

//   difference() {
//     ring(outer_d1=knuckle_narrow_d,
//          color=color,
//          outer_d2=knuckle_base_d,
//          d=knuckle_bearing_hole_d,
//          h=knuckle_narrow_h,
//          fn=250);

//     translate([0, 0, -dimple_depth]) {
//       ring(outer_d=knuckle_bearing_hole_d + ring_w,
//            d=(knuckle_bearing_hole_d + ring_w) - 0.5,
//            h=dimple_depth * 2,
//            fn=250);
//     }

//     mirror_copy([0, 0, 0]) {
//       translate([0, 0, dimple_z2]) {

//         difference() {
//           difference() {
//             ring(outer_d1=dimple_dias2[0] + 1,
//                  outer_d2=dimple_dias2[1] + 1,
//                  d2=dimple_dias2[1] - dimple_depth,
//                  d1=dimple_dias2[0] - dimple_depth,
//                  h=dimple_h2,
//                  fn=200);
//             translate([0, 0, -0.5]) {
//               cube_3d([dimple_dias2[1] * 0.6, dimple_dias2[1], knuckle_narrow_h + 1]);
//             }
//             rotate([0, 0, 0]) {
//               translate([0, 0, -0.5]) {
//                 cube_3d([dimple_dias2[1] * 2, 2, knuckle_narrow_h + 1]);
//               }
//             }
//           }
//           // rotate([0, angle, 0]) {
//           //   translate([dimple_dias2[0] / 2 - 0.5, 0, -0.5]) {
//           //     cube_3d([1, 2, knuckle_narrow_h + 1]);
//           //   }
//           // }
//         }
//       }
//     }

//     mirror_copy([1, 0, 0]) {
//       translate([0, 0, dimple_z]) {
//         difference() {
//           ring(outer_d1=dimple_dias[0] + 1,
//                outer_d2=dimple_dias[1] + 1,
//                d2=dimple_dias[1] - dimple_depth,
//                d1=dimple_dias[0] - dimple_depth,
//                h=dimple_h,
//                fn=200);
//           translate([dimple_l, 0, -0.5]) {
//             cube_3d([dimple_dias[1], dimple_dias[1], knuckle_narrow_h + 1]);
//           }
//         }
//         translate([0, 0, dimple_h - margin]) {
//           translate([0, 0, 0]) {
//             for (a = [-40:5:40]) {
//               translate([0, 0, 0]) {
//                 rotate([0, 0, a])
//                   translate([hole_circle_r + margin, 0, 0]) {
//                   rotate([0, angle, 0]) {
//                     rotate([0, 90, 0]) {
//                       cylinder(d=hole_d,
//                                h=dimple_h,
//                                center=true,
//                                $fn=100);
//                     }
//                   }
//                 }
//               }
//             }
//           }

//           translate([0, 0, -margin / 2]) {
//             for (a = [-40:5:40]) {
//               rotate([0, 0, a])
//                 translate([hole_circle_r + margin, 0, 0]) {
//                 rotate([0, angle, 0]) {
//                   rotate([0, 90, 0]) {
//                     cylinder(d=hole_d,
//                              h=dimple_h,
//                              center=true,
//                              $fn=100);
//                   }
//                 }
//               }
//             }
//           }
//         }
//       }
//     }

//   }
// }

module knuckle(color=color,
               show_lower_tie_rod=show_lower_tie_rod,
               show_upper_tie_rod=show_upper_tie_rod,
               show_steering_tie_rod=show_steering_tie_rod,
               show_shoulder_bolt=show_shoulder_bolt,
               show_eye_bolt=show_eye_bolt,
               show_steering_eye_bolt=show_steering_eye_bolt,
               is_left=false,
               eye_bolt_h=14) {
  module _knuckle() {
    render() {
      union() {
        knuckle_lower(color=color);
        translate([0, 0, knuckle_narrow_h]) {
          knuckle_base(color=color,
                       show_lower_tie_rod=show_lower_tie_rod,
                       show_upper_tie_rod=show_upper_tie_rod,
                       show_shoulder_bolt=show_shoulder_bolt,
                       show_eye_bolt=show_eye_bolt,
                       show_steering_eye_bolt=show_steering_eye_bolt,
                       show_steering_tie_rod=show_steering_tie_rod,
                       eye_bolt_h=eye_bolt_h);
        }
      }
    }
  }

  if (is_left) {
    mirror([1, 0, 0]) {
      _knuckle();
    }
  } else {
    _knuckle();
  }
}

translate([0, 0, wheel_w]) {

  knuckle(is_left=true, show_shoulder_bolt=true);
}
front_wheel(show_bearing=true,
            show_upper_hub=true,
            show_extra_lower_hub=true,
            show_extra_upper_hub=true);

// $fn = 120;

// H  = 30;          // height
// D1 = 50;          // diameter at z=0
// D2 = 30;          // diameter at z=H

// hole_d = 0.5;
// n      = 200;      // number of holes
// z0     = 15;      // height where the holes go through (0..H)
// margin = 1.0;       // keep holes this far inside the surface at z0

// module holes_at_cylinder(d1, d2, h, z, margin) {
// }

// difference() {
//   cylinder(h=H, d1=D1, d2=D2);

//   // choose bolt-circle radius at height z0
//   hole_circle_r = (diameter_at_z(d1=D1, d2=D2, h=H, z=z0) / 2) - margin;

//   for (i = [0:n-1]) {

//     a = 360/n * i;

//     translate([0, 0, 0]) {
//       rotate([0, 0, a])
//         translate([hole_circle_r, 0, z0]) {
//         rotate([0, 90, 0]) {
//           #cylinder(d=hole_d, h=D2, center=true);
//         }
//       }
//     }
//   }
// }
