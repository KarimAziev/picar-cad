/**
  * Module: Ring terminal placeholder
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>

use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>
use <../../lib/trapezoids.scad>

plist_example = ["d", 4.33,
                 "od", 6.61,
                 "w", 3.35,
                 "l", 9.1,
                 "t", 0.62,
                 "color", metallic_silver_5,
                 "insulate", ["color", "#3771E1",
                              "l", 10.5,
                              "d", 5.9]];

function ring_terminal_props(plist) =
  let (d=plist_get("d", plist),
       od=plist_get("od", plist),
       l=plist_get("l", plist),
       t=plist_get("t", plist),
       w=plist_get("w", plist),
       insulate=plist_get("insulate", plist, []),
       insulate_color=plist_get("color", insulate),
       insulate_l=plist_get("l", insulate, 0),
       insulate_d=plist_get("d", insulate),
       d1=plist_get("d1", insulate),
       d2=plist_get("d2", insulate),
       total_l = insulate_l + l,
       max_w = max(concat((insulate_l > 0 ? [for (v = [d1, d2, insulate_d]) if (v) v] : []), [t])))

  ["t", t,
   "l", l,
   "d", d,
   "od", od,
   "insulate_l", insulate_l,
   "w", w,
   "insulate", insulate,
   "color", plist_get("color", plist),
   "insulate_color", insulate_color,
   "insulate_d", insulate_d,
   "d1", d1,
   "d2", d2,
   "total_l", total_l,
   "max_w", max_w];

module ring_terminal(plist, orientation="whl", anchor=[0, 0, 1], spin=0) {
  props = ring_terminal_props(plist);
  l = plist_get("l", props);
  t = plist_get("t", props);
  d = plist_get("d", props);
  od = plist_get("od", props);
  insulate_l = plist_get("insulate_l", props);
  w = plist_get("w", props);
  color = plist_get("color", props);
  insulate_color = plist_get("insulate_color", props);
  insulate_d = plist_get("insulate_d", props);
  d1 = plist_get("d1", props);
  d2 = plist_get("d2", props);
  total_l = plist_get("total_l", props);
  max_w = plist_get("max_w", props);

  with_orientation(from="whl",
                   to=orientation,
                   anchor=anchor,
                   size=[od, total_l, max_w]) {
    maybe_rotate([0, 0, spin]) {
      translate([0, 0, insulate_l]) {
        color(color, alpha=1) {
          let (tran_l = l - od) {
            translate([0, 0, tran_l / 2]) {
              rotate([90, 0, 0]) {
                linear_extrude(height=t, center=true) {
                  trapezoid(b=w, t=d, h=tran_l + od - d, center=true);
                }
              }
            }
            translate([0, 0, tran_l]) {
              rotate([0, 0, 90]) {
                ring(od=od, d=d, h=t, orientation="hlw");
              }
            }
          }
        }
      }

      if (insulate_l > 0 && insulate_d || d1 || d2) {
        let (d1 = with_default(d1, insulate_d),
             h1 = insulate_l * 0.4,
             d2 = with_default(d2, d1 * 0.84),
             h2 = insulate_l * 0.4,
             h_tran = insulate_l - h1 - h2) {

          color(insulate_color, alpha=1) {
            cyl(h=h1, d=d1);
            translate([0, 0, h1]) {
              cyl(h=h_tran, d1=d1, d2=d2);
              translate([0, 0, h_tran]) {
                cyl(h=h2, d=d2);
              }
            }
          }
        }
      }
    }
  }
}

ring_terminal(plist_example, anchor=[1, 1, 1]);