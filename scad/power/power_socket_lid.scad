/**
 * Module: A removable lid, onto which the main battery case is then mounted.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>
include <../power_lid_parameters.scad>

use <../components/closable_box/sliding_box.scad>
use <../components/closable_box/sliding_lid.scad>
use <../core/slot_layout.scad>
use <../core/slot_layout_components.scad>
use <../lib/debug.scad>
use <../lib/holes.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/text.scad>
use <../lib/transforms.scad>
use <../placeholders/xt90e-m.scad>

module power_socket_case_lid(size=power_socket_case_size,
                             color,
                             side_thickness=power_socket_case_side_thickness,
                             front_thickness=power_socket_case_front_thickness,
                             fn=power_socket_case_fn,
                             corner_rad=power_socket_case_corner_rad,
                             rim_h=power_socket_case_rim_h,
                             rim_w=power_socket_case_rim_w,
                             include_rim_sizing=power_socket_case_use_rim_sizing,
                             use_inner_round=power_socket_case_use_inner_round,
                             rim_front_w=power_socket_case_rim_front_w,
                             lid_thickness=power_socket_case_lid_thickness,
                             rail_thickness=power_socket_case_rail_thickness,
                             rail_tolerance=power_socket_case_rail_tolerance,
                             hook_h=power_socket_case_hook_h,
                             hook_l=power_socket_case_hook_l,
                             rail_top_thickness=power_socket_case_rail_top_thickness,
                             hook_distance=power_socket_case_hook_distance,
                             center=true,
                             debug=false) {

  module lid_box() {
    color(color, alpha=1) {
      sliding_lid(size=size,
                  thickness=lid_thickness,
                  debug=debug,
                  side_thickness=side_thickness,
                  corner_rad=corner_rad,
                  use_inner_round=use_inner_round,
                  rim_h=rim_h,
                  fn=fn,
                  include_rim_sizing=include_rim_sizing,
                  front_thickness=front_thickness,
                  rim_w=rim_w,
                  rim_front_w=rim_front_w,
                  hook_h=hook_h,
                  hook_l=hook_l,
                  rail_thickness=rail_thickness,
                  rail_tolerance=rail_tolerance,
                  rail_top_thickness=rail_top_thickness,
                  hook_distance=hook_distance);
    }
  }
  maybe_translate([center ? 0 : size[0] / 2, center ? 0 : size[1] / 2, 0]) {
    difference() {
      lid_box();
      translate([power_case_bolt_spacing_offset_x,
                 power_case_bolt_spacing_offset_y,
                 0]) {

        four_corner_children(power_case_bottom_bolt_spacing,
                             center=true) {
          counterbore(d=power_case_bottom_bolt_dia,
                      h=lid_thickness,
                      sink=false,
                      reverse=false);
        }
      }
      four_corner_children(power_socket_bolt_lid_mounting_spacing,
                           center=true) {
        counterbore(d=power_case_bottom_bolt_dia,
                    h=lid_thickness,
                    sink=false,
                    reverse=false);
      }
    }
  }
}
power_socket_case_lid();
