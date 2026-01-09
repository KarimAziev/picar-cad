/**
 * Module: Placeholder for schottky diodes
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../colors.scad>

use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <smd_resistor.scad>

module schottky_diode(plist, center=false) {
  plist = with_default(plist, []);
  size = plist_get("placeholder_size", plist, [3.4, 1.4, 0.4]);
  x = size[0];
  y = size[1];

  border_color = plist_get("border_color", plist, "white");

  body_h = plist_get("body_h", plist, 0.01);
  border_w = plist_get("border_w", plist, undef);
  border_p = plist_get("border_p", plist, undef);
  body_color = plist_get("body_color", plist, matte_black);
  fillet_factor = plist_get("fillet_factor", plist, 0.2);
  pad_color = plist_get("pad_color", plist, "lightyellow");
  pad_factor_x = plist_get("pad_factor_x", plist, x > y ? 0.6 : 1.1);
  pad_factor_y = plist_get("pad_factor_y", plist, x < y ? 0.6 : 1.1);
  marking = plist_get("marking", plist, undef);
  mark_color = plist_get("mark_color", plist, undef);
  mark_size = plist_get("mark_size", plist, undef);
  mark_font = plist_get("mark_font", plist, "Liberation Sans:style=Bold");
  mark_spacing = plist_get("mark_spacing", plist, 0.8);
  use_inner_round = plist_get("use_inner_round", plist, false);

  smd_resistor(size=size,
               center=center,
               border_color=border_color,
               body_h=body_h,
               border_w=border_w,
               border_p=border_p,
               body_color=body_color,
               fillet_factor=fillet_factor,
               pad_color=pad_color,
               pad_factor_x=pad_factor_x,
               pad_factor_y=pad_factor_y,
               marking=marking,
               mark_color=mark_color,
               mark_size=mark_size,
               mark_font=mark_font,
               mark_spacing=mark_spacing,
               use_inner_round=use_inner_round);
}

schottky_diode(["type", "schottky_diode", "size", [3, 2, 1]]);
