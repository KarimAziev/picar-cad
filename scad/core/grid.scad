/**
 * Module: Grid component
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../colors.scad>
use <../lib/shapes2d.scad>
use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/debug.scad>
use <../lib/text.scad>
use <../lib/shapes3d.scad>

function percent_to_mm(percent, total_val) = percent * total_val / 100;
function maybe_to_mm(val, total_val) = val > 1 ? val : percent_to_mm(val * 100,
                                                                     total_val);

// sum of a[0..i-1]
function sum_prefix(a, i) = i <= 0 ? 0 : sum([for (k=[0:i-1]) a[k]]);

function grid_is(x) = plist_is(x) && plist_get("type", x, "") == "grid";
function row_is(x)= plist_is(x) && !is_undef(plist_get("cells", x, undef));
function cell_is(x) = plist_is(x) && !is_undef(plist_get("w", x, undef));

function merge_specs_rows_by_placeholder_types(grid,
                                               plist,
                                               override=false,
                                               placeholder_types) =
  let (rows = [for (row = plist_get("rows", grid, []))
           let (mapped_row = grid_is(row)
                ? merge_specs_rows_by_placeholder_types(row=row,
                                                        plist=plist,
                                                        override=override,
                                                        placeholder_types=placeholder_types)
                : plist_merge(row, ["cells", [for (cell = plist_get("cells", row, []))
                                    let (placeholder = plist_get("placeholder", cell, []),
                                         placeholder_type = plist_get("placeholder_type", placeholder),
                                         updated_cell =
                                         member(placeholder_type, placeholder_types)
                                         ? plist_merge(cell, ["placeholder",
                                                              (override
                                                               ? plist_merge(placeholder, plist)
                                                               : plist_merge(plist, placeholder))])
                                         : cell)
                                      updated_cell]]))
             mapped_row])
             plist_merge(grid, ["rows", rows]);

module grid_plist_render(size,
                         grid,
                         mode,
                         debug=false,
                         debug_spec=[],
                         level=0) {
  inner_x = size[0];
  inner_y = size[1];

  rows = plist_get("rows", grid, []);

  debug_spec = with_default(debug_spec, []);
  debug_gap = plist_get("gap", debug_spec, 4);
  debug_color = plist_get("color", debug_spec, yellow_3);
  debug_border_w = plist_get("border_w", debug_spec, 1);
  debug_border_h = plist_get("border_h", debug_spec, 1);

  debug_text_h = plist_get("text_h", debug_spec, 1);

  debug_cell_text_h = plist_get("text_cell_h", debug_spec, 1);

  row_h_specs = [for (r = rows) plist_get("h", r, 0)];
  row_heights = [for (hs = row_h_specs) maybe_to_mm(hs, inner_y)];

  for (ri=[0:len(rows)-1]) {
    row = rows[ri];
    assert(row_is(row),
           str("Row ", ri, " must be a plist with keys 'h' and 'cells'"));

    debug_row = plist_get("debug", row, false);
    debug_row_text = plist_get("debug_text", row);

    h = row_heights[ri];
    half_h = h / 2;

    y_acc = sum_prefix(row_heights, ri);

    translate([0, -y_acc - h, 0]) {

      if (debug || debug_row) {
        color(debug_color, alpha=1) {
          cube_border(size=[inner_x, h],
                      center=false,
                      border_w=debug_border_w,
                      h=debug_border_h);
        }
        if (!is_undef(debug_text_h) && debug_text_h > 0) {
          if (!is_undef(debug_row_text) && !is_string(debug_row_text)) {
            text_from_plist(plist=debug_row_text);
          } else {
            color(debug_color, alpha=1) {
              let (txt = is_undef(debug_row_text) ?
                   str("L", level, " R", ri, "  ",
                       truncate(h), "mm")
                   : debug_row_text,
                   txt_len = len(txt)) {
                translate([-debug_gap - txt_len, h / 2, 0]) {
                  text_fit(txt=txt,
                           x=txt_len,
                           y=half_h,
                           h=debug_text_h);
                }
              }
            }
          }
        }
      }

      cells = plist_get("cells", row, []);

      w_specs = [for (c=cells) plist_get("w", c, 0)];
      widths  = [for (ws=w_specs) maybe_to_mm(ws, inner_x)];

      for (ci=[0:len(cells)-1]) {
        cell = cells[ci];
        assert(cell_is(cell),
               str("Cell R", ri,"C", ci," must be a plist with key 'w'"));

        w = widths[ci];
        half_w = w / 2;
        x_acc = sum_prefix(widths, ci);
        cell_debug = plist_get("debug", cell);
        cell_debug_text = plist_get("debug_text", cell);

        translate([x_acc, 0, 0]) {
          nested = plist_get("grid", cell, undef);

          if ((debug || cell_debug) && is_undef(nested)) {
            color(debug_color, alpha=1) {
              cube_border(size=[w, h],
                          center=false,
                          border_w=debug_border_w,
                          h=debug_border_h);
            }

            if (!is_undef(debug_cell_text_h) && debug_cell_text_h > 0) {
              translate([half_w, half_h, 0]) {
                if (!is_undef(cell_debug_text) && !is_string(cell_debug_text)) {
                  text_from_plist(plist=cell_debug_text);
                } else {
                  color(debug_color, alpha=1)
                    text_fit(txt=is_string(cell_debug_text) ? cell_debug_text
                             : str(truncate(w), "mm"),
                             x=half_w,
                             y=half_h,
                             h=debug_text_h);
                }
              }
            }
          }

          $mode = mode;
          $cell_size = [w, h];
          $cell = cell;
          $spin = plist_get("spin", cell, 0);
          $slot = plist_get("slot", cell, []);
          $slot_type = plist_get("type", $slot);
          $placeholder = plist_get("placeholder", cell, []);
          $placeholder_type = plist_get("type", $placeholder);

          if (!is_undef(nested)) {
            assert(grid_is(nested),
                   str("Cell R", ri,"C", ci," has 'grid' but it's not a grid plist"));

            translate([0, h, 0]) {

              grid_plist_render(size=[w, h],
                                grid=nested,
                                debug=debug,
                                debug_spec=debug_spec,
                                level=level + 1) {
                children();
              }
            }
          } else {

            children();
          }
        }
      }
    }
  }
}

module grid_plist(grid,
                  debug=false,
                  mode,
                  debug_spec=["gap", 10,
                              "color", yellow_3,
                              "text_h", 1,
                              "border_h", 2,
                              "border_w", 0.5,
                              "size", 2],
                  level=0) {
  assert(grid_is(grid),
         "grid_plist: grid must be a plist with type='grid'");

  size = plist_get("size", grid, undef);
  assert(!is_undef(size) && len(size)==2,
         "grid_plist: grid must have 'size'=[x,y] at top level");

  grid_plist_render(size=size,
                    grid=grid,
                    debug=debug,
                    mode=mode,
                    debug_spec=debug_spec,
                    level=level) {
    $mode = mode;
    children();
  }
}
parent_size = [56.7, 65];

grid_plist(["type","grid",
            "size", parent_size,
            "rows", [["h", 12.0, "cells",
                      [["w", 0.25],
                       ["w", 0.25, "grid",
                        ["type","grid",
                         "rows",
                         [["h", 0.5, "cells",
                           [["w", 1.0]]],
                          ["h", 0.5, "cells",
                           [["w", 0.5,
                             "slot", ["type",
                                      "rect",
                                      "size", [10, 5]],
                             "placeholder", ["type",
                                             "atm_fuse_holder"]],
                            ["w", 0.5]]]]]],
                       ["w", 0.25],
                       ["w", 0.25]]],

                     ["h", 11.0, "cells",
                      [["w", 0.25],
                       ["w", 0.5],
                       ["w", 0.25]]],
                     ["h", 6.0,  "cells", [["w", 0.25],
                                           ["w", 0.5],
                                           ["w", 0.25]]],
                     ["h", 11.0, "cells", [["w", 0.5],
                                           ["w", 0.5]]],
                     ["h", 3.0,  "cells", [["w", 0.2],
                                           ["w", 0.2],
                                           ["w", 0.2],
                                           ["w", 0.2],
                                           ["w", 0.2]]],
                     ["h", 3.0,  "cells", [["w", 0.2],
                                           ["w", 0.2],
                                           ["w", 0.2],
                                           ["w", 0.2],
                                           ["w", 0.2]]],
                     ["h", 4.0,  "cells", [["w", 0.1],
                                           ["w", 0.8],
                                           ["w", 0.1]]]]],
           debug=true);