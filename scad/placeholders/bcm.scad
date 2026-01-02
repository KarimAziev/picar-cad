/**
 * Module: Broadcom BCM Processor
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../parameters.scad>
include <../colors.scad>

use <../lib/shapes2d.scad>
use <../lib/transforms.scad>
use <../lib/plist.scad>

module rpi_rectangle_3d(size, r_factor=0.05, fn=40, center=false) {
  linear_extrude(height=size[2], center=center) {
    rounded_rect(size=[size[0], size[1]],
                 r=min(size[0], size[1]) * r_factor,
                 fn=fn);
  }
}

module bcm_processor_base(size=rpi_processor_size,
                          step=5,
                          extra_h=1,
                          txt,
                          colr=metallic_yellow_silver_2,
                          txt_color,
                          txt_size,
                          txt_spacing=1,
                          txt_font,
                          scale_both_sides=false,
                          r_factor=0.06) {
  small_size_x = size[0] - step;
  small_size_y = size[1] - (scale_both_sides ? step : 0);
  union() {
    color(colr, alpha=1) {
      rpi_rectangle_3d(size=size, r_factor=r_factor);
    }

    translate([step / 2, (scale_both_sides ? step / 2 : 0), 0]) {
      color(colr, alpha=1) {
        rpi_rectangle_3d(size=[small_size_x,
                               small_size_y,
                               size[2] + extra_h],
                         r_factor=0);
      }

      if (!is_undef(txt)) {
        text_size = is_undef(txt_size)
          ? min(small_size_x, small_size_y) / len(txt)
          : txt_size;
        tm = textmetrics(text=txt,
                         spacing=txt_spacing,
                         font=txt_font,
                         size=text_size);

        translate([small_size_x / 2 - tm.size[0] / 2,
                   small_size_y / 2 - tm.size[1] / 2,
                   size[2] + extra_h]) {
          color(txt_color, alpha=1) {
            linear_extrude(height=0.01, center=false) {
              text(text=txt,
                   spacing=txt_spacing,
                   font=txt_font,
                   size=text_size);
            }
          }
        }
      }
    }
  }
}

module bcm_processor(size=rpi_processor_size,
                     detailed=rpi_model_detailed,
                     scale_both_sides=false,
                     r=0.8,
                     step=5,
                     extra_h=1,
                     txt,
                     txt_color,
                     txt_size,
                     txt_spacing=1,
                     txt_font,
                     colr=metallic_yellow_silver_2,
                     r_factor=0.06,
                     center=false) {
  translate([center ? -size[0] / 2 : 0, center ? -size[1] / 2 : 0, 0]) {
    if (detailed) {
      offset_3d(r=r, size=size[1]) {
        union() {
          bcm_processor_base(size=size,
                             step=step,
                             txt=txt,
                             colr=colr,
                             txt_spacing=txt_spacing,
                             txt_font=txt_font,
                             txt_size=txt_size,
                             txt_color=txt_color,
                             scale_both_sides=scale_both_sides,
                             extra_h=extra_h,
                             r_factor=r_factor);
        }
      }
    } else {
      bcm_processor_base(size=size,
                         step=step,
                         txt=txt,
                         colr=colr,
                         txt_size=txt_size,
                         txt_spacing=txt_spacing,
                         txt_font=txt_font,
                         txt_color=txt_color,
                         scale_both_sides=scale_both_sides,
                         extra_h=extra_h,
                         r_factor=r_factor);
    }
  }
}

bcm_processor(detailed=true, txt="Hailo");