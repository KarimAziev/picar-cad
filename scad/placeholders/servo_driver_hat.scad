
/**
 * Module: Placeholder for Servo Driver HAT
 * (https://www.waveshare.com/wiki/Servo_Driver_HAT)
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../parameters.scad>
include <../colors.scad>

use <../lib/shapes2d.scad>
use <../lib/holes.scad>
use <../lib/transforms.scad>
use <pin_headers.scad>
use <screw_terminal.scad>
use <pad_hole.scad>
use <../lib/placement.scad>
use <standoff.scad>
use <smd_chip.scad>
use <smd_resistor.scad>
use <../lib/shapes3d.scad>
use <../lib/functions.scad>

basic_resistor_size              = [1.0, 2.5, 0.5, 0.01, false];
servo_driver_hat_resistors_specs = [[basic_resistor_size,
                                     ["lightyellow", 1.1, 0.7, 0.1,
                                      0.2, "white"],
                                     [brown_2, 0.1],
                                     [],
                                     [4.0, 1.0, 0],
                                     []],
                                    [basic_resistor_size,
                                     ["lightyellow", 1.1, 0.7, 0.1,
                                      0.2, "white"],
                                     [brown_2, 0.1],
                                     [],
                                     [4.0, -2.3, 0],
                                     []],
                                    [[2.5, 2.0, 0.5, 0.01, false],
                                     [matte_black, 1.1, 0.7],
                                     [matte_black, 0.1],
                                     [],
                                     [0.8, -0.3, 0],
                                     []],
                                    [basic_resistor_size,
                                     ["lightyellow", 1.1, 0.7, 0.1,
                                      0.2, "white"],
                                     [brown_2, 0.1],
                                     [],
                                     [-1.0, 1.0, 0],
                                     []],
                                    [basic_resistor_size,
                                     ["lightyellow", 1.1, 0.7, 0.1,
                                      0.2, "white"],
                                     [brown_2, 0.1],
                                     [],
                                     [-1.0, -2.3, 0],
                                     []],
                                    [[1.5, 3.3, 2.5, 0.01, false],
                                     [metallic_silver_1, 1.05, 0.6],
                                     [brown_2, 0.1],
                                     [],
                                     [-3.75, -0.9, 0],
                                     []],
                                    [[1.5, 3.3, 2.5, 0.01, false],
                                     [metallic_silver_1, 1.05, 0.6],
                                     [brown_2, 0.1],
                                     [],
                                     [-5.60, -0.9, 0],
                                     []],
                                    [[6.15, 6.15, 2.7, 0.01, false],
                                     [metallic_silver_1, 0.00, 0.0],
                                     [brown_2, 0.1],
                                     ["100", "grey"],
                                     [-5.65, -9.9, 0],
                                     []],
                                    [[2.15, 6.0, 0.8, 0.01, false],
                                     [brown_2, 1.1, 0.7],
                                     [matte_black, 1.2],
                                     [],
                                     [1.60, -9.8, 0],
                                     []]];

module servo_driver_hat_pca9865_chip() {
  smd_chip(length=servo_driver_hat_chip_len,
           w=servo_driver_hat_chip_w,
           j_lead_n=servo_driver_hat_chip_j_lead_n,
           j_lead_thickness=servo_driver_hat_chip_j_lead_thickness,
           total_w=servo_driver_hat_chip_total_w,
           h=servo_driver_hat_chip_h,
           smd_color=black_1,
           center=true);
}

module servo_driver_hat(show_standoff=true, center=true) {
  w = servo_driver_hat_size[0];
  l = servo_driver_hat_size[1];
  h = servo_driver_hat_size[2];

  half_of_w = w / 2;
  half_of_l = l / 2;

  translate([center ? 0 : half_of_w, center ? 0 : half_of_l, 0]) {
    union() {
      color(medium_blue_1, alpha=1) {
        linear_extrude(height=h, center=false) {
          difference() {
            rounded_rect(size=[servo_driver_hat_size[0],
                               servo_driver_hat_size[1]],
                         r=servo_driver_corner_rad,
                         center=true);
            four_corner_holes_2d(size=servo_driver_hat_screws_size,
                                 center=true);
          }
        }
      }
      four_corner_children(size=servo_driver_hat_screws_size) {
        pad_hole(specs=servo_driver_hat_mounting_hole_pad_spec,
                 thickness=h,
                 screw_d=servo_driver_hat_screw_dia);
      }

      translate([-half_of_w + rpi_pin_header_width,
                 -half_of_l
                 + rpi_pin_header_width
                 * rpi_pin_headers_cols / 2
                 + rpi_screws_offset * 2,
                 -servo_driver_hat_header_height]) {
        pin_headers(cols=rpi_pin_headers_cols,
                    rows=rpi_pin_headers_rows,
                    header_width=rpi_pin_header_width,
                    header_height=servo_driver_hat_header_height,
                    pin_height=servo_driver_hat_pin_height,
                    z_offset=-servo_driver_hat_header_height,
                    p=0.65,
                    center=true);
      }
      translate([0,
                 -half_of_l
                 + servo_driver_hat_screw_terminal_thickness / 2,
                 h]) {
        rotate([0, 0, 180]) {
          screw_terminal(thickness=servo_driver_hat_screw_terminal_thickness,
                         base_h=servo_driver_hat_screw_terminal_base_h,
                         top_l=servo_driver_hat_screw_terminal_top_l,
                         top_h=servo_driver_hat_screw_terminal_top_h,
                         contacts_n=servo_driver_hat_screw_terminal_contacts_n,
                         contact_w=servo_driver_hat_screw_terminal_contact_w,
                         contact_h=servo_driver_hat_screw_terminal_contact_h,
                         pitch=servo_driver_hat_screw_terminal_pitch,
                         colr="green");
        }
      }
      translate([-servo_driver_hat_chip_i2c_x_distance,
                 half_of_l
                 - servo_driver_hat_chip_i2c_y_distance,

                 h]) {

        smd_resistors_row(amount=5,
                          gap=servo_driver_hat_i2c_addr_gap,
                          size=servo_driver_hat_i2c_addr_size,
                          text_gap=servo_driver_hat_i2c_addr_text_gap,
                          border_w=0.1,
                          border_p=0.3,
                          body_h=0.1,
                          text_spacing=0.9,
                          text_size=servo_driver_hat_i2c_addr_text_size,
                          prefix="A",
                          center=false,
                          axle="y",
                          text_valign="bottom") {
          translate([servo_driver_hat_i2c_addr_size[0]
                     + servo_driver_hat_i2c_addr_text_gap * 2
                     + servo_driver_hat_i2c_addr_text_size,
                     0, 0]) {
            let (p = servo_driver_hat_i2c_addr_size[0] * 0.1) {
              translate([0, p, 0]) {
                union() {
                  color("lightyellow", alpha=1) {
                    translate([-p, 0, 0]) {

                      linear_extrude(height=servo_driver_hat_i2c_addr_size[2],
                                     center=false) {
                        intersection() {
                          square(size=[servo_driver_hat_i2c_addr_size[0] / 2 - p ,
                                       servo_driver_hat_i2c_addr_size[1] - p * 2]);
                          translate([p / 2, p / 2, 0]) {
                            square(size=[servo_driver_hat_i2c_addr_size[0] / 2 - p * 2,
                                         servo_driver_hat_i2c_addr_size[1] - p * 2]);
                          }
                        }
                        translate([p + servo_driver_hat_i2c_addr_size[0] / 2, 0, 0]) {
                          intersection() {
                            square(size=[servo_driver_hat_i2c_addr_size[0] / 2 - p,
                                         servo_driver_hat_i2c_addr_size[1] - p * 2]);
                            translate([p / 2, p / 2, 0]) {
                              square(size=[servo_driver_hat_i2c_addr_size[0] / 2 - p * 2,
                                           servo_driver_hat_i2c_addr_size[1] - p]);
                            }
                          }
                        }
                      }
                    }
                  }
                  translate([0, 0, 0]) {
                    linear_extrude(height=servo_driver_hat_i2c_addr_size[2],
                                   center=false) {
                      difference() {
                        translate([-p, -p, 0]) {
                          square(size=[servo_driver_hat_i2c_addr_size[0],
                                       servo_driver_hat_i2c_addr_size[1]]);
                        }

                        square(size=[servo_driver_hat_i2c_addr_size[0] - p * 2,
                                     servo_driver_hat_i2c_addr_size[1] - p * 2]);
                      }
                    }
                  }
                }
              }
            }
          }
        }
        translate([servo_driver_hat_i2c_addr_size[0] * 2
                   + servo_driver_hat_i2c_addr_text_gap * 2.5
                   + servo_driver_hat_i2c_addr_text_size, 0, 0]) {

          rotate([0, 0, 90]) {
            color("white", alpha=1) {
              linear_extrude(height=0.01, center=false) {
                text(servo_driver_hat_i2c_addr_text_label,
                     size=servo_driver_hat_i2c_addr_text_label_size,
                     valign="top");
              }
            }
          }
        }
      }
      translate([0, half_of_l
                 - servo_driver_hat_chip_2_total_w / 2
                 - servo_driver_hat_chip_2_x_distance,
                 h]) {
        smd_chip(length=servo_driver_hat_chip_2_len,
                 w=servo_driver_hat_chip_2_w,
                 j_lead_n=servo_driver_hat_chip_2_j_lead_n,
                 j_lead_thickness=servo_driver_hat_chip_2_j_lead_thickness,
                 total_w=servo_driver_hat_chip_2_total_w,
                 h=servo_driver_hat_chip_2_h,
                 smd_color=black_1,
                 center=true);
      }
      translate([0, half_of_l
                 - servo_driver_hat_chip_total_w / 2
                 - servo_driver_hat_chip_x_distance,
                 h]) {
        servo_driver_hat_pca9865_chip();
      }
      translate([0, 0, h]) {

        smd_resistors_from_specs(specs=servo_driver_hat_resistors_specs);
      }

      let (step = servo_driver_hat_side_pins_headers_margin
           + servo_driver_hat_side_pin_cols * rpi_pin_header_width,
           total_y = step * (servo_driver_hat_side_pins_headers_count - 1),
           z_offset=servo_driver_hat_side_pin_height / 2
           - servo_driver_hat_side_header_height / 2,
           step_z = rpi_pin_header_width,
           start_len = 0.65 * servo_driver_hat_side_pin_height,
           end_len   = servo_driver_hat_side_pin_height,
           step_len  = (servo_driver_hat_side_pin_rows > 1)
           ? (end_len - start_len) / (servo_driver_hat_side_pin_rows - 1)
           : 0) {

        translate([half_of_w + servo_driver_hat_side_header_height,
                   -total_y / 2,
                   h + step_z]) {
          for (i = [0 : servo_driver_hat_side_pins_headers_count - 1]) {
            let (y = step * i) {

              translate([0, y, 0]) {
                for (r = [0 : servo_driver_hat_side_pin_rows - 1]) {
                  let (length = (servo_driver_hat_side_pin_rows > 1)
                       ? start_len + r
                       * step_len : end_len,
                       l_len = (step_z * (r + 1)) + step_z) {
                    translate([0, 0, step_z * r]) {
                      rotate([0, -90, 0]) {
                        pin_headers(cols=servo_driver_hat_side_pin_cols,
                                    rows=1,
                                    pin_colr=metallic_yellow_1,
                                    header_width=rpi_pin_header_width,
                                    header_height=servo_driver_hat_side_header_height,
                                    pin_height=length,
                                    l_len=l_len,
                                    z_offset=z_offset,
                                    p=0.65,
                                    center=true) {
                          let (idx = $y + (i * servo_driver_hat_side_pins_headers_count),
                               text_h = 0.2) {
                            if (r == 0) {
                              translate([-servo_driver_hat_side_header_height + text_h, 0, length]) {
                                rotate([0, -90, 0]) {
                                  rotate([0, 180, -90]) {
                                    color("white", alpha=1) {
                                      linear_extrude(height=text_h, center=false) {
                                        text(str(idx), size=1);
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      if (show_standoff) {
        translate([0, 0, -servo_driver_hat_header_height]) {
          four_corner_children(servo_driver_hat_screws_size) {
            standoff(body_d=servo_driver_hat_screw_dia,
                     thread_d=servo_driver_hat_screw_dia / 2,
                     body_h=servo_driver_hat_header_height);
          }
        }
      }
    }
  }
}

servo_driver_hat();
