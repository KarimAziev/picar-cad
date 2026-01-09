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
use <../lib/shapes2d.scad>
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
                       center=true) {
  w = size[0];
  h = size[1];
  linear_extrude(height=thickness, center=true) {
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
                  font="Liberation Sans:style=Bold Italic",
                  tolerance) {
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
                     [0, h],
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
            for (i = [0 : len(servo_text) - 1]) {
              item = servo_text[i];
              txt = item[0];
              txt_size = text_sizes[i];
              fnt = is_undef(item[2]) ? font : item[2];
              z_offst = i > 0 ? sum(text_sizes, i) : 0;
              translate([0, 0, -z_offst]) {
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
    if (servo_text != undef) {
    }
    color(servo_color, alpha=alpha) {
      translate([0, 0, h - bolts_hat_z_offset]) {
        offst_x = bolt_x_offst(size[0], bolts_dia, bolts_offset);

        servo_bolts_hat(size=[servo_hat_w, servo_hat_h],
                        x_offset=offst_x,
                        d=bolts_dia + tolerance,
                        thickness=servo_hat_thickness);
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
              servo_horn();
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
             show_servo_horn=true,
             center=false) {
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
                 servo_hat_w=servo_hat_w,
                 bolts_dia=bolts_dia,
                 servo_hat_h=servo_hat_h,
                 servo_hat_thickness=servo_hat_thickness,
                 bolts_hat_z_offset=bolts_hat_z_offset,
                 servo_text=servo_text,
                 text_size=text_size,
                 font=font,
                 tolerance=tolerance);
      translate([-size[0] / 2 + gearbox_r1, 0, size[2]]) {
        servo_gearbox(h=gearbox_h,
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
                      show_servo_horn=show_servo_horn,
                      alpha=alpha) {
          children();
        }
      }
    }
  }
}

module servo_slot_2d(size=[head_neck_tilt_servo_slot_width,
                           head_neck_tilt_servo_slot_height],
                     bolts_dia=head_neck_tilt_servo_bolt_dia,
                     bolts_offset=head_neck_tilt_servo_bolts_offset,
                     center=true) {

  translate([center ? 0 : size[0] / 2, center ? 0 : size[1] / 2, 0]) {
    square([size[0], size[1]], center=true);
    offst_x = bolt_x_offst(size[0], bolts_dia, bolts_offset);
    for (x = [-offst_x, offst_x]) {
      translate([x, 0, 0]) {
        circle(r=bolts_dia * 0.5, $fn=360);
      }
    }
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
