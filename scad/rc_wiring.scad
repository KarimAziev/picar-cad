
include <parameters.scad>
include <rc_params.scad>

use <components/step_down_enclosure/step_down_voltage_enclosure.scad>
use <placeholders/perfboard.scad>
use <placeholders/rotary_encoder.scad>
use <placeholders/rpi_5.scad>

perfboard_plist = ["size", [20, 80, 1.6],
                   "bolt_spacing", [16, 76],
                   "rows", 28,
                   "cols", 6];

module wiring_plate() {
  translate([-10, 0, 0]) {
    rpi_5(anchor=[-1, 1, 1]);
  }

  translate([10, 0, 0]) {
    perfboard(perfboard_plist, anchor=[1, 1, -1]);
  }

  translate([-40, -20, 0]) {
    encoder(plist=as5048A_encoder_plist,
            show_bolt=false,
            show_nut=false,
            anchor=[-1, -1, 1]);
  }

  translate([40, 0, 0]) {
    encoder(plist=as5048A_encoder_plist,
            show_bolt=false,
            show_nut=false,
            anchor=[1, 1, 1]);
  }

  translate([0, -20, 0]) {
    step_down_voltage_enclosure(show_lid=false,
                                show_hardware=true,
                                show_enclosure=false,
                                show_fasteners=false,
                                show_step_down_standoff=false,
                                show_step_down_bolt=false,
                                show_ina_terminal=false,
                                show_ina_pins=false,
                                show_ina_standoff=false,
                                show_nut=false,
                                spin=180,
                                anchor=[1, -1, 1]);
  }
}

wiring_plate();