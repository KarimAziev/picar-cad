/**
 * Module: Helpers for Pins and j-leads
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>

use <../l_bracket.scad>

function j_lead_full_len(lower_len, upper_len, thickness) =
  lower_len + upper_len + thickness + thickness / 2;

function pin_pitch_edge_aligned(total_len, pin_w, count) =
  count > 1
  ? (total_len - pin_w) / (count - 1)
  : 0;

module pins_centered(pitch=2.54,
                     count=4,
                     pin_w,
                     pin_b,
                     pin_a,
                     pin_color=metallic_silver_2) {
  for (i=[0:count-1]) {
    let (x = (i - (count - 1) / 2) * pitch) {
      translate([x, 0, -pin_b / 2]) {
        rotate([90, 0, 0]) {
          color(pin_color) {
            l_bracket(size=[pin_w, pin_b, pin_a],
                      thickness=pin_w,
                      center=true);
          }
          children();
        };
      }
    }
  }
}

module j_leads_centered(pitch=2.54,
                        count=4,
                        thickness,
                        base_h,
                        upper_len,
                        lower_len) {
  for (i=[0:count-1]) {
    let (x = (i - (count - 1) / 2) * pitch) {
      translate([x, 0, 0]) {
        j_lead(upper_len=upper_len,
               lower_len=lower_len,
               thickness=thickness,
               base_h=base_h,
               center=true);
      }
    }
  }
}

module j_lead(lower_len=5,
              base_h=12,
              upper_len=4,
              thickness=2,
              center=false) {

  full_w = j_lead_full_len(upper_len=upper_len,
                           lower_len=lower_len,
                           thickness=thickness);

  x = center ? -thickness / 2 : 0;
  y = center
    ? -full_w / 2
    : 0;
  z = 0;
  translate([x,
             y,
             z]) {
    translate([0, upper_len, 0]) {
      union() {
        l_bracket(size=[thickness,
                        lower_len + thickness,
                        base_h],
                  thickness=thickness,
                  children_modes=[["union", "vertical"]],
                  center=false) {
          translate([0,
                     base_h / 2,
                     upper_len / 2]) {
            cube([thickness,
                  thickness,
                  upper_len + thickness],
                 center=true);
          }
        }
      }
    }
  }
}