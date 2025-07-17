
include <parameters.scad>
include <placeholders/motor.scad>
use <util.scad>

module motor_mount_connector(size=[motor_mount_panel_width * 0.8, 5], thickness=motor_mount_panel_thickness) {
  union() {
    linear_extrude(height=thickness) {
      square(size, center=true);
    }
  }
}

module rear_motor_mount_3d(height=motor_mount_panel_thickness) {
  linear_extrude(height=height) {
    difference() {
      rotate([180, 0, 0]) {
        rounded_rect_two([motor_mount_panel_width, motor_mount_panel_height], center=true);
      }

      offst = 9;
      translate([0, 0, -1]) {
        for (y = [-offst, offst]) {
          translate([0, y, 0]) {
            circle(r = m3_hole_dia / 2, $fn = 360);
          }
        }
      }
    }
  }
}

module motor_bracket_screws_2d(d=m2_hole_dia) {
  for (y = motor_bracket_screws) {
    translate([0, y, 0]) {
      circle(r = d / 2, $fn = 360);
    }
  }
}

module motor_bracket(size=[motor_mount_panel_width, motor_bracket_panel_height, motor_bracket_panel_height],
                     thickness=motor_mount_panel_thickness, y_r=motor_mount_panel_width / 2,
                     z_r=motor_mount_panel_width / 2,
                     show_wheel_and_motor=false) {
  x = size[0];
  y = size[1];
  z = size[2];

  ur = (y_r == undef) ? 0 : y_r;
  lr = (z_r == undef) ? 0 : z_r;

  union() {
    linear_extrude(height=thickness, center=false) {
      difference() {
        rounded_rect_two([x, y], center=true, r=ur);
        motor_bracket_screws_2d(m2_hole_dia);
      }
    }
    translate([0, -y / 2, z / 2]) {
      rotate([90, 0, 0]) {
        linear_extrude(height=thickness, center=false) {
          difference() {
            rounded_rect_two([x, z], center=true, r=lr);
            motor_bracket_screws_2d(m3_hole_dia);
          }
        }
        if (show_wheel_and_motor) {

          translate([gearbox_body_main_len / 2 - motor_body_neck_len / 2, 0,
                     -gearbox_side_height / 2]) {
            rotate([180, 180, 0]) {
              motor(show_wheel=true);
            }
          }
        }
      }
    }
  }
}

// motor_mount_panel();

rotate([0, 0, 90]) {
  translate([10, 14, 0]) {
    motor_bracket(show_wheel_and_motor=true);
  }
}
