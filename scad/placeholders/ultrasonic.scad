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
use <pins.scad>
use <smd_chip.scad>

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

    translate([0, 0, ultrasonic_thickness]) {
      linear_extrude(height=0.1, center=false) {
        color(metallic_silver_1, alpha=1) {
          for (spec = texts) {
            let (txt = spec[0],
                 txt_x = spec[1]) {
              translate([txt_x,
                         text_y,
                         ultrasonic_thickness]) {
                text(txt,
                     size=ultrasonic_text_size,
                     halign=txt_x > 0 ? "center" : "right",
                     valign="center");
              }
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
    translate([0, 0, -ultrasonic_smd_h]) {
      ultrasonic_solder_blobs();
    }
  }
}

module ultrasonic_transducer() {
  half_of_h = ultrasonic_transducer_h / 2;
  transducer_rad = ultrasonic_transducer_dia / 2;
  inner_rad = ultrasonic_transducer_inner_dia / 2;
  lower_h = 0.1;

  h_upper = ultrasonic_transducer_h * 0.05;
  cutout_h = ultrasonic_transducer_h / 2;

  union() {
    difference() {
      color(metallic_silver_5, alpha=1) {
        cylinder(h=ultrasonic_transducer_h,
                 r=transducer_rad,
                 center=true,
                 $fn=50);
      }
      translate([0, 0, half_of_h
                 - cutout_h / 2 + 0.5]) {
        cylinder(h=cutout_h,
                 r=inner_rad,
                 center=true,
                 $fn=30);
      }
    }
    color(matte_black, alpha=0.7) {
      translate([0, 0,
                 ultrasonic_transducer_h / 2
                 - h_upper / 2]) {
        cylinder(h=h_upper,
                 r=inner_rad,
                 center=true,
                 $fn=20);
      }
    }

    if (lower_h < ultrasonic_transducer_h) {
      translate([0, 0,
                 -ultrasonic_transducer_h / 2]) {
        color("white") {
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
  solder_blob_h = ultrasonic_thickness + 0.5;
  solder_blob_rad = ultrasonic_solder_blob_d / 2;
  half_of_w = ultrasonic_oscillator_w / 2;
  color(metallic_silver_1, alpha=1) {
    union() {
      linear_extrude(height=ultrasonic_oscillator_thickness,
                     center=false) {
        rounded_rect([ultrasonic_oscillator_w, ultrasonic_oscillator_h],
                     center=true,
                     fn=20);
      }

      for (x = [half_of_w
                - solder_blob_rad
                - ultrasonic_oscillator_solder_x,
                -half_of_w
                + solder_blob_rad
                + ultrasonic_oscillator_solder_x,]) {
        translate([x, 0, -solder_blob_h]) {
          ultrasonic_solder_blob(h=solder_blob_h);
        }
      }
    }
  }
}

module ultrasonic_smd_chip_2d(length=ultrasonic_smd_len,
                              h=ultrasonic_smd_w) {
  rounded_rect([length, h],
               center=true,
               fn=20,
               r=0.2);
}

module ultrasonic_smd_chip() {
  smd_chip(length=ultrasonic_smd_len,
           w=ultrasonic_smd_chip_w,
           j_lead_n=ultrasonic_smd_led_count,
           j_lead_thickness=ultrasonic_smd_led_thickness,
           total_w=ultrasonic_smd_w,
           h=ultrasonic_smd_h);
}

module ultrasonic_solder_blob(h=ultrasonic_smd_h,
                              $fn=30,
                              solder_color=metallic_silver_2) {
  rad = ultrasonic_solder_blob_d / 2;
  color(solder_color, alpha=1) {
    cylinder(h=h,
             r1=rad * 0.5,
             r2=rad,
             center=false,
             $fn=$fn);
  }
}

module ultrasonic_solder_blobs(size=ultrasonic_solder_blobs_positions,
                               center=true,
                               h=ultrasonic_smd_h,
                               $fn=30,
                               solder_color=metallic_silver_2) {
  for (x_ind = [0, 1])
    for (y_ind = [0, 1]) {
      x_pos = (center ? -size[0] / 2 : 0) + x_ind * size[0];
      y_pos = (center ? -size[1] / 2 : 0) + y_ind * size[1];
      translate([x_pos, y_pos, 0]) {
        ultrasonic_solder_blob(h=h,
                               $fn=$fn,
                               solder_color=solder_color);
        children();
      }
    }
}

module ultrasonic_smd_slots(half_of_board_w = ultrasonic_w / 2,
                            length=ultrasonic_smd_len,
                            w=ultrasonic_smd_w,
                            thickness=ultrasonic_smd_h,
                            x_offset=ultrasonic_smd_x_offst,
                            use_2d=false) {
  translate([0, 0, -thickness]) {
    rotate([180, 0, 0]) {
      translate([0,
                 0,
                 use_2d ? 0 : -thickness]) {

        children();
        translate([half_of_board_w
                   - length / 2
                   - x_offset,
                   0,
                   0]) {
          children();
        }
        translate([-half_of_board_w
                   + w / 2
                   + x_offset,
                   0,
                   0]) {
          rotate([0, 0, 90]) {
            children();
          }
        }
      }
    }
  }
}

module ultrasonic_smd_chips(half_of_board_w = ultrasonic_w / 2,
                            length=ultrasonic_smd_len,
                            w=ultrasonic_smd_w,
                            thickness=ultrasonic_smd_h,
                            j_lead_n=ultrasonic_smd_led_count,
                            j_lead_thickness=ultrasonic_smd_led_thickness,
                            x_offset=ultrasonic_smd_x_offst,
                            h=ultrasonic_smd_h) {
  ultrasonic_smd_slots(half_of_board_w=half_of_board_w,
                       length=ultrasonic_smd_len,
                       w=ultrasonic_smd_w,
                       thickness=thickness,
                       x_offset=x_offset) {

    smd_chip(length=length,
             w=ultrasonic_smd_chip_w,
             j_lead_n=j_lead_n,
             j_lead_thickness=j_lead_thickness,
             center=true,
             total_w=w,
             h=h);
  }
}

module ultrasonic_pins() {
  union() {
    color(matte_black, alpha=1) {
      linear_extrude(height=ultrasonic_pins_jack_thickness,
                     center=false) {
        rounded_rect(size=[ultrasonic_pins_jack_w,
                           ultrasonic_pins_jack_h],
                     center=true,
                     r_factor=0.1);
      }
    }

    if (ultrasonic_pins_count > 0) {
      spacing = ultrasonic_pins_jack_w / ultrasonic_pins_count;

      color(metallic_silver_1, alpha=1) {
        translate([0,
                   0,
                   ultrasonic_pin_protrusion_h
                   + ultrasonic_thickness
                   + ultrasonic_pins_jack_thickness
                   + ultrasonic_pin_thickness / 2]) {
          pins_centered(pin_w=ultrasonic_pin_thickness,
                        pin_b=ultrasonic_pin_len_b,
                        pin_a=ultrasonic_pin_len_a,
                        pitch=spacing);
        }
      }
    }
  }
}
