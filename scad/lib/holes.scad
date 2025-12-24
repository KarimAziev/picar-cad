/**
 * Module: Modules for holes counterbore, countersink,
 * counterbore_single_slots_by_specs, four_corner_children,
 * four_corner_holes_2d, four_corner_hole_rows, notched_circle,
 * two_x_bolts_2d/3d,
 * dotted_bolts_line_y
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
use <shapes3d.scad>
use <transforms.scad>
use <functions.scad>
use <debug.scad>
use <text.scad>
use <../placeholders/bolt.scad>
use <shapes2d.scad>

module counterbore(h,
                   d,
                   bore_d,
                   bore_h,
                   center=false,
                   sink=false,
                   fn=60,
                   no_bore=false,
                   autoscale_step = 0.1,
                   reverse=false) {
  bore_h = is_undef(bore_h) ? h * 0.3 : bore_h;
  bore_r = (is_undef(bore_d) ? d * 2.8 : bore_d) / 2;
  auto_scale = !is_undef(autoscale_step) && autoscale_step != 0;
  cbore_h = auto_scale ? bore_h + autoscale_step : bore_h;

  module main_slot() {
    cylinder(h=auto_scale
             ? h + (autoscale_step * 2)
             : h,
             r=d / 2,
             center=false,
             $fn=fn);
  }

  module cbore_hole() {
    if (sink) {
      r1 = !reverse ? d / 2 : bore_r;
      r2 = !reverse ? bore_r : d / 2;
      cylinder(h=cbore_h,
               r1=r1,
               r2=r2,
               center=false,
               $fn=fn);
    } else {
      cylinder(h=cbore_h,
               r=bore_r,
               center=false,
               $fn=fn);
    }
  }

  translate([0,
             0,
             !center
             ? 0
             : -h / 2]) {
    if (!auto_scale) {
      main_slot();
    } else {
      translate([0, 0, -autoscale_step]) {
        main_slot();
      }
    }
    if (!no_bore) {
      translate([0, 0, !reverse ? h - bore_h
                 : auto_scale
                 ? -autoscale_step
                 : 0]) {
        cbore_hole();
      }
    }
  };
}

module rect_slot(h,
                 recess_h,
                 size,
                 recess_size,
                 autoscale_step = 0.1,
                 r,
                 r_factor=0.3,
                 fn=40,
                 two_rounded_corners=false,
                 reverse=false,
                 center=false) {

  slot_x = size[0];
  slot_y = size[1];
  recess_size = with_default(recess_size, []);

  recess_enabled = (!is_undef(recess_size[0])
                    || !is_undef(recess_size[1])) &&
    (with_default(recess_size[0], 0) > slot_x
     || with_default(recess_size[1], 0) > slot_y);

  auto_scale = !is_undef(autoscale_step) && autoscale_step != 0;
  recess_x = recess_enabled
    ? max(with_default(recess_size[0], 0), slot_x)
    : recess_size[0];
  recess_y = recess_enabled
    ? max(with_default(recess_size[1], 0), slot_y)
    : recess_size[1];

  recess_base_h = with_default(recess_h, max(1, h / 2.2));

  recess_z = !reverse
    ? h - recess_base_h
    : auto_scale
    ? -autoscale_step
    : 0;

  module main_slot() {
    linear_extrude(height=auto_scale
                   ? h + (autoscale_step * 2)
                   : h,
                   center=false) {
      if (!two_rounded_corners) {
        rounded_rect(size=[slot_x, slot_y],
                     r_factor=r_factor,
                     fn=fn,
                     r=r,
                     center=true);
      } else {
        rounded_rect_two(size=[slot_x, slot_y],
                         r_factor=r_factor,
                         r=r,
                         center=true);
      }
    }
  }

  translate([center ? 0
             : (recess_enabled ? recess_x / 2 : slot_x / 2),
             center ? 0 : (recess_enabled ? recess_y / 2 : slot_y / 2),
             0]) {
    union() {

      if (!auto_scale) {
        main_slot();
      } else {
        translate([0, 0, -autoscale_step]) {
          main_slot();
        }
      }

      if (recess_enabled) {
        translate([0, 0, recess_z]) {

          linear_extrude(height=recess_base_h +
                         (auto_scale ? autoscale_step : 0), center=false) {
            if (!two_rounded_corners) {
              rounded_rect(size=[recess_x, recess_y],
                           r_factor=r_factor,
                           r=r,
                           fn=fn,
                           center=true);
            } else {
              rounded_rect_two(size=[slot_x, slot_y],
                               r_factor=r_factor,
                               r=r,
                               center=true);
            }
          }
        }
      }
    }
  }
}

/**
 * Convenience wrapper that builds a countersink by calling counterbore() with
 * sink=true. Uses the same parameters as counterbore but forces a tapered upper
 * region (conical frustum).
 */

module countersink(h, d, bore_d, bore_h, center=false, fn=60) {
  counterbore(h=h,
              d=d,
              bore_d=bore_d,
              center=center,
              bore_h=bore_h,
              fn=fn,
              sink=true);
}

module four_corner_holes_2d(size=[10, 10],
                            center=false,
                            hole_dia=3,
                            fn=60) {
  for (x_ind = [0, 1])
    for (y_ind = [0, 1]) {
      x_pos = (center ? -size[0] / 2 : 0) + x_ind * size[0];
      y_pos = (center ? -size[1] / 2 : 0) + y_ind * size[1];
      translate([x_pos, y_pos]) {
        circle(r=hole_dia / 2, $fn=fn);
        children();
      }
    }
}

module dotted_bolts_line_y(x_poses, y, d=1.5) {
  for (x = x_poses) {
    translate([x, y]) {
      circle(d = d, $fn = 50);
    }
  }
}

module two_x_bolts_3d(x=0, d=2.4, center=true, h=10) {
  translate([x, 0, 0]) {
    cylinder(h, r=d / 2, $fn=360, center=center);
  }

  mirror([1, 0, 0]) {
    translate([x, 0, 0]) {
      cylinder(h, r=d / 2, $fn=360, center=center);
    }
  }
}
module two_x_bolts_2d(x=0, d=2.4, fn=360) {
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

module counterbore_single_slots_by_specs(specs,
                                         thickness,
                                         cfactor=1.5,
                                         sink=false) {
  dia_sizes = map_idx(specs, 0, 0);
  y_spaces = map_idx(specs, 1, 0);

  for (i = [0 : len(specs) - 1]) {
    let (spec=specs[i],
         dia=spec[0],
         prev_y_space=i > 0 ? sum(y_spaces, i) : 0,
         prev_dias=i > 0 ? sum(dia_sizes, i) : 0,
         y = prev_y_space + prev_dias,
         x = is_undef(spec[2]) ? 0 : spec[2],
         y_offset = is_undef(spec[3]) ? 0 : spec[3],
         bore_spec = is_undef(spec[4]) ? [] : spec[4],
         bore_d = is_undef(bore_spec[0]) ? dia * cfactor : bore_spec[0],
         bore_h = is_undef(bore_spec[1]) ? thickness / 2 : bore_spec[1],
         autoscale_step = with_default(bore_spec[2]),
         bore_reverse = bore_spec[3]) {

      translate([x, y + y_offset, -0.1]) {
        counterbore(d=dia,
                    h=thickness + (is_undef(autoscale_step) ? 0.2 : 0),
                    bore_h=bore_h,
                    reverse=bore_reverse,
                    autoscale_step=autoscale_step,
                    bore_d=bore_d,
                    center=false,
                    sink=sink);
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
 *   - counterbore_spec(optional): custom counter bore spec: [bore_dia, bore_h]
 *
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

 **Example**:
 ```scad
 four_corner_hole_rows([[15.2, 35.55, 5, 0, 0, 0]], thickness=1, center=true);
 ```
*/

module four_corner_hole_rows(specs,
                             thickness,
                             default_font,
                             default_size = 4,
                             default_spacing = 1,
                             default_halign = "center",
                             default_valign = "baseline",
                             default_color,
                             default_bore_dia_factor= 1.5,
                             default_bore_h_factor= 0.5,
                             sink=false,
                             center=false,
                             children_by_idx = false,
                             bolt_mode = false) {
  sizes = map_idx(specs, 0, []);
  dia_sizes = map_idx(specs, 1, []);

  x_sizes = map_idx(sizes, 0, []);
  y_sizes = map_idx(sizes, 1, []);
  offsets = map_idx(specs, 2, []);
  y_gaps_after = map_idx(offsets, 0, [0]);
  x_offsets = map_idx(offsets, 1, []);
  y_offsets = map_idx(offsets, 2, []);

  bore_sizes = map_idx(specs, 3, []);
  debug_specs = map_idx(specs, 4, []);
  bolt_mode_specs = map_idx(specs, 5, []);

  for (i = [0 : len(specs) - 1]) {
    let (spec=specs[i],
         dia=spec[1],
         prev_y_size= i > 0 ? sum(y_sizes, i) : 0,
         prev_y_space=i > 0 ? sum(y_gaps_after, i) : 0,
         prev_dias=i > 0 ? sum(dia_sizes, i) : 0,
         y = prev_y_size + prev_y_space + prev_dias,
         x = is_undef(x_offsets[i]) ? 0 : x_offsets[i],
         y_offset = is_undef(y_offsets[i]) ? 0 : y_offsets[i],
         bore_spec = is_undef(bore_sizes[i]) ? [] : bore_sizes[i],
         bore_d = is_undef(bore_spec[0]) ? dia * default_bore_dia_factor : bore_spec[0],
         bore_h = is_undef(bore_spec[1]) ? thickness * default_bore_h_factor : bore_spec[1],
         autoscale_step = with_default(bore_spec[2], 0.1),
         bore_reverse = bore_spec[3],
         debug_spec = with_default(debug_specs[i], [false]),
         bolt_spec = with_default(bolt_mode_specs[i], []),
         bolt_type = with_default(bolt_spec[0], "pan"),
         bolt_h = with_default(bolt_spec[1], thickness + 2),
         bolt_head_h = with_default(bolt_spec[2], 2)) {

      translate([x - (center ? 0 : x_sizes[i] / 2), y + y_offset, 0]) {
        $spec = spec;
        $i = i;
        if ($children > 0) {
          if (children_by_idx) {
            children($i);
          } else{
            children();
          }
        } else {
          four_corner_children(size=[x_sizes[i],
                                     y_sizes[i]],
                               center=center) {
            debug_highlight(debug=debug_spec[0]) {
              if (bolt_mode) {
                translate([0, 0, -bolt_h + (thickness - (bore_h > 0 && bore_d > dia
                                                         ? bore_h
                                                         : 0))]) {
                  bolt(d=dia,
                       h=bolt_h,
                       head_h=bolt_head_h,
                       head_d=head_d,
                       head_type=bolt_type);
                }
              } else {
                counterbore(d=dia,
                            h=thickness,
                            bore_h=bore_h,
                            reverse=bore_reverse,
                            autoscale_step=autoscale_step,
                            bore_d=bore_d,
                            center=false,
                            sink=sink);
              }

              if (is_list(debug_spec) && debug_spec[0]) {
                text_from_spec(is_bool(debug_spec[0])
                               ? slice(debug_spec,
                                       1,
                                       len(debug_spec) - 1)
                               : debug_spec,
                               default_font=default_font,
                               default_size=default_size,
                               default_spacing=default_spacing,
                               default_halign=default_halign,
                               default_valign=default_valign,
                               default_color=default_color,
                               default_height=thickness);
              }
            }
          }
        }
      }
    }
  }
}

difference() {
  translate([0, 0, 1.5]) {
    cube([20, 30, 3], center=true);
  }
  rect_slot(size=[10, 20],
            recess_size=[12, 25],
            h=3,
            reverse=false,
            autoscale_step=1,
            center=true);
}

translate([100, 0, 0]) {
  #counterbore(h=3,
               d=3,
               bore_d=6,
               bore_h=2,
               sink=false,
               fn=100,
               autoscale_step=1,
               reverse=false);
  #rect_slot(size=[10, 20],
             recess_size=[12, 25],
             h=3,
             reverse=false,
             autoscale_step=1,
             center=false,);
}