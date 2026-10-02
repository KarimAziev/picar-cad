include <../parameters.scad>

use <../lib/holes.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <standoff.scad>

module perf_grid(cols, rows, d, pad_d, spacing, h, $fn=100) {
  step = spacing + pad_d;
  total_x = cols * pad_d + (cols - 1) * spacing;
  total_y = rows * pad_d + (rows - 1) * spacing;

  translate([-total_x/2, -total_y/2, 0]) {
    for (i = [0 : cols - 1]) {
      let (x = i * step + pad_d / 2) {
        for (j = [0 : rows - 1]) {
          let (y = j * step + pad_d / 2) {
            translate([x, y, 0]) {
              difference() {
                cylinder(r = pad_d / 2, h = h, $fn = $fn);
                translate([0, 0, -0.5]) {
                  cylinder(r = d / 2, h = h + 1, $fn = $fn);
                }
              }
            }
          }
        }
      }
    }
  }
}

module perf_board(size=[20, 80, 1.6],
                  corner_r=1,
                  pad_dia=1.9,
                  perf_grid_d=1,
                  spacing=0.54,
                  bolt_d=2.0,
                  bolt_spacing=[16.0, 76.0],
                  rows=28,
                  cols=6,
                  $fn=100,
                  bus_pad_rx=1.9,
                  bus_pad_ry=1.0,
                  bus_pad_cols=4,
                  bus_pad_offset = 0.8,
                  bus_pad_spacing=0.8,
                  standoff_h = 2,
                  bolt_visible_h = 2,
                  perf_color="green",
                  pin_color="silver",
                  bus_pad_color="silver",
                  stand_up=true,
                  show_bolt = true,
                  show_standoff = true,
                  show_nut=true) {
  x = size[0];
  y = size[1];
  z = size[2];

  standoffs = calc_standoff_params(min_h=standoff_h, d=bolt_d);
  standoff_real_h = len(standoffs[1]) > 0 ? sum(standoffs[1]) : 0;

  translate([0, 0, stand_up ? with_default(standoff_real_h, 0) : 0]) {
    union() {
      difference() {
        union() {
          color(perf_color, alpha=1) {
            difference() {
              linear_extrude(height=z, center=false) {
                rounded_rect([x, y], center=true, r=corner_r, fn=$fn);
              }
            }
          }
          if (cols > 0 && rows > 0 && pad_dia > 0) {
            color(pin_color, alpha=1) {
              translate([0, 0, -0.05]) {
                perf_grid(d=perf_grid_d,
                          cols=cols,
                          rows=rows,
                          h=z + 0.1,
                          pad_d=pad_dia,
                          spacing=spacing,
                          $fn=$fn);
              };
            }
          }
          if (bus_pad_cols > 0) {
            color(bus_pad_color, alpha=1) {
              mirror_copy([0, 1, 0]) {
                let (step = bus_pad_spacing + bus_pad_rx,
                     total_x = bus_pad_cols * bus_pad_rx + (bus_pad_cols - 1)
                     * bus_pad_spacing) {
                  translate([-total_x / 2,
                             y / 2 -
                             (bus_pad_ry + bus_pad_rx) / 2,
                             -0.05]) {
                    linear_extrude(height=z + 0.1, center=false) {
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
        translate([0, 0, -0.1]) {
          linear_extrude(height=z + 0.2, center=false) {
            four_corner_holes_2d(size=bolt_spacing,
                                 d=bolt_d,
                                 center=true);
          }
        }
      }
    }
    if (show_standoff && !is_undef(standoff_h) && standoff_h > 0) {
      translate([0, 0, -standoff_real_h]) {
        four_corner_children(size=bolt_spacing, center=true) {
          standoffs_stack(d=bolt_d,
                          show_bolt=show_bolt,
                          nut_pos=standoff_h,
                          bolt_visible_h=bolt_visible_h,
                          min_h=standoff_h,
                          show_nut=show_nut);
        }
      }
    }
  }
}

module perf_bord_from_plist(plist,
                            bolt_visible_h=2,
                            stand_up=true,
                            show_bolt = true,
                            show_standoff = true,
                            show_nut=true,
                            center=true) {
  plist = with_default(plist, []);
  size = plist_get("size", plist, [20, 80, 1.6]);
  corner_r = plist_get("corner_r", plist, 1);
  pad_dia = plist_get("pad_dia", plist, 1.9);
  perf_grid_d = plist_get("perf_grid_d", plist, 1);
  spacing = plist_get("spacing", plist, 0.54);
  bolt_d = plist_get("d", plist, 2.0);
  bolt_spacing = plist_get("slot_size",
                           plist,
                           [16.0, 76.0]);
  rows = plist_get("rows", plist, 28);
  cols = plist_get("cols", plist, 6);
  $fn = plist_get("$fn", plist, 100);
  bus_pad_rx = plist_get("bus_pad_rx", plist, 1.9);
  bus_pad_ry = plist_get("bus_pad_ry", plist, 1.0);
  bus_pad_cols = plist_get("bus_pad_cols", plist, 4);
  bus_pad_offset = plist_get("bus_pad_offset", plist,  0.8);
  bus_pad_spacing = plist_get("bus_pad_spacing", plist, 0.8);
  perf_color = plist_get("perf_color", plist, "green");
  pin_color = plist_get("pin_color", plist, "silver");
  bus_pad_color = plist_get("bus_pad_color", plist, "silver");
  standoff_h = plist_get("standoff_h", plist,  2);

  translate([center ? 0 : size[0] / 2, center ? 0 : size[1] / 2, 0]) {
    perf_board(size=size,
               corner_r=corner_r,
               pad_dia=pad_dia,
               perf_grid_d=perf_grid_d,
               spacing=spacing,
               bolt_d=bolt_d,
               bolt_spacing=bolt_spacing,
               rows=rows,
               cols=cols,
               $fn=$fn,
               bus_pad_rx=bus_pad_rx,
               bus_pad_ry=bus_pad_ry,
               bus_pad_cols=bus_pad_cols,
               bus_pad_offset=bus_pad_offset,
               bus_pad_spacing=bus_pad_spacing,
               perf_color=perf_color,
               pin_color=pin_color,
               standoff_h=standoff_h,
               bolt_visible_h=bolt_visible_h,
               bus_pad_color=bus_pad_color,
               stand_up=stand_up,
               show_bolt=show_bolt,
               show_standoff=show_standoff,
               show_nut=show_nut);
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  perf_board_mount_props
  ─────────────────────────────────────────────────────────────────────────────
  Resolve board, mounting hardware and optional populated-board headroom.
  **Parameters:**
  - `pl`: Existing perf-board plist; component_h reserves space above the PCB.
  **Returns:** Centered XY `size`, bolt_spacing, bolt_d, standoff_h and wire_d.
  The legacy default board is 20 × 80 mm with a 16 × 76 mm mounting pattern.
 */
function perf_board_mount_props(pl=[]) =
  let (board = plist_get("size", pl, [20, 80, 1.6]),
       pitch = plist_get("slot_size", pl, [16, 76]),
       d = plist_get("d", pl, 2),
       h = standoff_real_h(plist_get("standoff_h", pl, 2), d),
       hardware = calc_standoff_params(d, h)[0],
       wire_d = plist_get("wire_d", pl, 0),
       component_h = plist_get("component_h", pl, 0),
       pad_d = plist_get("pad_dia", pl, 1.9),
       spacing = plist_get("spacing", pl, 0.54),
       counts = [plist_get("cols", pl, 6), plist_get("rows", pl, 28)],
       grid_size = [for (n = counts) max(0, n * pad_d + (n - 1) * spacing)],
       bus_n = plist_get("bus_pad_cols", pl, 4),
       bus_w = bus_n * plist_get("bus_pad_rx", pl, 1.9)
       + max(0, bus_n - 1) * plist_get("bus_pad_spacing", pl, 0.8),
       mount_d = max(2 * d, plist_get("body_d", hardware)),
       size = [max(board[0], pitch[0] + mount_d, wire_d),
               max(board[1], pitch[1] + mount_d, wire_d),
               h + max(board[2] + component_h,
                       plist_get("thread_h", hardware)) + 0.1])
  assert(len(board) == 3 && min(board) > 0 && min(pitch) > 0 && d > 0,
         "Invalid perf-board dimensions")
  assert(pitch[0] + d <= board[0] && pitch[1] + d <= board[1],
         "Perf-board mounting holes must fit inside its PCB")
  assert(grid_size[0] <= board[0] && grid_size[1] <= board[1]
         && bus_w <= board[0],
         "Perf-board copper grid must fit its PCB; adjust rows/cols/bus_pad_cols")
  assert(h > 0 && component_h >= 0 && wire_d >= 0,
         "Perf board needs standoffs and nonnegative component/wire clearance")
  ["size", size,
   "bolt_spacing", pitch,
   "bolt_d", d,
   "standoff_h", h,
   "wire_d", wire_d];

/**
  ─────────────────────────────────────────────────────────────────────────────
  perf_board_mount
  ─────────────────────────────────────────────────────────────────────────────
  Render a perf board on standoffs or its parent mounting cutouts.
  **Parameters:**
  - `pl`: Hardware plist accepted by perf_board_mount_props.
  - `parent_t`: Parent thickness below Z=0.
  - `anchor`: Shared envelope anchor; centered on XY by default.
  - `slot_mode`: Emit mounting holes and optional center wire passage.
  - `show_hardware`: Display board and standoffs in solid mode.
 */
module perf_board_mount(pl=[],
                        parent_t=3,
                        anchor=[0, 0, 1],
                        slot_mode=false,
                        show_hardware=true) {
  p = perf_board_mount_props(pl);
  with_anchor(anchor, plist_get("size", p), centered=true) {
    if (slot_mode) {
      pcb_mount_slots(p, parent_t);
    } else if (show_hardware) {
      perf_bord_from_plist(pl,
                           bolt_visible_h=parent_t,
                           show_bolt=false,
                           show_nut=false);
    }
  }
}
