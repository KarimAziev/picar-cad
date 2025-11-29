/**
 * Module: Case for IR LED This file contains an enclosure for a modified
 * Waveshare Infrared LED Light Board Module.
 *
 * The original LED board is incompatible with the Raspberry Camera Module 3,
 * and the quality of Waveshare’s original camera is unsatisfactory.
 *
 * Nevertheless, this LED board can be used with Camera Module 3 and other
 * Raspberry Pi cameras. To do so, solder two wires (GND and V+) to the screw
 * holes on the LED board (the screw holes serve both for mechanical attachment
 * and for power). Then connect the positive wire to 3.3V and the ground wire to
 * GND.
 *
 * Two key modules in this file:

 * ir_case_printable: provides the LED housing and a “rail” that secures it with
 * two M2 screws. The housing also includes a bracket for mounting to the robot
 * head.
 *
 * ir_case_assembly: renders the assembled unit. (In head/head_mount.scad you
 * can also call head_mount(show_ir_case=true) to view the assembly mounted on
 * the head.)
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <parameters.scad>
include <colors.scad>

use <l_bracket.scad>
use <slider.scad>
use <placeholders/ir_led.scad>
use <lib/transforms.scad>

function is_ir_case_light_detector_enabled(name) =
  ir_light_detector_position == "both"
  || ir_light_detector_position == name;

function is_ir_case_bracket_enabled(name) = ir_case_bracket_position == "both"
  || ir_case_bracket_position == name;

function ir_case_full_thickness() = ir_case_thickness
  + ir_case_led_boss_thickness;

function ir_case_holes_full_h() = ir_case_led_dia
  + ir_light_detector_dia
  + ir_light_offset_from_led_y;

function ir_case_slider_y_pos() =
  ir_case_height
  + ir_light_offset_from_led_y
  - ir_light_detector_dia
  - ir_case_led_dia / 2;

function ir_case_rail_y_pos() =
  ir_case_slider_y_pos()
  - ir_case_rail_w / 2
  + ir_case_rail_clearance / 2;

module ir_case_slider_holes_2d() {
  y_pos = ir_case_slider_y_pos();
  translate([ir_case_carriage_len / 2,
             y_pos, 0]) {
    circle(r=ir_case_rail_screw_dia / 2, $fn=360);
  }
  translate([ir_case_width
             - ir_case_carriage_len / 2,
             y_pos, 0]) {
    circle(r=ir_case_rail_screw_dia / 2, $fn=360);
  }
}

module ir_case_rail() {
  full_thickness = ir_case_full_thickness()
    + ir_case_carriage_h
    + ir_case_rail_h
    + ir_case_rail_protrusion_h;
  slider_holes_extra_h = 1;

  inner_w = ir_case_rail_w - ir_case_rail_clearance;

  base_w = (ir_case_carriage_wall_thickness * 2) + inner_w;

  difference() {
    translate([ir_case_width, ir_case_rail_y_pos()
               - ir_case_carriage_wall_thickness,
               full_thickness]) {

      rotate([0, 0, 90]) {
        rotate([-90, 0, 0]) {
          slider_dovetail_rail(l=ir_case_width,
                               base_h=ir_case_rail_protrusion_h,
                               base_w=base_w,
                               center=false,
                               base_angle=ir_case_rail_protrusion_angle,
                               h=ir_case_rail_h,
                               w=inner_w,
                               angle=ir_case_rail_angle,
                               r=ir_case_rail_offset_rad,
                               base_r=ir_case_rail_protrusion_offset_rad);
        }
      }
    }
    linear_extrude(height=full_thickness
                   + slider_holes_extra_h,
                   center=false,
                   convexity=2) {
      ir_case_slider_holes_2d();
    }
  }
}

module ir_case_slider() {
  thickness = ir_case_full_thickness();
  full_w = ir_case_rail_w + (ir_case_carriage_wall_thickness * 2);

  difference() {
    translate([0,
               ir_case_slider_y_pos()
               - full_w / 2,
               0]) {
      rotate([0, 0, 90]) {
        translate_copy([0, -ir_case_width + ir_case_carriage_len, 0]) {
          rotate([90, 0, 0]) {
            slider_carriage(l=ir_case_carriage_len,
                            h=ir_case_rail_h,
                            w=ir_case_rail_w,
                            base_h=thickness + ir_case_carriage_h,
                            angle=ir_case_rail_angle,
                            wall=ir_case_carriage_wall_thickness,
                            r=ir_case_carriage_offset_rad,
                            trapezoid_rad=ir_case_rail_offset_rad);
          }
        }
      }
    }

    linear_extrude(height=thickness
                   + ir_case_carriage_h + 1,
                   center=false,
                   convexity=2) {
      ir_case_slider_holes_2d();
    }
  }
}

module ir_case_holes_2d() {
  ir_rad = ir_case_led_dia / 2;
  ir_light_rad = ir_light_detector_dia / 2;
  ir_light_x = ir_rad - ir_light_rad + ir_light_offset_from_led_x;
  ir_light_y = ir_rad + ir_light_rad + ir_light_offset_from_led_y;

  translate([ir_case_width / 2,
             ir_rad,
             0]) {
    circle(r=ir_rad, $fn=200);

    for (pos = [is_ir_case_light_detector_enabled("right")
                ? [ir_light_x, ir_light_y, 0]
                : undef,
                is_ir_case_light_detector_enabled("left")
                ? [-ir_light_x, ir_light_y, 0]
                : undef]) {
      if (!is_undef(pos)) {
        translate(pos) {
          circle(r=ir_light_rad, $fn=100);
        }
      }
    }
  }
}

module ir_case_outline_2d(center=false, fn) {
  w = ir_case_width;
  h = ir_case_height;
  rad1 = ir_light_detector_dia / 2;
  rad2 = ir_case_led_dia / 2;

  offst = center ? [-w/2, -h/2] : [0, 0];

  hull() {
    translate([rad2, rad2] + offst) {
      circle(rad2, $fn=fn);
    }
    translate([w - rad2, rad2] + offst) {
      circle(rad2, $fn=fn);
    }
    translate([rad1, h - rad1] + offst) {
      circle(rad1, $fn=fn);
    }
    translate([w - rad1, h - rad1] + offst)
      circle(rad1, $fn=fn);
  }
}

module ir_case_base_plate(h=ir_case_thickness) {
  linear_extrude(height=h, center=false, convexity=2) {
    difference() {
      ir_case_outline_2d();
      translate([0, ir_case_height
                 - ir_case_holes_full_h()
                 - ir_case_holes_distance_from_top, 0]) {
        ir_case_holes_2d();
      }
      ir_case_slider_holes_2d();
    }
  }
}

module ir_case_screws_pan_holes() {
  for (x=ir_case_screw_pan_holes_x_offsets) {
    translate([0, x, 0]) {
      circle(r=ir_case_screw_dia / 2, $fn=360);
    }
  }
}

module ir_case_bracket() {
  l_bracket(size=[ir_case_l_bracket_w,
                  ir_case_l_bracket_h,
                  ir_case_l_bracket_len],
            center=false,
            thickness=ir_case_full_thickness(),
            children_modes=[["difference", "horizontal"]],
            y_r=min(ir_case_l_bracket_h, ir_case_l_bracket_w) * 0.5,
            z_r=0) {
    ir_case_screws_pan_holes();
  }
}

module ir_case() {
  full_thickness = ir_case_full_thickness();

  y_offst = ir_case_height - ir_case_holes_distance_from_top
    - ir_light_detector_dia;
  union() {
    difference() {
      ir_case_base_plate(h=full_thickness);
      translate([0, y_offst,
                 ir_case_led_boss_thickness]) {
        linear_extrude(height=ir_case_thickness + ir_case_led_boss_thickness,
                       center=false,
                       convexity=2) {
          square([ir_case_width + 1, ir_case_height], center=false);
        }
      }
    }

    ir_case_slider();

    for (spec = [["right",
                  [ir_case_l_bracket_len + ir_case_width, y_offst, 0],
                  [90, 0, -90]],
                 ["left",
                  [-ir_case_l_bracket_len, y_offst -
                   ir_case_l_bracket_w, 0],
                  [90, 0, 90]]]) {
      let (name = spec[0],
           offst = spec[1],
           rotation = spec[2]) {
        if (is_ir_case_bracket_enabled(name)) {
          translate(offst) {
            rotate(rotation) {
              ir_case_bracket();
            }
          }
        }
      }
      ;
    }
  }
}

module ir_case_assembly(show_rail=true,
                        show_ir_led=true,
                        case_color="white",
                        rail_color="white") {
  union() {
    color(case_color, alpha=1) {
      ir_case();
    }
    if (show_rail) {
      color(rail_color, alpha=1) {
        ir_case_rail();
      }
    }
    if (show_ir_led) {
      translate([ir_led_board_w +
                 ((ir_case_width - ir_led_board_w) / 2),
                 0,
                 ir_case_full_thickness()
                 + ir_led_thickness]) {
        rotate([0, 180, 0]) {
          ir_led_board();
        }
      }
    }
  }
}

module ir_case_printable(show_rail=true,
                         show_case=true,
                         spacing=2,
                         case_color="white",
                         rail_color="white") {
  union() {
    if (show_case) {
      color(case_color, alpha=1) {
        ir_case();
      }
    }

    if (show_rail) {
      rotate([180, 0, 0]) {
        translate([0,
                   spacing,
                   -ir_case_full_thickness()
                   - ir_case_carriage_h
                   - ir_case_rail_protrusion_h
                   - ir_case_rail_h]) {
          color(rail_color) {
            ir_case_rail();
          }
        }
      }
    }
  }
}

ir_case_printable(show_case=true, show_rail=true);
