/**
 * Module: Placeholder for Ultrasonic HC-SR04
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <../util.scad>
use <../l_bracket.scad>

module ultrasonic() {
  half_of_board_w = ultrasonic_w / 2;
  half_of_board_h = ultrasonic_h / 2;

  transducer_rad = ultrasonic_transducer_dia / 2;
  text_x = ultrasonic_screw_size[0] / 2
    - ultrasonic_screw_dia / 2
    - ultrasonic_text_size;

  text_y = -ultrasonic_screw_size[1] / 2;

  texts = [["T", -text_x],
           ["R", text_x]];

  union() {
    color(medium_blue_1, alpha=1) {
      linear_extrude(height=ultrasonic_thickness, center=false) {
        difference() {
          rounded_rect(size=[ultrasonic_w, ultrasonic_h],
                       center=true,
                       r=ultrasonic_offset_rad);
          four_corner_holes_2d(size=ultrasonic_screw_size,
                               hole_dia=ultrasonic_screw_dia,
                               center=true);
        }
      }
    }
    mirror_copy([1, 0, 0]) {
      translate([half_of_board_w
                 - transducer_rad
                 - ultrasonic_transducer_x_offset,
                 0,
                 ultrasonic_transducer_h / 2
                 + ultrasonic_thickness]) {
        ultrasonic_transducer();
      }
    }

    linear_extrude(height=ultrasonic_thickness + 0.1, center=false) {
      color(metalic_silver_1, alpha=1) {
        for (spec = texts) {
          let (txt = spec[0],
               txt_x = spec[1]) {
            translate([txt_x,
                       text_y,
                       ultrasonic_thickness]) {
              text(txt,
                   size=ultrasonic_text_size,
                   halign=txt_x > 0 ? "left" : "right",
                   valign="top");
            }
          }
        }
      }
    }

    translate([0,
               half_of_board_h
               - ultrasonic_oscillator_h / 2
               - ultrasonic_oscillator_y_offset,
               ultrasonic_thickness]) {
      ultrasonic_oscillator();
    }

    translate([0,
               -half_of_board_h
               + ultrasonic_pins_jack_h / 2
               + ultrasonic_pins_jack_y_offset,
               - ultrasonic_pins_jack_thickness]) {
      ultrasonic_pins();
    }

    ultrasonic_smd_chips();
  }
}

module ultrasonic_transducer() {
  transducer_rad = ultrasonic_transducer_dia / 2;
  lower_h = 0.1;
  union() {
    color(metalic_silver_2, alpha=1) {
      cylinder(h=ultrasonic_transducer_h,
               r=transducer_rad,
               center=true,
               $fn=50);
    }
    color(matte_black, alpha=1) {
      cylinder(h=ultrasonic_transducer_h + 0.5,
               r=ultrasonic_transducer_inner_dia / 2,
               center=true,
               $fn=30);
    }
    if (lower_h < ultrasonic_transducer_h) {
      translate([0, 0,
                 -ultrasonic_transducer_h / 2]) {
        color(light_grey) {
          cylinder(h=lower_h,
                   r=transducer_rad + 0.4,
                   center=true,
                   $fn=50);
        }
      }
    }
  }
}

module ultrasonic_oscillator() {
  color(metalic_silver_1, alpha=1) {
    linear_extrude(height=ultrasonic_oscillator_thickness,
                   center=false) {
      rounded_rect([ultrasonic_oscillator_w, ultrasonic_oscillator_h],
                   center=true,
                   fn=20);
    }
  }
}

module ultrasonic_smd_chip_2d(length=ultrasonic_smd_len,
                              h=ultrasonic_smd_h) {
  rounded_rect([length, h],
               center=true,
               fn=20,
               r=0.2);
}

module ultrasonic_smd_chip(length=ultrasonic_smd_len,
                           h=ultrasonic_smd_h,
                           thickness=ultrasonic_smd_thickness) {
  color(onyx, alpha=1) {
    linear_extrude(height=thickness,
                   center=false) {
      ultrasonic_smd_chip_2d(length=length, h=h);
    }
  }
}

module ultrasonic_smd_chips(half_of_board_w = ultrasonic_w / 2,
                            length=ultrasonic_smd_len,
                            h=ultrasonic_smd_h,
                            thickness=ultrasonic_smd_thickness,
                            use_2d=false) {
  translate([0,
             0,
             use_2d ? 0 : -thickness]) {

    if (use_2d) {
      ultrasonic_smd_chip_2d(length=length, h=h);
    } else {
      ultrasonic_smd_chip(length=length, h=h, thickness=thickness);
    }
    translate([half_of_board_w
               - length / 2
               - ultrasonic_smd_x_offst,
               0,
               0]) {
      if (use_2d) {
        ultrasonic_smd_chip_2d(length=length, h=h);
      } else {
        ultrasonic_smd_chip(length=length, h=h, thickness=thickness);
      }
    }
    translate([-half_of_board_w
               + h / 2
               + ultrasonic_smd_x_offst,
               0,
               0]) {
      rotate([0, 0, 90]) {
        if (use_2d) {
          ultrasonic_smd_chip_2d(length=length, h=h);
        } else {
          ultrasonic_smd_chip(length=length, h=h, thickness=thickness);
        }
      }
    }
  }
}

module ultrasonic_pins() {
  union() {
    color(matte_black, alpha=1) {
      linear_extrude(height=ultrasonic_pins_jack_thickness,
                     center=false) {
        rounded_rect(size=[ultrasonic_pins_jack_w,
                           ultrasonic_pins_jack_h],
                     center=true);
      }
    }
    if (ultrasonic_pins_count > 0) {
      spacing = (ultrasonic_pins_jack_w
                 - (ultrasonic_pin_thickness * ultrasonic_pins_count))
        / ultrasonic_pins_count;
      step = spacing + ultrasonic_pin_thickness;
      amount = ultrasonic_pins_count;

      color(metalic_silver_1, alpha=1) {
        for (i = [0 : amount - 1]) {
          let (x = (i * step),
               y = 0,
               z = -ultrasonic_pin_len_b / 2
               + ultrasonic_pins_jack_thickness
               + ultrasonic_thickness
               + ultrasonic_pin_protrusion_h) {
            translate([x
                       - ultrasonic_pins_jack_w / 2
                       + spacing / 2
                       + ultrasonic_pin_thickness / 2, y, z]) {
              rotate([90, 0, 0]) {
                l_bracket(size=[ultrasonic_pin_thickness,
                                ultrasonic_pin_len_b,
                                ultrasonic_pin_len_a],
                          thickness=ultrasonic_pin_thickness,
                          center=true);
              }
            }
          }
        }
      }
    }
  }
}

ultrasonic();
