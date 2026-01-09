/**
 * Module: SMD Power Inductor
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../colors.scad>

use <../../lib/debug.scad>
use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/text.scad>
use <../../lib/transforms.scad>

module shielded_power_inductor(size=[10, 10, 5],
                               r,
                               r_factor=0.2,
                               color=metallic_silver_4,
                               text,
                               text_props,
                               center=false) {
  x = size[0];
  y = size[1];
  h = size[2];
  text_props = with_default(text_props, []);
  translate([center ? 0 : x / 2, center ? 0 : y / 2, 0]) {
    color(color, alpha=1) {
      linear_extrude(height=size[2], center=false) {
        rounded_rect(size, center=true, r_factor=r_factor, r=r);
      }
    }
    if (!is_undef(text)) {
      translate([0, 0, h]) {
        rotate([0, 0, x < y ? 90 : 0]) {
          color(plist_get("color", text_props, matte_black_2), alpha=1) {
            text_fit(txt=is_num(text) ? str(text) : text,
                     x=min(x, y) * 0.6,
                     y=min(x, y) * 0.6,
                     spacing=plist_get("spacing", text_props, 1),
                     font=plist_get("font", text_props),
                     h=0.1);
          }
        }
      }
    }
  }
}

module unshielded_power_inductor(size=[10, 10, 5],
                                 d,
                                 thickness=1,
                                 cutout_d,
                                 color=matte_black,
                                 text,
                                 text_props,
                                 center=false) {

  x = size[0];
  y = size[1];
  h = size[2];
  text_props = with_default(text_props, []);
  cutout_d = with_default(cutout_d, min(x, y) * 0.25);
  d = with_default(d, min(x, y) - cutout_d);

  module base_lid() {
    color(color, alpha=1) {
      linear_extrude(height=thickness, center=false) {
        difference() {
          chamfered_rect(size=size);
          if (x >= y) {
            mirror_copy([1, 0, 0]) {
              translate([-x / 2, 0, 0]) {
                circle(d=cutout_d, $fn=10);
              }
            }
          } else {
            mirror_copy([0, 1, 0]) {
              translate([0, -y / 2, 0]) {
                circle(d=cutout_d, $fn=10);
              }
            }
          }
        }
      }
    }
  }

  translate([center ? 0 : x / 2, center ? 0 : y / 2, 0]) {
    union() {
      base_lid();
      color(metallic_gold_2, alpha=1) {
        translate([0, 0, thickness]) {
          cylinder(d=d, h=h - thickness * 2);
        }
      }
      translate([0, 0, h - thickness]) {
        base_lid();
        if (!is_undef(text)) {
          color(plist_get("color", text_props, matte_black_2), alpha=1) {
            translate([0, 0, thickness]) {
              text_fit(txt=is_num(text) ? str(text) : text,
                       x=x - cutout_d - 0.1,
                       y=y - cutout_d - 0.1,
                       spacing=plist_get("spacing", text_props, 1),
                       font=plist_get("font", text_props),
                       h=0.1);
            }
          }
        }
      }
    }
  }
}

module shielded_power_inductor_from_plist(plist, center=false) {
  size = plist_get("placeholder_size", plist);
  r = plist_get("r", plist, undef);
  r_factor = plist_get("r_factor", plist, 0.2);
  color = plist_get("color", plist, metallic_silver_4);
  text = plist_get("text", plist, undef);
  text_props = plist_get("text_props", plist, undef);

  shielded_power_inductor(size=size,
                          r=r,
                          r_factor=r_factor,
                          color=color,
                          text=text,
                          text_props=text_props,
                          center=center);
}

module unshielded_power_inductor_from_plist(plist, center=false) {
  size = plist_get("placeholder_size", plist);
  d = plist_get("d", plist, undef);
  thickness = plist_get("thickness", plist, 1);
  cutout_d = plist_get("cutout_d", plist, undef);
  color = plist_get("color", plist, matte_black);
  text = plist_get("text", plist, undef);
  text_props = plist_get("text_props", plist, undef);

  unshielded_power_inductor(center=center,
                            size=size,
                            d=d,
                            thickness=thickness,
                            cutout_d=cutout_d,
                            color=color,
                            text=text,
                            text_props=text_props);
}

size = [10, 10, 5];

translate([1, 0, 0]) {
  unshielded_power_inductor_from_plist(["placeholder_size", size,
                                        "text", 330]);
}

translate([-size[0] - 1, 0, 0]) {
  shielded_power_inductor_from_plist(["placeholder_size", size, "text", 220]);
}