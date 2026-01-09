/**
 * Module: Common slot renderer
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../colors.scad>

use <../core/slot_layout.scad>
use <../lib/debug.scad>
use <../lib/functions.scad>
use <../lib/holes.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/text.scad>
use <../lib/transforms.scad>

module slot_renderer(plist,
                     slot_type,
                     cell_size,
                     align_x = -1,
                     align_y = -1,
                     thickness,
                     spin,
                     placeholder,
                     placeholder_size,
                     thickness=2,
                     debug=false) {

  spin = with_default(spin, 0);
  slot_size = plist_get("slot_size", plist, plist_get("size", plist));
  slot_type = with_default(slot_type, plist_get("slot_type", plist));
  cell_size = with_default(cell_size, slot_size);

  debug_highlight(debug) {

    if (slot_type == "rect") {
      let (recess_h = plist_get("recess_h", plist, 0),
           recess_size = plist_get("recess_size", plist, []),
           round_side = plist_get("round_side", plist, 0),
           corner_rad = plist_get("corner_rad", plist),

           recess_corner_rad = plist_get("recess_corner_rad",
                                         plist,
                                         corner_rad),
           corner_factor = plist_get("corner_factor", plist, 0.3),
           reverse = plist_get("recess_reverse", plist, false),
           full_size = full_rect_slot_size(size=slot_size,
                                           recess_size=recess_size)) {
        align_children_with_spin(parent_size=cell_size,
                                 size=full_size,
                                 align_x=align_x,
                                 align_y=align_y,
                                 spin=spin) {
          rect_slot(size=[with_default(slot_size[0], 0),
                          with_default(slot_size[1], 0)],
                    recess_size=recess_size,
                    recess_h=recess_h,
                    h=thickness,
                    r=corner_rad,
                    recess_corner_r=recess_corner_rad,
                    r_factor=corner_factor,
                    side=round_side,
                    reverse=reverse,
                    center=false);
        }
      }
    } else if (slot_type == "four_corner_holes") {
      let (d = plist_get("d", plist, 0),
           bore_h = plist_get("bore_h", plist, 0),
           bore_d = plist_get("bore_d", plist, 0),
           sink = plist_get("sink", plist, false),
           reverse = plist_get("bore_reverse", plist, false),
           fn = plist_get("fn", plist, 60),
           full_size = four_corner_counterbores_full_size(size=slot_size,
                                                          d=d,
                                                          bore_d=bore_d,
                                                          bore_h=bore_h)) {
        align_children_with_spin(parent_size=cell_size,
                                 size=full_size,
                                 align_x=align_x,
                                 align_y=align_y,
                                 spin=spin) {
          four_corner_counterbores(size=[with_default(slot_size[0], 0),
                                         with_default(slot_size[1], 0)],
                                   center=false,
                                   d=d,
                                   fn=fn,
                                   bore_d=bore_d,
                                   h=thickness,
                                   sink=sink,
                                   bore_h=bore_h,
                                   reverse=reverse);
        }
      }
    } else if (slot_type == "counterbore") {
      let (d = plist_get("d", plist, with_default(slot_size[0], 0)),
           bore_h = plist_get("bore_h", plist, 0),
           bore_d = plist_get("bore_d", plist, 0),
           sink = plist_get("sink", plist, false),
           reverse = plist_get("bore_reverse", plist, false),
           size = is_no_bore(bore_h=bore_h, bore_d=bore_d)
           ? [d, d]
           : [max(bore_d, d), max(bore_d, d)],
           parent_size = is_undef(cell_size) ? size : cell_size) {

        align_children_with_spin(parent_size=parent_size,
                                 size=size,
                                 align_x=align_x,
                                 align_y=align_y,
                                 spin=spin) {
          counterbore(d=d,
                      bore_d=bore_d,
                      sink=sink,
                      h=thickness,
                      bore_h=bore_h,
                      reverse=reverse,
                      center=false);
        }
      }
    } else if (!is_undef(slot_type)) {
      $type = slot_type;
      $plist = plist;
      $thickness = thickness;
      $cell_size = cell_size;
      $align_x = align_x;
      $align_y = align_y;
      $spin = spin;
      $placeholder = placeholder;
      $placeholder_size = placeholder_size;

      children();
    }
  }
}

dia = 10;
bore_dia = 18;
bore_h = 1;
rect_size = [20, 30];
single_hole_d = 8;
four_corner_holes_size = [40, 60];
gap = 2;

union() {
  slot_renderer(["slot_type", "four_corner_holes",
                 "d", dia,
                 "slot_size", four_corner_holes_size,
                 "bore_h", bore_h,
                 "bore_d", bore_dia],
                thickness=3);
  translate([0,
             four_corner_counterbores_full_size(d=dia,
                                                bore_d=bore_dia,
                                                bore_h=bore_h,
                                                size=four_corner_holes_size)[1]
             + gap,
             0]) {
    slot_renderer(["slot_type", "counterbore",
                   "d", dia,
                   "bore_h", bore_h,
                   "bore_d", bore_dia],
                  thickness=3);
    translate([0, bore_dia + gap, 0]) {
      slot_renderer(["slot_type", "rect",
                     "slot_size", rect_size,
                     "corner_rad", 3],
                    thickness=3);
    }
  }
}
