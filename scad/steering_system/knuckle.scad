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
 *     A bent "elbow" connector with a cutout for the curved axle shaft.
 *     The shaft is secured with a single bolt.
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
                     knuckle_color=blue_grey_carbon,
                     knuckle_color_alpha=0.6,
                     knuckle_shaft_color=matte_black) {
  border_w = (knuckle_dia - knuckle_bearing_outer_dia) / 2;

  union() {
    knuckle_bent_shaft_connector(knuckle_color=blue_grey_carbon,
                                 knuckle_shaft_color=knuckle_shaft_color,
                                 show_wheel=show_wheel,
                                 show_shaft=show_shaft);

    knuckle_main_connector(border_w=border_w,
                           knuckle_color=knuckle_color,
                           knuckle_color_alpha=knuckle_color_alpha,
                           show_bearing=show_bearing);

    knuckle_bearing_bracket_connector(border_w=border_w,
                                      knuckle_color=knuckle_color,
                                      show_bearing=show_bearing);
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

module knuckle_bent_shaft_connector_notch(knuckle_color) {
  notch_width = calc_notch_width(knuckle_dia, knuckle_shaft_connector_dia);
  difference() {
    translate([0, -notch_width, 0]) {
      color(knuckle_color) {
        linear_extrude(height=knuckle_shaft_connector_dia, center=false) {
          rounded_rect(size = [knuckle_shaft_connector_dia, notch_width], center=true,
                       r=min(knuckle_shaft_connector_dia, notch_width) / 2);
        }
      }
    }

    translate([0, 0, -0.5]) {
      linear_extrude(height=knuckle_shaft_connector_dia + 1, center=false) {
        circle(knuckle_bearing_outer_dia / 2, $fn=360);
      }
    }
  }
}

module knuckle_bent_shaft_connector(knuckle_color=blue_grey_carbon,
                                    knuckle_shaft_color=matte_black,
                                    show_shaft=false,
                                    show_wheel=false,
                                    fn=100) {
  rad = knuckle_shaft_connector_dia / 2;
  union() {
    knuckle_bent_shaft_connector_notch(knuckle_color=knuckle_color);

    translate([0, 0, -knuckle_shaft_vertical_len]) {
      union() {
        translate([0, -knuckle_dia / 2, 0]) {
          translate([0,
                     0,
                     knuckle_shaft_vertical_len + rad]) {
            color(knuckle_color) {
              rotate([90, 0, 0]) {
                cylinder(h=knuckle_shaft_upper_horiz_len,
                         r=rad,
                         center=false,
                         $fn=fn);
              }
            }

            if (show_shaft) {
              translate([0, -knuckle_shaft_upper_horiz_len - rad, 0]) {
                knuckle_shaft(show_wheel=show_wheel,
                              knuckle_shaft_color=knuckle_shaft_color);
              }
            }
            difference() {
              translate([0,
                         -knuckle_shaft_upper_horiz_len,
                         -rad]) {
                rotate([90, 0, -90]) {
                  color(knuckle_color) {
                    rotate_extrude(angle = 90, $fn=fn) {
                      translate([rad, 0]) {
                        circle(r = rad, $fn=fn);
                      }
                    }
                  }
                }
              }
              translate([0, -knuckle_shaft_upper_horiz_len - rad, -rad / 2]) {
                knuckle_screws_slots(d=knuckle_shaft_screws_dia,
                                     h=knuckle_shaft_connector_dia + 1);
              }
              translate([0,
                         -knuckle_shaft_upper_horiz_len - rad,
                         -knuckle_shaft_vertical_len / 2]) {
                cylinder(h=knuckle_shaft_vertical_len,
                         r=knuckle_shaft_dia / 2,
                         center=false,
                         $fn=360);
              }
            }
          }
        }
      }
    }
  }
}

module knuckle_bearing_bracket_connector(border_w=border_w,
                                         knuckle_color=blue_grey_carbon,
                                         show_bearing=false) {
  rotate([0, 0, knuckle_bracket_connector_angle]) {
    translate([knuckle_dia / 2 - border_w,
               0,
               knuckle_bracket_connector_height]) {
      color(knuckle_color) {
        linear_extrude(height = knuckle_bracket_connector_height, center=false) {
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
            linear_extrude(height = knuckle_bracket_connector_height, center=false) {
              difference() {
                square([knuckle_bracket_connector_len, bracket_bearing_outer_d], center=true);
                translate([knuckle_bracket_connector_len / 2, 0, 0]) {
                  circle(d=bracket_bearing_d, $fn=360);
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
      knuckle_shaft_upper_horiz_len +
      knuckle_bracket_connector_height +
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
                      show_shaft=true,
                      show_wheel=false);
}
