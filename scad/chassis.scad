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

body_width                        = 100;

body_height                       = 235;
body_depth                        = 2;

steering_servo_hole_width         = 24;
steering_servo_hole_height        = 12;
steering_servo_screw_dia          = 2;

pan_servo_hole_dia                = 7;

motor_wall_height                 = 10;
motor_mount_width                 = 3;
motor_wall_depth                  = 30;

m2_hole_dia                       = 2.4;
m25_hole_dia                      = 2.8;
m3_hole_dia                       = 3.2;

wheels_offset_y                   = body_height * 0.3;

raspberry_pi_offset               = body_height * 0.06;
raspberry_pi5_screws_size         = [50, 58, 10];

battery_holders_screws_size       = [20, 70, 10];
extra_battery_holders_screws_size = [0, 20, 10];

ups_hat_screws_size               = [48, 86, 10];

extra_cutouts_dia                 = 8;

module rear_wheel_motor_mount() {
  translate([0, 0, motor_wall_depth * 0.5]) {
    difference() {
      cube(size = [motor_mount_width, motor_wall_height, motor_wall_depth],
           center = true);
      for (y = [-9, 9]) {
        translate([0, -(motor_wall_height / 2) + 5, y]) {
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
        rounded_rect(size=[size, motor_wall_depth], r=5, center=true);
      }
      cube(size = [size * 0.7, motor_wall_depth * 0.5, motor_wall_depth],
           center = true);
      translate([0, motor_wall_depth * 0.5, 0]) {
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
  four_corner_holes(size = raspberry_pi5_screws_size,
                    center = true,
                    hole_dia = m25_hole_dia);
}

module ups_hat_screws() {
  four_corner_holes(size = ups_hat_screws_size,
                    center = true,
                    hole_dia = m3_hole_dia);
}

module battery_holders_screws() {
  four_corner_holes(size = battery_holders_screws_size,
                    center = true,
                    hole_dia = m2_hole_dia);
}

module extra_battery_holders_screws() {
  x_offst = 24;
  for (y = number_sequence(-102, 40, 10)) {
    translate([0, y, 0]) {
      four_corner_holes(size = [20, 10, 5],
                        center = true,
                        hole_dia = m2_hole_dia);
    }
    translate([-x_offst, y, 0]) {
      four_corner_holes(size = [20, 10, 5],
                        center = true,
                        hole_dia = m2_hole_dia);
    }

    translate([x_offst, y, 0]) {
      four_corner_holes(size = [20, 10, 5],
                        center = true,
                        hole_dia = m2_hole_dia);
    }
  }
  for (y = number_sequence(-100, 100, 20)) {
    translate([0, y, 0]) {
      four_corner_holes(size = extra_battery_holders_screws_size,
                        center = true,
                        hole_dia = m2_hole_dia);
    }
  }
}

// module extra_cutout_square() {
//   translate([49, 18, 0]) {
//     rotate([0, 0, 23]) {
//       square([14, 40], center=true);
//       translate([6, 32, 0]) {
//         square([20, 40], center=true);
//       }

//       translate([0, -26, 0]) {
//         square([15, 40], center=true);
//       }
//     }
//   }
//   translate([35, -116, 0]) {
//     rotate([0, 0, 44]) {
//       square([30, 20], center=true);
//     }
//   }
// }

module extra_cutout_square() {
  offset1_x = 0.49 * body_width;
  offset1_y = 18/235 * body_height;
  rot1 = 23;

  sq1_w = 14/100 * body_width;
  sq1_h = 55/235 * body_height;
  sq2_w = 26/100 * body_width;
  sq2_h = 40/235 * body_height;
  sq3_w = 15/100 * body_width;
  sq3_h = 40/235 * body_height;

  tx_for_sq2 = 6/100 * body_width;
  ty_for_sq2 = 32/235 * body_height;
  ty_for_sq3 = -26/235 * body_height;

  offset2_x = 35/100 * body_width;
  offset2_y = -116/235 * body_height;
  rot2 = 44;
  sq4_w = 30/100 * body_width;
  sq4_h = body_width * 0.25;

  translate([offset1_x, offset1_y, 0]) {
    rotate([0, 0, rot1]) {
      square([sq1_w, sq1_h], center=true);
      translate([tx_for_sq2, ty_for_sq2, 0]) {
        square([sq2_w, sq2_h], center=true);
      }
      translate([0, ty_for_sq3, 0]) {
        square([sq3_w, sq3_h], center=true);
      }
    }
  }
  translate([offset2_x, offset2_y, 0]) {
    rotate([0, 0, rot2]) {
      square([sq4_w, sq4_h], center=true);
    }
  }
}

module extra_cutouts_2d() {
  translate([0, 50/235 * body_height, 0]) {
    square([30/100 * body_width, 10/235 * body_height], center=true);
  }

  translate([-22/100 * body_width, 81/235 * body_height, 0]) {
    square([10/100 * body_width, 6/235 * body_height], center=true);
  }

  /* for (x = [-0.48 * body_width, 0.48 * body_width]) { */
  /*   dotted_lines_fill_y(body_height, */
  /*                       starts = [x, 42/235 * body_height], */
  /*                       body_height / 2, */
  /*                       r = 15); */
  /* } */

  extra_cutout_square();
  mirror([1, 0, 0])
    extra_cutout_square();

  translate([0, -10/235 * body_height, 0]) {
    for (offset = [-10/235 * body_height, 0, -20/235 * body_height]) {
      translate([0, offset, 0])
        dotted_screws_line_y([-(body_width*0.5 - extra_cutouts_dia),
                              body_width*0.5 - extra_cutouts_dia],
                             y = 0,
                             d = extra_cutouts_dia);
    }
  }
}

module steering_servo_cutout_2d() {
  translate([(steering_servo_hole_width * 0.25) + 1, wheels_offset_y + 2, 0]) {
    square([steering_servo_hole_width, steering_servo_hole_height], center=true);
    for (x = [[-steering_servo_hole_width, -m2_hole_dia],
              [steering_servo_hole_width, m2_hole_dia]]) {
      translate([x[0] / 2 + x[1], 0, 0]) {
        circle(r=steering_servo_screw_dia * 0.5, $fn=360);
      }
    }
  }
}

module pan_servo_cutout_2d() {
  translate([0, wheels_offset_y + 32, 0]) {
    circle(r=pan_servo_hole_dia / 2, $fn=360);
    servo_screw_d = 1.5;
    step = servo_screw_d + 0.5;
    end = (body_width / 2) - pan_servo_hole_dia;
    servo_screws_x = concat([for (i = [-end:step:-5]) i],
                            [for (i = [5:step:end]) i]);
    dotted_screws_line_y(servo_screws_x, y=0, d=1.5);
    translate([0, 10, 0]) {
      square([10, 5], center = true);
    }
    translate([0, -10, 0]) {
      square([10, 5], center = true);
    }
    translate([0, -18, 0]) {
      square([10, 5], center = true);
    }
  }
}

module chassis_front_wheel_cutouts_2d() {
  for (x = [-body_width, body_width]) {
    translate([x * 0.7, wheels_offset_y, 0]) {
      circle(r = 35);
    }
  }
  for (x = [body_width, -body_width]) {
    translate([x * 0.5, body_height * 0.4, 0]) {
      rounded_rect(size=[80, 4], r=2, center=true);
    }
  }
}

module chassis_battery_screws_2d(y_offset=10) {
  dotted_lines_fill_y(body_height * 0.7, starts=[-10, -body_height / 2], y_offset=y_offset, r=m2_hole_dia / 2);
  dotted_lines_fill_y(body_height * 0.7, starts=[10, -body_height / 2], y_offset=y_offset, r=m2_hole_dia / 2);
}

module chassis_base_2d() {
  union() {
    difference() {
      rounded_rect(size=[body_width, body_height], center=true);
      chassis_front_wheel_cutouts_2d();
      extra_cutouts_2d();
    }
    translate([0, wheels_offset_y, 0]) {
      wheels_plate_down_2d();
    }
  }
}

module chassis_base_3d() {
  linear_extrude(body_depth, center = false) {
    difference() {
      chassis_base_2d();
      steering_servo_cutout_2d();
      pan_servo_cutout_2d();
    }
  }
}

module chassis_plate() {
  difference() {
    union() {
      chassis_base_3d();

      for (offsets = [[body_width, 20], [-body_width, 20]]) {
        translate([offsets[0] * 0.5,
                   (-body_height * 0.5 + motor_wall_height * 0.5) + offsets[1],
                   0]) {
          rear_wheel_motor_mount();
        }
      }

      translate([0, body_height * 0.5, motor_wall_depth * 0.5]) {
        front_wall();
      }

      translate([0, -(body_height / 2) + 1, 25 / 2]) {
        rotate([90, 0, 0]) {
          back_mount();
        }
      }
    }

    translate([0, -(body_height / 2) + 42]) {
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
    translate([0, raspberry_pi_offset + -22, 0]) {
      battery_holders_screws();
    }

    extra_battery_holders_screws();
  }
}

color("white") {
  chassis_plate();
}
