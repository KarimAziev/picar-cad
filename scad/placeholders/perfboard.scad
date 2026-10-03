/**
  * Module: Perfboard placeholder
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../bolt_parameters.scad>
include <../colors.scad>

use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <standoff.scad>

// Minimal board: ["size", [20, 80, 1.6], "bolt_spacing", [16, 76]].
// Omitted rows/cols fit the pad grid between mounting rows and bus pads;
// omitted bus_pad_cols fits the bus pads between the corner mounting holes.
// Explicit zero counts hide the corresponding pads.
perfboard_plist_example = ["size", [20, 80, 1.6],
                          "bolt_spacing", [16, 76]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  perfboard_props
  ─────────────────────────────────────────────────────────────────────────────
  Resolve a PCB and its automatically fitted pad counts.
  **Parameters:**
  - `pl`: Required `size` and `bolt_spacing`. Optional pad dimensions and colors
    describe the copper pattern; rows, cols and bus_pad_cols override its counts.
  **Returns:** Plist containing the board dimensions and resolved pad properties.
  `cols` fits bolt_spacing[0]; `rows` fits bolt_spacing[1] minus two bus-pad
  end margins (bus_pad_rx + bus_pad_ry + bus_pad_offset). `bus_pad_cols` fits
  bolt_spacing[0] minus two bolt diameters. Counts are nonnegative integers.
 */
function perfboard_props(pl) =
  assert(plist_is(pl), "Perfboard requires a hardware plist")
  let (size = plist_get("size", pl), pitch = plist_get("bolt_spacing", pl))
  assert(is_list(size) && len(size) == 3 && min(size) > 0,
         "Perfboard size must contain three positive dimensions")
  assert(is_list(pitch) && len(pitch) == 2 && min(pitch) > 0,
         "Perfboard bolt_spacing must contain two positive dimensions")
  let (p = plist_merge(["bolt_d", m2_hole_dia, "corner_r", 1,
                        "pad_d", 1.9, "perf_grid_d", 1, "spacing", 0.54,
                        "bus_pad_rx", 1.9, "bus_pad_ry", 1,
                        "bus_pad_offset", 0.8, "bus_pad_spacing", 0.8,
                        "board_color", "green", "pin_color", "silver",
                        "bus_pad_color", "silver"], pl),
       d = plist_get("bolt_d", p), pad = plist_get("pad_d", p),
       gap = plist_get("spacing", p), rx = plist_get("bus_pad_rx", p),
       ry = plist_get("bus_pad_ry", p), offset = plist_get("bus_pad_offset", p),
       bus_gap = plist_get("bus_pad_spacing", p))
  assert(d > 0 && pad > 0 && gap >= 0 && rx > 0 && ry >= 0
         && offset >= 0 && bus_gap >= 0, "Invalid perfboard pad dimensions")
  assert(pitch[0] + d <= size[0] && pitch[1] + d <= size[1],
         "Perfboard mounting holes must fit inside its PCB")
  let (cols = plist_get("cols", p, max(0, floor((pitch[0] + gap) / (pad + gap)))),
       rows = plist_get("rows", p,
         max(0, floor((pitch[1] - 2 * (rx + ry + offset) + gap) / (pad + gap)))),
       bus_cols = plist_get("bus_pad_cols", p,
         max(0, floor((pitch[0] - 2 * d + bus_gap) / (rx + bus_gap)))))
  assert(len([for (n = [rows, cols, bus_cols])
                if (!is_num(n) || n < 0 || n != floor(n)) n]) == 0,
         "Perfboard pad counts must be nonnegative integers")
  assert(cols * pad + max(0, cols - 1) * gap <= size[0]
         && rows * pad + max(0, rows - 1) * gap <= size[1]
         && bus_cols * rx + max(0, bus_cols - 1) * bus_gap <= size[0],
         "Perfboard copper grid must fit its PCB")
  plist_merge(p, ["rows", rows, "cols", cols, "bus_pad_cols", bus_cols]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  perfboard_bolt_positions
  ─────────────────────────────────────────────────────────────────────────────
  Return selected mounting centers in the centered PCB XY frame.
  **Parameters:**
  - `pl`: PCB plist with bolt_spacing.
  - `bolt_idxes`: Undef selects all corners; [] selects none. Each [x,y] index
    uses 0 for the negative side and 1 for the positive side.
  **Returns:** List of [x,y] hole centers before orientation or assembly rotation.
 */
function perfboard_bolt_positions(pl, bolt_idxes) =
  let (pitch = plist_get("bolt_spacing", pl))
  assert(is_undef(bolt_idxes) || (is_list(bolt_idxes)
         && len([for (idx = bolt_idxes)
                   if (!in_list(idx, [[0, 0], [0, 1], [1, 0], [1, 1]])) idx]) == 0),
         "Perfboard bolt_idxes must contain corner index pairs")
  [for (x = [0, 1], y = [0, 1])
      if (is_undef(bolt_idxes) || in_list([x, y], bolt_idxes))
        [(x - 0.5) * pitch[0], (y - 0.5) * pitch[1]]];

module perfgrid(cols, rows, d, pad_d, spacing, h, color, $fn=10) {
  step = spacing + pad_d;
  total_x = cols * pad_d + (cols - 1) * spacing;
  total_y = rows * pad_d + (rows - 1) * spacing;

  translate([-total_x / 2, -total_y / 2, 0]) {
    for (i = [0 : cols - 1]) {
      let (x = i * step + pad_d / 2) {
        for (j = [0 : rows - 1]) {
          let (y = j * step + pad_d / 2) {
            translate([x, y, 0]) {
              ring(d=d, od=pad_d, h=h, color=color, fn=$fn);
            }
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  perfboard
  ─────────────────────────────────────────────────────────────────────────────
  Render a PCB with copper pads, mounting holes and optional standoffs.
  **Parameters:**
  - `plist`: Board properties accepted by perfboard_props.
  - `$fn`: Curve resolution, default 100.
  - `size_key`: Plist key for board dimensions.
  - `bolt_spacing_key`: Plist key for corner hole-center spacing.
  - `bolt_idxes`: Selected standoff/cutter corners; undef selects all, [] none.
    All four physical PCB holes remain visible.
  - `orientation`: Axis order applied to the PCB and mounting hardware.
  - `anchor`: PCB reference-box anchor, centered on XY by default.
  - `standoff_h`: Minimum standoff height; available hardware determines height.
  - `bolt_visible_h`: Parent thickness below the standoffs.
  - `slot_mode`: Emit selected mounting cutters toward the parent, including
    slot_bore_d/slot_bore_h recesses when supplied in the plist.
  - `stand_up`: Raise the PCB by the selected standoff height.
  - `show_bolt`: Display screws under the standoffs.
  - `show_standoff`: Display the selected mounting hardware.
  - `show_nut`: Display nuts above the PCB.
  The PCB reference box is centered on XY with its bottom at Z=0 before
  stand_up and orientation. Slot mode shares the same reference and placement.
 */
module perfboard(plist,
                  $fn=100,
                  size_key="size",
                  bolt_spacing_key="bolt_spacing",
                  bolt_idxes,
                  orientation="wlh",
                  anchor=[0, 0, 1],
                  standoff_h=2,
                  bolt_visible_h=2,
                  slot_mode=false,
                  stand_up=true,
                  show_bolt=true,
                  show_standoff=true,
                  show_nut=true) {

  p = perfboard_props(plist_merge(plist,
    ["size", plist_get(size_key, plist),
     "bolt_spacing", plist_get(bolt_spacing_key, plist)]));
  size = plist_get("size", p);
  bolt_spacing = plist_get("bolt_spacing", p);

  bolt_d = plist_get("bolt_d", p);
  corner_r = plist_get("corner_r", p);
  pad_d = plist_get("pad_d", p);
  perf_grid_d = plist_get("perf_grid_d", p);
  spacing = plist_get("spacing", p);
  bus_pad_rx = plist_get("bus_pad_rx", p);
  bus_pad_ry = plist_get("bus_pad_ry", p);
  bus_pad_offset = plist_get("bus_pad_offset", p);
  bus_pad_spacing = plist_get("bus_pad_spacing", p);
  board_color = plist_get("board_color", p);
  pin_color = plist_get("pin_color", p);
  bus_pad_color = plist_get("bus_pad_color", p);
  rows = plist_get("rows", p);
  cols = plist_get("cols", p);
  bus_pad_cols = plist_get("bus_pad_cols", p);

  standoffs = calc_standoff_params(min_h=standoff_h, d=bolt_d);
  standoff_real_h = with_default(len(standoffs[1]) > 0 ? sum(standoffs[1]) : 0,
                                 0);

  y = size[1];
  thickness = size[2];

  slot_bore_d = plist_get("slot_bore_d", plist);
  slot_bore_sink = plist_get("slot_bore_sink", plist);
  slot_bore_h = plist_get("slot_bore_h", plist);

  module _standoff() {
    standoffs_stack(d=bolt_d,
                    show_bolt=show_bolt,
                    nut_pos=thickness,
                    bolt_visible_h=bolt_visible_h,
                    min_h=standoff_h,
                    show_nut=show_nut);
  }

  module _with_allowed_bolts() {
    for (pos = perfboard_bolt_positions(p, bolt_idxes)) {
      translate(concat(pos, [0])) {
        children();
      }
    }
  }

  module _slot() {
    translate([0, 0, -standoff_real_h - bolt_visible_h]) {
      _with_allowed_bolts() {
        counterbore(h=bolt_visible_h,
                    d=bolt_d,
                    reverse=true,
                    bore_d=slot_bore_d,
                    bore_h=slot_bore_h,
                    sink=slot_bore_sink);
      }
    }
  }

  module _main() {
    union() {
      difference() {
        union() {
          cuboid(size=size, r=corner_r, fn=$fn, color=board_color);
          if (cols > 0 && rows > 0 && pad_d > 0) {
            translate([0, 0, -0.05]) {
              perfgrid(d=perf_grid_d,
                       cols=cols,
                       rows=rows,
                       h=thickness + 0.1,
                       pad_d=pad_d,
                       spacing=spacing,
                       color=pin_color,
                       $fn=$fn);
            }
          }
          if (bus_pad_cols > 0) {
            color(bus_pad_color, alpha=1) {
              mirror_copy([0, 1, 0]) {
                let (step = bus_pad_spacing + bus_pad_rx,
                     total_x = bus_pad_cols * bus_pad_rx
                     + (bus_pad_cols - 1) * bus_pad_spacing) {
                  translate([-total_x / 2,
                             y / 2 -
                             (bus_pad_ry + bus_pad_rx) / 2,
                             -0.05]) {
                    linear_extrude(height=thickness + 0.1, center=false) {
                      for (i = [0 : bus_pad_cols - 1]) {
                        let (bx = i * step + bus_pad_rx / 2) {
                          translate([bx, -bus_pad_offset, 0]) {
                            capsule(y=bus_pad_ry,
                                    d=bus_pad_rx,
                                    center=true);
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        four_corner_children(size=bolt_spacing, center=true) {
          counterbore(h=thickness, d=bolt_d);
        }
      }

      if (show_standoff && !is_undef(standoff_h) && standoff_h > 0) {
        translate([0, 0, -standoff_real_h]) {
          _with_allowed_bolts() {
            _standoff();
          }
        }
      }
    }
  }

  with_orientation(from="wlh",
                   to=orientation,
                   anchor=anchor,
                   size=size) {
    translate([0, 0, (stand_up ? with_default(standoff_real_h, 0) : 0)]) {
      if (slot_mode) {
        _slot();
      } else {
        _main();
      }
    }
  }
}

perfboard(perfboard_plist_example);

/**
  ─────────────────────────────────────────────────────────────────────────────
  perf_board_mount_props
  ─────────────────────────────────────────────────────────────────────────────
  Resolve the envelope of a mounted and optionally populated perfboard.
  **Parameters:**
  - `pl`: Board plist with explicit bolt_d, standoff_h, wire_d, component_h,
    slot_bore_d, slot_bore_h and slot_bore_sink from the caller's parameter preset.
    Optional bolt_idxes selects mounting corners.
  **Returns:** Mount envelope `size`, `board_size`, resolved `component`,
  bolt_spacing, bolt_d, standoff_h, wire_d and selected `bolt_positions`.
 */
function perf_board_mount_props(pl) =
  assert(plist_is(pl), "Perfboard mount requires an explicit hardware plist")
  assert(len([for (k = ["bolt_d", "standoff_h", "wire_d", "component_h",
                       "slot_bore_d", "slot_bore_h", "slot_bore_sink"])
                if (is_undef(plist_get(k, pl))) k]) == 0,
         "Perfboard mount requires explicit mounting parameters")
  let (p = perfboard_props(pl), board = plist_get("size", p),
       pitch = plist_get("bolt_spacing", p), d = plist_get("bolt_d", p),
       requested_h = plist_get("standoff_h", p),
       h = standoff_real_h(requested_h, d),
       hardware = calc_standoff_params(d, h)[0],
       wire = plist_get("wire_d", p), populated = plist_get("component_h", p),
       bore = plist_get("slot_bore_d", p), bore_h = plist_get("slot_bore_h", p),
       positions = perfboard_bolt_positions(p, plist_get("bolt_idxes", p)),
       mount_d = max(bore, plist_get("body_d", hardware)),
       size = [max(board[0], pitch[0] + mount_d, wire),
               max(board[1], pitch[1] + mount_d, wire),
               h + max(board[2] + populated, plist_get("thread_h", hardware)) + 0.1])
  assert(requested_h > 0 && h > 0 && wire >= 0 && populated >= 0,
         "Perfboard mount needs standoffs and nonnegative clearances")
  assert(bore >= d && bore_h > 0 && is_bool(plist_get("slot_bore_sink", p)),
         "Invalid perfboard mounting recess")
  ["size", size, "board_size", board, "component", p,
   "bolt_spacing", pitch, "bolt_d", d, "standoff_h", h,
   "wire_d", wire, "mount_d", mount_d, "bolt_positions", positions];

/**
  ─────────────────────────────────────────────────────────────────────────────
  perf_board_mount
  ─────────────────────────────────────────────────────────────────────────────
  Render a perfboard on standoffs or matching parent mounting cutouts.
  **Parameters:**
  - `pl`: Explicit hardware plist accepted by perf_board_mount_props.
  - `parent_t`: Parent thickness below the mounting plane, supplied by its owner.
  - `anchor`: Mount envelope anchor, centered on XY by default.
  - `slot_mode`: Emit selected holes, underside recesses and optional wire passage.
  - `show_hardware`: Display the board and standoffs in solid mode.
  - `orientation`: Axis order for the complete mount envelope.
 */
module perf_board_mount(pl,
                        parent_t,
                        anchor=[0, 0, 1],
                        slot_mode=false,
                        show_hardware=true,
                        orientation="wlh") {
  p = perf_board_mount_props(pl);
  component = plist_get("component", p);
  assert(is_num(parent_t) && parent_t > 0,
         "Perfboard parent_t must be a positive thickness");
  assert(!slot_mode || plist_get("slot_bore_h", component) < parent_t,
         "Perfboard recess must leave material in the parent wall");
  with_orientation(to=orientation, size=plist_get("size", p), anchor=anchor) {
    if (slot_mode || show_hardware) {
      perfboard(component,
                bolt_idxes=plist_get("bolt_idxes", component),
                standoff_h=plist_get("standoff_h", p),
                bolt_visible_h=parent_t,
                slot_mode=slot_mode,
                show_bolt=false,
                show_nut=false);
    }
    if (slot_mode && plist_get("wire_d", p) > 0) {
      translate([0, 0, -parent_t - 0.1]) {
        cylinder(d=plist_get("wire_d", p), h=parent_t + 0.2, $fn=32);
      }
    }
  }
}
