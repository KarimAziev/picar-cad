// This module defines a robot chassis designed for a four-wheeled vehicle.
// The front wheels are controlled by servo steering while the rear wheels are powered by two separate motors.

// Key design features include:
//   - A top plate with cutouts for a Raspberry Pi 5 and a UPS Module 3S
//     (refer to: https://www.waveshare.com/wiki/UPS_Module_3S),
//   - A bottom plate with openings for standard battery holders (accommodating two 18650 LiPo batteries),
//   - Back plate provisions with holes for mounting two switch buttons (tumblers).
//
// The overall design focuses on providing flexible mounting options for separate power suppliers, such as:
//   - A power supply for the servo HAT,
//   - A power supply for the motor driver HAT, and
//   - A power module for the Raspberry Pi 5 itself.

use <util.scad>;
use <wheels_plate_down.scad>;
use <back_mount.scad>;

body_width                 = 100;
body_height                = 235;
body_depth                 = 2;

wheel_height               = 20;

steering_wheel_screws_dia  = 3.5;
steering_servo_hole_width  = 24;
steering_servo_hole_height = 12;
steering_servo_screw_dia   = 2;

pan_servo_hole_dia         = 7;

back_wheel_height          = 10;
back_wheel_width           = 3;
back_wheel_depth           = 30;
back_wheel_hole_dia        = 15;
m2_hole_dia                = 2.4;
m25_hole_dia               = 2.8;
m3_hole_dia                = 3.2;

module back_wheel_wall() {
  translate([0, 0, back_wheel_depth * 0.5]) {
    difference() {
      cube(size = [back_wheel_width, back_wheel_height, back_wheel_depth], center = true);
      for (y = [-10, 10]) {
        translate([0, -(back_wheel_height / 2) + 5, y]) {
          rotate([90, 0, 90]) {
            cylinder(10, r=m3_hole_dia / 2, $fn=360, center=true);
          }
        }
      }
    }
  }
}

module front_wall() {
  rotate([90, 0, 0]) {
    difference() {
      size = body_width * 0.8;
      linear_extrude(1) {
        rounded_rect(size=[size, back_wheel_depth], r=5, center=true);
      }

      cube(size = [size * 0.7, back_wheel_depth * 0.5, back_wheel_depth], center = true);

      translate([0, back_wheel_depth * 0.5, 0]) {
        cube(size = [20, 10, 20], center = true);
      }

      for (x = [-size + 10, size - 10]) {
        translate([x / 2, 0, 0]) {
          cylinder(10, r=m3_hole_dia / 2, $fn=360, center=true);
        }
      }
    }
  }
}

module raspberry_pi5_screws() {
  four_corner_holes(size = [50, 60, 10], center = true, hole_dia = m25_hole_dia);
}

module ups_hat_screws() {
  four_corner_holes(size = [48, 86, 10], center = true, hole_dia = m3_hole_dia);
}

module battery_holders_holes() {
  four_corner_holes(size = [20, 70, 10], center = true, hole_dia = m2_hole_dia);
}

module chassis_plate() {
  wheels_offset_y = body_height * 0.3;
  difference() {
    union() {
      linear_extrude(body_depth, center = false) {
        difference() {
          union() {
            difference() {
              rounded_rect(size=[body_width, body_height], center=true);
              translate([body_width * 0.7, wheels_offset_y, 0]) {
                circle(r = 35);
              }
              translate([-body_width * 0.7, wheels_offset_y, 0]) {
                circle(r = 35);
              }

              for (x = [body_width, -body_width]) {
                translate([x * 0.5, body_height * 0.4, 0]) {
                  rounded_rect(size=[80, 5], center=true);
                }
              }
            }

            translate([0, wheels_offset_y, 0]) {
              wheels_plate_down_2d();
            }
          }

          translate([(steering_servo_hole_width * 0.25) + 1, wheels_offset_y + 2, 0]) {
            square([steering_servo_hole_width, steering_servo_hole_height], center=true);

            translate([(steering_servo_hole_width / 2) + m2_hole_dia, 0, 0]) {
              circle(r=steering_servo_screw_dia * 0.5, $fn=360);
            }
            translate([-(steering_servo_hole_width / 2) - m2_hole_dia, 0, 0]) {
              circle(r=steering_servo_screw_dia * 0.5, $fn=360);
            }
          }

          translate([0, wheels_offset_y + 30, 0]) { // i need here to create ring
            circle(r=pan_servo_hole_dia / 2, $fn=360);
          }
        }
      }

      // translate([0, wheels_offset_y + 30, 0]) {
      //   difference() {
      //     rad = pan_servo_hole_dia / 2;
      //     cylinder(1, r = pan_servo_hole_dia / 2, center = true);
      //     cylinder(4, r = rad * 0.8, center = true);
      //   }
      // }

      for (offsets = [[body_width, 20], [-body_width, 20], [-body_width, 50], [body_width, 50]]) {
        x = offsets[0];
        translate([x * 0.5, (-body_height * 0.5 + back_wheel_height * 0.5) + offsets[1], 0]) {
          back_wheel_wall();
        }
      }
      translate([0, body_height * 0.5, back_wheel_depth * 0.5]) {
        front_wall();
      }

      translate([0, -(body_height / 2) + 1, 25 / 2]) {
        rotate([90, 0, 0]) {
          back_mount();
        }
      }
    }

    raspberry_pi_offset = body_height * 0.03;

    translate([0, -(body_height / 2) + 55]) {
      rotate([0, 0, 90]) {
        ups_hat_screws();
      }
    }

    translate([0, raspberry_pi_offset, 0]) {
      raspberry_pi5_screws();
      rotate([0, 0, 90]) {
        raspberry_pi5_screws();
      }
    }
    translate([0, raspberry_pi_offset + -20, 0]) {
      battery_holders_holes();
    }

    four_corner_holes(size = [0, 20, 10], center = true, hole_dia = m2_hole_dia);

    translate([0, -50, 0]) {
      four_corner_holes(size = [0, 20, 10], center = true, hole_dia = m2_hole_dia);
      translate([0, -50, 0]) {
        four_corner_holes(size = [0, 20, 10], center = true, hole_dia = m2_hole_dia);
      }
    }
  }
}

color("white") {
  chassis_plate();
}
