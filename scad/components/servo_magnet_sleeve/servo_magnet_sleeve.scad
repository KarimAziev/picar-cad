/**
  * Module: Servo Magnet Sleeve
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../colors.scad>
include <../../rc_params.scad>

use <../../lib/shapes3d.scad>
use <../../placeholders/bolt.scad>

module servo_magnet_sleeve(bolt_d,
                           bolt_h,
                           bolt_head_h,
                           bolt_head_d,
                           bottom_thickness,
                           magnet_d,
                           magnet_h,
                           magnet_h_outer_h,
                           magnet_d_clearance,
                           thickness,
                           show_bolt=false,
                           show_magnet=false,
                           bolt_head_h_clearance=0.2,
                           bolt_head_d_clearance=0.6,
                           magnet_color=metallic_silver_2,
                           color=cobalt_blue_metallic,
                           alpha=1.0) {

  magnet_d_with_clearance = magnet_d + magnet_d_clearance;
  bolt_head_d_with_clearance = bolt_head_d + bolt_head_d_clearance;

  od = thickness * 2 + magnet_d_with_clearance;
  bolt_od = bolt_head_d_with_clearance + thickness * 2;

  transition_h = bolt_head_h + bolt_head_h_clearance;

  h3 = magnet_h - magnet_h_outer_h;

  ring(h=bottom_thickness, od=bolt_od, d=bolt_d, color=color, alpha=alpha);
  if (show_bolt) {
    translate([0, 0, -bolt_h + bottom_thickness]) {
      bolt(h=bolt_h, d=bolt_d, head_h=bolt_head_h, head_d=bolt_head_d);
    }
  }

  translate([0, 0, bottom_thickness]) {
    ring(h=transition_h,
         d=bolt_head_d_with_clearance,
         od1=bolt_od,
         od2=od,
         color=color,
         alpha=alpha);
    translate([0, 0, transition_h]) {
      if (show_magnet) {
        cyl(d=magnet_d, h=magnet_h, color=magnet_color);
      }
      ring(h=h3,
           d=magnet_d_with_clearance,
           od=od,
           color=color,
           alpha=alpha);
    }
  }
}
