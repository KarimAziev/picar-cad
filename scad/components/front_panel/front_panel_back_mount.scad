/**
 * Module: A detachable back panel that secures the ultrasonic sensor from behind.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../colors.scad>
include <../../parameters.scad>

use <../../lib/holes.scad>
use <../../lib/shapes2d.scad>
use <../../lib/transforms.scad>
use <../../placeholders/smd/smd_chip.scad>
use <../../placeholders/ultrasonic.scad>
use <ultrasonic_rect_slots.scad>
use <util.scad>

module front_panel_back_mount(h=front_panel_height,
                              w=front_panel_width,
                              bolts_x_offset=front_panel_bolts_x_offset,
                              thickness=front_panel_rear_panel_thickness) {

  union() {
    linear_extrude(thickness) {
      difference() {
        rounded_rect(size=[w, h],
                     center=true,
                     r=front_panel_offset_rad);
        four_corner_holes_2d(size=ultrasonic_bolt_spacing,
                             d=ultrasonic_bolt_dia + 0.2,
                             center=true);

        ultrasonic_smd_slots(half_of_board_w=ultrasonic_w / 2,
                             length=ultrasonic_smd_len,
                             w=ultrasonic_smd_w,
                             thickness=ultrasonic_smd_h,
                             x_offset=ultrasonic_smd_x_offst) {
          smd_chip_slot_2d(length=ultrasonic_smd_len,
                           total_w=ultrasonic_smd_w,
                           center=true);
        }

        translate([0, -front_panel_bolts_y_offst, 0]) {
          two_x_bolts_2d(x=bolts_x_offset,
                         d=front_panel_bolt_dia);
        }
        four_corner_holes_2d(size=ultrasonic_solder_blobs_positions,
                             d=front_panel_solder_blob_dia,
                             center=true);
        ultrasonic_rect_slots_2d(h=ultrasonic_h,
                                 jack_w=ultrasonic_pins_jack_w + 2,
                                 jack_h=0,
                                 oscilator_h=ultrasonic_oscillator_h,
                                 oscilator_w=ultrasonic_oscillator_w);
        pw = ultrasonic_pins_jack_w + 2;
        ph = h - ultrasonic_h + ultrasonic_pins_jack_h;

        translate([0, -h / 2 + ph / 2]) {
          square([pw, ph], center=true);
        }
      }
    }
    translate([0, 0, thickness]) {
      linear_extrude(height=front_rear_panel_boss_height(),
                     center=false,
                     convexity=2) {
        mirror_copy([1, 0, 0]) {
          translate([bolts_x_offset,
                     -front_panel_bolts_y_offst,
                     0]) {
            ring_2d(r=front_panel_bolt_dia / 2,
                    fn=100,
                    w=front_panel_rear_panel_ring_width,
                    outer=true);
          }
        }
      }
    }
  }
}

front_panel_back_mount();
