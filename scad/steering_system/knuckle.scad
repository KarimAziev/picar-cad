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
use <knuckle_connector.scad>
use <bearing_connector.scad>

module knuckle_mount(show_wheel=false,
                     show_bearing=false,
                     show_shaft=false,
                     knuckle_color=cobalt_blue_metalic,
                     knuckle_color_alpha=0.6,
                     knuckle_shaft_color=matte_black) {
  border_w = (knuckle_dia - knuckle_bearing_outer_dia) / 2;

  union() {
    knuckle_bent_shaft_connector(knuckle_color=cobalt_blue_metalic,
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
                                      show_bearing=show_bearing);
  }
}

module knuckle_main_connector(border_w,
                              show_bearing=false,
                              knuckle_color=cobalt_blue_metalic,
                              knuckle_color_alpha=0.6) {
  union() {
    color(knuckle_color, alpha=knuckle_color_alpha) {
      linear_extrude(height=knuckle_height, center=false, convexity=2) {
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

module knuckle_bent_shaft_connector(knuckle_color=cobalt_blue_metalic,
                                    knuckle_shaft_color=matte_black,
                                    show_shaft=false,
                                    show_wheel=false,
                                    border_w=border_w) {

  notch_width = calc_notch_width(max(knuckle_dia, knuckle_shaft_connector_dia),
                                 min(knuckle_dia, knuckle_shaft_connector_dia));

  offst = knuckle_shaft_connector_dia / 2;
  y_offst = -(notch_width + knuckle_shaft_connector_extra_len +
              border_w + offst);

  union() {
    difference() {
      rotate([0, 0, -90]) {
        knuckle_connector(parent_dia=knuckle_dia,
                          outer_d=knuckle_shaft_connector_dia,
                          inner_d=knuckle_shaft_dia,
                          h=knuckle_height,
                          length=knuckle_shaft_connector_extra_len,
                          border_w=border_w,
                          connector_color=knuckle_color,
                          children_modes=["difference"],
                          fn=360) {
          h = knuckle_shaft_connector_dia + 1;
          translate([offst, 0, knuckle_height - knuckle_shaft_screws_offset]) {
            knuckle_screws_slots(d=knuckle_shaft_screw_dia, h=h);
            translate([0, 0, -knuckle_shaft_screw_dia
                       - knuckle_shaft_screws_distance]) {
              knuckle_screws_slots(d=knuckle_shaft_screw_dia, h=h);
            }
          }
        }
      }
    }

    if (show_shaft) {
      translate([0,
                 y_offst,
                 knuckle_height]) {
        mirror([assembly_shaft_use_front_steering ? 1 : 0, 0, 0]) {
          rotate([0, 0, assembly_shaft_use_front_steering ? 0 : 180]) {
            knuckle_shaft(show_wheel=show_wheel,
                          knuckle_shaft_color=knuckle_shaft_color);
          }
        }
      };
    }
  }
}

module knuckle_bearing_bracket_connector(border_w=
                                         (knuckle_dia
                                          - knuckle_bearing_outer_dia) / 2,
                                         knuckle_color=cobalt_blue_metalic,
                                         show_bearing=false) {

  rotate([0, 0, steering_alpha_deg]) {
    translate([0, 0, knuckle_height - knuckle_bracket_connector_height]) {
      knuckle_connector(parent_dia=knuckle_dia,
                        outer_d=steering_bracket_bearing_outer_d,
                        inner_d=steering_bracket_bearing_d,
                        h=knuckle_bracket_connector_height,
                        length=steering_knuckle_bracket_connector_len,
                        border_w=border_w,
                        connector_color=knuckle_color,
                        fn=360) {
        if (show_bearing) {
          translate([steering_bracket_bearing_outer_d / 2, 0,
                     -steering_bracket_bearing_flanged_height]) {
            bearing(d=steering_bracket_bearing_d,
                    h=steering_bracket_bearing_height,
                    flanged_w=steering_breacket_bearing_flanged_width,
                    flanged_h=steering_bracket_bearing_flanged_height,
                    shaft_d=round(steering_bracket_bearing_shaft_d),
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
  knuckle_print_plate(show_bearing=false,
                      show_shaft=false,
                      show_wheel=false);
}