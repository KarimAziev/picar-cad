/**

 * Module: Raspberry Pi 5 model
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../colors.scad>
include <../parameters.scad>

use <../lib/holes.scad>
use <../lib/shapes2d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <ai_hat.scad>
use <bcm.scad>
use <gpio_expansion_board.scad>
use <motor_driver_hat.scad>
use <pad_hole.scad>
use <pin_header.scad>
use <servo_driver_hat.scad>
use <standoff.scad>

show_standoffs            = true;
show_ai_hat               = true;
show_motor_driver_hat     = true;
show_servo_driver_hat     = true;
show_gpio_expansion_board = true;

module io_controller(size=rpi_io_size) {
  color(matte_black, alpha=1) {
    rpi_rectangle_3d(size);
  }
}

module wifi_bt(size=rpi_wifi_bt_size) {
  color(metallic_silver_1, alpha=1) {
    rpi_rectangle_3d(size);
  }
}

module ethernet(size=rpi_ethernet_jack_size) {
  hole_x_factor = 0.9;
  hole_y_factor = 0.2;
  hole_z_factor = 0.8;
  hole_x = size[0] * hole_x_factor;
  hole_y = size[1] * hole_y_factor;
  hole_z = size[2] * hole_z_factor;
  x_offst = ((1 - hole_x_factor) * size[0]) / 2;
  y_offst = ((1 - hole_y_factor) * size[1]) + 1;
  z_offst = size[2] - hole_z - 1;
  union() {
    difference() {
      color(metallic_yellow_silver) {
        linear_extrude(height=size[2], center=false) {
          rounded_rect(size=size, r=min(size[1], size[2]) * 0.1, center=false);
        }
      }
      translate([x_offst, y_offst, size[2] - hole_z - 0.5]) {
        linear_extrude(height=hole_z, center=false) {
          rounded_rect(size=[hole_x, hole_y], r=0.5, center=false);
        }
      }
    }

    color(matte_black, alpha=1) {
      translate([x_offst, y_offst, z_offst]) {
        linear_extrude(height=hole_z, center=false) {
          square(size=[hole_x, 1], center=false);
        }
      }
    }
  }
}

module usb(size=rpi_usb_size) {
  hole_x_factor = 0.9;
  hole_y_factor = 0.2;
  hole_z_factor = 0.4;
  hole_x = size[0] * hole_x_factor;
  hole_y = size[1] * hole_y_factor;
  hole_z = size[2] * hole_z_factor;
  x_offst = ((1 - hole_x_factor) * size[0]) / 2;
  y_offst = ((1 - hole_y_factor) * size[1]) + 1;

  union() {
    difference() {
      color(metallic_yellow_silver) {
        linear_extrude(height=size[2], center=false) {
          rounded_rect(size=size, r=1.5, center=false);
        }
      }
      translate([x_offst, y_offst, size[2] - hole_z - 0.5]) {
        linear_extrude(height=hole_z, center=false) {
          rounded_rect(size=[hole_x, hole_y], r=0.5, center=false);
        }
      }
      translate([x_offst, y_offst, 0.5]) {
        linear_extrude(height=hole_z, center=false) {
          rounded_rect(size=[hole_x, hole_y], r=0.5, center=false);
        }
      }
    }
    color(matte_black, alpha=1) {
      translate([x_offst, 1, size[2] - (hole_z_factor * 2) - 2]) {
        linear_extrude(height=1.5, center=false) {
          square(size=[hole_x, size[1] - 1], center=false);
        }
      }
    }
    color(matte_black, alpha=1) {
      translate([x_offst, 1, hole_z - 1.5]) {
        linear_extrude(height=1.5, center=false) {
          square(size=[hole_x, size[1] - 1], center=false);
        }
      }
    }
    color(matte_black, alpha=0.9) {
      translate([x_offst, y_offst, 1]) {
        linear_extrude(height=hole_z * 2, center=false) {
          square(size=[hole_x, 1], center=false);
        }
      }
    }
  }
}

module ram_2d(size=rpi_ram_size) {
  rounded_rect(size=size, r=1.5, center=false);
}

module ram(size=rpi_ram_size) {
  color(matte_black, alpha=1) {
    rpi_rectangle_3d(size=size, r_factor=0);
  }
}

module usb_jack_base(size=rpi_usb_c_jack_size) {
  difference() {
    linear_extrude(height=size[2], center=false) {
      rounded_rect([size[0], size[1]],
                   center=true,
                   r=min(size[0], size[1]) * 0.1);
    }
    translate([size[0] * 0.1 + 1, 0, size[2] * 0.1]) {
      linear_extrude(height=size[2] * 0.8, center=false) {
        square([size[0] * 0.8, size[1] * 0.9], center=true);
      }
    }
  }
}

module usb_jack(size=rpi_usb_c_jack_size) {
  union() {
    color("silver", alpha=1) {
      usb_jack_base();
    }
    color(matte_black, alpha=1) {
      translate([size[0] * 0.05, 0, size[2] * 0.1]) {
        linear_extrude(height=size[2] * 0.8, center=false) {
          square([size[0] * 0.8, size[1] * 0.9], center=true);
        }
      }
    }
  }
}

module micro_hdmi_jack(size=rpi_micro_hdmi_jack_size) {
  usb_jack(size);
}

module rtc_battery_connector(size=rpi_rtc_connector_size) {
  if (rpi_model_detailed) {
    difference() {
      hole_w = size[0] * 0.6;
      hole_h = size[1] * 0.8;
      linear_extrude(height=size[2], center=false) {
        square([size[0], size[1]], center=false);
      }

      translate([hole_w / 2,
                 (size[1] - hole_h) / 2,
                 size[2] - size[2] / 2 + 1]) {
        linear_extrude(height=size[2] * 0.5, center=false) {
          square([hole_w, hole_h],
                 center=false);
        }
      }
    }
  } else {
    linear_extrude(height=size[2], center=false) {
      square([size[0], size[1]], center=false);
    }
  }
}

module uart_connector(size=rpi_uart_connector_size) {
  rtc_battery_connector(size);
}

module pci_connector(size=rpi_pci_size, extra_x=2) {
  union() {
    color(metallic_yellow_silver_2, alpha=1) {
      cube(size, center=false);
    }
    translate([-extra_x / 2, 0, size[2]]) {
      color(jet_black, alpha=1) {
        linear_extrude(height=1, center=false) {
          difference() {
            rounded_rect([size[0] + extra_x, size[1]]);
            translate([extra_x / 2, size[1] / 2, 0]) {
              square([size[0], size[1]]);
            }
          }
        }
      }
    }
  }
}

module csi_camera_connector(size=rpi_csi_size) {
  pci_connector(size=size);
}

module on_off_buton(size=rpi_on_off_button_size,
                    dia=rpi_on_off_button_dia) {
  rotate([90, 0, 0]) {
    union() {
      color(matte_black, alpha=1) {
        linear_extrude(height=size[2], center=false) {
          square([size[0], size[1]], center=true);
        }
      }
      linear_extrude(height=size[2] + 0.8, center=false) {
        circle(r=dia / 2, $fn=8);
      }
    }
  }
}

module rpi_usb_hdmi_connectors() {
  x_offst = 2;
  uart_x_offst = -rpi_micro_hdmi_jack_size[0] / 2 + x_offst / 2;
  translate([rpi_width - rpi_usb_c_jack_size[0] / 2 + x_offst,
             rpi_usb_c_jack_size[1] / 2 + m25_hole_dia * 2 + 0.8,
             0]) {
    usb_jack();
    translate([uart_x_offst,
               rpi_usb_c_jack_size[1] / 2 +
               rpi_rtc_connector_size[1] / 2,
               0]) {
      color(metallic_yellow_silver_2, alpha=1) {
        rtc_battery_connector();
      }
    }
    translate([0,
               rpi_usb_c_jack_size[1],
               0]) {
      translate([0,  rpi_micro_hdmi_jack_size[1], 0]) {
        micro_hdmi_jack();
        translate([-rpi_usb_c_jack_size[0],
                   -rpi_micro_hdmi_jack_size[1] / 2,
                   0]) {
          rotate([0, 0, 90]) {
            color("white", alpha=1) {
              linear_extrude(height=0.1, center=false) {
                text("HDMI",
                     size=4,
                     font=rpi_text_font,
                     halign="left",
                     valign="center");
              }
            }
          }
        }
        translate([uart_x_offst + 1,
                   rpi_micro_hdmi_jack_size[1]
                   - rpi_uart_connector_size[1] / 2,
                   0]) {
          color(metallic_yellow_silver_2, alpha=1) {
            uart_connector();
          }
        }
        translate([0,
                   rpi_micro_hdmi_jack_size[0]
                   + rpi_uart_connector_size[1] + 1.2,
                   0]) {
          micro_hdmi_jack();
        }
      }
    }
  }
}

module rpi_standoffs(standoff_height=rpi_standoff_height,
                     bolt_visible_h) {
  show_bolt = !is_undef(bolt_visible_h);

  translate([rpi_bolts_offset, rpi_bolts_offset, -standoff_height]) {
    four_corner_children(size=rpi_bolt_spacing,
                         center=false) {

      standoffs_stack(d=m2_hole_dia,
                      min_h=standoff_height,
                      thread_at_top=true,
                      show_bolt=show_bolt,
                      bolt_visible_h=bolt_visible_h);
    }
  }
}

module rpi_5(size=[rpi_width, rpi_len, rpi_thickness],
             bolt_spacing=rpi_bolt_spacing,
             corner_rad=rpi_offset_rad,
             slot_thickness=chassis_thickness,
             mount_dia=rpi_bolt_hole_dia,
             placeholder_hole_dia=2.5,
             bolt_offset=rpi_bolts_offset,
             header_height=rpi_pin_header_height,
             header_width=rpi_pin_header_width,
             pin_height=rpi_pin_height,
             header_cols=rpi_pin_headers_cols,
             header_rows=rpi_pin_headers_rows,
             show_standoffs=show_standoffs,
             show_ai_hat=show_ai_hat,
             show_motor_driver_hat=show_motor_driver_hat,
             show_servo_driver_hat=show_servo_driver_hat,
             show_gpio_expansion_board=show_gpio_expansion_board,
             pad_hole_specs=rpi_pad_hole_specs,
             usb_size=rpi_usb_size,
             csi_size=rpi_csi_size,
             io_size=rpi_io_size,
             wifi_bt_size=rpi_wifi_bt_size,
             pci_size=rpi_pci_size,
             on_off_button_size=rpi_on_off_button_size,
             on_off_button_dia=rpi_on_off_button_dia,
             ethernet_jack_size=rpi_ethernet_jack_size,
             standoff_height=rpi_standoff_height,
             bolt_visible_h=chassis_thickness - chassis_counterbore_h,
             slot_mode=false) {
  w = size[0];
  length = size[1];
  h = size[2];
  if (slot_mode) {
    translate([bolt_offset, bolt_offset, 0]) {
      four_corner_children(bolt_spacing,
                           center=false) {
        counterbore(d=mount_dia,
                    h=slot_thickness,
                    bore_h=chassis_counterbore_h,
                    bore_d=rpi_bolt_cbore_dia,
                    autoscale_step=0.1,
                    sink=true,
                    reverse=true);
      }
    }
  }
  else {
    translate([0, 0, show_standoffs ? standoff_height + bolt_visible_h : 0]) {
      union() {
        union() {
          color(green_3, alpha=1) {
            linear_extrude(height=h, center=false) {
              difference() {
                rounded_rect([w, length], r=corner_rad);
                translate([bolt_offset, bolt_offset, 0]) {
                  four_corner_holes_2d(size=bolt_spacing,
                                       center=false,
                                       hole_dia=placeholder_hole_dia);
                }
              }
            }
          }
          if (show_standoffs) {
            rpi_standoffs(standoff_height=standoff_height,
                          bolt_visible_h=bolt_visible_h);
          }

          translate([0, 0, h]) {
            translate([0, bolt_offset * 2, 0]) {
              pin_header(cols=header_cols,
                         rows=header_rows,
                         header_width=header_width,
                         header_height=header_height,
                         pin_height=pin_height,
                         z_offset=h + 0.5,
                         p=0.65,
                         center=false);
              translate([header_width * 2 + 1, 0, 0]) {
                wifi_bt(size=wifi_bt_size);
              }
            }
          }
          translate([0, 0, h]) {
            color(yellow_3, alpha=1) {
              translate([bolt_offset, bolt_offset, 0]) {
                four_corner_children(size=bolt_spacing, center=false) {
                  pad_hole(bolt_d=placeholder_hole_dia,
                           specs=pad_hole_specs,
                           thickness=0.1);
                }
              }
            }
            translate([header_width * 2 + rpi_ram_size[1] + 2,
                       header_width * 10,
                       0]) {
              bcm_processor();
            }

            translate([header_width * 2 + 5,
                       header_width * 10,
                       0]) {
              ram();
              translate([-1, 0, 0]) {
                color("white", alpha=1) {
                  rotate([0, 0, 90]) {
                    linear_extrude(height=0.1, center=false) {
                      text(rpi_model_text,
                           size=2,
                           font=rpi_text_font,
                           valign="bottom");
                    }
                  }
                }
              }
            }
            union() {
              offst = 3;
              translate([0, length - usb_size[1] + offst, h]) {
                usb(size=usb_size);
                translate([usb_size[0] + 5, 0, 0]) {
                  usb(size=usb_size);

                  translate([0, -usb_size[1], 0]) {
                    io_controller(size=io_size);
                  }
                }
              }
              translate([(usb_size[0] + 5) * 2,
                         length
                         - ethernet_jack_size[1]
                         + offst,
                         0]) {
                ethernet(size=ethernet_jack_size);
              }
            }
            rpi_usb_hdmi_connectors();

            translate([rpi_csi_position_x, rpi_csi_position_y, 0]) {
              csi_camera_connector(size=csi_size);
              translate([0, -csi_size[1] - 3, 0]) {
                csi_camera_connector(size=csi_size);
              }
            }
            translate([w / 2 - pci_size[0] / 2,
                       0,
                       0]) {
              pci_connector(size=pci_size);
              translate([pci_size[0] + 7,
                         rpi_on_off_button_size[1] +
                         rpi_on_off_button_dia / 2 - 0.2,
                         h]) {
                on_off_buton(size=on_off_button_size,
                             dia=on_off_button_dia);
              }
            }
          }
        }

        translate([0,
                   0,
                   header_height + (h / 2) +
                   (show_ai_hat
                    ? ai_hat_header_height : 0)]) {
          if (show_ai_hat) {
            ai_hat(center=false);
          }
          translate([0,
                     0,
                     (show_servo_driver_hat
                      ? servo_driver_hat_header_height
                      : 0)
                     + (show_ai_hat ? ai_hat_size[2]
                        : 0)]) {
            if (show_servo_driver_hat) {
              servo_driver_hat(center=false);
            }

            translate([0,
                       0,
                       (show_motor_driver_hat
                        ? motor_driver_hat_lower_header_height
                        : 0) +
                       (show_servo_driver_hat
                        ? servo_driver_hat_size[2]
                        : 0)]) {

              if (show_motor_driver_hat) {
                motor_driver_hat(center=false,
                                 show_upper_pin_header=show_gpio_expansion_board,
                                 show_lower_pin_header=true,
                                 extra_standoff_h=motor_driver_hat_upper_header_height);
              }
              let (extra_upper_header_height = show_motor_driver_hat
                   ? motor_driver_hat_upper_header_height
                   + motor_driver_hat_size[2]
                   : 0) {
                translate([0,
                           0,
                           (show_gpio_expansion_board
                            ? gpio_expansion_header_height
                            : 0) + extra_upper_header_height]) {
                  if (show_gpio_expansion_board) {
                    gpio_expansion_board(center=false,
                                         show_nut=true,
                                         extra_standoff_h=extra_upper_header_height);
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

rpi_5(show_standoffs=show_standoffs,
      show_ai_hat=show_ai_hat,
      bolt_visible_h=chassis_thickness - chassis_counterbore_h);
