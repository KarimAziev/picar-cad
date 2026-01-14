/**
 * Module: Slots for ultrasonic oscilator on front and rear panel
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../colors.scad>
include <../../parameters.scad>

use <../../lib/shapes2d.scad>

module ultrasonic_rect_slots_2d(h=front_panel_height,
                                oscilator_w=ultrasonic_oscillator_w + 2,
                                oscilator_h=ultrasonic_oscillator_h + 2,
                                jack_w=ultrasonic_pins_jack_w + 2,
                                jack_h=ultrasonic_pins_jack_h + 2,
                                oscilator_y_offset=ultrasonic_oscillator_y_offset) {

  union() {
    if (oscilator_h > 0 && oscilator_w > 0) {
      translate([0,
                 h / 2 - oscilator_h / 2
                 - oscilator_y_offset]) {
        rounded_rect([oscilator_w, oscilator_h],
                     center=true,
                     r=min(2,
                           min(oscilator_h, oscilator_w) * 0.3),
                     fn=20);
      }
    }

    if (jack_h > 0 && jack_w > 0) {
      translate([0, -h / 2 + jack_h / 2]) {
        rounded_rect([jack_w, jack_h],
                     center=true,
                     r=min(2,
                           min(jack_h, jack_w) * 0.3),
                     fn=20);
      }
    }
  }
}

ultrasonic_rect_slots_2d();