/**
 * Module: A dummy mockup of the servo.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
use <../util.scad>

servo_size          = [23, 11.6, 20];
servo_offset        = steering_servo_screws_offset;
servo_hat_w         = 33;
servo_hat_h         = servo_size[1];
servo_hat_thickness = 1.6;
screws_hat_z_offset = 4;
servo_gear_h        = 2;
servo_gear_d        = 3;
servo_gearbox_h     = 6;
servo_gearbox_rad   = servo_size[1] * 0.5;

module servo_screws_hat(size,
                        x_offset,
                        d=steering_servo_screw_dia,
                        thickness=servo_hat_thickness) {
  w = size[0];
  h = size[1];
  linear_extrude(height = thickness, center = true) {
    difference() {
      rounded_rect(size = [w, h], r = h * 0.1, center = true);
      two_x_screws_2d(x_offset, d=d);
    }
  }
}

module servo(size=servo_size,
             screws_dia=steering_servo_screw_dia,
             servo_offset=steering_servo_screws_offset + (abs(steering_servo_slot_width - servo_size[0]) / 2),
             gearbox_height=servo_gearbox_h,
             gear_height=servo_gear_h,
             servo_hat_w=servo_hat_w,
             servo_hat_h=servo_hat_h,
             servo_hat_thickness=servo_hat_thickness,
             screws_hat_z_offset=screws_hat_z_offset,
             gear_dia=servo_gear_d,
             gearbox_rad=servo_gearbox_rad,
             servo_color="#343434",
             servo_gear_color="#3E3E3E",
             servo_text="EMAX ES08MA II",
             text_depth=0.5,
             text_size=1,
             tolerance=0.3) {
  union() {
    color(servo_color) {
      difference() {
        cube(size, center=true);
        translate([size[1], 0, size[2] - 0.2]) {
          rotate([0, 10, 0]) {
            cube([size[0] + 1, size[1] + 1, size[2]], center=true);
          }
        }
      }
    }
    if (servo_text != undef) {
      translate([-size[1] + len(servo_text) * 0.5, size[1] * 0.5, 0]) {
        rotate([180 + 90, 0, 0]) {
          linear_extrude(height=text_depth) {
            text(servo_text, size=text_size,
                 halign="center",
                 valign="center");
          }
        }
      }
    }

    translate([size[1] - gearbox_rad, 0, -size[2] * 0.5]) {
      union() {
        color(servo_gear_color) {
          hull() {
            cylinder(h = gearbox_height, r = gearbox_rad, center=true);
            translate([-gearbox_rad, 0, 0]) {
              cylinder(h = gearbox_height,
                       r = gearbox_rad * 0.4,
                       center=true,
                       $fn=30);
            }
          }
        }

        translate([0, 0, -gearbox_height * 0.4 - gear_height * 0.5]) {
          rotate([180, 0, 0]) {
            union() {
              color("#b8860b") {
                cylinder(h = gear_height,
                         r = gear_dia * 0.3,
                         center = true,
                         $fn=30);
              }
              lower_h = (gear_height * 0.9);

              translate([0, 0, lower_h / 2]) {
                difference() {
                  color("#b8860b") {
                    cylinder(h = lower_h,
                             r = gear_dia * 0.5,
                             center = true,
                             $fn=20);
                  }

                  color("black") {
                    cylinder(h = gear_height,
                             r = gear_dia * 0.2,
                             center = true,
                             $fn=20);
                  }
                }
              }
            }
          }
        }
      }
    }

    color(servo_color) {
      translate([0, 0, -size[2] * 0.5 + screws_hat_z_offset]) {
        offst_x = screw_x_offst(size[0], screws_dia, servo_offset);

        servo_screws_hat(size=[servo_hat_w, servo_hat_h],
                         x_offset=offst_x,
                         d=screws_dia + tolerance,
                         thickness=servo_hat_thickness);
      }
    }
  }
}

module servo_slot_2d(size=[steering_servo_slot_width,
                           steering_servo_slot_height],
                     screws_dia=steering_servo_screw_dia,
                     screws_offset=steering_servo_screws_offset,
                     center=true) {

  square([size[0], size[1]], center=true);

  offst_x = screw_x_offst(size[0], screws_dia, screws_offset);

  for (x = [-offst_x, offst_x]) {
    translate([x, 0, 0]) {
      circle(r=screws_dia * 0.5, $fn=360);
    }
  }
}

module servo_slot_3d(size=[steering_servo_slot_width,
                           steering_servo_slot_height],
                     screws_dia=steering_servo_screw_dia,
                     screws_offset=steering_servo_screws_offset,
                     thickness=3,
                     center=true) {

  linear_extrude(height=thickness, center=center) {
    servo_slot_2d(size=size, screws_dia=screws_dia, screws_offset=screws_offset);
  }
}

module servo_slot_wall(size=[steering_servo_slot_width,
                             steering_servo_slot_height],
                       screws_dia=steering_servo_screw_dia,
                       screws_offset=steering_servo_screws_offset,
                       thickness=2,
                       center=true) {
  offst_x = screw_x_offst(size[0], screws_dia, screws_offset);
  w = 4 + screws_dia * 2 + size[0];

  linear_extrude(height=thickness, center=center) {
    difference() {
      square(size = [w, size[1] + 4], center=center);
      servo_slot_2d(size=size, screws_dia=screws_dia, screws_offset=screws_offset, center=center);
    }
  }
}

module servo_align(thickness=undef, hat_z_offset=screws_hat_z_offset, hat_thickness=servo_hat_thickness, servo_size=servo_size) {
  for (i = [0 : $children - 1])
    translate([0, 0, servo_size[2] / 2 - hat_z_offset + servo_hat_thickness]) {
      children(i);
    }
}

// servo_slot_wall();
// servo_align(thickness=2, hat_z_offset=screws_hat_z_offset, hat_thickness=servo_hat_thickness) {
//   servo();
// }
// servo();
