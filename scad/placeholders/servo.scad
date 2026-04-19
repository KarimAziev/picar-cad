/**
 * Module: A dummy mockup of the servo.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>
include <../steering_params.scad>

use <../lib/functions.scad>
use <../lib/holes.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/slots.scad>
use <../lib/text.scad>
use <../lib/wire.scad>
use <bolt.scad>
use <servo_horn.scad>

function servo_gear_total_height(gear_size) =
  sum([for (i = [0 : len(gear_size) - 1]) gear_size[i][0]]);

function servo_full_height(height, gearbox_h, gear_size) =
  height + gearbox_h + servo_gear_total_height(gear_size);

function servo_height_after_hat(h, z_offst, hat_thickness, center_hat=true) =
  h - z_offst - (center_hat ? (hat_thickness / 2) : hat_thickness);

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

module servo_socket(size, color) {
  color(color) {
    translate([0, -size[1] / 2, 0]) {
      cube(size=size,
           center=false);
    }
  };
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
                  text_plist,
                  text_size,
                  cut_len_top_depth,
                  cut_len_top_len,
                  font="Liberation Sans:style=Bold Italic",
                  bolt_spacing,
                  center_hat_z=true,
                  tolerance,
                  socket_size,
                  socket_z_offset,
                  socket_side,
                  wiring_path,
                  wiring_d=1.5,
                  wiring_colors=["black", "red", "white"]) {
  cut_len_top_depth = with_default(cut_len_top_depth, 0);
  cut_len_top_len = with_default(cut_len_top_len, 0);
  length = size[0];
  w = size[1];
  h = size[2];

  module _text(bg_pad_top,
               text_height,
               total_size,
               z_offset,
               bg_t,
               bg_l,
               bg_h,
               bg_w,
               bg_color,
               text_pl) {
    union() {
      if (!is_undef(bg_color)) {
        translate([0,
                   bg_w < w ? (w - bg_w) / 2 + bg_t : 0,
                   -bg_h / 2 + h - z_offset]) {
          color(bg_color, alpha=1) {
            cube([bg_l, bg_w, bg_h],
                 center=true);
          }
        }
      }

      translate([0,
                 w / 2,
                 h - z_offset - total_size[1] - bg_pad_top]) {
        rotate([90, 0, 180]) {
          text_rows(texts=servo_text,
                    plist=text_pl,
                    default_font=font,
                    default_size=text_size,
                    default_height=text_height,
                    center_x=true,
                    center_y=false);
        }
      }
    }
  }

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
    }

    if (!is_undef(servo_text)) {
      let (text_pl = with_default(text_plist, []),
           text_both_sides=plist_get("text_both_sides", text_pl),
           bg = plist_get("background", text_pl, with_default(text_pl, [])),
           bg_color = plist_get("color", bg),
           default_pad = is_undef(bg_color) ? 0 : 2,
           bg_pad_top = plist_get("pad_top", bg, default_pad),
           bg_pad_bottom = plist_get("pad_bottom", bg, default_pad),
           bg_p_left = plist_get("pad_left", bg, 0),
           bg_p_right = plist_get("pad_right", bg, 0),
           bg_pad_left = bg_p_left == 0 ? 0.01 : bg_p_left,
           bg_pad_right = bg_p_right == 0 ? 0.01 : bg_p_right,
           bg_t = 0.1,
           text_height=bg_t * 2,
           plist=normalize_texts(texts=servo_text,
                                 plist=text_pl,
                                 default_font=font,
                                 default_height=text_height,
                                 default_size=text_size),
           total_size=plist_get("total_size", plist),
           bg_l = length - bg_pad_left - bg_pad_right,
           bg_h = total_size[1] + bg_pad_top + bg_pad_bottom,
           bg_w = w + (bg_t * (bg_pad_left > 0 ? -1 : 1)),
           z_offset = center_hat_z
           ? bolts_hat_z_offset + servo_hat_thickness
           : bolts_hat_z_offset) {

        _text(bg_pad_top=bg_pad_top,
              text_height=text_height,
              total_size=total_size,
              z_offset=z_offset,
              bg_t=bg_t,
              bg_h=bg_h,
              bg_w=bg_w,
              bg_l=bg_l,
              bg_color=bg_color,
              text_pl=text_pl);
        if (text_both_sides) {
          rotate([0, 0, 180]) {
            _text(bg_pad_top=bg_pad_top,
                  text_height=text_height,
                  total_size=total_size,
                  z_offset=z_offset,
                  bg_t=bg_t,
                  bg_h=bg_h,
                  bg_w=bg_w,
                  bg_l=bg_l,
                  bg_color=bg_color,
                  text_pl=text_pl);
          }
        }
      }
    }

    if (!is_undef(socket_size)) {
      let (x=socket_side == -1 ? (-(length / 2) - socket_size[0]) : length / 2,
           z_off = is_undef(socket_z_offset) ? 0 : socket_z_offset) {
        translate([x,
                   0,
                   z_off]) {
          servo_socket(socket_size, color=servo_color);
        }
        if (!is_undef(wiring_path)) {
          let (z = z_off + socket_size[2] / 2,
               pts = concat([[x, 0, z],
                             [x + (socket_side * 15), 0, z]],
                            wiring_path)) {

            wire_bundle(points=pts,
                        d=wiring_d,
                        colors=wiring_colors);
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
             text_plist,
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
             wiring_path,
             wiring_d=1.5,
             wiring_colors=["black", "red", "white"],
             servo_horn_rotation=45,
             show_servo_horn_screws,
             show_servo_horn_bolt,
             servo_horn_single=false,
             servo_horn_screw_side,
             show_servo_horn=true,
             center_hat_z=true,
             socket_size,
             socket_z_offset,
             socket_side,
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
                 text_plist=text_plist,
                 center_hat_z=center_hat_z,
                 bolt_spacing=bolt_spacing,
                 tolerance=tolerance,
                 socket_size=socket_size,
                 socket_z_offset=socket_z_offset,
                 socket_side=socket_side,
                 wiring_path=wiring_path,
                 wiring_d=wiring_d,
                 wiring_colors=wiring_colors);

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

servo(size=[dsservo_size[0],
            dsservo_size[1],
            dsservo_size[2]],
      bolts_dia=dsservo_bolt_dia,
      bolt_spacing=dsservo_bolt_spacing,
      servo_hat_w=dsservo_hat_w,
      center=true,
      servo_hat_h=dsservo_hat_h,
      servo_hat_thickness=dsservo_hat_thickness,
      center_hat_z=false,
      bolts_offset=dsservo_bolts_offset,
      bolts_hat_z_offset=dsservo_hat_z_offset,
      servo_color=dsservo_color,
      gearbox_box_color=dsservo_color,
      servo_text=dsservo_text,
      text_size=dsservo_text_size,
      text_plist=dsservo_text_plist,
      tolerance=0.3,
      cut_len=dsservo_cut_len,
      gearbox_h=dsservo_gearbox_h,
      gearbox_d1=dsservo_gearbox_d1,
      servo_horn_rotation=$t * ($t > 0.5 ? -90 : 45),
      wiring_path=[[-100, 0, dsservo_socket_z_offset]],
      gearbox_d2=dsservo_gearbox_d2,
      gearbox_x_offset=dsservo_gearbox_x_offset,
      show_servo_horn=false,
      gearbox_mode=dsservo_gearbox_mode,
      gearbox_gear_size=dsservo_gearbox_size,
      cut_len_top_len=dsservo_cut_len_top,
      cut_len_top_depth=dsservo_cut_top_depth,
      socket_size=dsservo_socket_size,
      socket_z_offset=dsservo_socket_z_offset,
      socket_side=dsservo_socket_side);