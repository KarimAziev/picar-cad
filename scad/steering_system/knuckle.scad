/**
 * Module: Steering knuckle
 * This file defines modules related to the steering knuckle and its components,
 * including a removable bent shaft that connects the steering knuckle to the wheel hub.
 *
 * Main module:
 * - `knuckle_mount`:
 *     The core module that includes all subcomponents.
 *
 * Auxiliary modules:
 * - `knuckle_main_connector`:
 *     A cylindrical piece with a bearing cutout that attaches to the steering frame.
 *
 * - `knuckle_bearing_bracket_connector`:
 *     An elongated arm with a bearing cutout at one end. It connects to the L-bracket
 *     and forms part of the Ackermann steering geometry.
 *
 * - `knuckle_bent_shaft_connector`:
 *     An arm with a cutout for the curved axle shaft.
 *     The shaft is secured with two bolts.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <../placeholders/bearing.scad>
use <../util.scad>
use <knuckle_shaft.scad>
use <bearing_connector.scad>

module knuckle_mount(show_wheel=false,
                     show_bearing=false,
                     show_shaft=false,
                     show_text=false,
                     knuckle_color=blue_grey_carbon,
                     knuckle_color_alpha=0.6,
                     knuckle_shaft_color=matte_black) {
  border_w = (knuckle_dia - knuckle_bearing_outer_dia) / 2;

  union() {

    knuckle_bent_shaft_connector(knuckle_color=blue_grey_carbon,
                                 knuckle_shaft_color=knuckle_shaft_color,
                                 show_wheel=show_wheel,
                                 show_shaft=show_shaft,
                                 border_w=border_w);

    knuckle_main_connector(border_w=border_w,
                           knuckle_color=knuckle_color,
                           knuckle_color_alpha=knuckle_color_alpha,
                           show_bearing=show_bearing);

    knuckle_bearing_bracket_connector(border_w=border_w,
                                      knuckle_color=knuckle_color,
                                      show_bearing=show_bearing,
                                      show_text=show_text);
  }
}

module knuckle_main_connector(border_w,
                              show_bearing=false,
                              knuckle_color=blue_grey_carbon,
                              knuckle_color_alpha=0.6) {
  union() {
    color(knuckle_color, alpha=knuckle_color_alpha) {
      linear_extrude(height=knuckle_height, center=false) {
        ring_2d_outer(r=knuckle_bearing_outer_dia / 2,
                      w=border_w, fn=360);
      }
    }
    if (show_bearing) {
      translate([0, 0, -knuckle_bearing_flanged_height]) {
        bearing(d=knuckle_bearing_outer_dia,
                h=knuckle_bearing_height,
                flanged_w=knuckle_bearing_flanged_width,
                flanged_h=knuckle_bearing_flanged_height,
                shaft_d=round(knuckle_bearing_inner_dia),
                shaft_ring_w=1,
                outer_ring_w=0.5,
                outer_col=metalic_silver_3,
                rings=[[1, metalic_yellow_silver],
                       [0.5, onyx]]);
      }
    }
  }
}

module knuckle_bent_shaft_connector(knuckle_color=blue_grey_carbon,
                                    knuckle_shaft_color=matte_black,
                                    show_shaft=false,
                                    show_wheel=false,
                                    border_w=border_w,
                                    fn=100) {

  notch_width = calc_notch_width(knuckle_dia, knuckle_shaft_connector_dia);

  offst = knuckle_shaft_connector_extra_len + knuckle_shaft_connector_dia / 2;
  screw_holes_z = knuckle_shaft_screws_dia / 2 + knuckle_shaft_screws_offset;

  rotate([0, 0, -90]) {
    translate([knuckle_dia / 2 - notch_width, 0, 0]) {
      difference() {
        union() {
          color(knuckle_color) {
            linear_extrude(height = knuckle_height, center=false) {
              difference() {
                translate([0, -knuckle_shaft_connector_dia / 2, 0]) {
                  square([notch_width, knuckle_shaft_connector_dia],
                         center=false);
                }
                translate([-notch_width / 2 + border_w / 2, 0, 0]) {
                  circle(d=knuckle_dia, $fn=60);
                }
              }
            }
          }

          translate([knuckle_shaft_connector_dia / 2 - 0.1, 0, 0]) {
            union() {
              color(knuckle_color) {
                linear_extrude(height = knuckle_height, center=false) {
                  translate([0, -knuckle_shaft_connector_dia / 2, 0]) {
                    difference() {
                      square([offst, knuckle_shaft_connector_dia],
                             center=false);
                      translate([offst, knuckle_shaft_connector_dia / 2, 0]) {
                        circle(d=knuckle_shaft_dia, $fn=360);
                      }
                    }
                  }
                }
              }
              translate([offst, 0, 0]) {
                ring_w = (knuckle_shaft_connector_dia - knuckle_shaft_dia) / 2;
                color(knuckle_color) {
                  linear_extrude(height = knuckle_height) {
                    ring_2d(r=knuckle_shaft_dia / 2,
                            w=ring_w,
                            fn=360,
                            outer=true);
                  }
                }
              }
            }
          }
        }

        translate([knuckle_shaft_connector_dia / 2 + offst,
                   0,
                   screw_holes_z]) {
          rad = knuckle_shaft_screws_dia / 2;
          h = knuckle_shaft_connector_dia + 1;

          knuckle_screws_slots(d=knuckle_shaft_screws_dia,
                               h=knuckle_shaft_connector_dia + 1);

          translate([0, 0, screw_holes_z]) {
            knuckle_screws_slots(d=knuckle_shaft_screws_dia,
                                 h=knuckle_shaft_connector_dia + 1);
          }
        }
      }
    }
  }
  if (show_shaft) {
    koffst = knuckle_screws_offset();
    extra_offst = (knuckle_height + knuckle_screws_offset());

    x_offst = -knuckle_dia / 2 + notch_width
      - knuckle_shaft_connector_dia / 2 - offst;
    z_offst = knuckle_height;

    translate([0,
               x_offst,
               z_offst]) {
      rotate([0, 0, 180]) {
        knuckle_shaft(show_wheel=show_wheel,
                      knuckle_shaft_color=knuckle_shaft_color);
      }
    }
  }
}

module knuckle_bearing_bracket_connector(border_w=border_w,
                                         knuckle_color=blue_grey_carbon,
                                         show_text=false,
                                         show_bearing=false) {

  rotate([0, 0, ackermann_angle_deg + 90]) {
    translate([knuckle_dia / 2 - border_w,
               0,
               knuckle_height - knuckle_bracket_connector_height]) {
      color(knuckle_color) {
        linear_extrude(height=knuckle_bracket_connector_height, center=false) {
          difference() {
            square([border_w, bracket_bearing_outer_d], center=true);
            translate([-knuckle_dia / 2, 0, 0]) {
              circle(d=knuckle_dia, $fn=60);
            }
          }
        }
      }

      translate([knuckle_bracket_connector_len / 2, 0, 0]) {
        union() {
          color(knuckle_color) {
            linear_extrude(height=knuckle_bracket_connector_height,
                           center=false) {
              difference() {
                square([knuckle_bracket_connector_len, bracket_bearing_outer_d],
                       center=true);
                translate([knuckle_bracket_connector_len / 2, 0, 0]) {
                  circle(d=bracket_bearing_d, $fn=360);
                }
              }
            }
          }

          if (show_text) {
            color("red") {
              translate([-2, bracket_bearing_outer_d / 2 + 1 , 0]) {
                linear_extrude(height=knuckle_bracket_connector_height,
                               center=false) {
                  text(str("V: ", round(ackermann_angle_deg + 90), "°"),
                       size=3,
                       halign="center",
                       valign="bottom",
                       font = "Liberation Sans:style=Bold Italic");
                }
              }
            }

            color(knuckle_color) {
              translate([0, -bracket_bearing_outer_d - 2, 0]) {
                linear_extrude(height=knuckle_bracket_connector_height,
                               center=false) {
                  text(str("A:  ", truncate(knuckle_bracket_connector_len, 2)),
                       size=4, halign="center",
                       valign="bottom",
                       font = "Liberation Sans:style=Bold Italic");
                }
              }
            }
          }

          translate([knuckle_bracket_connector_len / 2, 0, 0]) {
            color(knuckle_color) {
              bearing_upper_connector(h=knuckle_bracket_connector_height);
            }

            if (show_bearing) {
              translate([0, 0, -bracket_bearing_flanged_height]) {
                bearing(d=bracket_bearing_d,
                        h=bracket_bearing_height,
                        flanged_w=bracket_bearing_flanged_width,
                        flanged_h=bracket_bearing_flanged_height,
                        shaft_d=round(bracket_bearing_shaft_d),
                        shaft_ring_w=1,
                        outer_ring_w=0.5,
                        outer_col=metalic_silver_3,
                        rings=[[1, metalic_yellow_silver]]);
              }
            }
          }
        }
      }
    }
  }
}

module knuckle_print_plate(show_bearing=false,
                           show_shaft=false,
                           show_wheel=false) {
  rotate([180, 0, 0]) {
    offst = knuckle_shaft_lower_horiz_len +
      knuckle_dia +
      knuckle_shaft_dia;
    translate([offst / 2, 0, 0]) {
      knuckle_mount(show_bearing=show_bearing,
                    show_shaft=show_shaft,
                    show_wheel=show_wheel);
    }
    translate([-offst / 2, 0, 0]) {
      mirror([1, 0, 0]) {
        knuckle_mount(show_bearing=show_bearing,
                      show_shaft=show_shaft,
                      show_wheel=show_wheel);
      }
    }
  }
}

union() {
  // knuckle_mount(show_bearing=false,
  //               show_shaft=true,
  //               show_wheel=false);
  knuckle_print_plate(show_bearing=false,
                      show_shaft=false,
                      show_wheel=false);
}
