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

module rpi_rectangle_3d(size, r_factor=0.05, fn=40, center=false) {
  linear_extrude(height=size[2], center=center) {
    rounded_rect(size=[size[0], size[1]],
                 r=min(size[0], size[1]) * r_factor, fn=fn);
  }
}

module bcm_processor_base(size=rpi_processor_size,
                          step=5,
                          extra_h=1,
                          r_factor=0.06) {

  union() {
    rpi_rectangle_3d(size=size, r_factor=r_factor);
    small_size_x = size[0] - step;
    translate([step / 2, 0, 0]) {

      rpi_rectangle_3d(size=[small_size_x, size[1], size[2] + extra_h],
                       r_factor=0);
    }
  }
}

module bcm_processor(size=rpi_processor_size,
                     detailed=rpi_model_detailed,
                     r=0.8,
                     step=5,
                     extra_h=1,
                     r_factor=0.06,
                     center=false) {
  translate([center ? -size[0] / 2 : 0, center ? -size[1] / 2 : 0, 0]) {
    color(metallic_yellow_silver_2, alpha=1) {
      if (detailed) {
        offset_3d(r=r, size=size[1]) {
          union() {
            bcm_processor_base(size=size,
                               step=step,
                               extra_h=extra_h,
                               r_factor=r_factor);
          }
        }
      } else {
        bcm_processor_base(size=size,
                           step=step,
                           extra_h=extra_h,
                           r_factor=r_factor);
      }
    }
  }
}

bcm_processor(detailed=true);