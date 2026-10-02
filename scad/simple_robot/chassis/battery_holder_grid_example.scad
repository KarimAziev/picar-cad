/**
 * Module: Simple robot battery-holder grid example
 *
 * Demonstrates the legacy chassis layout using the shared grid helpers.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../chassis_parameters.scad>

use <../../core/grid.scad>
use <../../core/slot_placeholder_grid.scad>
use <../../placeholders/battery_holder/util.scad>

echo("MERGED",
     merge_specs_rows_by_placeholder_types(chassis_body_battery_holders_specs,
                                           plist=["show_battery", true],
                                           override=true,
                                           placeholder_types=["battery_holder"]));

specs = ["type", "grid",
         "size", [chassis_body_w, chassis_body_len],
         "rows",
         maybe_add_battery_holders_rows_h([["cells",
                                            [["w", 0.5,
                                              "placeholder",
                                              ["placeholder_type", "battery_holder",
                                               "mount_type", battery_holder_mount_type,
                                               "count", 3,
                                               "show_battery", true,
                                               "terminal_type", battery_holder_terminal_type,
                                               "side_wall_cutout_type", battery_holder_side_wall_type,]],
                                             ["w", 0.5,
                                              "placeholder",
                                              ["placeholder_type", "battery_holder",
                                               "terminal_type", "coil_spring",
                                               "side_wall_cutout_type", "enclosed",
                                               "battery_len", 70,
                                               "battery_dia", 21,
                                               "show_battery", true,
                                               "mount_type", "under_cell",
                                               "battery_color", "pink",
                                               "color", "black"]]]],
                                           ["cells",
                                            [["w", 1,
                                              "spin", 90,
                                              "align_y", 1,
                                              "placeholder",
                                              ["placeholder_type", "battery_holder",
                                               "show_battery", true,
                                               "count", 1,
                                               "mount_type", battery_holder_mount_type,
                                               "terminal_type", battery_holder_terminal_type,
                                               "side_wall_cutout_type", battery_holder_side_wall_type,]]],]])];

translate([-chassis_body_w / 2, 0, 0]) {
  slot_or_placeholder_grid(mode="placeholder",
                           grid=specs,
                           debug=true,
                           debug_spec=["border_w", 0]);
}

// translate([-chassis_body_w / 2, 0, 0]) {
//   slot_or_placeholder_grid(mode="slot",
//                            grid=chassis_body_battery_holders_specs,
//                            debug=true);
// }
