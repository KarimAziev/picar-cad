// This file arranges all robot parts on the printer’s build plate for fabrication.
// It assembles a robot chassis with a four-wheeled configuration:
//   - The front wheels are steered via a servo mechanism.
//   - The rear wheels are driven by two motors.
// In addition, the design prioritizes mounting options for multiple independent power modules - for example:
//   - One for the servo HAT,
//   - One for the motor driver HAT, and
//   - One for a UPS module (e.g., UPS_Module_3S) that can power the Raspberry Pi 5.

include <parameters.scad>
use <chassis.scad>
use <head_mount.scad>
use <steering_system.scad>
use <front_panel.scad>

color("white") {
  chassis_plate();
  half_wheels_distance = wheels_distance * 0.5;

  translate([-(chassis_width / 2) - (steering_link_width + steering_tie_rod_width + 4),
             -half_wheels_distance,
             0]) {
    rotate([0, 0, 90]) {
      steering_lower_link_detachable();
    }
  }

  translate([-(chassis_width / 2) - steering_tie_rod_width - 4,
             -half_wheels_distance,
             0]) {
    rotate([0, 0, 90]) {
      steering_tie_rod();
    }
  }
  translate([(chassis_width / 2 + head_plate_width * 0.5) + 6, 0, 0]) {
    head_mount();
  }

  translate([-(wheels_distance / 2) - front_panel_height * 0.5,
             half_wheels_distance,
             0]) {
    rotate([0, 0, 90]) {
      front_panel_back_mount();
    }
  }
}
