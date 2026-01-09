/**
 * Module: ATC ATO Blade Fuse Holder
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/transforms.scad>

function atc_ato_blade_full_h() =
  atc_ato_blade_fuse_holder_bottom_cover_h
  + atc_ato_blade_fuse_holder_top_cover_h;

function atc_ato_blade_full_thickness() =
  max(atc_ato_blade_fuse_holder_top_cover_thickness,
      atc_ato_blade_fuse_holder_bottom_cover_thickness)
  + atc_ato_blade_fuse_holder_top_joint_thickness
  + atc_ato_blade_mounting_wall_thickness;

function atc_ato_blade_full_w() =
  max(atc_ato_blade_fuse_holder_bottom_cover_w,
      atc_ato_blade_fuse_holder_top_cover_w)
  + atc_ato_blade_mounting_wall_w;

module atc_ato_blade_fuse_holder_top_cover() {
  color(matte_black, alpha=1) {
    union() {
      linear_extrude(height=atc_ato_blade_fuse_holder_top_cover_h,
                     center=false) {
        rounded_rect(size=[atc_ato_blade_fuse_holder_top_cover_w,
                           atc_ato_blade_fuse_holder_top_cover_thickness],
                     center=true,
                     r=atc_ato_blade_fuse_holder_top_rad);
      }
      mirror_copy([1, 0, 0]) {
        translate([atc_ato_blade_fuse_holder_top_cover_w / 2
                   - atc_ato_blade_fuse_holder_top_joint_thickness / 2
                   - atc_ato_blade_fuse_holder_top_rad,
                   atc_ato_blade_fuse_holder_top_cover_thickness / 2,
                   0]) {
          atc_ato_blade_fuse_holder_top_holder_wall_joint();
        }
      }
      translate([0,
                 -atc_ato_blade_fuse_holder_top_cover_thickness / 2
                 - atc_ato_blade_mounting_wall_thickness + 0.5,
                 atc_ato_blade_fuse_holder_top_cover_h
                 - atc_ato_blade_mounting_wall_h]) {
        rounded_cube([atc_ato_blade_mounting_wall_w +
                      (atc_ato_blade_fuse_holder_top_cover_w / 2),
                      atc_ato_blade_mounting_wall_thickness,
                      atc_ato_blade_mounting_wall_h],
                     center=false,
                     r=0.5);
      }

      mirror_copy([1, 0, 0]) {
        translate([atc_ato_blade_fuse_holder_top_cover_w / 2
                   - atc_ato_blade_mounting_wall_thickness / 2
                   - atc_ato_blade_fuse_holder_top_rad,
                   -atc_ato_blade_fuse_holder_top_cover_thickness / 2
                   - atc_ato_blade_mounting_wall_thickness / 2 + 0.5,
                   0]) {
          rounded_cube([atc_ato_blade_fuse_holder_top_cover_w * 0.1,
                        atc_ato_blade_mounting_wall_thickness,
                        atc_ato_blade_fuse_holder_top_cover_h]);
        }
      }
    }
  }
}

module atc_ato_blade_fuse_holder_top_holder_wall_joint(center=true) {
  max_x = atc_ato_blade_fuse_holder_top_cover_h;
  max_y = atc_ato_blade_fuse_holder_top_joint_h;
  pts = [[-1 * max_x, 0],
         [-0.8 * max_x, 0.4 * max_y],
         [-0.675 * max_x, 1 * max_y],
         [-0.5 * max_x, 1 * max_y],
         [-0.45 * max_x, 0.7*max_y],
         [0, 0]];
  rotate([90, 90, 90]) {
    linear_extrude(height=atc_ato_blade_fuse_holder_top_joint_thickness,
                   center=center) {

      polygon(pts);
    }
  }
}

module atc_ato_blade_fuse_holder_bottom_cover() {
  color(matte_black, alpha=1) {
    linear_extrude(height=atc_ato_blade_fuse_holder_bottom_cover_h,
                   center=false) {
      rounded_rect(size=[atc_ato_blade_fuse_holder_bottom_cover_w,
                         atc_ato_blade_fuse_holder_bottom_cover_thickness],
                   center=true,
                   r=atc_ato_blade_fuse_holder_bottom_rad);
    }
  }
}

module atc_ato_blade_fuse_holder() {
  union() {
    atc_ato_blade_fuse_holder_bottom_cover();
    translate([0, 0, atc_ato_blade_fuse_holder_bottom_cover_h]) {
      atc_ato_blade_fuse_holder_top_cover();
    }
  }
}

atc_ato_blade_fuse_holder();
