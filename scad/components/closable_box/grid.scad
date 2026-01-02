/**
 * Module: Grid component
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
use <../../lib/functions.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>
use <../../lib/debug.scad>
use <../../lib/text.scad>
use <../../lib/plist.scad>

function cumsums(a) = [for (i =
                              [0 : len(a) - 1]) sum([for (j = [0 : i]) a[j]])];
function spec_to_mm(spec, span) = spec > 1 ? spec : spec * span;

module grid(grid_spec,
            inner_wall_thickness,
            parent_size,
            debug=false) {

  if (!is_undef(grid_spec) && len(grid_spec) > 0) {
    inner_x = parent_size[0];
    inner_y = parent_size[1];
    row_pcts = [for (r = grid_spec) r[0]];
    row_total = sum(row_pcts);
    row_heights = [for (rp = row_pcts) inner_y * rp / row_total];

    cell_pct_lists = [for (r = grid_spec) r[1]];
    cell_widths_per_row = [for (cl = cell_pct_lists)
        let (tot = sum(cl)) [for (c = cl) inner_x * c / tot]];

    is_pair = (len(inner_wall_thickness) == 2);
    row_wall_spec = is_pair
      ? inner_wall_thickness[0]
      : inner_wall_thickness;

    col_wall_spec = is_pair
      ? inner_wall_thickness[1]
      : inner_wall_thickness;

    row_prefix = cumsums(row_heights);
    row_bottoms = [for (i = [0 : len(row_heights) - 1])
        -inner_y/2 + (i == 0 ? 0 : sum([for (j=[0:i-1])
                                           row_heights[j]]))];

    eps = 0.02;

    if (debug) {
      #rect_border(size=parent_size,
                   border_w=1,
                   inner=false,
                   center=true);
    }

    // horizontal walls (between rows)
    for (i = [0 : len(row_heights) - 2]) {
      let (y_border = -inner_y/2 + row_prefix[i],
           t = spec_to_mm(row_wall_spec, (row_heights[i]
                                          + row_heights[i + 1])
                          / 2))
        translate([0, -y_border, 0]) {
        square([inner_x + eps, t + eps], center=true);
      }
    }

    for (ri = [0 : len(cell_widths_per_row) - 1]) {
      let (cw = cell_widths_per_row[ri],
           cw_prefix = cumsums(cw),
           row_bot = row_bottoms[ri],
           row_h = row_heights[ri],
           y_center = row_bot + row_h / 2)
        for (ci = [0 : len(cw) - 2]) {
          let (x_border = -inner_x/2 + cw_prefix[ci],
               tcol = spec_to_mm(col_wall_spec,
                                 (cw[ci] + cw[ci + 1]) / 2))
            translate([x_border, -y_center]) {
            square([tcol + eps, row_h + eps], center=true);
          }
        }
    }
  }
}

module rect_border(size,
                   border_w=0.5,
                   inner=true,
                   r=0,
                   center=false,
                   fn,
                   r_factor=0.3,
                   side) {
  container_size = inner ? size : [size[0] + border_w, size[1] + border_w];
  translate([center ? 0 : size[0] / 2, center ? 0 : size[1] / 2, 0]) {

    difference() {
      rounded_rect(size=container_size,
                   r=r,
                   center=true,
                   fn=fn,
                   r_factor=r_factor,
                   side=side);
      rounded_rect(size=[container_size[0] - border_w,
                         container_size[1] - border_w],
                   r=r,
                   center=true,
                   fn=fn,
                   r_factor=r_factor,
                   side=side);
    }
  }
}

grid(grid_spec=[[0.4, [0.25, 0.25, 0.25, 0.25]],
                [0.1, [0.25, 0.25, 0.25, 0.25]],
                [0.2, [0.25, 0.25, 0.25, 0.25]],
                [0.2, [0.25, 0.25, 0.25, 0.25]]],
     parent_size=[200, 100],
     debug=true,
     inner_wall_thickness = [0.05, 0.02]);
