/**
 * Module: The front panel of the vehicle.
 *
 * This module includes:
 *
 *  - The main chassis-integrated front panel with integrated slots for mounting the HC-SR04 ultrasonic sensor.
 *  - A detachable back panel that secures the ultrasonic sensor from behind.
 *  - A separate sensor fixation detail which is secured using two R3090 rivets.
 *
 * Sensor and Attachment Information:
 *
 *  - Sensor: HC-SR04 ultrasonic sensor
 *  - Attachment Hardware: R3090 rivet
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <parameters.scad>
use <util.scad>

module motor_mount_connector(size=[motor_mount_panel_width * 0.8, 5], thickness=motor_mount_panel_thickness) {
  linear_extrude(height=thickness) {
    square(size, center = true);
  }
}

module rear_motor_mount_3d(height=motor_mount_panel_thickness) {
  linear_extrude(height=height) {
    difference() {
      rounded_rect([motor_mount_panel_width, motor_mount_panel_height], 1, center=true);
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

// Combines the motor mount panel with a connector that attaches to the chassis.
// The assembly is rotated and translated into position.
module motor_mount_panel() {
  connector_size = [motor_mount_panel_width * 1.5, chassis_thickness + 1];
  rotate([180, 0, 0]) {
    translate([0, 0, -(motor_mount_panel_height * 0.5) - (connector_size[1] * 0.5) - 1]) {
      rotate([90, 0, 90]) {
        union() {
          rear_motor_mount_3d();
          translate([0, (motor_mount_panel_height * 0.5) + (connector_size[1] * 0.5) - 1, 0]) {
            motor_mount_connector([connector_size[0], connector_size[1]]);
          }
        }
      }
    }
  }
}

color("white") {
  motor_mount_panel();
}
