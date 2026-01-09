/**
 * Module: Battery holder utility functions
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../colors.scad>
include <../../parameters.scad>

use <../../core/grid.scad>
use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <contact.scad>

function _battery_holder_full_len(front_rear_thickness, battery_len) =
  battery_len + front_rear_thickness * 2;

function _battery_holder_single_width(inner_thickness, battery_dia) =
  battery_dia + inner_thickness * 2;

function _battery_holder_full_w(inner_thickness, count, battery_dia) =
  let (single_width =
       _battery_holder_single_width(inner_thickness=inner_thickness,
                                    battery_dia=battery_dia),
       total_w = single_width * count)
  total_w;

function battery_holder_solder_tab_full_len(inner_thickness,
                                            side_thickness,
                                            count,
                                            front_rear_thickness,
                                            battery_dia,
                                            battery_len,
                                            terminal_type,
                                            contact_hole_d,
                                            tab_contact_slot_pad_len) =
  let (solder_len =
       solder_tab_outer_len(battery_dia=battery_dia,
                            contact_hole_d=contact_hole_d,
                            front_rear_thickness=front_rear_thickness),
       slot_len = tab_contact_slot_pad_len
       + front_rear_thickness
       + solder_len,
       full_len = length + (slot_len - front_rear_thickness) * 2,
       length =
       _battery_holder_full_len(front_rear_thickness=front_rear_thickness,
                                battery_len=battery_len),
       base_width = _battery_holder_full_w(inner_thickness=inner_thickness,
                                           count=count,
                                           battery_dia=battery_dia),
       full_w = base_width + side_thickness * 2)

  [full_w, full_len];

function battery_holder_full_size(inner_thickness,
                                  side_thickness,
                                  count,
                                  front_rear_thickness,
                                  battery_dia,
                                  battery_len,
                                  terminal_type,
                                  contact_hole_d,
                                  tab_contact_slot_pad_len) =
  let (solder_len =
       (terminal_type == "solder_tab"
        ? solder_tab_outer_len(battery_dia=battery_dia,
                               contact_hole_d=contact_hole_d,
                               front_rear_thickness=front_rear_thickness)
        + tab_contact_slot_pad_len
        : 0),
       length =
       _battery_holder_full_len(front_rear_thickness=front_rear_thickness,
                                battery_len=battery_len),
       full_len = length + solder_len * 2,
       base_width = _battery_holder_full_w(inner_thickness=inner_thickness,
                                           count=count,
                                           battery_dia=battery_dia),
       full_w = base_width + side_thickness * 2)

  [full_w, full_len];

function battery_holder_full_size_from_plist(plist = []) =
  battery_holder_full_size(inner_thickness=plist_get("inner_thickness",
                                                     plist,
                                                     battery_holder_inner_thickness),
                           side_thickness=plist_get("side_thickness",
                                                    plist,
                                                    battery_holder_side_thickness),
                           count=plist_get("count", plist,
                                           battery_holder_cell_count),
                           front_rear_thickness=plist_get("front_rear_thickness",
                                                          plist,
                                                          battery_holder_front_rear_thickness),
                           battery_dia=plist_get("battery_dia", plist,
                                                 battery_dia),
                           battery_len=plist_get("battery_len",
                                                 plist,
                                                 battery_length),
                           terminal_type=plist_get("terminal_type",
                                                   plist,
                                                   battery_holder_terminal_type),
                           contact_hole_d=plist_get("contact_hole_d", plist,
                                                    battery_holder_tab_hole_d),
                           tab_contact_slot_pad_len=plist_get("tab_contact_slot_pad_len",
                                                              plist,
                                                              battery_holder_tab_slot_extra_len));

function maybe_add_battery_holders_rows_h(rows) =
  [for (row = rows)
      let (batt_holder_sizes = [for (cell = plist_get("cells", row, []))
               let (placeholder = plist_get("placeholder", cell, []),
                    placeholder_type = plist_get("placeholder_type", placeholder))
                 if (placeholder_type == "battery_holder")
                   battery_holder_full_size_from_plist(placeholder)],
           batt_holder_lengths = [for (v = batt_holder_sizes) v[1]],
           h = len(batt_holder_lengths) > 0
           ? max(batt_holder_lengths)
           : plist_get(row, "h", 0))
        plist_merge(["h", h], row)];

echo("MERGED",
     merge_specs_rows_by_placeholder_types(chassis_body_battery_holders_specs,
                                           plist=["show_battery", true],
                                           override=true,
                                           placeholder_types=["battery_holder"]));

// echo("ROWS",
//      maybe_add_battery_holders_rows_h([["cells",
//                                         [["w", 0.5,
//                                           "align_y", -1,
//                                           "align_x", -1,
//                                           "placeholder",
//                                           ["placeholder_type", "battery_holder",
//                                            "battery_len", battery_length,
//                                            "battery_dia", battery_dia,
//                                            "mount_type", "intercell",
//                                            "terminal_type", "solder_tab",
//                                            "side_wall_cutout_type", "skeleton"]],
//                                          ["w", 0.5,
//                                           "align_y", -1,
//                                           "align_x", -1,
//                                           "placeholder",
//                                           ["placeholder_type", "battery_holder",
//                                            "battery_len", battery_length,
//                                            "battery_dia", battery_dia,
//                                            "mount_type", "intercell",
//                                            "terminal_type", "solder_tab",
//                                            "side_wall_cutout_type", "skeleton"]]]]]));