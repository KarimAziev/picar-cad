/**
 * Placeholder model for the Waveshare Infrared LED Light Board
 (https://www.waveshare.com/infrared-led-board.html or
 https://www.waveshare.com/infrared-led-board-b.html)
 *
 * - Visual mockup of the Waveshare Infrared LED Light Board used for
 *   assembly previews and placement checks. Not an electrical or
 *   manufacturable PCB model - intended only for geometry/layout in the
 *   larger assembly (e.g., scad/ir_case.scad and head/head_mount.scad).
 *
 * Main modules
 * - ir_led_board()            // renders the PCB, mounting ears, bolt holes,
 *                             // the LED body and its light detector - centered
 *                             // for easy placement in assemblies.
 * - ir_led()                  // renders only the LED cylinder (useful for
 *                             // quick positioning, testing or isolated previews).
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/shapes2d.scad>

module ir_led_light_detector() {
  rad_1 = ir_led_light_detector_dia_1 / 2;
  rad_2 = ir_led_light_detector_dia_2 / 2;

  translate([max(rad_1, rad_2), max(rad_1, rad_2), 0]) {
    color(matte_black, alpha=1) {
      cylinder(h=ir_led_light_detector_h,
               r1=rad_1,
               r2=rad_2,
               center=false,
               $fn=40);
    }
    translate([0, 0, ir_led_light_detector_h]) {
      color("lightpink", alpha=0.6) {
        cylinder(h=0.1,
                 r=rad_2 - 0.4,
                 center=false,
                 $fn=40);
      }
    }
  }
}

module ir_led() {
  rad = ir_led_dia / 2;
  translate([rad, rad, 0]) {
    color(matte_black, alpha=1) {
      cylinder(h=ir_led_height,
               r=rad,
               center=false,
               $fn=40);
    }
    translate([0, 0, ir_led_height]) {
      color(ir_1, alpha=0.6) {
        cylinder(h=0.1,
                 r=rad - 1,
                 center=false,
                 $fn=40);
      }
    }
  }
}

module ir_led_board() {
  ear_dia = (ir_led_board_w - ir_led_board_cutout_depth) / 2 - 0.2;
  ear_rad = ear_dia / 2;
  bolt_rad = ir_led_bolt_dia / 2;
  union() {
    color(matte_black, alpha=1) {
      linear_extrude(height=ir_led_thickness, center=false) {
        translate([0, ir_led_board_len, 0]) {
          rotate([180, 0, 0]) {
            difference() {
              union() {
                translate([0, ir_led_board_cutout_depth - 0.1, 0]) {
                  rounded_rect_two([ir_led_board_w,
                                    ir_led_board_len
                                    - ir_led_board_cutout_depth],
                                   r=min(ir_led_board_w, ir_led_board_len)
                                   * 0.5);
                }
                translate([0, ear_rad, 0]) {
                  translate([ear_rad, 0, 0]) {
                    circle(r=ear_rad, $fn=100);
                  }
                  translate([ir_led_board_w - ear_rad, 0, 0]) {
                    circle(r=ear_rad, $fn=100);
                  }
                }
              }
              translate([ir_led_board_w / 2, ir_led_board_cutout_depth / 2, 0]) {
                rect_w = ir_led_board_w - (ear_dia * 2);
                rounded_rect([rect_w, ir_led_board_cutout_depth],
                             center=true,
                             r=0.5,
                             fn=40);
              }
              translate([0,
                         bolt_rad + 0.4, 0]) {
                translate([ear_rad, 0, 0]) {
                  circle(r=bolt_rad, $fn=10);
                }
                translate([ir_led_board_w - ear_rad, 0, 0]) {
                  circle(r=bolt_rad, $fn=10);
                }
              }
            }
          }
        }
      }
    }
    translate([ir_led_board_w / 2
               - ir_led_dia / 2,
               ir_led_y_offset,
               ir_led_thickness]) {
      ir_led();
    }
    translate([ir_led_light_detector_offset_x,
               ir_led_y_offset + ir_led_dia
               + ir_led_light_detector_offset_from_led,
               ir_led_thickness]) {
      ir_led_light_detector();
    }
  }
}

ir_led_board();
