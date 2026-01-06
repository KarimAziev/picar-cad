include <../parameters.scad>
use <../lib/shapes2d.scad>
use <../lib/holes.scad>
use <smd/smd_chip.scad>
use <../lib/transforms.scad>
use <../lib/shapes3d.scad>
use <../lib/functions.scad>

use <pin_header.scad>
use <screw_terminal.scad>
use <../lib/placement.scad>
use <pad_hole.scad>
use <../lib/plist.scad>

// [...[diameter, color]]
ina260_mounting_hole_pad_spec             = [[3.4, yellow_3],
                                             [4.0, "white"]];
ina260_mounting_hole_distance             = 1.5;

ina260_corner_rad                         = 3;

ina260_chip_size                          = [4.4, 5.1, 0.8];
ina260_chip_jlead_x_len                   = 1.47;
ina260_chip_jlead_lower_lead_fraction     = 0.8; // [0.0:1.0]
ina260_chip_jlead_thickness               = 0.2;
ina260_chip_y_offset                      = 7.7;
ina260_chip_pin_count                     = 8;

ina260_pin_step                           = 2.54;

ina260_pin_d                              = 1;
// [...[diameter, color]]
ina260_pin_hole_pad_spec                  = [[1.7, yellow_3]];
ina260_pin_hole_y_offset                  = 1.4;

ina260_pad_holes_text_specs               = [["Vcc", "top"],
                                             ["GND", "bottom"],
                                             ["SCL", "top"],
                                             ["SDA", "bottom"],
                                             ["Alert", "top"],
                                             ["VBus", "bottom"],
                                             ["Vin+", "top"],
                                             ["Vin-", "bottom"]];

ina260_pin_holes_default_text_spec        = [0.75, "Liberation Sans:style=Bold", "white"];
ina260_power_pad_texts                    = [["Vin+", "top", "right", 90, [-4.4, 2.06, 0]],
                                             ["Vin-", "top", "left", 90, [2.8, -2.5, 0]]];

ina260_top_texts                          = [["INA260", "top", "right", 90,
                                              [6.4, 2.06, 0],
                                              1.75,
                                              "Liberation Sans:style=Bold",
                                              "white"],
                                             ["Power Sensor", "top", "right", 90,
                                              [8.7, 4.5, 0],
                                              1.4,
                                              "Liberation Sans:style=Bold", "white"],
                                             ["I2C", "top", "right",
                                              0,
                                              [-7.2, 3.8, 0],
                                              1.0,
                                              "Liberation Sans:style=Bold", "white"],
                                             ["Addr", "top", "right",
                                              0,
                                              [-7.2, 2.0, 0],
                                              0.9,
                                              "Liberation Sans:style=Bold", "white"]];
ina260_bottom_texts                       = [["INA260 Precision DC",
                                              "top",
                                              "right",
                                              0,
                                              [9.7, 3.5, 0],
                                              1.45,
                                              "Liberation Sans:style=Bold",
                                              "white"],
                                             ["Current/Power Monitor",
                                              "top",
                                              "right",
                                              0,
                                              [10.9, 1.5, 0],
                                              1.30,
                                              "Liberation Sans:style=Bold",
                                              "white",
                                              1.15],
                                             ["Bus voltage: 0-36V",
                                              "top",
                                              "right",
                                              0,
                                              [5, -1.5, 0],
                                              1.30,
                                              "Liberation Sans:style=Bold",
                                              "white",],
                                             ["Max Current: 15A",
                                              "top",
                                              "right",
                                              0,
                                              [4, -3.5, 0],
                                              1.30,
                                              "Liberation Sans:style=Bold",
                                              "white",],
                                             ["VCC/Logic: 3-5V",
                                              "top",
                                              "right",
                                              0,
                                              [3.4, -5.5, 0],
                                              1.30,
                                              "Liberation Sans:style=Bold",
                                              "white",]];

ina260_screw_terminal_thickness           = 5.8;
ina260_screw_terminal_base_h              = 6.8;              // base height (Z)
ina260_screw_terminal_top_l               = 4.50;              // top trapezoid top side length
ina260_screw_terminal_top_h               = 3.2;               // top trapezoid height
ina260_screw_terminal_contacts_n          = 2;            // number of contact boxes
ina260_screw_terminal_contact_w           = 3.5;           // contact box width (X)
ina260_screw_terminal_contact_h           = 4.47;          // contact box height (Z)
ina260_screw_terminal_pitch               = 5.0;              // center-to-center spacing (X)
ina260_screw_terminal_colr                = matte_black;

ina260_screw_terminal_pin_thickness       = 0.4;       // lower thin pin cross/width
ina260_screw_terminal_pin_h               = 3.9;               // lower thin pin height
ina260_screw_terminal_wall_thickness      = 0.6;  // wall offset from base top
ina260_screw_terminal_isosceles_trapezoid = true;

ina260_pin_height                         = 11.45;
ina260_pin_thickness                      = 0.40;
ina260_pin_header_height                  = 2.45;
ina260_pin_header_thickness               = 2.45;
ina260_pin_header_z_offset=4;

ina260_power_pad_pin_hole_d               = 0.8;
ina260_power_pad_d                        = 2.4;
ina260_power_pad_len                      = 2.5;
ina260_power_pad_colr                     = metallic_yellow_1;
ina260_power_pad_y_offset                 = 1.5;
ina260_power_pad_x_offset                 = 2.54;
ina260_power_pad_border_w                 = 0.4;

ina260_power_rect_padding                 = [3.0, 1.4];
ina260_power_pad_text_spec                = [1.6, "Liberation Sans:style=Bold", "white"];
ina260_i2c_addr_specs                     = [[[3.0, 1.8, 0.2, 0], [3.5, 2, 1.5]],
                                             [[3.0, 1.8, 0.2, 0], [3.5, 2, 1.0]]];
ina260_i2c_addr_text_spec                 = [0.9, "Liberation Sans:style=Bold", "white"];
ina260_show_pins                          = true;
ina260_show_terminal                      = true;

ina_plist                                 = ["placeholder_size", ina260_size,
                                             "slot_size", ina260_bolt_spacing,
                                             "d", ina260_bolt_dia,
                                             "corner_rad", ina260_corner_rad,
                                             "pad_hole_spec", ina260_mounting_hole_pad_spec,
                                             "pin_holes_text_specs", ina260_pad_holes_text_specs,
                                             "default_pin_text_spec", ina260_pin_holes_default_text_spec,
                                             "chip_size", ina260_chip_size,
                                             "chip_jlead_lower_lead_fraction", ina260_chip_jlead_lower_lead_fraction,
                                             "chip_jlead_thickness", ina260_chip_jlead_thickness,
                                             "chip_y_offset", ina260_chip_y_offset,
                                             "chip_jlead_count", ina260_chip_pin_count,
                                             "pin_hole_d", ina260_pin_d,
                                             "pin_hole_pad_spec", ina260_pin_hole_pad_spec,
                                             "pin_step", ina260_pin_step,
                                             "pin_y_offset", ina260_pin_hole_y_offset,
                                             "pin_height", ina260_pin_height,
                                             "pin_thickness", ina260_pin_thickness,
                                             "pin_header_height", ina260_pin_header_height,
                                             "pin_header_thickness", ina260_pin_header_thickness,
                                             "pin_header_z_offset", ina260_pin_header_z_offset,
                                             "top_texts", ina260_top_texts,
                                             "bottom_texts", ina260_bottom_texts,
                                             "power_pad", ["pin_hole_d", ina260_power_pad_pin_hole_d,
                                                           "d", ina260_power_pad_d,
                                                           "len", ina260_power_pad_len,
                                                           "colr", ina260_power_pad_colr,
                                                           "y_offset", ina260_power_pad_y_offset,
                                                           "x_offset", ina260_power_pad_x_offset,
                                                           "border_w", ina260_power_pad_border_w,
                                                           "pad_texts", ina260_power_pad_texts,
                                                           "rect_padding", ina260_power_rect_padding,
                                                           "text_spec", ina260_power_pad_text_spec],
                                             "i2c_addr_specs", ina260_i2c_addr_specs,
                                             "i2c_addr_text_spec", ina260_i2c_addr_text_spec,
                                             "show_pins", ina260_show_pins,
                                             "show_terminal", ina260_show_terminal];

module ina260(size=ina260_size,
              bolt_spacing=ina260_bolt_spacing,
              bolt_d=ina260_bolt_dia,
              corner_rad=ina260_corner_rad,
              pad_hole_spec=ina260_mounting_hole_pad_spec,
              pin_holes_text_specs=ina260_pad_holes_text_specs,
              default_pin_text_spec=ina260_pin_holes_default_text_spec,
              chip_size=ina260_chip_size,
              chip_jlead_lower_lead_fraction=ina260_chip_jlead_lower_lead_fraction,
              chip_jlead_thickness=ina260_chip_jlead_thickness,
              chip_y_offset=ina260_chip_y_offset,
              chip_jlead_count=ina260_chip_pin_count,
              pin_hole_d=ina260_pin_d,
              pin_hole_pad_spec=ina260_pin_hole_pad_spec,
              pin_step=ina260_pin_step,
              pin_y_offset=ina260_pin_hole_y_offset,
              pin_height=ina260_pin_height,
              pin_thickness=ina260_pin_thickness,
              pin_header_height=ina260_pin_header_height,
              pin_header_thickness=ina260_pin_header_thickness,
              pin_header_z_offset=ina260_pin_header_z_offset,
              top_texts=ina260_top_texts,
              bottom_texts=ina260_bottom_texts,
              power_pad_pin_hole_d=ina260_power_pad_pin_hole_d,
              power_pad_d=ina260_power_pad_d,
              power_pad_len=ina260_power_pad_len,
              power_pad_colr=ina260_power_pad_colr,
              power_pad_y_offset=ina260_power_pad_y_offset,
              power_pad_x_offset=ina260_power_pad_x_offset,
              power_pad_border_w=ina260_power_pad_border_w,
              power_pad_texts=ina260_power_pad_texts,
              power_rect_padding=ina260_power_rect_padding,
              power_pad_text_spec=ina260_power_pad_text_spec,
              i2c_addr_specs=ina260_i2c_addr_specs,
              i2c_addr_text_spec=ina260_i2c_addr_text_spec,
              show_pins=ina260_show_pins,
              show_terminal=ina260_show_terminal) {
  xsize = size[0];
  ysize = size[1];
  thickness = size[2];

  chip_xsize                            = chip_size[0];
  chip_ysize                            = chip_size[1];
  chip_thickness                        = chip_size[2];

  pin_hole_largest_pad_spec = sort_by_idx(elems=pin_hole_pad_spec,
                                          idx=0,
                                          asc=false)[0];
  pin_d = pin_hole_largest_pad_spec[0];

  pin_gap = pin_step - pin_d;

  mounting_hole_y_offset = ysize / 2
    - bolt_d / 2
    - ina260_mounting_hole_distance;
  union() {
    difference() {
      union() {
        color(medium_blue_2, alpha=1) {
          linear_extrude(height=thickness, center=false, convexity=3) {
            difference() {
              rounded_rect(size=[xsize, ysize, thickness],
                           r=corner_rad,
                           center=true,
                           fn=100);
              translate([0,
                         mounting_hole_y_offset,
                         0]) {
                four_corner_holes_2d(size=bolt_spacing,
                                     hole_dia=bolt_d,
                                     center=true);
              }
            }
          }
        }

        translate([0,
                   -ysize / 2 + chip_ysize / 2 + chip_y_offset,
                   thickness]) {
          rotate([0, 0, 90]) {
            smd_chip(length=chip_ysize,
                     w=chip_xsize,
                     j_lead_n=chip_jlead_count,
                     lower_lead_fraction=chip_jlead_lower_lead_fraction,
                     j_lead_thickness=chip_jlead_thickness,
                     total_w=chip_xsize + (ina260_chip_jlead_x_len * 2),
                     h=chip_thickness,
                     center=true);
          }
        }
        translate([0, mounting_hole_y_offset, 0]) {
          four_corner_children(size=bolt_spacing, center=true) {
            pad_hole(bolt_d=bolt_d,
                     thickness=thickness,
                     specs=pad_hole_spec);
          }
        }

        if (len(i2c_addr_specs) > 0) {
          translate([-xsize / 2,
                     -ysize / 2 +
                     pin_d / 2 + pin_y_offset +
                     i2c_addr_specs[0][0][1],
                     thickness]) {
            color(metallic_yellow_1, alpha=1) {
              rounded_rect_slots(specs=i2c_addr_specs,
                                 thickness=0.1,
                                 center=false,
                                 default_r_tolerance=0);
            }

            color(i2c_addr_text_spec[2], alpha=1) {
              rounded_rect_slots(specs=i2c_addr_specs,
                                 thickness=0.1,
                                 center=false,
                                 default_r_tolerance=0) {
                rotate([0, 0, 90]) {
                  let (txt = str("A", $i),
                       size=i2c_addr_text_spec[0],
                       tm=textmetrics(text=txt,
                                      size=size,
                                      font=i2c_addr_text_spec[1])) {
                    translate([0, tm.size[1] / 2, 0]) {

                      linear_extrude(height=0.01, center=false) {
                        text(txt, size=size, valign="bottom");
                      }
                    }
                  }
                }
              }
            }
          }
        }

        let (full_len = power_pad_len + power_pad_d,
             y_offset = ysize / 2 - full_len / 2 - power_pad_y_offset) {
          for (i = [0 : 1]) {
            let (txt_spec=power_pad_texts[i]) {
              translate([i == 0
                         ? -power_pad_x_offset
                         : power_pad_x_offset,
                         y_offset,
                         -0.1]) {
                color(power_pad_colr, alpha=1) {
                  linear_extrude(height=thickness + 0.2,
                                 center=false,
                                 convexity=2) {
                    capsule(y=power_pad_len, d=power_pad_d);
                  }
                }

                if (!is_undef(txt_spec)) {
                  let (txt=txt_spec[0],
                       txt_valigh=txt_spec[1],
                       txt_haligh=txt_spec[2],
                       z_rotation=txt_spec[3],
                       translation=txt_spec[4]) {
                    translate(translation) {
                      translate([0, 0, thickness]) {
                        color(power_pad_text_spec[2], alpha=1) {
                          rotate([0, 0, z_rotation]) {
                            linear_extrude(height=0.15,
                                           center=false,
                                           convexity=2) {
                              text(txt,
                                   size=power_pad_text_spec[0],
                                   valign=txt_valigh,
                                   halign=txt_haligh,
                                   font=power_pad_text_spec[1]);
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
          color(power_pad_text_spec[2], alpha=1) {
            let (x_size = power_pad_x_offset * 2 + power_pad_d
                 + power_rect_padding[0],
                 y_size = power_pad_y_offset + full_len
                 + power_pad_border_w + power_rect_padding[1],
                 y_offset=ysize / 2 - y_size / 2) {
              translate([0, y_offset, thickness]) {
                linear_extrude(height=0.05, center=false) {
                  difference() {
                    square([x_size, y_size], center=true);
                    translate([0, power_pad_border_w / 2, 0]) {
                      square([x_size - power_pad_border_w, y_size],
                             center=true);
                    }
                  }
                }
              }
            }
          }
        }

        rotate([0, 180, 0]) {
          for (txt_spec = bottom_texts) {
            let (txt=txt_spec[0],
                 txt_valigh=txt_spec[1],
                 txt_haligh=txt_spec[2],
                 z_rotation=txt_spec[3],
                 translation=txt_spec[4],
                 size=txt_spec[5],
                 font=txt_spec[6],
                 colr=txt_spec[7],
                 spacing=txt_spec[8]) {
              translate(translation) {
                color(colr, alpha=1) {
                  rotate([0, 0, z_rotation]) {
                    linear_extrude(height=0.01,
                                   center=false,
                                   convexity=2) {
                      text(txt,
                           size=size,
                           spacing=spacing,
                           valign=txt_valigh,
                           halign=txt_haligh,
                           font=colr);
                    }
                  }
                }
              }
            }
          }
        }

        for (txt_spec = top_texts) {
          let (txt=txt_spec[0],
               txt_valigh=txt_spec[1],
               txt_haligh=txt_spec[2],
               z_rotation=txt_spec[3],
               translation=txt_spec[4],
               size=txt_spec[5],
               font=txt_spec[6],
               colr=txt_spec[7]) {
            translate(translation) {
              translate([0, 0, thickness]) {
                color(colr, alpha=1) {
                  rotate([0, 0, z_rotation]) {
                    linear_extrude(height=0.01,
                                   center=false,
                                   convexity=2) {
                      text(txt,
                           size=size,
                           valign=txt_valigh,
                           halign=txt_haligh,
                           font=colr);
                    }
                  }
                }
              }
            }
          }
        }

        let (step = pin_step,
             cols = len(pin_holes_text_specs),
             total_x = cols * pin_d + (cols - 1) * pin_gap) {
          translate([-total_x / 2,
                     -ysize / 2 - pin_d / 2,
                     0]) {
            for (i = [0 : len(pin_holes_text_specs) - 1]) {
              let (text_spec = pin_holes_text_specs[i],
                   txt = text_spec[0],
                   pos=text_spec[1],
                   size=is_undef(text_spec[2])
                   ? default_pin_text_spec[0]
                   : text_spec[2],
                   font=is_undef(text_spec[3])
                   ? default_pin_text_spec[1]
                   : text_spec[3],
                   colr=is_undef(text_spec[4])
                   ? default_pin_text_spec[2]
                   : text_spec[4],
                   tm=textmetrics(text=txt,
                                  size=size,
                                  font=font),
                   bx = i * step + pin_d / 2) {

                translate([bx, pin_d + pin_y_offset, 0]) {
                  pad_hole(bolt_d=pin_hole_d,
                           thickness=thickness,
                           specs=pin_hole_pad_spec);
                  color(colr, alpha=1) {
                    translate([-tm.size[0] / 2,
                               pos == "top"
                               ? pin_d - size
                               : -pin_d,
                               thickness]) {
                      linear_extrude(height=0.1,
                                     convexity=2,
                                     center=false) {
                        text(txt,
                             size=size,
                             valign="bottom",
                             font=font);
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      let (step = pin_step,
           cols = len(pin_holes_text_specs),
           total_x = cols * pin_d + (cols - 1) * pin_gap) {
        translate([-total_x / 2,
                   -ysize / 2 - pin_d / 2,
                   -0.1]) {
          for (i = [0 : len(pin_holes_text_specs) - 1]) {
            let (bx = i * step + pin_d / 2) {

              translate([bx, pin_d + pin_y_offset, 0]) {
                cylinder(d=pin_hole_d, h=thickness + 0.2, $fn=30);
              }
            }
          }
        }
      }
      mirror_copy([1, 0, 0]) {
        let (full_len = power_pad_len + power_pad_d) {
          translate([power_pad_x_offset,
                     ysize / 2 - full_len / 2
                     - power_pad_y_offset,
                     -0.15]) {
            color(power_pad_colr, alpha=1) {
              cylinder(d=power_pad_pin_hole_d, h=thickness + 0.3, $fn=30);
            }
          }
        }
      }
    }

    if (show_terminal) {
      translate([0,
                 ysize / 2 - ina260_screw_terminal_thickness / 2
                 - power_pad_y_offset + power_pad_pin_hole_d / 2,
                 thickness]) {
        screw_terminal(thickness=ina260_screw_terminal_thickness,
                       isosceles_trapezoid=ina260_screw_terminal_isosceles_trapezoid,
                       base_h=ina260_screw_terminal_base_h,
                       top_l=ina260_screw_terminal_top_l,
                       top_h=ina260_screw_terminal_top_h,
                       contacts_n=ina260_screw_terminal_contacts_n,
                       contact_w=ina260_screw_terminal_contact_w,
                       contact_h=ina260_screw_terminal_contact_h,
                       pitch=ina260_screw_terminal_pitch,
                       colr=ina260_screw_terminal_colr,
                       pin_thickness=ina260_screw_terminal_pin_thickness,
                       pin_h=ina260_screw_terminal_pin_h,
                       wall_thickness=ina260_screw_terminal_wall_thickness);
      }
    }
    if (show_pins) {
      translate([0,
                 -ysize / 2 + pin_header_thickness / 2
                 + pin_y_offset
                 - pin_thickness,
                 thickness]) {
        rotate([0, 0, 90]) {
          pin_header(cols=8,
                      rows=1,
                      header_width=pin_header_thickness,
                      header_height=pin_header_height,
                      header_y_width=pin_step,
                      pin_height=pin_height,
                      z_offset=thickness + pin_header_z_offset,
                      center=true,
                      p=pin_thickness);
        }
      }
    }
  }
}

module ina260_screw_terminal(plist,
                             parent_size,
                             power_pad_pin_hole_d) {
  plist = with_default(plist, []);
  thickness = plist_get("thickness", plist, ina260_screw_terminal_thickness);
  isosceles_trapezoid = plist_get("isosceles_trapezoid",
                                  plist,
                                  ina260_screw_terminal_isosceles_trapezoid);
  base_h = plist_get("base_h", plist, ina260_screw_terminal_base_h);
  top_l = plist_get("top_l", plist, ina260_screw_terminal_top_l);
  top_h = plist_get("top_h", plist, ina260_screw_terminal_top_h);
  contacts_n = plist_get("contacts_n", plist, ina260_screw_terminal_contacts_n);
  contact_w = plist_get("contact_w", plist, ina260_screw_terminal_contact_w);
  contact_h = plist_get("contact_h", plist, ina260_screw_terminal_contact_h);
  pitch = plist_get("pitch", plist, ina260_screw_terminal_pitch);
  colr = plist_get("colr", plist, ina260_screw_terminal_colr);
  pin_thickness = plist_get("pin_thickness",
                            plist,
                            ina260_screw_terminal_pin_thickness);
  pin_h = plist_get("pin_h", plist, ina260_screw_terminal_pin_h);
  wall_thickness = plist_get("wall_thickness",
                             plist,
                             ina260_screw_terminal_wall_thickness);
  translate([0,
             ysize / 2 - ina260_screw_terminal_thickness / 2
             - power_pad_y_offset + power_pad_pin_hole_d / 2,
             thickness]) {
    screw_terminal(thickness=ina260_screw_terminal_thickness,
                   isosceles_trapezoid=ina260_screw_terminal_isosceles_trapezoid,
                   base_h=ina260_screw_terminal_base_h,
                   top_l=ina260_screw_terminal_top_l,
                   top_h=ina260_screw_terminal_top_h,
                   contacts_n=ina260_screw_terminal_contacts_n,
                   contact_w=ina260_screw_terminal_contact_w,
                   contact_h=ina260_screw_terminal_contact_h,
                   pitch=ina260_screw_terminal_pitch,
                   colr=ina260_screw_terminal_colr,
                   pin_thickness=ina260_screw_terminal_pin_thickness,
                   pin_h=ina260_screw_terminal_pin_h,
                   wall_thickness=ina260_screw_terminal_wall_thickness);
  }
}

ina260();
