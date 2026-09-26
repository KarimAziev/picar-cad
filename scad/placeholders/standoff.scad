/**
 * Module: Standoff placeholder
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/placement.scad>
use <../lib/plist.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <bolt.scad>

// Memoize attainable minimum heights for integer hardware sizes. Enumerating
// every permutation becomes impractical for the tall battery support columns.
function _standoff_height_table(target, heights, n=1, table=[[]]) =
  n > target ? table[target] :
  let (candidates = [for (h = heights) concat([h], table[max(0, n-h)])],
       best = best_list_by_lower_sum(candidates))
  _standoff_height_table(target, heights, n+1, concat(table, [best]));

function standoff_heights(min_h,
                          body_heights = [20, 15, 10, 9, 8, 6, 5]) =
  min_h <= 0 || len(body_heights) == 0 ? [] :
  assert(min(body_heights) > 0, "Standoff body heights must be positive")
  len([for (h = body_heights) if (h != floor(h)) h]) == 0
  ? _standoff_height_table(ceil(min_h), body_heights)
  : best_height_combo(min_h, body_heights, ceil(min_h / min(body_heights)) + 1);

function calc_standoff_params(d, min_h) =
  let (norm_specs = [for (spec = standoff_specs)
           [plist_get("thread_d", spec), spec]],
       sorted_norm = sort_by_idx(norm_specs, asc=true, idx=0),
       sorted_specs = [for (pair = sorted_norm) pair[1]],
       sorted_dias = [for (spec = sorted_specs) plist_get("thread_d", spec)],
       found = [for (i = [0 : len(sorted_specs) - 1])
           let (spec = sorted_specs[i],
                dia = sorted_dias[i],
                next_dia = sorted_dias[i + 1])
             if (d == dia || (dia < d && (is_undef(next_dia) || next_dia > d)))
               spec][0],
       standoffs = is_undef(found)
       ? []
       : standoff_heights(min_h=min_h,
                          body_heights=plist_get("body_heights", found, [])))
  [found, standoffs];

function standoff_real_h(min_h, d) =
  let (params=calc_standoff_params(min_h=min_h, d=d),
       heights = params[1])
  sum(heights);

module standoff(thread_d=3,
                thread_h=5,
                body_h=4,
                body_d,
                colr=yellow_2,
                thread_at_top=true,
                show_bolt=false,
                bolt_visible_h=0,
                bolt_h,
                bolt_thread_len,      // h of threaded portion (undef -> h)
                bolt_pitch = undef,           // thread pitch (undef -> default metric)
                bolt_threaded = true,         // produce thread ridges
                bolt_thread_depth = undef,    // radial thread depth (undef -> 0.6*pitch)
                bolt_thread_starts = 2,       // 1 = single-start, 2 = two-start (parallel helices)
                bolt_head_type = "pan",       // "pan" | "hex" | "round" | "countersunk" | "none"
                bolt_head_d,        // across-flats for hex or diameter for round/countersunk
                bolt_head_h,
                bolt_color,
                nut_color=metallic_silver_3,
                bolt_unthreaded = 0,          // h at top (next to head) that's unthreaded
                nut_pos,
                show_nut = false,
                $fn=6) {
  module standoff_body() {
    difference() {
      color(colr, alpha=1) {
        cylinder(d=is_undef(body_d) ?
                 thread_d * 2
                 : body_d,
                 h=body_h,
                 $fn=$fn);
      }

      translate([0, 0, -0.1]) {
        cylinder(d=thread_d, h=thread_h + 0.2, $fn=8);
      }
    }
  }

  module standoff_bolt(height) {
    if (show_bolt) {
      bolt(d=thread_d,
           h=height,
           thread_len=bolt_thread_len,
           pitch=bolt_pitch,
           threaded=bolt_threaded,
           bolt_color=bolt_color,
           thread_depth=bolt_thread_depth,
           thread_starts=bolt_thread_starts,
           head_type=bolt_head_type,
           head_d=bolt_head_d,
           head_h=bolt_head_h,
           unthreaded=bolt_unthreaded);
    }
  }
  module standoff_thread() {
    bolt(d=thread_d,
         h=thread_h,
         bolt_color=colr,
         head_type="none",
         lock_nut=false,
         nut_color=nut_color,
         nut_head_distance=with_default(nut_pos,
                                        thread_h - 1),
         show_nut=show_nut);
  }
  if (thread_at_top) {
    if (show_bolt) {
      let (bolt_visible_h = with_default(bolt_visible_h, 0),
           bolt_h = with_default(bolt_h, round(bolt_visible_h + body_h))) {
        translate([0, 0, bolt_h - bolt_visible_h]) {
          rotate([0, 180, 0]) {
            standoff_bolt(height=bolt_h);
          }
        }
      }
    }

    standoff_body();
    translate([0, 0, body_h + thread_h]) {
      rotate([180, 0, 0]) {
        standoff_thread();
      }
    }
  } else {
    standoff_thread();
    if (show_bolt) {

      let (bolt_visible_h = with_default(bolt_visible_h, 0),
           bolt_h = with_default(bolt_h, round(bolt_visible_h + body_h))) {
        translate([0, 0, body_h + thread_h - (bolt_h - bolt_visible_h)]) {
          standoff_bolt(height=bolt_h);
        }
      }
    }
    translate([0, 0, thread_h]) {
      standoff_body();
    }
  }
}

module standoffs_stack(d,
                       min_h,
                       colr=yellow_2,
                       thread_at_top=true,
                       border_color=metallic_gold_2,
                       show_bolt=false,
                       bolt_visible_h=0,
                       bolt_h,
                       bolt_thread_len,      // h of threaded portion (undef -> h)
                       bolt_pitch = undef,           // thread pitch (undef -> default metric)
                       bolt_threaded = true,         // produce thread ridges
                       bolt_thread_depth = undef,    // radial thread depth (undef -> 0.6*pitch)
                       bolt_thread_starts = 2,       // 1 = single-start, 2 = two-start (parallel helices)
                       bolt_head_type = "pan",       // "pan" | "hex" | "round" | "countersunk" | "none"
                       bolt_head_d,        // across-flats for hex or diameter for round/countersunk
                       bolt_head_h,
                       bolt_unthreaded = 0,          // h at top (next to head) that's unthreaded
                       bolt_color,
                       nut_color=metallic_silver_3,
                       nut_pos,
                       show_nut = false,
                       fn=6) {

  standoffs = calc_standoff_params(min_h=min_h, d=d);

  if (!is_undef(standoffs) && len(standoffs[1]) > 0) {
    spec = standoffs[0];
    heights = standoffs[1];
    thread_d = plist_get("thread_d", spec);
    body_d = plist_get("body_d", spec);
    thread_h = plist_get("thread_h", spec);
    fn = plist_get("fn", spec, fn);
    colr = plist_get("color", spec, colr);

    for (i = [0 : len(heights) - 1]) {
      let (body_h = heights[i],
           z = i > 0 ? sum(heights, i) + 0.01 : 0) {
        translate([0, 0, z]) {
          if (i > 0) {
            standoff(body_h=0.4,
                     bolt_color=bolt_color,
                     body_d=body_d + 0.1,
                     thread_d=thread_d,
                     thread_h=0,
                     thread_at_top=thread_at_top,
                     colr=border_color,
                     show_bolt=false,
                     bolt_visible_h=bolt_visible_h,
                     bolt_h=bolt_h,
                     bolt_thread_len=bolt_thread_len,
                     bolt_pitch=bolt_pitch,
                     bolt_threaded=bolt_threaded,
                     bolt_thread_depth=bolt_thread_depth,
                     bolt_thread_starts=bolt_thread_starts,
                     bolt_head_type=bolt_head_type,
                     bolt_head_d=bolt_head_d,
                     bolt_head_h=bolt_head_h,
                     bolt_unthreaded=bolt_unthreaded,
                     $fn=fn);
          }
          standoff(body_h=body_h,
                   body_d=body_d,
                   thread_d=thread_d,
                   bolt_color=bolt_color,
                   thread_h=thread_h,
                   colr=colr,
                   show_bolt=show_bolt && i == 0,
                   thread_at_top=thread_at_top,
                   bolt_visible_h=bolt_visible_h,
                   bolt_unthreaded=bolt_unthreaded,
                   nut_pos=nut_pos,
                   show_nut=show_nut && i == len(heights) - 1,
                   bolt_h=bolt_h,
                   bolt_thread_len=bolt_thread_len,
                   bolt_pitch=bolt_pitch,
                   bolt_threaded=bolt_threaded,
                   bolt_thread_depth=bolt_thread_depth,
                   bolt_thread_starts=bolt_thread_starts,
                   bolt_head_type=bolt_head_type,
                   bolt_head_d=bolt_head_d,
                   bolt_head_h=bolt_head_h,
                   nut_color=nut_color,
                   $fn=fn);
        }
      }
    }
  }
}

module standoffs_sequence(body_heights=[20, 15, 10, 9, 8, 6, 5],
                          gap=2,
                          thread_h=5,
                          thread_d = 3,
                          body_d=5.20,
                          colr=yellow_2,
                          thread_at_top=true,
                          $fn=6,
                          show_text=true,
                          center=false) {
  cols = len(body_heights);
  columns_children(w=body_d,
                   gap=gap,
                   cols=cols,
                   center=center) {
    standoff(body_d=body_d,
             body_h=body_heights[$i],
             thread_d=thread_d,
             thread_h=thread_h,
             colr=colr,
             thread_at_top=thread_at_top,
             $fn=$fn);
    if (show_text) {
      translate([0, gap, 0]) {
        color(colr, alpha=1) {
          linear_extrude(height=0.5, center=false) {
            text(str(body_heights[$i]),
                 size=gap / 2,
                 halign="center",
                 valign="top");
          }
        }
      }
    }
  }
}

module standoff_grid(sizes=[[3, 5.20, 5, [20, 15, 10, 9, 8, 6, 5], 6],
                            [2.5, 4.20, 4, [20, 15, 10, 9, 8, 6, 5], 6],
                            [2, 3.0, 3.0, [20, 15, 10, 9, 8, 6, 5], 12],
                            [2, 4.50, 5.0, [20, 15, 10, 9, 8, 6, 5], 6,
                             white_off_1]],
                     gap=6,
                     show_text=true,
                     colr=yellow_2) {
  max_body_d = max([for (n = sizes) n[1]]);
  rows_children(gap=gap, rows=len(sizes), w=max_body_d) {
    let (spec = sizes[$i]) {
      standoffs_sequence(show_text=show_text,
                         gap=gap,
                         thread_d=spec[0],
                         body_d=spec[1],
                         thread_h=spec[2],
                         body_heights=spec[3],
                         $fn=with_default(spec[4], 6),
                         colr=with_default(spec[5], colr));
      if (show_text) {
        color(with_default(spec[5], colr), alpha=1) {
          translate([-gap / 2, gap, 0]) {
            linear_extrude(height=0.5, center=false) {
              text(str("M", spec[0]),
                   size=gap / 2,
                   halign="right",
                   valign="top");
            }
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  four_corner_standoffs
  ─────────────────────────────────────────────────────────────────────────────
  Render four hardware stacks or their parent mounting holes.
  **Parameters:**
  - `h`: Minimum combined body length, rounded up to available hardware.
  - `parent_thickness`: Parent plate thickness; undef hides mounting screws.
  - `slot_mode`: Emit parent cutters instead of hardware.
  - `bolt_d`: Standoff thread / parent hole diameter.
  - `cbore_h`: Screw-head recess depth.
  - `cbore_d`: Screw-head recess diameter.
  - `bolt_spacing`: Hole-center spacing in X/Y.
  - `thread_at_top`: Place the male studs at the top of each stack.
  - `sink`: Countersunk heads/recesses when true, pan heads/counterbores otherwise.
  - `offsets_xy`: Offset of the mounting pattern's center.
  - `z_anchor`: Anchor on the body-height interval, excluding male studs.
  Mounting screws enter the bottom standoff's threaded hole; countersunk heads
  sit flush with the parent underside when its recess accommodates their height.
 */
module four_corner_standoffs(h,
                             parent_thickness=0,
                             slot_mode=false,
                             bolt_d=0,
                             cbore_h=0,
                             cbore_d=0,
                             bolt_spacing,
                             thread_at_top=true,
                             sink=true,
                             offsets_xy=[0, 0],
                             z_anchor=1) {

  standoffs_real_h = standoff_real_h(min_h=h, d=bolt_d);

  show_bolt = !is_undef(parent_thickness);
  recess_h = with_default(cbore_h, 0);
  // Seat a countersunk head flush, rather than lifting it into a deeper
  // clearance cone (which would make its wider rim intersect the plate).
  seat_h = sink ? min(recess_h, find_bolt_head_h(bolt_d, "countersunk")) : recess_h;
  visible_h = show_bolt ? max(0, parent_thickness - seat_h) : 0;
  engagement = plist_get("thread_h", calc_standoff_params(bolt_d, h)[0], 0);
  offsets_xy = with_default(offsets_xy, [0, 0]);
  offset_x = with_default(offsets_xy[0], 0);
  offset_y = with_default(offsets_xy[1], 0);

  with_anchor(anchor=[1, 1, z_anchor],
              size=[0, 0, standoffs_real_h],
              centered=true) {
    translate([offset_x, offset_y, 0]) {
      four_corner_children(size=bolt_spacing,
                           center=true) {
        if (slot_mode) {
          counterbore(h=parent_thickness,
                      d=bolt_d,
                      sink=sink,
                      bore_d=cbore_d,
                      reverse=thread_at_top,
                      bore_h=cbore_h);
        } else {
          standoffs_stack(d=bolt_d,
                          bolt_h=visible_h + engagement,
                          min_h=h,
                          thread_at_top=thread_at_top,
                          show_bolt=show_bolt,
                          bolt_head_type=sink ? "countersunk" : "pan",
                          bolt_visible_h=visible_h);
        }
      }
    }
  }
}

// standoff_grid();

four_corner_standoffs(h=20,
                      parent_thickness=4,
                      thread_at_top=false,
                      z_anchor=1,
                      bolt_d=2.5,
                      bolt_spacing=[43.0, 43.0]);
difference() {
  cuboid([50.0, 50.0, 4]);
  four_corner_standoffs(h=20,
                        parent_thickness=4,
                        cbore_d=7,
                        cbore_h=2,
                        z_anchor=1,
                        slot_mode=true,
                        bolt_d=2.5,
                        bolt_spacing=[43.0, 43.0]);
}
// nut_pos = 0;
// standoff(show_bolt=true,
//          thread_at_top=false,
//          bolt_visible_h=2,
//          nut_pos=nut_pos,
//          body_h=12,
//          show_nut=true);
