/**
 * Module: A dummy mockup of the servo.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
use <../util.scad>

servo_size          = [23, 11, 20];
servo_offset        = steering_servo_screws_offset;
servo_hat_w         = 33;
servo_hat_h         = servo_size[1];
servo_hat_thickness = 1.6;
screws_hat_z_offset = 4;

module servo_screws_hat(size,
                        x_offset,
                        d=steering_servo_screw_dia,
                        thickness=servo_hat_thickness) {
  w= size[0];
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
             servo_offset=servo_offset,
             gearbox_height=6,
             gear_height=3,
             servo_hat_w=servo_hat_w,
             servo_hat_h=servo_hat_h,
             servo_hat_thickness=servo_hat_thickness,
             screws_hat_z_offset=screws_hat_z_offset,
             gear_dia=3,
             servo_color="#343434",
             servo_text="EMAX ES08MA II",
             text_depth=0.5,
             text_size=1) {
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

    gearbox_rad = size[1] * 0.5;
    translate([size[1] - gearbox_rad, 0, -size[2] * 0.5]) {
      union() {
        color(servo_color) {
          hull() {
            cylinder(h = gearbox_height, r = gearbox_rad, center=true);
            translate([-gearbox_rad, 0, 0]) {
              cylinder(h = gearbox_height,
                       r = gearbox_rad * 0.4,
                       center=true,
                       $fn=50);
            }
          }
        }

        translate([0, 0, -gearbox_height * 0.5 - gear_height * 0.5]) {
          color("gold") {
            union() {
              cylinder(h = gear_height,
                       r = gear_dia * 0.3,
                       center = true,
                       $fn=50);
              lower_h = (gear_height * 0.9);
              translate([0, 0, lower_h / 2]) {
                cylinder(h = lower_h,
                         r = gear_dia * 0.5,
                         center = true,
                         $fn=50);
              }
            }
          }
        }
      }
    }

    color(servo_color) {
      translate([0, 0, -size[2] * 0.5 + screws_hat_z_offset]) {
        x_offset = servo_size[0] * 0.5 + screws_dia;
        servo_screws_hat(size=[servo_hat_w, servo_hat_h],
                         x_offset=x_offset);
      }
    }
  }
}

module servo_slot_2d(size=[steering_servo_slot_width,
                           steering_servo_slot_height],
                     screws_dia=steering_servo_screw_dia,
                     screws_offset=steering_servo_screws_offset) {
  square([size[0], size[1]], center=true);
  offst_x = (size[0] / 2 + screws_dia * 0.5) + screws_offset;

  for (x = [-offst_x, offst_x]) {
    translate([x, 0, 0]) {
      circle(r=screws_dia * 0.5, $fn=360);
    }
  }
}

servo();
