/**
 * Module: Tie rod shaft placeholder
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../colors.scad>
include <../parameters.scad>
include <../steering_params.scad>

use <../lib/functions.scad>
use <../lib/text.scad>
use <bolt.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  tie_rod_shaft
  ─────────────────────────────────────────────────────────────────────────────

  Creates a tie rod shaft placeholder with a threaded section on each end.

  **Parameters**:

  `body_d`: Outer diameter of the main body.
  `body_len`: Length of the main body (excluding threaded sections).
  `body_end_len`: Length of each tapered transition between `thread_d` and `body_d`.
                If undef or <= 0, the body is a straight cylinder.
  `thread_len`: Length of each threaded section.
  `thread_d`: Thread diameter.
  `fn`: Resolution ($fn) used for cylinders.
  `color`: Color of the tie rod.
  `show_nuts`: Whether to show nuts on each threaded section.
  `nut_h`: Optional length of the nut.

  **Notes**:

  The overall length along Z is: `body_len + 2 * thread_len`.
  */
module tie_rod_shaft(body_len,
                     body_d,
                     body_end_len,
                     thread_len,
                     thread_d,
                     fn=6,
                     nut_h,
                     color=metallic_silver_1,
                     show_nuts=true,
                     show_len=true,
                     extra_text,
                     text_color=pink_1) {
  color(color) {
    translate([0, 0, thread_len]) {
      if (!is_undef(body_end_len) && body_end_len > 0) {
        cylinder(d1=thread_d, d2=body_d, h=body_end_len, $fn=fn);
        translate([0, 0, body_end_len]) {
          cylinder(d=body_d, h=body_len - body_end_len * 2, $fn=fn);
          translate([0, 0, body_len - body_end_len * 2]) {
            cylinder(d1=body_d, d2=thread_d, h=body_end_len, $fn=fn);
          }
        }
      } else {
        cylinder(d=body_d, h=body_len, $fn=fn);
      }
    }
  }
  if (show_len) {
    let (body_l_txt = str("Body: ", body_len, "mm"),
         full_l_txt = is_string(extra_text)
         ? extra_text
         : str("Full: ", body_len + thread_len * 2, "mm"),
         txt_h=0.01,
         face_w = body_d / 2,
         texts_1=[full_l_txt, body_l_txt],
         texts=concat(texts_1, texts_1, texts_1)) {
      for (i = [0 : len(texts) - 1]) {
        let (txt = texts[i],
             z_angle = i * 60) {
          translate([0, 0, 0]) {

            rotate([0, 0, z_angle]) {
              translate([0, -body_d / 2, thread_len + body_len / 2]) {
                rotate([90, 90, 0]) {
                  color(text_color) {
                    text_fit(txt,
                             x=body_len * 0.9,
                             y=face_w * 0.9,
                             h=txt_h);
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  translate([0, 0, body_len + thread_len]) {
    bolt(d=thread_d,
         h=thread_len,
         bolt_color=color,
         head_type="none",
         show_nut=show_nuts,
         nut_head_distance=thread_len,
         nut_h=nut_h);
  }
  bolt(d=thread_d,
       h=thread_len,
       bolt_color=color,
       head_type="none",
       show_nut=show_nuts,
       nut_head_distance=0,
       nut_h=nut_h);
}

tie_rod_shaft(body_len=steering_servo_tie_rod_body_len,
              body_d=steering_servo_tie_rod_body_d,
              body_end_len=steering_servo_tie_rod_body_end_len,
              thread_len=steering_servo_tie_rod_thread_len,
              thread_d=steering_servo_tie_rod_thread_d,
              fn=steering_servo_tie_rod_fn,
              color=steering_servo_tie_rod_color);