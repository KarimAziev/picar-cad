/**
 * Module: Placement modules
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
use <functions.scad>
use <holes.scad>
use <shapes3d.scad>
use <slots.scad>



module row_of_circles(total_width,
                      d,
                      spacing,
                      starts=[0, 0],
                      vertical=false,
                      fn=360,
                      direction=1) {
  step = spacing + d;
  amount = floor(total_width / step);

  if (amount > 0) {
    for (i = [0 : amount - 1]) {
      let (s = i * step,
           x = vertical ? starts[0] : starts[0] + s,
           y = vertical ? starts[1] + s : starts[1]) {
        translate([direction > 0 ? x : -x, direction > 0 ? y : -y]) {
          circle(r = d / 2, $fn=fn);
        }
      }
    }
  }
}

module row_of_cubes(total_width,
                    size=[2.4, 2.4, 10],
                    spacing=3.6,
                    starts=[0, 0],
                    center=false,
                    y_center=false,
                    z_center=false,
                    direction=1) {
  step = spacing + size[0];
  amount = floor(total_width / step);

  if (amount > 0) {
    half_of_w = total_width / 2;

    x_offst = center ? -half_of_w : 0;

    translate([x_offst,
               y_center ? 0 : size[1] / 2,
               0]) {
      for (i = [1 : amount]) {
        let (s = i * step,
             x = starts[0] + s,
             y = starts[1]) {
          translate([direction > 0 ? x : -x, direction > 0 ? y : -y]) {
            translate([0, 0, z_center ? 0 : size[2] / 2]) {
              cube(size, center=true);
            }
          }
        }
      }
    }
  }
}

/**
  Example
  ```scad
  columns_children(gap=2, cols=5, w=10) {
    cube(size=[10, 2, 2],
       center=true);
  }
  ```
 */
module columns_children(cols, w, gap=0, center=false) {
  cols_params = calc_cols_params(cols=cols, w=w, gap=gap);
  step = cols_params[0];
  total_x = cols_params[1];
  translate([center ? -total_x / 2 : 0, 0, 0]) {
    for (i = [0 : cols - 1]) {
      let (bx = i * step + w / 2) {
        translate([bx, 0, 0]) {
          $i = i;
          children();
        }
      }
    }
  }
}
/**
  Example
  ```scad
  rows_children(gap=2, rows=5, w=10) {
    cube(size=[2, 10, 2],
        center=true);
  }

  ```
 */
module rows_children(rows,
                     w,
                     gap=0,
                     center=false,
                     reverse=false) {
  rows_params = calc_cols_params(cols=rows, w=w, gap=gap);
  step = rows_params[0];
  total_y = rows_params[1];
  translate([0, center ? -total_y / 2 : reverse ? -total_y : 0, 0]) {
    for (i = [0 : rows - 1]) {
      let (by = i * step + w / 2) {
        translate([0, by, 0]) {
          $i = i;
          children();
        }
      }
    }
  }
}

module vent_slots_panel(w, h, z, slot_w, slot_gap, slot_h, rows) {
  cols = max(0, floor((w - slot_gap)/(slot_w + slot_gap)));
  row_pitch = (rows>1) ? ((h-slot_h)/(rows-1)) : 0;
  for (r=[0:rows-1]) {
    y0 = h/2 - slot_h/2 - r*row_pitch;
    for (c=[0:cols-1]) {
      x = -w/2 + slot_gap + slot_w/2 + c*(slot_w + slot_gap);
      translate([x, y0, 0]) {
        cube([slot_w, slot_h, z], center=true);
      }
    }
  }
}

module cube_path(specs) {
  sizes = map_idx(specs, 0, [0, 0, 0, 0]);
  y_sizes = map_idx(sizes, 1, 0);

  offsets = map_idx(specs, 1, [0, 0, 0]);
  y_gaps = map_idx(offsets, 0, 0);
  x_offsets = map_idx(offsets, 1, 0);
  y_offsets = map_idx(offsets, 2, 0);
  z_offsets = map_idx(offsets, 3, 0);

  for (i = [0 : len(specs) - 1]) {
    let (spec=specs[i],
         prev_y_size= i > 0 ? sum(y_sizes, i) : 0,
         prev_y_space=i > 0 ? sum(y_gaps, i) : 0,
         y = prev_y_size + prev_y_space) {

      let (x_offset = x_offsets[i],
           y_offset = y_offsets[i],
           z_offset = z_offsets[i]) {

        $spec = spec;
        $i = i;

        translate([x_offset, y + y_offset, z_offset]) {
          if (!$children) {
            translate([-sizes[i][0] / 2, 0, 0]) {
              cube(size=sizes[i]);
            }
          } else {
            children();
          }
        }
      }
    }
  }
}

/**
   Renders a sequence of rounded rectangular holes (or rectangular counter-bores)
   laid out along the Y axis.

   Each entry in specs describes a single hole. Entries are placed one after
   another along +Y; each entry may also provide an optional local offset and an
   optional rectangular counter-bore (a shallow larger rectangular recess).

   Note on terminology:
   - "counterbore" is commonly used for circular holes. For non-circular holes the
   terms "rectangular counterbore", "rectangular counter-pocket" or simply
   "rectangular recess" are clearer. This module implements a rectangular
   shallow recess in the same axis as the hole.

   Parameters:
   specs: list of per-hole specifications. Each item is a 2-4 element list:
   [ size, offset?, recess_spec? ]

   - size: [ width_x, length_y, corner_radius, radius_tolerance? ]
   width_x      : hole width along the X axis
   length_y     : hole length along the Y axis (also used when stacking)
   corner_radius: radius used for rounded corners
   radius_tolerance (optional): additional radius applied on top of
   corner_radius (used for clearance). If omitted, default_r_tolerance
   is used.

   - offset? (optional): [ y_gap, x_offset, y_offset, z_offset? ]
   y_gap   : distance (gap) after this hole before placing the next hole.
   Has effect only if there is a following spec.
   x_offset: local X translation for this hole.
   y_offset: local Y translation for this hole; does NOT affect the
   placement of subsequent holes (useful for intended overlaps).
   z_offset: local Z translation for this hole (optional).

   - recess_spec? (optional): [ recess_x, recess_y, recess_h?, reverse? ]
   recess_x, recess_y : size of the rectangular recess (larger than main size)
   recess_h? : depth/thickness of the recess (optional - a sensible
   default is chosen if omitted)
   reverse?         : boolean. If true, the recess is positioned at the
   opposite face (i.e. reversed along Z).

   thickness: extrusion depth (height) of the main hole
   center: boolean. If true the hole(s) are centered at the origin in X and Y;
   otherwise they are placed so their min corner is at the origin.
   rotation: optional rotation applied to each hole and to its children.
   Pass the same kind of value you supply to rotate().
   default_r_tolerance: fallback extra radius added to corner radius when a
   per-size radius_tolerance is not supplied.

   Behaviour notes:
   - Holes are placed sequentially along +Y. The stacking position for item i is
   the sum of all earlier size[length_y] plus the sum of earlier y_gap values.
   - y_offset is local to the single hole and does not affect the stacking of
   later holes.
   - If a recess_spec is provided, a larger shallow rectangular recess is
   created on top of the main hole. It does not affect the stacking position.
   - If rotation is provided, the module rotates both the drawn hole and any
   children() placed inside the hole.

   Example:
   ```scad
   rounded_rect_slots(specs=[[[9.5, 30.4, 2.0], [0, -12.0, -10], [20, 38]],  // first hole + counterbore
   [[9.5, 8.4, 2.0], [26, -2.0, 0]]],  // second hole
      thickness=4,
      center=false,
      default_r_tolerance=0);
   ```
*/

module rounded_rect_slots(specs,
                          thickness,
                          center=false,
                          rotation,
                          default_r_tolerance=0) {
  sizes = map_idx(specs, 0, [0, 0, 0, 0]);
  y_sizes = map_idx(sizes, 1, 0);

  offsets = map_idx(specs, 1, [0, 0, 0]);
  y_gaps = map_idx(offsets, 0, 0);
  x_offsets = map_idx(offsets, 1, 0);
  y_offsets = map_idx(offsets, 2, 0);
  z_offsets = map_idx(offsets, 3, 0);

  recess_specs = map_idx(specs, 2, []);

  for (i = [0 : len(specs) - 1]) {
    let (spec=specs[i],
         prev_y_size = i > 0 ? sum(y_sizes, i) : 0,
         prev_y_space=i > 0 ? sum(y_gaps, i) : 0,
         y = prev_y_size + prev_y_space) {

      let (x_offset = x_offsets[i],
           y_offset = y_offsets[i],
           z_offset = z_offsets[i],
           recess_spec = recess_specs[i]) {

        $spec = spec;
        $i = i;

        translate([x_offset, y + y_offset, z_offset]) {
          if (!$children) {
            if (rotation) {
              rotate(rotation) {
                rect_slot(size=sizes[i],
                          recess_size=recess_spec,
                          r=sizes[i][2] + with_default(sizes[i][3],
                                                       default_r_tolerance),
                          center=center,
                          recess_h=recess_spec[2],
                          reverse=recess_spec[3],
                          h=thickness);
              }
            } else {
              rect_slot(size=sizes[i],
                        recess_size=recess_spec,
                        recess_h=recess_spec[2],
                        r=sizes[i][2] + with_default(sizes[i][3],
                                                     default_r_tolerance),
                        center=center,
                        reverse=recess_spec[3],
                        h=thickness);
            }
          }

          if (rotation) {
            rotate(rotation) {
              children();
            }
          } else {
            children();
          }
        }
      }
    }
  }
}
