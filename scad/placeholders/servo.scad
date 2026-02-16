/**
 * Module: A dummy mockup of the servo.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/holes.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/slots.scad>
use <bolt.scad>
use <servo_horn.scad>

function servo_gear_total_height(gear_size) =
  sum([for (i = [0 : len(gear_size) - 1]) gear_size[i][0]]);

function servo_full_height(height, gearbox_h, gear_size) =
  height + gearbox_h + servo_gear_total_height(gear_size);

function servo_height_after_hat(h, z_offst, hat_thickness) =
  h - z_offst - (hat_thickness / 2);

function servo_height_before_hat(h, z_offst, hat_thickness) =
  h - (h - z_offst + hat_thickness / 2);

function servo_gear_center_x(length, d1) = length - d1;

module servo_bolts_hat(size,
                       x_offset,
                       d,
                       thickness,
                       center_z=true,
                       center=true) {
  w = size[0];
  h = size[1];
  linear_extrude(height=thickness, center=center_z) {
    difference() {
      rounded_rect(size = [w, h], r = h * 0.1, center=center);
      two_x_bolts_2d(x_offset, d=d);
    }
  }
}

module servo_body(size,
                  bolts_offset,
                  servo_color=jet_black,
                  alpha=1,
                  cut_len=0,
                  servo_hat_w,
                  bolts_dia,
                  servo_hat_h,
                  servo_hat_thickness,
                  bolts_hat_z_offset,
                  servo_text,
                  text_size,
                  cut_len_top_depth,
                  cut_len_top_len,
                  font="Liberation Sans:style=Bold Italic",
                  bolt_spacing,
                  center_hat_z=true,
                  tolerance) {
  cut_len_top_depth = with_default(cut_len_top_depth, 0);
  cut_len_top_len = with_default(cut_len_top_len, 0);
  length = size[0];
  w = size[1];
  h = size[2];
  union() {
    translate([-length / 2, w / 2, 0]) {
      color(servo_color, alpha=alpha) {
        rotate([90, 0, 0]) {
          linear_extrude(height=w, center=false) {
            polygon([[cut_len, 0],
                     [0, cut_len],
                     [0, h - cut_len_top_depth],
                     [cut_len_top_len, h],
                     [length, h],
                     [length, 0]]);
          }
        }
      }
      if (alpha > 0 && servo_text) {
        if (is_string(servo_text)) {
          translate([length / 2, 0, h / 2]) {
            rotate([90, 0, 180]) {
              linear_extrude(height=0.01,
                             center=false) {
                text(servo_text,
                     font=font,
                     size=text_size,
                     halign="center",
                     valign="bottom");
              }
            }
          }
        } else {
          translate([length / 2, 0, h / 2]) {
            text_sizes = [for (i = [0 : len(servo_text) - 1])
                is_undef(servo_text[i][1])
                  ? text_size
                  : servo_text[i][1]];
            text_paddings = [for (i = [0 : len(servo_text) - 1])
                is_undef(servo_text[i][3])
                  ? 0
                  : servo_text[i][3]];
            for (i = [0 : len(servo_text) - 1]) {
              item = servo_text[i];
              txt = item[0];
              txt_size = text_sizes[i];
              fnt = is_undef(item[2]) ? font : item[2];
              padding =  i > 0 ? sum(text_sizes, i) : 0;
              z_offst = i > 0 ? sum(text_paddings, i) : 0;
              translate([0, 0, -z_offst - padding]) {
                rotate([90, 0, 180]) {
                  linear_extrude(height=0.01,
                                 center=false) {
                    text(txt,
                         size=txt_size,
                         font=fnt,
                         halign="center",
                         valign="bottom");
                  }
                }
              }
            }
          }
        }
      }
    }

    translate([0, 0, h - bolts_hat_z_offset]) {
      color(servo_color, alpha=alpha) {
        if (!is_undef(bolt_spacing)) {
          translate([0, 0, center_hat_z ? -servo_hat_thickness / 2 : 0]) {
            difference() {
              linear_extrude(height=servo_hat_thickness, center=false) {
                rounded_rect(size = [servo_hat_w, servo_hat_h],
                             r = servo_hat_h * 0.1,
                             center=true);
              }
              four_corner_counterbores(size=bolt_spacing,
                                       d=bolts_dia + tolerance,
                                       h=servo_hat_thickness);
            }
          }
        } else {
          offst_x = bolt_x_offst(size[0], bolts_dia, bolts_offset);

          servo_bolts_hat(size=[servo_hat_w, servo_hat_h],
                          x_offset=offst_x,
                          d=bolts_dia + tolerance,
                          center_z=center_hat_z,
                          thickness=servo_hat_thickness);
        }
      }
    }
  }
}

module servo_gearbox(h,
                     d1,
                     r1,
                     d2,
                     r2,
                     x_offset,
                     mode, // hull or union
                     box_color=jet_black,
                     alpha=1,
                     gear_size=[[0.5, 1, dark_gold_2],
                                [2, 2, dark_gold_2]],
                     max_angle=90,
                     min_angle=-90,
                     servo_horn_rotation=0,
                     servo_horn_single,
                     servo_horn_screw_side,
                     show_servo_horn_screws,
                     show_servo_horn_bolt,
                     show_servo_horn=true,
                     center=true) {
  r1 = is_undef(r1) ? d1 / 2 : r1;
  r2 = is_undef(r2) ? is_undef(d2) ? r1 * 0.4 : d2 / 2 : r2;
  x_offset = is_undef(x_offset) ? 0 : x_offset;

  total_gear_h = servo_gear_total_height(gear_size);

  translate([center ? 0 : r1 + r2, 0, 0]) {
    union() {
      color(box_color, alpha=alpha) {
        linear_extrude(height=h, center=false) {
          r2_x = x_offset;
          if (mode == "hull") {
            translate([-r1 - r2, 0, 0]) {
            }
            hull() {
              circle(r=r1);
              translate([r1 + x_offset, 0, 0]) {
                circle(r=r2);
              }
            }
          } else {
            union() {
              circle(r=r1);
              translate([r2_x, 0]) {
                circle(r=r2);
              }
            }
          }
        }
      }

      translate([0, 0, h]) {
        for (i = [0 : len(gear_size) - 1]) {
          prev_heights = [for (i = [0 : i - 1]) gear_size[i][0]];
          offst = i == 0 ? 0 : sum(prev_heights);
          spec = gear_size[i];
          gh = spec[0];
          gd = spec[1];
          gcol = spec[2];
          color(gcol, alpha=alpha) {
            translate([0, 0, offst]) {
              linear_extrude(height=gh, center=false) {
                circle(r=gd / 2, $fn=spec[3]);
              }
            }
          }
        }
        if (show_servo_horn) {
          translate([0,
                     0,
                     total_gear_h
                     - servo_horn_arm_z_offset]) {
            rotate([0, 0, servo_horn_rotation]) {
              servo_horn(single=servo_horn_single,
                         screw_side=servo_horn_screw_side,
                         show_bolt=show_servo_horn_bolt,
                         show_screws=show_servo_horn_screws);
            }
          }
        }

        rotate([0, 0, $t * ($t > 0.5 ? min_angle : max_angle)]) {
          children();
        }
      }
    }
  }
}

module servo(size,
             bolts_dia,
             bolts_offset,
             bolt_spacing,
             servo_hat_w,
             servo_hat_h,
             servo_hat_thickness,
             bolts_hat_z_offset,
             servo_color=jet_black,
             alpha=1,
             servo_text=["EMAX", "ES08MA II"],
             font,
             text_size=3,
             tolerance=0.3,
             cut_len=3,
             cut_len_top_len,
             cut_len_top_depth,
             gearbox_h,
             gearbox_d1,
             gearbox_r1,
             gearbox_d2,
             gearbox_r2,
             gearbox_x_offset,
             gearbox_mode="hull", // hull or union
             gearbox_box_color=jet_black,
             gearbox_gear_size=[],
             max_angle=45,
             min_angle=-90,
             servo_horn_rotation=45,
             show_servo_horn_screws,
             show_servo_horn_bolt,
             servo_horn_single=false,
             servo_horn_screw_side,
             show_servo_horn=true,
             center_hat_z=true,
             center=false) {
  cut_len_top_depth = with_default(cut_len_top_depth, 0);
  length = size[0];
  w = size[1];

  gearbox_r1 = is_undef(gearbox_r1) ? gearbox_d1 / 2 : gearbox_r1;
  gearbox_r2 = is_undef(gearbox_r2) ? is_undef(gearbox_d2)
    ? gearbox_r1 * 0.4
    : gearbox_d2 / 2
    : gearbox_r2;
  gearbox_x_offset = is_undef(gearbox_x_offset) ? 0 : gearbox_x_offset;

  translate([center ? 0 : length / 2, center ? 0 : w / 2, 0]) {
    union() {
      servo_body(size=size,
                 bolts_offset=bolts_offset,
                 servo_color=servo_color,
                 alpha=alpha,
                 cut_len=cut_len,
                 cut_len_top_depth=cut_len_top_depth,
                 cut_len_top_len=cut_len_top_len,
                 servo_hat_w=servo_hat_w,
                 bolts_dia=bolts_dia,
                 servo_hat_h=servo_hat_h,
                 servo_hat_thickness=servo_hat_thickness,
                 bolts_hat_z_offset=bolts_hat_z_offset,
                 servo_text=servo_text,
                 text_size=text_size,
                 font=font,
                 center_hat_z=center_hat_z,
                 bolt_spacing=bolt_spacing,
                 tolerance=tolerance);
      translate([-size[0] / 2 + gearbox_r1, 0, size[2] - cut_len_top_depth]) {
        servo_gearbox(h=gearbox_h + cut_len_top_depth,
                      d1=gearbox_d1,
                      r1=gearbox_r1,
                      r2=gearbox_r2,
                      d2=gearbox_d2,
                      x_offset=gearbox_x_offset,
                      box_color=gearbox_box_color,
                      gear_size=gearbox_gear_size,
                      mode=gearbox_mode,
                      max_angle=max_angle,
                      min_angle=min_angle,
                      servo_horn_rotation=servo_horn_rotation,
                      show_servo_horn_bolt=show_servo_horn_bolt,
                      servo_horn_single=servo_horn_single,
                      servo_horn_screw_side=servo_horn_screw_side,
                      show_servo_horn=show_servo_horn,
                      show_servo_horn_screws=show_servo_horn_screws,
                      alpha=alpha) {
          children();
        }
      }
    }
  }
}

module with_servo_slot_slots(size=[head_neck_tilt_servo_slot_width,
                                   head_neck_tilt_servo_slot_height],
                             bolts_dia=head_neck_tilt_servo_bolt_dia,
                             bolts_offset=head_neck_tilt_servo_bolts_offset,
                             center=true,
                             y_axle=false) {
  translate([center ? 0 : size[0] / 2, center ? 0 : size[1] / 2, 0]) {
    if ($children > 1) {
      children(0);
    }

    offst = bolt_x_offst(size[y_axle ? 1 : 0], bolts_dia, bolts_offset);
    for (v = [-offst, offst]) {
      translate([y_axle ? 0 : v, y_axle ? v : 0, 0]) {
        children($children > 1 ? 1 : 0);
      }
    }
  }
}

module servo_slot_2d(size=[head_neck_tilt_servo_slot_width,
                           head_neck_tilt_servo_slot_height],
                     bolts_dia=head_neck_tilt_servo_bolt_dia,
                     bolts_offset=head_neck_tilt_servo_bolts_offset,
                     center=true,
                     y_axle=false) {

  with_servo_slot_slots(size=size,
                        bolts_dia=bolts_dia,
                        bolts_offset=bolts_offset,
                        center=center,
                        y_axle=y_axle) {
    square([size[0], size[1]], center=true);
    circle(r=bolts_dia / 2, $fn=360);
  }
}

module servo_slot_3d(size=[steering_servo_slot_width,
                           steering_servo_slot_height],
                     bolts_dia=steering_servo_bolt_dia,
                     bolts_offset=steering_servo_bolts_offset,
                     thickness=3,
                     center=true) {

  linear_extrude(height=thickness, center=center) {
    servo_slot_2d(size=size,
                  bolts_dia=bolts_dia,
                  bolts_offset=bolts_offset);
  }
}
