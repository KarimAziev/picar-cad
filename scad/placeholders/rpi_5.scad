/**
 * Module: Raspberry Pi 5 model
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../parameters.scad>
include <../colors.scad>
use <../util.scad>

module rpi_rectangle_3d(size, r_factor=0.05, fn=40, center=false) {
  linear_extrude(height=size[2], center=center) {
    rounded_rect(size=[size[0], size[1]],
                 r=min(size[0], size[1]) * r_factor, fn=fn);
  }
}

module io_controller(size=rpi_io_size) {
  color(matte_black, alpha=1) {
    rpi_rectangle_3d(size);
  }
}

module wifi_bt(size=rpi_wifi_bt_size) {
  color(metalic_silver_1, alpha=1) {
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
      color(metalic_yellow_silver_2) {
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
      color(metalic_yellow_silver_2) {
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

module bcm_processor_base(size=rpi_processor_size) {

  union() {
    rpi_rectangle_3d(size=size, r_factor=0.06);
    step = 5;
    small_size_x = size[0] - step;
    translate([step / 2, 0, 0]) {

      rpi_rectangle_3d(size=[small_size_x, size[1], size[2] + 1],
                       r_factor=0);
    }
  }
}

module bcm_processor(size=rpi_processor_size) {

  color(metalic_yellow_silver_2, alpha=1) {
    if (rpi_model_detailed) {
      offset_3d(r=0.8, size=rpi_processor_size[1]) {
        union() {
          bcm_processor_base(size=size);
        }
      }
    } else {
      bcm_processor_base(size=size);
    }
  }
}

module pin_headers(cols=20,
                   rows=2,
                   header_width=rpi_pin_header_width,
                   header_height=rpi_pin_header_height,
                   pin_height=rpi_pin_height,
                   p=0.65) {
  for (y = [0 : (cols -1)]) {
    for (x = [0 : (rows  - 1)]) {
      translate([header_width * x, header_width * y, 0]) {
        union() {
          color(matte_black) {
            cube([header_width, header_width, header_height]);
          }
          color(metalic_yellow_1) {
            translate([(header_width - p) / 2,
                       (header_width - p) / 2,
                       -rpi_thickness / 2 - 0.5]) {
              cube([p, p, pin_height]);
            }
          }
        }
      }
    }
  }
}

module usb_jack_base(size=rpi_usb_c_jack_size) {
  difference() {
    linear_extrude(height=size[2], center=false) {
      rounded_rect([size[0], size[1]], center=true,
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

module pci_connector(size=rpi_pci_size) {
  union() {
    extra_x = 2;
    cube(size, center=false);
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

function rpi_5_screws_offset() = m25_hole_dia + 0.4;

module rpi_usb_hdmi_connectors() {
  x_offst = 2;
  uart_x_offst = -rpi_micro_hdmi_jack_size[0] / 2 + x_offst / 2;
  translate([rpi_width - rpi_usb_c_jack_size[0] / 2 + x_offst,
             rpi_usb_c_jack_size[1] / 2 + m25_hole_dia * 2 + 0.8,
             0]) {
    usb_jack();
    translate([uart_x_offst,
               rpi_usb_c_jack_size[1] / 2 +
               rpi_rtc_connector_size[1] / 2, 0]) {
      rtc_battery_connector();
    }
    translate([0,
               rpi_usb_c_jack_size[1],
               0]) {
      translate([0,  rpi_micro_hdmi_jack_size[1], 0]) {
        micro_hdmi_jack();
        translate([-rpi_usb_c_jack_size[0], -rpi_micro_hdmi_jack_size[1] / 2,
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
                   - rpi_uart_connector_size[1] / 2, 0]) {
          uart_connector();
        }
        translate([0, rpi_micro_hdmi_jack_size[0]
                   + rpi_uart_connector_size[1] + 1.2, 0]) {
          micro_hdmi_jack();
        }
      }
    }
  }
}

module rpi_standoffs(standoff_height=10,
                     standoff_lower_height=4) {
  color("gold", alpha=1) {
    translate([0, 0, -standoff_height]) {
      linear_extrude(height=standoff_height, center=false) {
        translate([rpi_5_screws_offset(), rpi_5_screws_offset(), 0]) {
          four_corner_holes_2d(size=rpi_screws_size,
                               center=false,
                               hole_dia=m2_hole_dia);
        }
      }
    }
    translate([0, 0, -standoff_height - standoff_lower_height]) {
      linear_extrude(height=standoff_lower_height, center=false) {
        translate([rpi_5_screws_offset(), rpi_5_screws_offset(), 0]) {
          four_corner_holes_2d(size=rpi_screws_size,
                               center=false,
                               hole_dia=m2_hole_dia / 2);
        }
      }
    }
    translate([rpi_5_screws_offset(), rpi_5_screws_offset(), 0]) {
      linear_extrude(height=standoff_lower_height, center=false) {
        four_corner_holes_2d(size=rpi_screws_size,
                             center=false,
                             hole_dia=m2_hole_dia / 2);
      }
    }
  }
}

module rpi_5(show_standoffs=false,
             standoff_height=10,
             standoff_lower_height=4) {
  hole_offst = 0.4;
  union() {
    color(green_3, alpha=1) {
      linear_extrude(height=rpi_thickness, center=false) {
        difference() {
          rounded_rect([rpi_width, rpi_len], r=rpi_offset_rad);
          translate([rpi_5_screws_offset(), rpi_5_screws_offset(), 0]) {
            four_corner_holes_2d(size=rpi_screws_size,
                                 center=false,
                                 hole_dia=m25_hole_dia);
          }
        }
      }
    }
    if (show_standoffs) {
      rpi_standoffs(standoff_height=standoff_height,
                    standoff_lower_height=standoff_lower_height);
    }

    translate([0, 0, rpi_thickness / 2]) {
      translate([0, m25_hole_dia * 2 + hole_offst * 2, 0]) {
        pin_headers();
        translate([rpi_pin_header_width * 2 + 1,
                   0,
                   rpi_thickness / 2]) {
          wifi_bt();
        }
      }
    }
    translate([0, 0, rpi_thickness]) {
      color(yellow_3, alpha=1) {
        linear_extrude(height=0.1, center=false) {
          for (x_ind = [0, 1])
            for (y_ind = [0, 1]) {
              x_pos = x_ind * rpi_screws_size[0];
              y_pos = y_ind * rpi_screws_size[1];
              translate([x_pos + m25_hole_dia + hole_offst,
                         y_pos + m25_hole_dia + hole_offst]) {
                ring_2d(r=m25_hole_dia / 2, w=1,
                        outer=true,
                        fn=40);
              }
            }
        }
      }
      translate([rpi_pin_header_width * 2 + rpi_ram_size[1] + 2,
                 rpi_pin_header_width * 10,
                 0]) {
        bcm_processor();
      }

      translate([rpi_pin_header_width * 2 + 5, rpi_pin_header_width * 10, 0]) {
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
        translate([0, rpi_len - rpi_usb_size[1] + offst, rpi_thickness]) {
          usb();
          translate([rpi_usb_size[0] + 5, 0, 0]) {
            usb();

            translate([0, -rpi_usb_size[1], 0]) {
              io_controller();
            }
          }
        }
        translate([(rpi_usb_size[0] + 5) * 2, rpi_len
                   - rpi_ethernet_jack_size[1]
                   + offst, 0]) {
          ethernet();
        }
      }
      rpi_usb_hdmi_connectors();

      translate([rpi_screws_size[0]
                 - rpi_csi_size[0] / 2 - 2,
                 rpi_screws_size[1] -
                 m25_hole_dia - 1,
                 0]) {
        csi_camera_connector(size=rpi_csi_size);
        translate([0, -rpi_csi_size[1] - 3, 0]) {
          csi_camera_connector(size=rpi_csi_size);
        }
      }
      translate([rpi_width / 2 - rpi_pci_size[0] / 2, 0,
                 0]) {
        pci_connector();
        translate([rpi_pci_size[0] + 7,
                   rpi_on_off_button_size[1] +
                   rpi_on_off_button_dia / 2 - 0.2,
                   rpi_thickness]) {
          on_off_buton();
        }
      }
    }
  }
}

rpi_5(show_standoffs=true);
