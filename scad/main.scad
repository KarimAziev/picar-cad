// This file arranges all robot parts on the printer’s build plate for fabrication.
// It assembles a robot chassis with a four-wheeled configuration:
//   - The front wheels are steered via a servo mechanism.
//   - The rear wheels are driven by two motors.
// In addition, the design prioritizes mounting options for multiple independent power modules - for example:
//   - One for the servo HAT,
//   - One for the motor driver HAT, and
//   - One for a UPS module (e.g., UPS_Module_3S) that can power the Raspberry Pi 5.

include <parameters.scad>
include <chassis.scad>;
use <head_mount.scad>;
use <steering_system.scad>;

color("white") {
  translate([-(chassis_width / 2) - 26, -40, 0]) {
    rotate([0, 0, 90]) {
      steering_lower_link_detachable();
    }
  }

  translate([-(chassis_width / 2) - 10, -40, 0]) {
    rotate([0, 0, 90]) {
      steering_tie_rod();
    }
  }
  translate([chassis_width / 2 + 38, 0, 0]) {
    head_mount();
  }
}
