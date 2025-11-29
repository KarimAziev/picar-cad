/**
 * Module: A mockup for the standard 18650 Battery Holder.
 * Amount of the batteries can be configured with variable battery_holder_batteries_count.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../parameters.scad>
include <../colors.scad>

use <battery.scad>
use <atm_fuse_holder.scad>
use <../lib/functions.scad>
use <../lib/transforms.scad>

battery_holder_color = matte_black;

function battery_holder_full_len(thickness) = battery_height + thickness * 3;
function battery_holder_full_width(thickness) = battery_dia + thickness * 2;

module battery_holder(batteries_count=battery_holder_batteries_count,
                      full_width,
                      full_len,
                      thickness=battery_holder_thickness,
                      screw_hole_dia=3.5,
                      contact_inc_step=1,
                      show_battery=true,
                      show_atm_fuse=true,
                      atm_fuse_spec=[[atm_fuse_holder_2_mounting_hole_h,
                                      atm_fuse_holder_2_mounting_hole_l,
                                      atm_fuse_holder_2_mounting_hole_r,
                                      atm_fuse_holder_2_mounting_hole_depth],
                                     [atm_fuse_holder_2_body_top_l,
                                      atm_fuse_holder_2_body_bottom_l,
                                      atm_fuse_holder_2_body_w,
                                      atm_fuse_holder_2_body_h,
                                      matte_black_2,
                                      true],
                                     [atm_fuse_holder_2_lid_top_l,
                                      atm_fuse_holder_2_lid_bottom_l,
                                      atm_fuse_holder_2_lid_w,
                                      atm_fuse_holder_2_lid_h,
                                      matte_black_2,
                                      true],
                                     [atm_fuse_holder_2_body_rib_l,
                                      atm_fuse_holder_2_body_rib_h,
                                      atm_fuse_holder_2_body_rib_n,
                                      atm_fuse_holder_2_body_rib_distance,
                                      atm_fuse_holder_2_body_rib_thickness],
                                     [atm_fuse_holder_2_lid_rib_l,
                                      atm_fuse_holder_2_lid_rib_h,
                                      atm_fuse_holder_2_lid_rib_n,
                                      atm_fuse_holder_2_lid_rib_distance,
                                      atm_fuse_holder_2_lid_rib_thickness],
                                     [atm_fuse_holder_body_wiring_d,
                                      [[15, 0, 0],
                                       [0, 0, 0]]]]) {

  if (batteries_count > 0) {
    full_width = is_undef(full_width)
      ? battery_holder_full_width(thickness)
      : full_width;

    full_len = is_undef(full_len)
      ? battery_holder_full_len(thickness)
      : full_len;

    union() {
      for (i = [0 : batteries_count - 1]) {
        translate([i * full_width, 0, 0]) {
          battery_holder_single_assembly(full_width=full_width,
                                         full_len=full_len,
                                         thickness=thickness,
                                         screw_hole_dia=screw_hole_dia,
                                         show_battery=show_battery,
                                         contact_inc_step=contact_inc_step);
        }
      }
    }
    if (show_atm_fuse) {
      let (mounting_hole_raw_spec = atm_fuse_spec[0],
           body_spec = atm_fuse_spec[1],
           lid_spec=atm_fuse_spec[2],
           body_rib_spec=atm_fuse_spec[3],
           lid_rib_spec=atm_fuse_spec[4],
           wire_spec=atm_fuse_spec[5],
           wire_d=wire_spec[0],
           wire_points=wire_spec[1],) {

        translate([-body_spec[3], 40, 0]) {
          rotate([0, 0, 90]) {
            atm_fuse_holder(show_lid=lid_spec[5],
                            show_body=body_spec[5],
                            center=false,
                            mounting_hole_spec=mounting_hole_raw_spec,
                            body_spec=body_spec,
                            lid_spec=lid_spec,
                            body_rib_spec=body_rib_spec,
                            wiring_d=wire_d,
                            wire_points=wire_points,
                            lid_rib_spec=lid_rib_spec);
          }
        }
      }
    }
  }
}

module battery_holder_single(full_width,
                             full_len,
                             thickness=battery_holder_thickness,
                             screw_hole_dia=3.5,
                             contact_inc_step=1) {

  full_width = is_undef(full_width)
    ? battery_holder_full_width(thickness)
    : full_width;

  full_len = is_undef(full_len)
    ? battery_holder_full_len(thickness)
    : full_len;

  union() {
    color(battery_holder_color, alpha=1) {
      linear_extrude(height=thickness, center=false) {
        difference() {
          square([full_width, full_len]);
          translate([full_width / 2, full_len / 2, 0]) {
            circle(r=screw_hole_dia / 2);
          }
        }
      }
      translate_copy([full_width, 0, 0]) {
        rotate([0, 90, 0]) {
          linear_extrude(height=thickness, center=false) {
            battery_holder_side_wall(length=full_len);
          }
        }
      }
    }

    translate([0, thickness, 0]) {
      battery_holder_top_wall(width=full_width,
                              height=battery_dia,
                              thickness=thickness,
                              contact_inc_step=contact_inc_step);
    }
    translate([0, full_len, 0]) {
      battery_holder_top_wall(width=full_width,
                              height=battery_dia,
                              thickness=thickness);
    }
  }
}

module battery_holder_single_assembly(full_width,
                                      full_len,
                                      thickness=battery_holder_thickness,
                                      screw_hole_dia=3.5,
                                      contact_inc_step=1,
                                      show_battery=true) {

  full_width = is_undef(full_width)
    ? battery_holder_full_width(thickness)
    : full_width;

  full_len = is_undef(full_len)
    ? battery_holder_full_len(thickness)
    : full_len;

  union() {
    battery_holder_single(full_width=full_width,
                          full_len=full_len,
                          thickness=thickness,
                          screw_hole_dia=screw_hole_dia,
                          contact_inc_step=contact_inc_step);

    if (show_battery) {
      translate([full_width / 2,
                 full_len - thickness,
                 full_width / 2]) {
        rotate([90, 0, 0]) {
          battery();
        }
      }
    }
  }
}

module battery_holder_top_wall(width=battery_dia + battery_holder_thickness * 2,
                               height=battery_dia,
                               thickness=battery_holder_thickness,
                               battery_contact_dia=5,
                               contact_inc_step=1) {

  rotate([90, 0, 0]) {
    union() {
      color(battery_holder_color, alpha=1) {
        linear_extrude(height=thickness, center=false) {
          square([width, height]);
        }
      }

      translate([0, 0, -contact_inc_step / 2]) {
        color(metallic_gold_2, alpha=1) {
          linear_extrude(height=thickness + contact_inc_step,
                         center=false) {
            translate([width / 2, height / 2, 0]) {
              circle(r=battery_contact_dia / 2, $fn=7);
            }
          }
        }
      }
    }
  }
}

module battery_holder_side_wall(length=battery_height,
                                thickness=battery_holder_thickness,
                                width=battery_dia,
                                cutout_depth=4) {

  half_of_len = length / 2;
  max_cutout_x = width - cutout_depth;
  upper_len = 0.3 * length;
  side_cutout_len = 0.09 * length;
  pts = [[0, half_of_len],
         [0, 0],
         [-width, 0],
         [-width, thickness],
         [-max_cutout_x, thickness],
         [-max_cutout_x, side_cutout_len],
         [-width, side_cutout_len],
         [-width, upper_len],
         [-max_cutout_x, upper_len * 1.05],
         [-max_cutout_x, half_of_len]];

  fillet(r=1) {
    polygon(points=pts);
    translate([0, half_of_len * 2, 0]) {
      rotate([180, 0, 0]) {
        polygon(points=pts);
      }
    }
  }
}

battery_holder();