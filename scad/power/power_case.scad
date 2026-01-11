/**
 * Module: Case for lipo packs like Turnigy Rapid
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/placement.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <common.scad>
use <power_case_rail.scad>

module power_case(size=[power_case_width,
                        power_case_length,
                        power_case_height],
                  lipo_pack_size=[lipo_pack_width,
                                  lipo_pack_length,
                                  lipo_pack_height],
                  bottom_bolt_d=power_case_bottom_bolt_dia,
                  bottom_bore_d=power_case_bottom_cbore_dia,
                  bottom_bore_h=power_case_bottom_cbore_h,
                  bolt_spacing=power_case_bottom_bolt_spacing,
                  bolt_offsets=[power_case_bolt_spacing_offset_x,
                                power_case_bolt_spacing_offset_y],
                  side_thickness=power_case_side_wall_thickness,
                  bottom_thickness=power_case_bottom_thickness,
                  front_thickness=power_case_front_wall_thickness,
                  front_rear_h=power_case_front_back_wall_h,
                  corner_rad=power_case_round_rad,
                  lipo_pack_tolerance=0.8,
                  case_color=white_snow_1,
                  side_vent_padding_x=power_case_side_slot_padding_x,
                  side_vent_padding_z=power_case_side_slot_padding_z,
                  side_vent_slot_h=power_case_side_slot_h,
                  side_vent_slot_w=power_case_side_slot_w,
                  side_vent_gap_x=power_case_side_slot_gap,
                  side_vent_gap_z=power_case_side_slot_gap_z,
                  front_vent_padding_x=power_case_front_slot_padding_x,
                  front_vent_padding_z=power_case_front_slot_padding_z,
                  front_vent_slot_h=power_case_front_slot_h,
                  front_vent_slot_w=power_case_front_slot_w,
                  front_vent_gap_x=power_case_front_slot_gap,
                  front_vent_gap_z=power_case_front_slot_gap_z,
                  rail_h=power_case_rail_height,
                  rail_hole_d=power_case_rail_bolt_dia,
                  rail_hole_distance=power_case_rail_hole_distance_from_edge,
                  rail_angle=power_case_rail_angle,
                  rail_r=power_case_rail_rad,
                  center=true,
                  alpha=1) {
  w = size[0];
  l = size[1];
  h = size[2];

  lipo_w = lipo_pack_size[0];
  lipo_h = lipo_pack_size[2];

  inner_x_cutout = w - side_thickness * 2;
  inner_y_cutout = l - front_thickness * 2;
  inner_lipo_x_cutout = lipo_w + lipo_pack_tolerance;
  maybe_translate([center ? 0 : w / 2, center ? 0 : l / 2, 0]) {
    color(case_color, alpha=alpha) {
      union() {
        difference() {
          // Outer case
          union() {
            rounded_cube([w, l, h], r=corner_rad, center=true);
            translate([0, 0, h - corner_rad / 2]) {
              cube([w, l, corner_rad], center=true);
            }
          }
          translate([0, 0, bottom_thickness]) {
            // Cutout for LiPo pack
            cube_3d([inner_lipo_x_cutout, inner_y_cutout, h], center=true);
          }

          // Holes for 4 corner mounting bolts
          with_power_case_mounting_holes(bolt_spacing=bolt_spacing,
                                         offsets=bolt_offsets) {
            counterbore(d=bottom_bolt_d,
                        h=bottom_thickness,
                        bore_h=bottom_bore_h,
                        bore_d=bottom_bore_d,
                        autoscale_step=0.1,
                        sink=false);
          }

          // Front and rear panels upper cutouts
          translate([0, 0, front_rear_h]) {
            rounded_cube([inner_x_cutout, l + 1, lipo_h + 1], center=true);
          }

          // Front and rear panels vent
          power_case_vent(panel_height=front_rear_h,
                          bottom_thickness=bottom_thickness,
                          padding_x=front_vent_padding_x,
                          padding_z=front_vent_padding_z,
                          slot_h=front_vent_slot_h,
                          slot_w=front_vent_slot_w,
                          slot_depth=front_thickness,
                          gap_x=front_vent_gap_x,
                          gap_z=front_vent_gap_z,
                          y_axle=false,
                          x_offset=-l / 2,
                          total_width=w - side_thickness * 2);

          // Side panels vent
          power_case_vent(panel_height=h,
                          bottom_thickness=bottom_thickness,
                          padding_x=side_vent_padding_x,
                          padding_z=side_vent_padding_z,
                          slot_depth=(w - inner_lipo_x_cutout) / 2,
                          slot_h=side_vent_slot_h,
                          slot_w=side_vent_slot_w,
                          gap_x=side_vent_gap_x,
                          gap_z=side_vent_gap_z,
                          y_axle=true,
                          x_offset=inner_lipo_x_cutout / 2,
                          total_width=inner_y_cutout);
        }
        mirror_copy([1, 0, 0]) {
          translate([w / 2 - side_thickness / 2, 0, h]) {
            power_case_rail(w=side_thickness,
                            l=l,
                            h=rail_h,
                            d=rail_hole_d,
                            distance=rail_hole_distance,
                            angle=rail_angle,
                            r=rail_r);
          }
        }
      }
    }
  }
}

module power_case_vent(panel_height,
                       bottom_thickness,
                       padding_x,
                       padding_z,
                       slot_h,
                       slot_w,
                       slot_depth,
                       gap_x,
                       gap_z,
                       y_axle,
                       x_offset,
                       total_width) {

  available_h = panel_height
    - bottom_thickness
    - padding_z;

  slot_z_step = gap_z + slot_h;
  slot_y_rows = floor(available_h / slot_z_step);
  for (i = [0 : slot_y_rows - 1]) {
    let (s = i * slot_z_step) {
      translate([0, 0, s]) {
        mirror_copy([y_axle ? 1 : 0, y_axle ? 0 : 1, 0]) {
          translate([y_axle ? x_offset - 0.1 : 0,
                     y_axle ? 0 : x_offset - 0.1,
                     bottom_thickness
                     + padding_z]) {
            rotate([0, 0, y_axle ? -90 : 0]) {
              row_of_cubes(total_width -
                           (padding_x * 2),
                           center=true,
                           spacing=gap_x,
                           y_center=false,
                           starts=[0, 0],
                           size=[slot_w,
                                 slot_depth + 0.2,
                                 slot_h]);
            }
          }
        }
      }
    }
  }
}

power_case();