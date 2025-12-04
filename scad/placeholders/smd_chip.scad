/**
 * Module: Placeholder for SMD chip (Surface Mount Device chip).
 *
 * An SMD chip is
 * an electronic component that is mounted directly onto the surface of a
 * printed circuit board (PC
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>

use <../l_bracket.scad>
use <pins.scad>
use <../lib/shapes2d.scad>
use <../lib/transforms.scad>

module smd_chip_2d(length,
                   w,
                   r=0.2,
                   fn=20,
                   center=false) {
  rounded_rect([length, w],
               center=center,
               fn=fn,
               r=r);
}

module smd_chip_slot_2d(length,
                        total_w,
                        r=0.2,
                        fn=20,
                        center=false) {
  rounded_rect([length, total_w],
               center=center,
               fn=fn,
               r=r);
}

module smd_chip(length,
                total_w,
                w,
                h,
                r=0.2,
                fn=20,
                smd_color=black_1,
                j_lead_n,
                j_lead_thickness=0.5,
                j_lead_color=metallic_yellow_silver,
                lower_lead_fraction=0.7,
                center=true) {

  let (thickness = j_lead_thickness,
       amount = j_lead_n,

       available_w = (total_w - w) / 2 - (thickness * 2),
       upper_len = available_w * (1 - lower_lead_fraction),
       lower_len = available_w * lower_lead_fraction,
       base_h = h * 0.9,
       full_len = j_lead_full_len(lower_len=lower_len,
                                  upper_len=upper_len,
                                  thickness=thickness),
       pitch = pin_pitch_edge_aligned(total_len=length,
                                      pin_w=thickness,
                                      count=amount),
       y = w / 2 - full_len / 2 + full_len) {

    translate([center ? 0 : length / 2, center ? 0 : total_w / 2, 0]) {

      union() {
        color(smd_color, alpha=1) {
          linear_extrude(height=h,
                         center=false) {
            smd_chip_2d(length=length,
                        w=w,
                        r=r,
                        fn=fn,
                        center=true);
          }
        }

        if (!is_undef(j_lead_n) && j_lead_n > 0) {
          mirror_copy([0, 1, 0]) {
            translate([0, y, 0]) {
              color(j_lead_color, alpha=1) {
                j_leads_centered(base_h=base_h,
                                 lower_len=lower_len,
                                 upper_len=upper_len,
                                 count=amount,
                                 thickness=thickness,
                                 pitch=pitch);
              }
            }
          }
        }
      }
    }
  }
}

smd_chip(length=ultrasonic_smd_len,
         w=ultrasonic_smd_chip_w,
         j_lead_n=ultrasonic_smd_led_count,
         j_lead_thickness=ultrasonic_smd_led_thickness,
         total_w=9,
         h=ultrasonic_smd_h,
         center=true);
