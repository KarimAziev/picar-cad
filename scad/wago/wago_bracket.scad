/**
  * Module: Screw-mounted Wago 221 cradle with releasable side clips.
  * The wire face is -Y. All printed geometry starts at zero on X/Y/Z.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../parameters.scad>
use <../lib/plist.scad>
use <../lib/transforms.scad>
use <../lib/shapes3d.scad>
use <../placeholders/bolt.scad>
use <../placeholders/wago/wago_221.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  wago_bracket_props
  ─────────────────────────────────────────────────────────────────────────────
  Resolve the cradle and its mounting pattern from the measured connector.
  **Parameters:**
  - `pl`: Bracket plist. `wago` is the hardware plist for wago_from_plist.
    `clearance` = 0.25 per XY side; `top_clearance` = 0.25 above the body;
    `base_t` = 2.4; `wall_t` = 1.6; `clip_l` = 8; `clip_overlap` = 0.5;
    `clip_rise` = 0.8; `flex_gap` = 0.8; `stop_h` = 2.5;
    `bolt_d` = 3 nominal, `bolt_clearance` = 0.3 diametral;
    `ear_d` = 10; `mount_side` = "rear" (compact) or "sides". All dimensions are mm. clip_overlap=0 omits the lip.
  **Returns:**
  Plist with printed `size`, measured `wago_size`, canonical `wago_pos`,
  two XY `mount_holes`, `tray_w`, and the resolved construction dimensions.
  The clip overlap must stay within the measured outer side shoulders.
 */
function wago_bracket_props(pl=[]) =
  assert(plist_is(pl), "Wago bracket parameters must be a plist")
  let (hardware = plist_get("wago", pl, []),
       n = plist_get("n", hardware, wago_n),
       conductor = plist_get("conductor_size", hardware, wago_conductor_size),
       ws = wago_size(n, conductor, plist_get("total_w", hardware, wago_total_w)),
       c = plist_get("clearance", pl, 0.25),
       zc = plist_get("top_clearance", pl, 0.25),
       t = plist_get("base_t", pl, 2.4),
       wall = plist_get("wall_t", pl, 1.6),
       clip_l = plist_get("clip_l", pl, 8),
       overlap = plist_get("clip_overlap", pl, 0.5),
       rise = plist_get("clip_rise", pl, 0.8),
       flex = plist_get("flex_gap", pl, 0.8),
       stop = plist_get("stop_h", pl, 2.5),
       d = plist_get("bolt_d", pl, 3),
       dc = plist_get("bolt_clearance", pl, 0.3),
       ear = plist_get("ear_d", pl, 10),
       mount_side = plist_get("mount_side", pl, "rear"),
       sides = mount_side == "sides",
       tray_w = ws[0] + 2*(c + wall),
       l = ws[1] + 2*(c + wall),
       h = t + ws[2] + zc + rise,
       shoulder = (ws[0] - n*conductor[0])/2,
       head_d = find_bolt_head_d(d, "pan"))
  assert(c >= 0 && zc >= 0 && t > 0 && wall > 0 && rise > 0 && flex > 0,
         "Wago clearances must be nonnegative and material dimensions positive")
  assert(clip_l > 0 && clip_l + 2*flex < ws[1] && stop > 0 && stop <= ws[2],
         "Wago clip length or end stop height is invalid")
  assert(overlap >= 0 && (overlap == 0 || overlap < shoulder),
         "Clip overlap must fit the measured side shoulder; set clip_overlap=0 for a plain cradle")
  assert(d > 0 && dc >= 0 && ear >= head_d + 2*wall && ear <= l,
         "Mounting ears must contain the bolt heads and a wall margin")
  assert(mount_side == "rear" || mount_side == "sides", "mount_side must be rear or sides")
  assert(sides || tray_w > 2*ear, "Rear ears need a wider connector; use mount_side=sides")
  ["size", [tray_w + (sides ? 2*ear : 0), l + (sides ? 0 : ear), h], "wago", hardware, "wago_size", ws,
   "wago_pos", [(sides ? ear : 0) + wall + c, wall + c, t],
   "mount_holes", sides ? [[ear/2, l/2], [ear + tray_w + ear/2, l/2]]
   : [[ear/2, l+ear/2], [tray_w-ear/2, l+ear/2]],
   "mount_side", mount_side, "tray_l", l, "tray_x", sides ? ear : 0,
   "tray_w", tray_w, "ear_d", ear, "base_t", t, "wall_t", wall,
   "clearance", c, "top_clearance", zc, "clip_l", clip_l,
   "clip_overlap", overlap, "clip_rise", rise, "flex_gap", flex,
   "stop_h", stop, "bolt_d", d, "hole_d", d + dc,
   "shoulder", shoulder];

/**
  ─────────────────────────────────────────────────────────────────────────────
  wago_bracket
  ─────────────────────────────────────────────────────────────────────────────
  Render the printable cradle, mounting cutters, or installed hardware.
  **Parameters:**
  - `pl`: Bracket plist accepted by wago_bracket_props.
  - `anchor`: Printed-envelope anchor; default [1,1,1] keeps positive bounds.
  - `slot_mode`: Emit two through holes along Z using the same reference box.
  - `slot_h`: Cutter depth from bracket bottom; default base thickness.
  - `show_wago`: Display the installed connector (default false).
  - `show_bolts`: Display pan-head mounting bolts (default false).
  - `show_bracket`: Display printed material (default true).
  - `bolt_l`: Preview bolt length, default 8; tips extend below the base.
  **Behavior:**
  Print base-down. Press clips outward to release the connector. The wire face
  and lever bank remain open; the small front stops only touch side shoulders.
  Flexible clip fit requires a physical coupon; lever details are approximate.
 */
module wago_bracket(pl=[], anchor=[1, 1, 1], slot_mode=false, slot_h=undef,
                     show_wago=false, show_bolts=false, show_bracket=true,
                     bolt_l=8) {
  p = wago_bracket_props(pl);
  size = plist_get("size", p);
  ws = plist_get("wago_size", p);
  wp = plist_get("wago_pos", p);
  ear = plist_get("ear_d", p);
  tw = plist_get("tray_w", p);
  tl = plist_get("tray_l", p);
  tx = plist_get("tray_x", p);
  sides = plist_get("mount_side", p) == "sides";
  t = plist_get("base_t", p);
  wall = plist_get("wall_t", p);
  c = plist_get("clearance", p);
  cl = plist_get("clip_l", p);
  gap = plist_get("flex_gap", p);
  lip = plist_get("clip_overlap", p);
  rise = plist_get("clip_rise", p);
  zlip = t + ws[2] + plist_get("top_clearance", p);
  depth = is_undef(slot_h) ? t : slot_h;
  assert(depth > 0 && bolt_l > 0, "Wago cutter depth and bolt length must be positive");

  module _holes(h) {
    for (xy = plist_get("mount_holes", p)) {
      translate(concat(xy, [-0.01])) {
        cylinder(d=plist_get("hole_d", p), h=h + 0.02, $fn=48);
      }
    }
  }

  with_anchor(anchor, size) {
    if (slot_mode) {
      _holes(depth);
    } else {
      if (show_bracket) {
        color(plist_get("color", pl, "SlateGray")) {
          difference() {
            union() {
              translate([tx, 0, 0]) {
                cuboid([tw, tl, t], r=1, anchor=[1, 1, 1]);
              }
              // Rounded ears join the floor over their full inner half.
              for (xy = plist_get("mount_holes", p)) {
                hull() {
                  for (point = [xy, sides
                                  ? [xy[0] < size[0]/2 ? ear + wall : ear + tw - wall, xy[1]]
                                  : [xy[0], tl-wall]]) {
                    translate(concat(point, [0])) {
                      cylinder(d=ear, h=t, $fn=48);
                    }
                  }
                }
              }
              for (right = [false, true]) {
                x = right ? tx + tw - wall : tx;
                // Isolated central cantilever, with low end guides either side.
                translate([x, (tl-cl)/2, t - 0.01]) {
                  cube([wall, cl, zlip-t + 0.01]);
                }
                for (y = [0, (tl+cl)/2 + gap]) {
                  guide_l = (tl-cl)/2 - gap;
                  translate([x, y, t - 0.01]) {
                    cube([wall, guide_l, plist_get("stop_h", p) + 0.01]);
                  }
                }
                if (lip > 0) {
                  // Relieved root and sloping insertion face.
                  // The lip underside is above the measured housing top.
                  translate([right ? x + wall : x, (tl+cl)/2, zlip]) {
                    rotate([90, 0, 0]) {
                      linear_extrude(height=cl) {
                        polygon(right
                          ? [[0,-c-lip], [-wall,-c-lip], [-wall-c,0],
                             [-wall-c-lip,0], [-wall,rise], [0,rise]]
                          : [[0,-c-lip], [wall,-c-lip], [wall+c,0],
                             [wall+c+lip,0], [wall,rise], [0,rise]]);
                      }
                    }
                  }
                }
                // Front stops reach only across the outer body shoulders.
                translate([right ? wp[0]+ws[0]-min(0.6, plist_get("shoulder", p)) : tx,
                           0, t - 0.01]) {
                  cube([wall+c+min(0.6, plist_get("shoulder", p)), wall,
                        plist_get("stop_h", p)+0.01]);
                }
              }
              translate([tx, tl-wall, t - 0.01]) {
                cube([tw, wall, plist_get("stop_h", p)+0.01]);
              }
            }
            _holes(t);
          }
        }
      }
      if (show_wago) {
        translate(wp) {
          wago_from_plist(plist_get("wago", p));
        }
      }
      if (show_bolts) {
        for (xy = plist_get("mount_holes", p)) {
          translate(concat(xy, [t-bolt_l])) {
            bolt(d=plist_get("bolt_d", p), h=bolt_l, threaded=false, head_type="pan");
          }
        }
      }
    }
  }
}

wago_bracket(show_wago=true);
