/**
 * Module: Steering servo panel
 *
 * This module defines the main steering servo mounting structure responsible for
 * housing and aligning the servo motor and its associated steering pinion with
 * the rack-and-pinion steering mechanism. It functions as the core frame
 * for motion transfer from a servo to the rack, and ultimately to the front wheels
 * via brackets and steering knuckles.
 *
 *
 **************************************************************************************
 *                          Simplified View (A frontal perspective)
 **************************************************************************************
 *                          +---------------------------+
 *                          |                           |
 *                          |         M2 bolt hole     |
 *                          |                           |
 *                          |            *              |
 *                          |      +-------------+      |
 *                          |      |             |      |
 *                          |      |  vertical   |      |
 *                          |      |  servo slot |      |
 *                          |      |  hole for   |      |
 *                          |      |  pinion     |      |
 *                          |      |             |      |
 *                          |      |             |      |
 * steering_kingpin_post    |      |             |      |
 *                          |      |             |      |                 steering_kingpin_post
 *    |                     |      |             |      |                    |
 *    v                     |      |             |      |                    v
 *   +---+                  |      +------------+|      |                  +---+
 *   |   |                  |         | front_h|        |                  |   |
 *   +---+------------------+--------+--------+---------+------------------+---+
 *   |   |                      steering_rack_support()                    |   | -----> steering_panel_kingpin_connector
 *   +-------------------------------------------------------------------------+
 *     |
 *     |
 *     v
 *     steering_panel_kingpin_connector
 *  z
 *  |
 *  y---x
 *
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../components/chassis/util.scad>
use <../lib/functions.scad>
use <../lib/holes.scad>
use <../lib/l_bracket.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/slots.scad>
use <../lib/text.scad>
use <../lib/transforms.scad>
use <../placeholders/bolt.scad>
use <../placeholders/steering_servo.scad>
use <bearing_shaft.scad>
use <knuckle_connector.scad>
use <rack.scad>
use <rack_util.scad>
use <steering_kingpin_post.scad>
use <steering_pinion.scad>
use <steering_rail.scad>
use <steering_servo_mount.scad>

show_rack               = false;
show_servo_mount_panel  = false;
show_servo              = false;
show_pinion             = false;
show_brackets           = false;
show_kingpin_posts      = false;

show_bolts_info         = false;
show_kingpin_bolt       = false;
show_hinges_bolts       = false;
show_panel_bolt         = false;

fasten_kingpin_bolt     = false;
fasten_hinges_bolts     = false;
fasten_panel_bolt       = false;

steering_hinge_bolt_rad = steering_panel_hinge_bolt_dia / 2;

hinge_pts = scale_upper_trapezoid_pts(x=steering_panel_hinge_w,
                                      y=steering_panel_hinge_length
                                      + steering_panel_hinge_corner_rad);

hinge_h                 = max(steering_rack_support_thickness * 0.8,
                              1);

function steering_panel_hinges_calc_x_distance() =
  poly_width_at_y(chassis_upper_pts,
                  chassis_upper_len - steering_panel_distance_from_top)
  - steering_panel_hinge_w / 2
  - steering_panel_hinge_x_offset;

function knuckle_connectors_x_offsets() =
  let (half_of_len=steering_panel_length / 2,
       knuckle_rad = knuckle_dia / 2)
  [half_of_len - knuckle_rad,
   -half_of_len + knuckle_rad];

module steering_panel_kingpin_connector(color,
                                        show_bolt=false,
                                        fasten_bolt=true,
                                        show_bolts_info=false,
                                        txt_size=4) {
  knuckle_rad = knuckle_dia / 2;

  border_w = steering_kingpin_post_border_w;
  color(color, alpha=1) {
    difference() {
      linear_extrude(height=steering_rack_support_thickness,
                     convexity=2,
                     center=false) {
        difference() {
          ring_2d(r=knuckle_rad, $fn=360, fn=100, w=border_w);
          circle(r=steering_hinge_bolt_rad, $fn=360);
        }
      }
      steering_kingpin_post_bolt_holes();
    }
  }
  if (show_bolt) {
    let (bolt_h=knuckle_dia,
         d=steering_kingpin_post_bolt_dia,
         bolt_head_type_d =
         find_bolt_head_d(inner_d=d,
                          head_type=steering_kingpin_post_bolt_head_type),

         notch_w = calc_notch_width(knuckle_dia,
                                    bolt_head_type_d),
         y = fasten_bolt ? -bolt_h + knuckle_dia / 2 - notch_w : 0,
         bolt_info_y = bolt_h + txt_size + knuckle_shaft_connector_extra_len
         + knuckle_shaft_connector_dia) {

      if (show_bolts_info) {
        translate([0,
                   bolt_info_y,
                   steering_rack_support_thickness]) {
          bolt_info_text(d=d,
                         h=bolt_h,
                         prefix="Two ",
                         plist=["size", txt_size]);
        }
      }

      translate([0, y, 0]) {
        steering_kingpin_post_bolt_holes(bolt_mode=true,
                                         bolt_h=bolt_h);
      }
    }
  }
}

module steering_chassis_bar_3d(length=steering_panel_length,
                               x_offsets=knuckle_connectors_x_offsets(),
                               center_y=false) {
  translate([0, center_y ? 0 : -steering_rack_support_width / 2, 0]) {
    difference() {
      linear_extrude(height=chassis_thickness, center=false) {
        rounded_rect(size=[length,
                           steering_rack_support_width],
                     center=true,
                     r=steering_rack_support_width * 0.5);
      }
      for (x = x_offsets) {
        translate([x, 0, 0]) {
          counterbore(h=chassis_thickness,
                      d=steering_panel_hinge_bolt_dia,
                      bore_d=steering_panel_hinge_bore_dia,
                      bore_h=steering_panel_hinge_bore_h,
                      sink=true,
                      fn=100,
                      reverse=true);
        }
      }
    }
  }
}

module hinge_3d(slot_mode=false,
                color,
                show_bolt=false,
                fasten_bolt=false,
                show_bolts_info=false) {
  max_d = max(steering_panel_hinge_bolt_dia, steering_panel_hinge_bore_dia);
  x = max_d / 2 + steering_panel_hinge_bolt_x_distance;
  y = max_d / 2 + steering_panel_hinge_bolt_distance;
  if (slot_mode) {
    translate([x, y, 0]) {
      counterbore(h=chassis_thickness,
                  d=steering_panel_hinge_bolt_dia,
                  bore_d=steering_panel_hinge_chassis_bore_dia,
                  bore_h=chassis_counterbore_h,
                  sink=true,
                  fn=100,
                  reverse=true);
    }
  } else {
    let (bore_h = hinge_h / 2) {
      color(color, alpha=1) {
        difference() {
          linear_extrude(height=hinge_h, center=false) {
            offset_vertices_2d(r=steering_panel_hinge_corner_rad) {
              polygon(hinge_pts);
            }
          }
          translate([x, y, 0]) {
            counterbore(h=hinge_h,
                        d=steering_panel_hinge_bolt_dia,
                        bore_d=steering_panel_hinge_bore_dia,
                        bore_h=bore_h,
                        sink=false,
                        fn=100,
                        reverse=false);
          }
        }
      }
      if (show_bolt || show_bolts_info) {
        let (d=steering_panel_hinge_bolt_dia,
             bolt_h = hinge_h + chassis_thickness,
             head_type = steering_panel_hinge_bolt_head_type,
             bolt_spec = find_bolt_nut_spec(d, default=[]),
             nut_spec = plist_get("lock_nut", bolt_spec, []),
             nut_h = plist_get("height", nut_spec, 0),
             z = fasten_bolt ? -hinge_h - bore_h : 0) {

          if (show_bolt) {
            translate([x, y, z]) {
              bolt(d=steering_panel_hinge_bolt_dia,
                   h=bolt_h,
                   nut_head_distance=bolt_h - nut_h,
                   head_type=head_type,
                   show_nut=nut_spec && fasten_bolt,
                   lock_nut=true);
            }
          }
        }
      }
    }
  }
}

module steering_hinges(slot_mode=false,
                       show_bolt=false,
                       show_bolts_info=false,
                       fasten_bolt=false,
                       txt_size=4,
                       color) {
  half_of_rack_w = steering_rack_support_width / 2;
  side_connector_offst_x = steering_panel_hinges_calc_x_distance();
  mirror_copy([1, 0, 0]) {
    translate([side_connector_offst_x,
               -half_of_rack_w - steering_panel_hinge_length,
               slot_mode ? 0 : -steering_rack_support_thickness / 2]) {
      hinge_3d(slot_mode=slot_mode,
               color=color,
               show_bolt=show_bolt,
               fasten_bolt=fasten_bolt,
               show_bolts_info=show_bolts_info);
    }
  }

  if (show_bolts_info && !slot_mode) {
    for (x = [-side_connector_offst_x, side_connector_offst_x]) {
      translate([x, -half_of_rack_w, 0]) {
        let (d=steering_panel_hinge_bolt_dia,
             bolt_h = hinge_h + chassis_thickness,
             bolt_info_y = steering_panel_hinge_length
             + steering_panel_hinge_corner_rad
             + txt_size,
             snapped_d = snap_bolt_d(d),
             bolt_txt = str("M",
                            snapped_d,
                            " x ",
                            bolt_h,
                            "mm,"),
             nut_txt = str("Lock Nut M", snapped_d)) {

          translate([0,
                     -bolt_info_y,
                     steering_rack_support_thickness]) {
            text_rows([bolt_txt, nut_txt],
                      plist=["size", txt_size,
                             "valign", "top",
                             "color", dark_gold_1,
                             "halign", x > 0 ? "left" : "right"]);
          }
        }
      }
    }
  }
}

module steering_rack_support(show_rack=false,
                             show_brackets=false,
                             show_kingpin_posts=false,
                             show_kingpin_bolt=false,
                             show_hinges_bolts=false,
                             show_panel_bolt=false,
                             fasten_kingpin_bolt=false,
                             fasten_hinges_bolts=false,
                             show_bolts_info=false,
                             fasten_panel_bolt=false,
                             show_bolts_info=false,
                             panel_color,
                             rack_color) {
  half_of_len = steering_panel_length / 2;
  notch_w = calc_notch_width(steering_rack_support_width < knuckle_dia
                             ? knuckle_dia
                             : steering_rack_support_width,
                             steering_rack_support_width < knuckle_dia
                             ? steering_rack_support_width
                             : knuckle_dia);
  knuckle_rad = knuckle_dia / 2;
  knuckle_x_poses = [half_of_len - knuckle_rad,
                     -half_of_len + knuckle_rad];
  servo_mount_clearance = 0.2;

  union() {
    union() {
      difference() {
        color(panel_color, alpha=1) {
          linear_extrude(height=steering_rack_support_thickness,
                         center=true) {
            rounded_rect(size=[steering_panel_length
                               - knuckle_dia * 2
                               + (is_num(notch_w) ? notch_w : 0),
                               steering_rack_support_width],
                         center=true,
                         r=0);
          }
        }

        translate([0, steering_rack_support_width, 0]) {
          steering_servo_mount_panel_bolt_holes();
        }

        translate([0, -servo_mount_clearance / 2, 0]) {
          steering_servo_mount_connector(clearance=servo_mount_clearance);
        }
      }

      if (show_panel_bolt) {
        bolt_hole_len = steering_servo_mount_pass_through_len();
        bolt_h = ceil(bolt_hole_len + 6);
        d = steering_servo_mount_connector_bolt_dia;
        unfset_pos = steering_rack_support_width / 2;
        bolt_head_type_h =
          find_bolt_head_h(inner_d=d,
                           head_type
                           =steering_servo_mount_connector_bolt_head_type);
        if (show_bolts_info) {
          let (txt_size = 4,
               text_base_dist = d + bolt_h + bolt_head_type_h + txt_size,
               text_dist = fasten_panel_bolt
               ? -text_base_dist - txt_size
               : text_base_dist) {
            translate([0,
                       text_dist,
                       steering_rack_support_thickness]) {
              bolt_info_text(d=steering_servo_mount_connector_bolt_dia,
                             h=bolt_h,
                             plist=["size", txt_size],
                             prefix="Two ",
                             suffix=" and nuts");
            }
          }
        }
        translate([0, unfset_pos + (fasten_panel_bolt ? -bolt_h : 0), 0]) {
          rotate([0, 0, 180]) {
            steering_servo_mount_with_bolt_mirror_x_positions() {
              rotate([90, 0, 0]) {
                bolt(d=d,
                     h=bolt_h,
                     head_type=steering_servo_mount_connector_bolt_head_type,
                     show_nut=fasten_panel_bolt,
                     nut_head_distance=bolt_hole_len + bolt_head_type_h);
              }
            }
          }
        }
      }

      for (x = knuckle_x_poses) {
        translate([x,
                   0,
                   -steering_rack_support_thickness
                   / 2]) {
          steering_panel_kingpin_connector(color=panel_color,
                                           show_bolt=show_kingpin_bolt,
                                           show_bolts_info=show_bolts_info,
                                           fasten_bolt=fasten_kingpin_bolt);
          if (show_kingpin_posts) {
            translate([0, 0, 0.01]) {
              steering_kingpin_post(color=panel_color);
            }
          }
        }
      }

      steering_hinges(color=panel_color,
                      show_bolt=show_hinges_bolts,
                      fasten_bolt=fasten_hinges_bolts,
                      show_bolts_info=show_bolts_info);
    }

    if (show_rack) {
      translate([0,
                 0,
                 steering_rack_support_thickness / 2
                 + steering_rack_z_distance_from_panel]) {
        rotate([0, 0, 180]) {
          rack_mount(show_brackets=show_brackets,
                     rack_color=is_undef(rack_color) ?
                     ppanel_color
                     : rack_color);
        }
      }
    }
  }
}

module steering_panel(panel_color,
                      rack_color,
                      show_rack=show_rack,
                      show_servo_mount_panel=show_servo_mount_panel,
                      show_servo=show_servo,
                      show_pinion=show_pinion,
                      show_brackets=show_brackets,
                      show_kingpin_posts=show_kingpin_posts,
                      show_kingpin_bolt=show_kingpin_bolt,
                      show_hinges_bolts=show_hinges_bolts,
                      show_panel_bolt=show_panel_bolt,
                      fasten_kingpin_bolt=fasten_kingpin_bolt,
                      fasten_hinges_bolts=fasten_hinges_bolts,
                      fasten_panel_bolt=fasten_panel_bolt,
                      show_bolts_info=show_bolts_info,
                      pinion_color=blue_grey_carbon,
                      center_y=true) {
  translate([0, center_y ? 0 : -steering_rack_support_width / 2, 0]) {
    union() {
      steering_rack_support(panel_color=panel_color,
                            show_rack=show_rack,
                            show_brackets=show_brackets,
                            show_kingpin_posts=show_kingpin_posts,
                            show_panel_bolt=show_panel_bolt,
                            show_hinges_bolts=show_hinges_bolts,
                            show_bolts_info=show_bolts_info,
                            show_kingpin_bolt=show_kingpin_bolt,
                            rack_color=rack_color,
                            fasten_kingpin_bolt=fasten_kingpin_bolt,
                            fasten_hinges_bolts=fasten_hinges_bolts,
                            fasten_panel_bolt=fasten_panel_bolt);

      translate([0, 0, steering_rack_support_thickness / 2]) {
        color(panel_color, alpha=1) {
          steering_rail();
          mirror_copy([0, 1, 0]) {
            steering_rack_anti_tilt_key();
          }
        }
      }
      if (show_servo_mount_panel) {
        steering_servo_mount(show_pinion=show_pinion,
                             show_servo=show_servo,
                             pinion_color=pinion_color);
      }
    }
  }
}

steering_panel(panel_color="white",
               rack_color=cobalt_blue_metallic,
               center_y=false);
