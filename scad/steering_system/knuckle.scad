/**
 * Module: Steering knuckle
 *
 * This file defines modules related to the steering knuckle and its components.
 *
 * Main module:
 * - `knuckle_mount`: The core module that includes all subcomponents.
 *
 * Auxiliary modules:
 *
 * - `knuckle_kingpin_connector`: A central cylindrical piece with a bearing cutout for attaching kingpin posts.
 *
 * - `knuckle_tie_rod_shaft_arm`: An elongated arm with a cutout and screw holes for the tie rod shaft.
 *
 * - `knuckle_bent_shaft_rack_link_arm`: An arm with two cutouts: one for the
 *    curved axle shaft and one for a bearing that connects the arm to the rack
 *    link. Note: connect only one knuckle to the rack link. When the rack moves,
 *    the "leading" knuckle rotates; it is then connected to the second, "driven"
 *    knuckle via a tie rod to achieve Ackermann geometry.
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
use <tie_rod_shaft.scad>

module knuckle_mount(show_wheel=false,
                     show_bearing=false,
                     show_shaft=false,
                     show_tie_rod=false,
                     show_tie_rod_arm_length=false,
                     knuckle_color="white",
                     knuckle_color_alpha=0.6,
                     knuckle_shaft_color="white") {

  union() {
    knuckle_bent_shaft_rack_link_arm(knuckle_color=knuckle_color,
                                     knuckle_shaft_color=knuckle_shaft_color,
                                     show_wheel=show_wheel,
                                     show_shaft=show_shaft,
                                     border_w=knuckle_border_w);

    knuckle_kingpin_connector(border_w=knuckle_border_w,
                              knuckle_color=knuckle_color,
                              knuckle_color_alpha=knuckle_color_alpha,
                              show_bearing=show_bearing);

    knuckle_tie_rod_shaft_arm(border_w=knuckle_border_w,
                              knuckle_color=knuckle_color,
                              show_tie_rod=show_tie_rod,
                              show_length=show_tie_rod_arm_length,
                              show_bearing=show_bearing,
                              show_shaft=show_shaft);
  }
}

module knuckle_kingpin_connector(border_w,
                                 show_bearing=false,
                                 knuckle_color="white",
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

module knuckle_bent_shaft_rack_link_arm(knuckle_color="white",
                                        knuckle_shaft_color="white",
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
                          children_modes=["difference", "union"],
                          fn=360) {
          h = knuckle_shaft_connector_dia + 1;
          translate([offst, 0, knuckle_height - knuckle_shaft_screws_offset]) {
            knuckle_screws_slots(d=knuckle_shaft_screw_dia, h=h);
            translate([0,
                       0,
                       - knuckle_shaft_screw_dia
                       - knuckle_shaft_screws_distance]) {
              knuckle_screws_slots(d=knuckle_shaft_screw_dia, h=h);
            }
          }

          translate([knuckle_shaft_connector_extra_len + border_w / 2,
                     0,
                     knuckle_height - knuckle_rack_link_arm_height]) {
            knuckle_connector(parent_dia=knuckle_dia,
                              outer_d=steering_rack_link_bearing_outer_d,
                              inner_d=steering_rack_link_bearing_d,
                              h=knuckle_rack_link_arm_height,
                              length=knuckle_shaft_connector_extra_len
                              + knuckle_shaft_connector_extra_arm_len,
                              border_w=border_w,
                              children_modes=["union"],
                              connector_color=knuckle_color,
                              fn=360);
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

module knuckle_tie_rod_shaft_arm(border_w=knuckle_border_w,
                                 knuckle_color="white",
                                 knuckle_shaft_color="white",
                                 show_length=false,
                                 show_bearing=false,
                                 show_tie_rod=false,
                                 show_shaft=false) {
  offst = tie_rod_shaft_knuckle_arm_dia / 2;

  rotate([0, 0, steering_alpha_deg]) {
    translate([0, 0, knuckle_height - tie_rod_shaft_knuckle_arm_height]) {
      knuckle_connector(parent_dia=knuckle_dia,
                        outer_d=tie_rod_shaft_knuckle_arm_dia,
                        inner_d=tie_rod_shaft_dia,
                        h=tie_rod_shaft_knuckle_arm_height,
                        length=knuckle_tie_rod_shaft_arm_len,
                        border_w=border_w,
                        children_modes=["difference", "union"],
                        connector_color=knuckle_color,
                        fn=360) {

        h = tie_rod_shaft_knuckle_arm_dia + 1;

        union() {
          translate([offst,
                     0,
                     tie_rod_shaft_knuckle_arm_height
                     - tie_rod_shaft_screw_offset]) {
            knuckle_screws_slots(d=tie_rod_shaft_screw_dia,
                                 h=h);
            translate([0, 0, -tie_rod_shaft_screw_dia
                       - tie_rod_shaft_screw_distance]) {
              knuckle_screws_slots(d=tie_rod_shaft_screw_dia,
                                   h=h);
            }
          }
        }

        union() {
          if (show_shaft) {
            translate([tie_rod_shaft_knuckle_arm_dia / 2,
                       0,
                       -tie_rod_shaft_full_len()
                       + tie_rod_shaft_knuckle_arm_height]) {
              tie_rod_shaft(shaft_color=knuckle_shaft_color,
                            show_bearing=show_bearing,
                            show_tie_rod=show_tie_rod);
            }
          }
          if (show_length) {
            knuckle_tie_rod_ring_w = (tie_rod_shaft_knuckle_arm_dia
                                      - tie_rod_shaft_dia) / 2;
            translate([0, 0, tie_rod_shaft_knuckle_arm_height]) {
              union() {
                color("yellow", alpha=0.6) {
                  translate([0, 2, 0]) {
                    linear_extrude(height=1, center=false) {
                      text(str(steering_arm_full_len, "mm"),
                           size=2,
                           halign="center",
                           valign="bottom");
                    }
                  }
                  translate([-steering_arm_full_len / 2
                             - tie_rod_shaft_knuckle_arm_dia / 2
                             + knuckle_tie_rod_ring_w / 2, -0.5, 0]) {

                    cube([steering_arm_full_len, 1, 1], center=false);
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

module knuckle_print_plate(show_wheel=false,
                           show_bearing=false,
                           show_shaft=false,
                           show_tie_rod=false,
                           show_tie_rod_arm_length=false,
                           knuckle_color="white",
                           knuckle_color_alpha=0.6,
                           knuckle_shaft_color="white",
                           spacing=4) {
  translate([0, 0, knuckle_height]) {
    rotate([180, 0, 0]) {
      knuckle_mount(show_bearing=show_bearing,
                    show_shaft=show_shaft,
                    show_wheel=show_wheel,
                    show_tie_rod=show_tie_rod,
                    show_tie_rod_arm_length=show_tie_rod_arm_length,
                    knuckle_color=knuckle_color,
                    knuckle_color_alpha=knuckle_color_alpha,
                    knuckle_shaft_color=knuckle_shaft_color,);
      translate([knuckle_dia + spacing, 0, 0]) {
        mirror([1, 0, 0]) {
          knuckle_mount(show_bearing=show_bearing,
                        show_shaft=show_shaft,
                        show_wheel=show_wheel,
                        show_tie_rod=show_tie_rod,
                        show_tie_rod_arm_length=show_tie_rod_arm_length,
                        knuckle_color=knuckle_color,
                        knuckle_color_alpha=knuckle_color_alpha,
                        knuckle_shaft_color=knuckle_shaft_color,);
        }
      }
    }
  }
}

union() {
  knuckle_print_plate(show_wheel=false,
                      show_bearing=false,
                      show_shaft=false,
                      show_tie_rod=false,
                      show_tie_rod_arm_length=false,
                      knuckle_color="white",
                      knuckle_color_alpha=0.6,
                      knuckle_shaft_color="white",
                      spacing=4);
}