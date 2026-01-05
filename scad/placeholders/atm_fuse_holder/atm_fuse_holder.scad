/**
 * Module: Mini ATM Blade Fuse Holder
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../parameters.scad>
include <../../colors.scad>

use <../../lib/transforms.scad>
use <../../lib/plist.scad>
use <../../lib/slots.scad>
use <atm_fuse_holder_cap.scad>
use <atm_fuse_holder_body.scad>

module atm_fuse_holder_from_spec(plist,
                                 align_x = -1,
                                 align_y = -1,
                                 thickness=2,
                                 cell_size,
                                 spin,
                                 slot_mode=false,
                                 center=true) {
  plist = with_default(plist, []);
  body_plist = plist_get("body", plist, []);
  reverse = plist_get("reverse", plist, false);
  size = plist_get("size",
                   body_plist,
                   [atm_fuse_holder_body_bottom_l,
                    atm_fuse_holder_body_thickness,
                    atm_fuse_holder_body_h,
                    atm_fuse_holder_body_top_l]);
  body_h = size[2];

  color = plist_get("color", plist, matte_black_2);
  show_cap = plist_get("show_cap",
                       plist,
                       true);
  show_body = plist_get("show_body",
                        plist,
                        true);
  wiring = plist_get("wiring",
                     plist,
                     ["d", atm_fuse_holder_body_wiring_d,
                      "socket_type", "sphere",
                      "socket_type_len", 4,
                      "color", red_1,
                      "cutted_len", 3,
                      "left_pts", [[25, 0, 0]],
                      "right_pts", [[25, 0, 0]]]);

  wiring_base_d = plist_get("base_d", wiring, min(size[1], size[2]) * 0.8);
  socket_type_len = plist_get("socket_type_len", wiring, 4);
  socket_type = plist_get("socket_type", wiring, "sphere");

  body_corner_rad = plist_get("corner_rad", body_plist, 2);
  body_round_side = plist_get("round_side", body_plist, "bottom");

  rib = plist_get("rib",
                  body_plist,
                  ["h", atm_fuse_holder_body_rib_h,
                   "l", atm_fuse_holder_body_rib_l,
                   "n", atm_fuse_holder_body_rib_n,
                   "thickness", atm_fuse_holder_body_rib_thickness,
                   "distance_from_top", 0]);
  cap_collar = plist_get("cap_collar",
                         plist,
                         ["size", [atm_fuse_holder_mounting_hole_l,
                                   atm_fuse_holder_mounting_hole_h,
                                   atm_fuse_holder_mounting_hole_depth],
                          "r", atm_fuse_holder_mounting_hole_r,
                          "fuse_holes_spacing", [8, 4],
                          "fuse_hole_size", [6.0, 1.82],
                          "fuse_holes_pad_x", 4,
                          "fuse_holes_pad_y", 0,
                          "rib_thickness", 1,
                          "rib_h", 0.8,
                          "colr", matte_black,
                          "rib_colr", matte_black_2,
                          "rib_positions", [0.5]]);

  cap_collar_size = plist_get("size",
                              cap_collar,
                              [atm_fuse_holder_mounting_hole_l,
                               atm_fuse_holder_mounting_hole_h,
                               atm_fuse_holder_mounting_hole_depth]);

  default_slot_size = [cap_collar_size[0] + 1, cap_collar_size[1] + 2];

  slot_size = plist_get("slot_size", plist, default_slot_size);

  slot_corner_rad = plist_get("corner_rad",
                              plist,
                              min(slot_size[0], slot_size[1]) * 0.63);

  cap_plist = plist_get("cap",
                        plist,
                        ["size", [atm_fuse_holder_cap_top_l,
                                  atm_fuse_holder_cap_thickness,
                                  atm_fuse_holder_cap_h,
                                  atm_fuse_holder_cap_bottom_l,],
                         "corner_rad", 2,
                         "round_side", "top",
                         "hole_size", atm_fuse_holder_cap_hole_size,
                         "color", matte_black_2,
                         "rib", ["h", atm_fuse_holder_cap_rib_h,
                                 "l", atm_fuse_holder_cap_rib_l,
                                 "n", atm_fuse_holder_cap_rib_n,
                                 "thickness", atm_fuse_holder_cap_rib_thickness,
                                 "distance_from_top", atm_fuse_holder_cap_rib_distance]]);

  module fuse_holder() {
    maybe_translate([0, 0, reverse ? body_h : 0]) {
      maybe_rotate([0, reverse ? 180 : 0, 0]) {
        union() {
          if (show_body) {
            atm_fuse_holder_body(size=size,
                                 round_side=body_round_side,
                                 color=color,
                                 wiring=wiring,
                                 corner_rad=body_corner_rad,
                                 rib=rib,
                                 cap_collar=cap_collar);
          }

          if (show_cap) {
            translate([0, 0, size[2]]) {
              atm_fuse_holder_cap_from_plist(cap_plist);
            }
          }
        }
      }
    }
  }

  full_slot_size = full_rect_slot_size(size=slot_size,
                                       plist_get("recess_size", plist));

  full_fuse_holder_size = [size[0] + (socket_type_len + (socket_type == "sphere"
                                                         ? wiring_base_d / 2
                                                         : 0)) * 2, size[1]];

  full_size = [max(full_fuse_holder_size[0],
                   full_slot_size[0]),
               max(full_fuse_holder_size[1],
                   full_slot_size[1])];

  module slot() {
    slot_data = plist_merge(plist,
                            ["h", thickness,
                             "size", slot_size,
                             "r", slot_corner_rad]);

    rect_slot_from_plist(slot_data, center=true);
  }

  module slot_or_placeholder() {
    if (slot_mode) {
      slot();
    } else {
      fuse_holder();
    }
  }

  if (center) {
    maybe_rotate([0, 0, spin]) {
      slot_or_placeholder();
    }
  } else {

    align_children_with_spin(parent_size=cell_size,
                             size=full_size,
                             align_x=align_x,
                             align_y=align_y,
                             spin=spin) {
      translate([full_size[0] / 2, full_size[1] / 2, 0]) {
        slot_or_placeholder();
      }
    }
  }
}

spin = -20;
atm_fuse_holder_from_spec(plist=[],
                          spin=spin,
                          slot_mode=true,
                          center=false);

atm_fuse_holder_from_spec(plist=["show_cap", false, "reverse", true],

                          spin=spin,
                          slot_mode=false,
                          center=false);
