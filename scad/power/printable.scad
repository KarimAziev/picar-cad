/**
 * Module: Printable parts of power case stack
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../parameters.scad>

use <../components/closable_box/grid.scad>
use <../core/grid.scad>
use <../lib/plist.scad>
use <../lib/transforms.scad>
use <power_case.scad>
use <power_lid.scad>
use <power_socket_case.scad>
use <power_socket_lid.scad>

power_case_printable_grid = ["type","grid",
                             "size", [max(power_case_width,
                                          power_socket_case_size[0],
                                          power_lid_width) * 4 + 20,
                                      max(power_case_length,
                                          power_socket_case_size[1])],
                             "rows",
                             [["h", 1,
                               "cells", [["w", 0.25,
                                          "placeholder", ["type", "power_case_lid"]],
                                         ["w", 0.25,
                                          "placeholder", ["type", "power_case"]],
                                         ["w", 0.25,
                                          "placeholder", ["type", "power_socket_lid"]],
                                         ["w", 0.25,
                                          "placeholder", ["type", "power_socket_case"]]]]]];

module power_case_printable_stack(grid=power_case_printable_grid,
                                  color="white",
                                  debug=false,
                                  debug_spec=["gap", 10,
                                              "color", yellow_3,
                                              "text_h", 1,
                                              "border_h", 2,
                                              "border_w", 0.5,
                                              "size", 2],

                                  level=0) {

  assert(grid_is(grid),
         "grid_plist: grid must be a plist with type='grid'");

  size = plist_get("size", grid, undef);
  assert(!is_undef(size) && len(size)==2,
         "grid_plist: grid must have 'size'=[x,y] at top level");

  grid_plist_render(size=size,
                    grid=grid,
                    debug=debug,
                    mode="placeholder",
                    debug_spec=debug_spec,
                    level=level) {

    placeholder_type = plist_get("type", $placeholder);
    spin = plist_get("spin", $cell, 0);
    y_offset = plist_get("y_offset", $cell);
    x_offset = plist_get("x_offset", $cell);
    has_offset = (is_num(x_offset) && x_offset != 0) || (is_num(y_offset) && y_offset != 0);

    maybe_translate([has_offset ? with_default(x_offset, 0) : x_offset,
                     has_offset ? with_default(y_offset, 0) : y_offset, 0]) {
      maybe_rotate([0, 0, spin]) {
        color(color, alpha=1) {
          if (placeholder_type == "power_case") {
            power_case(center=false);
          } else if (placeholder_type == "power_case_lid") {
            power_lid_printable(center=false);
          } else if (placeholder_type == "power_socket_case") {
            power_socket_case_printable(center=false);
          } else if (placeholder_type == "power_socket_lid") {
            power_socket_case_lid(center=false);
          }
        }
      }
    }
  }
}
power_case_printable_stack();