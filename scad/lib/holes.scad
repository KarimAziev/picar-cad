/**
 * Module: Modules for holes counterbore, countersink,
 * counterbore_single_slots_by_specs, four_corner_children,
 * four_corner_holes_2d, four_corner_hole_rows, notched_circle,
 * two_x_screws_2d/3d,
 * dotted_screws_line_y
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
use <shapes3d.scad>
use <transforms.scad>
use <functions.scad>

module counterbore(h,
                   d,
                   upper_d,
                   upper_h,
                   center=false,
                   sink=false,
                   fn=60) {
  upper_h = is_undef(upper_h) ? h * 0.3 : upper_h;
  upper_rad = (is_undef(upper_d) ? d * 2.8 : upper_d) / 2;

  translate([0, 0, center ? -h / 2 : 0]) {
    cylinder(h=h, r=d / 2, center=false, $fn=fn);
    translate([0, 0, h - upper_h]) {
      if (sink) {
        cylinder(h=upper_h, r1=d / 2, r2=upper_rad, center=false, $fn=fn,
                 $fa = 12,
                 $fs = 20,);
      } else {
        cylinder(h=upper_h, r=upper_rad, center=false, $fn=fn,
                 $fa = 12,
                 $fs = 20,);
      }
    }
  }
}

/**
 * Convenience wrapper that builds a countersink by calling counterbore() with
 * sink=true. Uses the same parameters as counterbore but forces a tapered upper
 * region (conical frustum).
 */

module countersink(h, d, upper_d, upper_h, center=false, fn=60) {
  counterbore(h=h,
              d=d,
              upper_d=upper_d,
              center=center,
              upper_h=upper_h,
              fn=fn,
              sink=true);
}

module four_corner_holes_2d(size=[10, 10],
                            center=false,
                            hole_dia=3,
                            fn_val=60) {
  for (x_ind = [0, 1])
    for (y_ind = [0, 1]) {
      x_pos = (center ? -size[0] / 2 : 0) + x_ind * size[0];
      y_pos = (center ? -size[1] / 2 : 0) + y_ind * size[1];
      translate([x_pos, y_pos]) {
        circle(r=hole_dia / 2, $fn=fn_val);
        children();
      }
    }
}

module dotted_screws_line_y(x_poses, y, d=1.5) {
  for (x = x_poses) {
    translate([x, y]) {
      circle(d = d, $fn = 50);
    }
  }
}

module two_x_screws_3d(x=0, d=2.4, center=true, h=10) {
  translate([x, 0, 0]) {
    cylinder(h, r=d / 2, $fn=360, center=center);
  }

  mirror([1, 0, 0]) {
    translate([x, 0, 0]) {
      cylinder(h, r=d / 2, $fn=360, center=center);
    }
  }
}
module two_x_screws_2d(x=0, d=2.4, fn=360) {
  mirror_copy([1, 0, 0]) {
    translate([x, 0, 0]) {
      circle(r = d / 2, $fn=fn);
      children();
    }
  }
}

/**
 * Create a vertical sequence of single circular counterbores (slots) from a
 * compact specs list.
 *
 * specs format:
 *   specs = [
 *     [ diameter, y_gap, x_offset?, y_offset? ],
 *     ...
 *   ]
 *
 *   - diameter     : hole diameter
 *   - y_gap        : gap after this slot before placing the next slot
 *   - x_offset (opt): local X translation for this slot (default 0)
 *   - y_offset (opt): local Y translation for this slot (default 0)
 *
 * Parameters:
 *   specs: list of slot specifications (see format above)
 *   thickness: main depth passed to counterbore()
 *   cfactor: multiplier applied to diameter to obtain the counterbore upper diameter
 *            (default 1.5)
 *
 * Behavior:
 * - Slots are stacked along +Y. The Y position for a slot is computed by
 *   accumulating previous y_gap and previous diameters (matching the original logic).
 * - Each slot is translated by its x_offset/y_offset and placed slightly below Z=0
 *   (-0.1) before the counterbore() call (preserving original behavior).
 */

module counterbore_single_slots_by_specs(specs, thickness, cfactor=1.5) {
  dia_sizes = map_idx(specs, 0, 0);
  y_spaces = map_idx(specs, 1, 0);

  for (i = [0 : len(specs) - 1]) {
    let (spec=specs[i],
         dia=spec[0],
         prev_y_space=i > 0 ? sum(y_spaces, i) : 0,
         prev_dias=i > 0 ? sum(dia_sizes, i) : 0,
         y = prev_y_space + prev_dias,
         x = is_undef(spec[2]) ? 0 : spec[2],
         y_offset = is_undef(spec[3]) ? 0 : spec[3]) {

      translate([x, y + y_offset, -0.1]) {
        counterbore(d=dia,
                    h=thickness
                    + 1,
                    upper_h=thickness / 2,
                    upper_d=dia * cfactor,
                    center=false,
                    sink=false);
      }
    }
  }
}

/**
 * Create groups of four circular holes (one in each corner of a rectangle)
 * according to a list of specifications. Each specification produces a rectangle
 * of size [width, height] and places four corner holes (via four_corner_children)
 * with the specified hole diameter and optional per-row offsets.
 *
 * specs format:
 *   specs = [
 *     [ width_x, height_y, hole_diameter, y_gap, x_offset?, y_offset?, counterbore_spec? ],
 *     ...
 *   ]
 *
 *   - width_x         : rectangle width (X direction) used for corner placement
 *   - height_y        : rectangle height (Y direction) used when stacking rows
 *   - hole_diameter   : diameter of each corner hole (passed to counterbore)
 *   - y_gap           : extra gap after this row before placing the next row
 *   - x_offset (opt)  : local X translation for this row (default 0)
 *   - y_offset (opt)  : local Y translation for this row (default 0)
 *   - counterbore_spec(optional): if you want a counterbore at each corner,
 *       supply a nested counterbore spec (format used by your counterbore module).
 *
 * Parameters:
 *   specs: array of per-row specs (see format above)
 *   thickness: total thickness/depth passed to the counterbore operation
 *
 * Behavior:
 * - Rows are stacked along +Y. The Y position for a row is the sum of earlier
 *   rows' height_y values, earlier y_gap values and earlier hole_diameter values
 *   (matches the original accumulation logic).
 * - Each row is translated by the optional x_offset and y_offset before
 *   generating the four corner holes.
 * - Each corner hole is created by calling counterbore() inside four_corner_children.
 */

module four_corner_hole_rows(specs, thickness) {
  y_sizes = map_idx(specs, 1, 0);
  dia_sizes = map_idx(specs, 2, 0);
  y_spaces = map_idx(specs, 3, 0);

  for (i = [0 : len(specs) - 1]) {
    let (spec=specs[i],
         dia=spec[2],
         prev_y_size= i > 0 ? sum(y_sizes, i) : 0,
         prev_y_space=i > 0 ? sum(y_spaces, i) : 0,
         prev_dias=i > 0 ? sum(dia_sizes, i) : 0,
         y = prev_y_size + prev_y_space + prev_dias,
         x = is_undef(spec[4]) ? 0 : spec[4],
         y_offset = is_undef(spec[5]) ? 0 : spec[5]) {

      translate([x - spec[0] / 2, y + y_offset, 0]) {
        four_corner_children(size=[spec[0], spec[1]],
                             center=false) {
          counterbore(d=dia,
                      h=thickness
                      + 0.2,
                      upper_h=thickness / 2,
                      upper_d=dia * 1.5,
                      center=false,
                      sink=false);
        }
      }
    }
  }
}
