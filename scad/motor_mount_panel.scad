// motor_mount_panel.scad - Defines the rear motor mount and connecting wall structure for the vehicle's chassis.
//
// This module includes:
// - Rear wheel motor mount with screw holes for M3 fasteners
// - A 3D extruded version of the mount panel with rounded corners
// - A connector to attach the motor mount to the main chassis wall
//
// Components:
// - Motor and rear wheel assembly
// - Attachments using M3 screws

include <parameters.scad>
use <util.scad>;

module motor_mount_connector(size=[motor_mount_panel_width * 0.8, 5], thickness=motor_mount_panel_thickness) {
  linear_extrude(height=thickness) {
    square(size, center = true);
  }
}

module rear_motor_mount_3d(height=motor_mount_panel_thickness) {
  difference() {
    linear_extrude(height=height) {
      rounded_rect([motor_mount_panel_width, motor_mount_panel_height], 1, center=true);
    }
    translate([0, 1, -1]) {
      linear_extrude(height = height + 2) {
        offst = 9;
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
