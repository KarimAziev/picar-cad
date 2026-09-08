/**
 * Module: Common 3D slots
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

use <functions.scad>
use <plist.scad>
use <shapes2d.scad>
use <transforms.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  is_no_bore
  ─────────────────────────────────────────────────────────────────────────────

  Decide whether the enlarged bore section of a counterbore should be skipped.

  **Parameters:**
  - `no_bore`: Explicit override flag.
  - `bore_h`: Bore height or depth.
  - `bore_d`: Bore diameter.

  **Returns:**
  `true` when the bore is disabled or missing enough data to generate it.
 */
function is_no_bore(no_bore,
                    bore_h,
                    bore_d) =
  no_bore == true
  || is_undef(bore_h)
  || is_undef(bore_d)
  || bore_d == 0
  || bore_h == 0;

/**
  ─────────────────────────────────────────────────────────────────────────────
  four_corner_counterbores_full_size
  ─────────────────────────────────────────────────────────────────────────────

  Compute the overall footprint required by a four-corner counterbore pattern.

  **Parameters:**
  - `size`: Center-to-center spacing between the corner holes as `[x, y]`.
  - `d`: Main hole diameter.
  - `bore_d`: Bore diameter.
  - `bore_h`: Bore height.
  - `no_bore`: If `true`, ignore the bore dimensions.

  **Returns:**
  `[width, height]` large enough to contain the holes and their bores.
 */
function four_corner_counterbores_full_size(size,
                                            d,
                                            bore_d,
                                            bore_h,
                                            no_bore = false) =
  let (inhibit_bore = is_no_bore(no_bore=no_bore, bore_h=bore_h, bore_d=bore_d),
       max_d = inhibit_bore ? d : (is_undef(bore_d) ? d * 2.8 : bore_d))
  [for (v = size) v + max_d];

/**
  ─────────────────────────────────────────────────────────────────────────────
  four_corner_counterbores_full_size_from_plist
  ─────────────────────────────────────────────────────────────────────────────

  Read four-corner counterbore dimensions from a property list and return the
  required overall footprint.

  **Parameters:**
  - `plist`: Property list containing `slot_size` or `size`, `d`, `bore_d`,
    `bore_h`, and optional `no_bore`.

  **Returns:**
  `[width, height]` large enough to contain the hole pattern.
 */
function four_corner_counterbores_full_size_from_plist(plist) =
  four_corner_counterbores_full_size(size=plist_get("slot_size", plist,
                                                    plist_get("size", plist)),
                                     d=plist_get("d", plist, undef),
                                     bore_d=plist_get("bore_d", plist, undef),
                                     bore_h=plist_get("bore_h", plist, undef),
                                     no_bore=plist_get("no_bore", plist,  false));

/**
  ─────────────────────────────────────────────────────────────────────────────
  rect_recess_enabled
  ─────────────────────────────────────────────────────────────────────────────

  Decide whether a rectangular slot should include its larger recess pocket.

  **Parameters:**
  - `size`: Base slot size as `[x, y]`.
  - `recess_size`: Requested recess size as `[x, y]`.

  **Returns:**
  `true` when `recess_size` is defined and exceeds the base slot in at least one
  axis.
 */
function rect_recess_enabled(size, recess_size) = let (slot_x = size[0],
                                                       slot_y = size[1],
                                                       disabled =
                                                       is_undef(recess_size)
                                                       || is_undef(recess_size[0])
                                                       || is_undef(recess_size[1]))
  !disabled &&
  (with_default(recess_size[0], 0) > slot_x
   || with_default(recess_size[1], 0) > slot_y);

/**
  ─────────────────────────────────────────────────────────────────────────────
  full_rect_slot_size
  ─────────────────────────────────────────────────────────────────────────────

  Compute the outer footprint required by a rectangular slot and its optional
  recess.

  **Parameters:**
  - `size`: Base slot size as `[x, y]`.
  - `recess_size`: Optional recess size as `[x, y]`.

  **Returns:**
  `[width, height]` of the largest active slot layer.
 */
function full_rect_slot_size(size, recess_size) =
  let (slot_x = size[0],
       slot_y = size[1],
       recess_enabled = rect_recess_enabled(size=size, recess_size=recess_size),
       x = recess_enabled
       ? max(with_default(recess_size[0], 0), slot_x)
       : slot_x,

       y = recess_enabled
       ? max(with_default(recess_size[1], 0), slot_y)
       : slot_y)
  [x, y];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rect_slot_full_size_from_plist
  ─────────────────────────────────────────────────────────────────────────────

  Read a rectangular slot definition from a property list and return the full
  2D footprint needed by the slot and recess.

  **Parameters:**
  - `plist`: Property list containing `slot_size` or `size` and optional
    `recess_size`.

  **Returns:**
  `[width, height]` of the largest active slot layer.
 */
function rect_slot_full_size_from_plist(plist) =
  full_rect_slot_size(size=plist_get(plist_get("slot_size",
                                               plist,
                                               plist_get("size", plist)),
                                     plist),
                      d=plist_get("recess_size", plist));

/**
  ─────────────────────────────────────────────────────────────────────────────
  counterbore
  ─────────────────────────────────────────────────────────────────────────────

  Creates a cylindrical hole with an optional enlarged section. The enlarged
  section can be either:

  - a **counterbore**: a cylindrical recess with a flat bottom, or
  - a **countersink**: a conical/beveled recess.

  The enlargement is placed on the top side of the hole by default. Set
  `reverse=true` to place it on the opposite side.

  **Parameters**:

  `h`: Total height of the hole.

  `d`: Diameter of the main hole.

  `bore_d`: Diameter of the enlarged section. If omitted, a default value is
  derived from `d`. If enlargement is disabled, this value is ignored.

  `bore_h`: Height/depth of the enlarged section. If omitted, a default value
  is derived from `h`. If enlargement is disabled, this value is ignored.

  `center`: If `true`, the hole is created at the origin. If `false`, it is
  translated so that its minimum X and Y coordinates are at 0.

  `sink`: If `true`, creates a countersink. Otherwise, creates a counterbore.

  `fn`: Number of fragments used to render circular geometry.

  `no_bore`: If `true`, disables the enlarged section and creates only the main
  hole.

  `autoscale_step`: Extra height added to both ends of the main hole to help
  ensure clean subtraction in boolean operations. Set to `0` to disable this
  behavior.

  `reverse`: If `true`, places the enlarged section on the opposite side of the
  hole.

  `teardrop_angle`: If defined and non-zero, creates the hole with a teardrop
   profile instead of a straight cylinder.
  `teardrop_both_sides`: When `teardrop_angle` is defined, set to `true` to
   mirror the pointed section of the teardrop to both sides, creating a shape
   that resembles an American football in 3D.

  **Examples**:
  ```scad

  // Simple hole without enlargement
  counterbore(h=2, d=3);

  // Counterbored hole
  counterbore(d=3, h=4, bore_d=6, bore_h=2);

  // Countersunk hole
  counterbore(d=3, h=4, bore_d=6, bore_h=2, sink=true);

  // Counterbored hole through a parent solid
  parent_thickness = 4;
  parent_size = [10, 10, parent_thickness];
  difference() {
    translate([0, 0, parent_size[2] / 2]) {
      cube(parent_size, center=true);
    }
    counterbore(
      d=3,
      h=parent_thickness,
      bore_h=parent_thickness / 2,
      bore_d=6.2
    );
  }

  ```
  */
module counterbore(h,
                   d,
                   bore_d,
                   bore_h,
                   center=true,
                   sink=false,
                   fn=60,
                   no_bore=false,
                   autoscale_step = 0.1,
                   reverse=false,
                   teardrop_angle,
                   teardrop_both_sides=false,
                   print_sink_angle=false) {

  is_teardrop = !is_undef(teardrop_angle) && teardrop_angle != 0;
  inhibit_bore = is_no_bore(no_bore=no_bore, bore_h=bore_h, bore_d=bore_d);
  bore_h = is_undef(bore_h) ? h * 0.3 : bore_h;
  bore_r = (is_undef(bore_d) ? d * 2.8 : bore_d) / 2;
  auto_scale = !is_undef(autoscale_step) && autoscale_step != 0;
  cbore_h = auto_scale ? bore_h + autoscale_step : bore_h;

  max_d = inhibit_bore ? d : bore_r * 2;

  module main_slot() {
    let (height = auto_scale
         ? h + (autoscale_step * 2)
         : h) {
      if (is_teardrop) {
        assert(is_num(teardrop_angle), "Teardop angle should be a number! ");
        teardrop(h=height,
                 d=d,
                 ang=teardrop_angle,
                 fn=fn,
                 both_sides=teardrop_both_sides);
      } else {
        cylinder(h=height,
                 d=d,
                 center=false,
                 $fn=fn);
      }
    }
  }

  module cbore_hole() {
    if (sink) {
      let (r1 = !reverse ? d / 2 : bore_r,
           r2 = !reverse ? bore_r : d / 2) {
        if (print_sink_angle) {
          let (angle = truncate(taper_angle_from_axis(d1=r1 * 2,
                                                      d2=r2 * 2,
                                                      h=cbore_h),
                                1)) {
            echo(str("Countersink angle is ",
                     angle,
                     " (d=", d,
                     ", bore_d=", bore_d,
                     ", h=", h,
                     ");"));
          }
        }
        if (is_teardrop) {
          teardrop(r1=r1,
                   r2=r2,
                   h=cbore_h,
                   ang=teardrop_angle,
                   fn=fn,
                   both_sides=teardrop_both_sides);
        } else {
          cylinder(h=cbore_h,
                   r1=r1,
                   r2=r2,
                   center=false,
                   $fn=fn);
        }
      }
    } else {

      if (is_teardrop) {
        teardrop(h=cbore_h,
                 d=bore_r * 2,
                 ang=teardrop_angle,
                 fn=fn,
                 both_sides=teardrop_both_sides);
      } else {
        cylinder(h=cbore_h,
                 r=bore_r,
                 center=false,
                 $fn=fn);
      }
    }
  }

  module _counterbore() {
    if (!auto_scale) {
      main_slot();
    } else {
      translate([0, 0, -autoscale_step]) {
        main_slot();
      }
    }
    if (!inhibit_bore) {
      translate([0,
                 0,
                 !reverse ? h - bore_h
                 : auto_scale
                 ? -autoscale_step
                 : 0]) {
        cbore_hole();
      }
    }
  }

  if (center) {
    _counterbore();
  } else {
    translate([max_d / 2, max_d / 2, 0]) {
      _counterbore();
    }
  };
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rect_slot
  ─────────────────────────────────────────────────────────────────────────────

  Create a rounded rectangular slot with an optional larger recess pocket.

  **Parameters:**
  - `h`: Main slot depth.
  - `recess_h`: Recess depth. When `undef`, defaults to roughly `h / 2.2`.
  - `size`: Main slot size as `[x, y]`.
  - `recess_size`: Optional recess size as `[x, y]`.
  - `autoscale_step`: Extra depth used to slightly extend subtractive geometry.
  - `recess_corner_r`: Optional corner radius override for the recess layer.
  - `r`: Explicit corner radius for the main slot.
  - `r_factor`: Radius factor used when `r` is `undef`.
  - `fn`: Fragment count for rounded corners.
  - `side`: Optional side selection forwarded to `rounded_rect()`.
  - `reverse`: If `true`, place the recess on the opposite face.
  - `center`: If `true`, keep the slot centered on XY before any rotation.
  - `spin`: Optional Z rotation in degrees.

  **Example**:
  ```scad
  rect_slot(size=[20, 10],
          h=5,
          reverse=true,
          recess_h=1.5,
          recess_size=[30, 15],
          r_factor=0.2,
          center=true);

  ```
  */
module rect_slot(h,
                 recess_h,
                 size,
                 recess_size,
                 autoscale_step=0.1,
                 recess_corner_r,
                 r,
                 r_factor=0.3,
                 fn=40,
                 side,
                 reverse=false,
                 center=false,
                 spin) {

  slot_x = size[0];
  slot_y = size[1];

  auto_scale = !is_undef(autoscale_step) && autoscale_step != 0;

  recess_size = with_default(recess_size, []);

  recess_enabled = rect_recess_enabled(size=size, recess_size=recess_size);

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
      rounded_rect(size=[slot_x, slot_y],
                   r_factor=r_factor,
                   fn=fn,
                   side=side,
                   r=r,
                   center=true);
    }
  }

  module _rect_slot() {
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
                         (auto_scale ? autoscale_step : 0),
                         center=false) {
            rounded_rect(size=[recess_x, recess_y],
                         r_factor=r_factor,
                         r=with_default(recess_corner_r, r),
                         side=side,
                         fn=fn,
                         center=true);
          }
        }
      }
    }
  }

  if (center) {
    maybe_rotate([0, 0, spin]) {
      _rect_slot();
    }
  } else {
    params = calc_rotated_bbox(recess_enabled ? recess_x : slot_x,
                               recess_enabled ? recess_y : slot_y,
                               with_default(spin, 0));
    sx = params[2];
    sy = params[3];
    maybe_translate((is_undef(spin) || abs(spin) == 0) ? undef : [sx, sy, 0]) {
      maybe_rotate([0, 0, spin]) {
        translate([(recess_enabled ? recess_x / 2 : slot_x / 2),
                   (recess_enabled ? recess_y / 2 : slot_y / 2),
                   0]) {
          _rect_slot();
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  four_corner_counterbores
  ─────────────────────────────────────────────────────────────────────────────

  Place `counterbore()` holes at the four corners of a rectangular pattern.

  **Parameters:**
  - `size`: Center-to-center spacing between corner holes as `[x, y]`.
  - `h`: Total hole depth.
  - `d`: Main hole diameter.
  - `bore_d`: Bore diameter.
  - `bore_h`: Bore height.
  - `center`: If `true`, keep the pattern centered on the origin.
  - `sink`: If `true`, use countersunk bores instead of flat-bottom bores.
  - `fn`: Fragment count for cylindrical geometry.
  - `no_bore`: If `true`, emit simple through-holes only.
  - `autoscale_step`: Extra subtractive depth used for clean boolean cuts.
  - `reverse`: If `true`, place the bore enlargement on the opposite face.
  - `spin`: Optional Z rotation in degrees.
  - `teardrop_angle`: If defined and non-zero, create the holes with teardrop
     profiles instead of straight cylinders.
  - `teardrop_both_sides`: When `teardrop_angle` is
     defined, set to `true` to mirror the pointed section of the teardrop to both
     sides, creating a shape that resembles an American football in 3D.
 */
module four_corner_counterbores(size,
                                h,
                                d,
                                bore_d,
                                bore_h,
                                center=true,
                                sink=false,
                                fn=60,
                                no_bore=false,
                                autoscale_step = 0.1,
                                reverse=false,
                                spin,
                                teardrop_angle,
                                teardrop_both_sides=false,
                                print_sink_angle=false) {

  full_size = four_corner_counterbores_full_size(size=size,
                                                 d=d,
                                                 bore_d=bore_d,
                                                 bore_h=bore_h,
                                                 no_bore=no_bore);

  full_x = full_size[0];
  full_y = full_size[1];

  module _cbores() {
    four_corner_children(size=size,
                         center=true) {
      counterbore(d=d,
                  bore_d=bore_d,
                  h=h,
                  sink=sink,
                  bore_h=bore_h,
                  reverse=reverse,
                  fn=fn,
                  no_bore=no_bore,
                  autoscale_step=autoscale_step,
                  teardrop_angle=teardrop_angle,
                  teardrop_both_sides=teardrop_both_sides,
                  print_sink_angle=print_sink_angle);
    }
  }

  if (center) {
    maybe_rotate([0, 0, spin]) {
      _cbores();
    }
  } else {
    spin_keep_bbox_at_origin(size=full_size, spin) {
      translate([full_x / 2, full_y / 2, 0]) {
        _cbores();
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rect_slot_from_plist
  ─────────────────────────────────────────────────────────────────────────────

  Build `rect_slot()` from a property list.

  **Parameters:**
  - `plist`: Property list containing the same keys accepted by `rect_slot()`.
  - `center`: Forwarded to `rect_slot()`.
 */
module rect_slot_from_plist(plist, center=false) {
  plist = with_default(plist, []);
  h = plist_get("h", plist);
  recess_h = plist_get("recess_h", plist);
  size = plist_get("slot_size",
                   plist,
                   plist_get("size", plist));
  recess_size = plist_get("recess_size", plist);
  autoscale_step = plist_get("autoscale_step", plist,  0.1);
  recess_corner_r = plist_get("recess_corner_r", plist);
  r = plist_get("r", plist);
  r_factor = plist_get("r_factor", plist, 0.3);
  fn = plist_get("fn", plist, 40);
  side = plist_get("side", plist);
  reverse = plist_get("reverse", plist, false);
  rect_slot(h=h,
            recess_h=recess_h,
            size=size,
            recess_size=recess_size,
            autoscale_step=autoscale_step,
            recess_corner_r=recess_corner_r,
            r=r,
            r_factor=r_factor,
            fn=fn,
            side=side,
            reverse=reverse,
            center=center);
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  four_corner_counterbores_from_plist
  ─────────────────────────────────────────────────────────────────────────────

  Build `four_corner_counterbores()` from a property list.

  **Parameters:**
  - `plist`: Property list containing the same keys accepted by
    `four_corner_counterbores()`.
  - `center`: Forwarded to `four_corner_counterbores()`.
 */
module four_corner_counterbores_from_plist(plist, center=true) {
  plist = with_default(plist, []);
  size = plist_get("slot_size",
                   plist,
                   plist_get("size", plist));
  h = plist_get("h", plist);
  d = plist_get("d", plist);
  bore_d = plist_get("bore_d", plist);
  bore_h = plist_get("bore_h", plist);
  sink = plist_get("sink", plist, false);
  fn = plist_get("fn", plist, $preview ? 50 : 300);
  no_bore = plist_get("no_bore", plist, false);
  autoscale_step = plist_get("autoscale_step", plist,  0.1);
  reverse = plist_get("reverse", plist, false);
  teardrop_angle = plist_get("teardrop_angle", plist);
  teardrop_both_sides = plist_get("teardrop_both_sides", plist, false);
  print_sink_angle = plist_get("print_sink_angle", plist, false);
  four_corner_counterbores(size=size,
                           h=h,
                           d=d,
                           bore_d=bore_d,
                           bore_h=bore_h,
                           sink=sink,
                           fn=fn,
                           no_bore=no_bore,
                           autoscale_step=autoscale_step,
                           reverse=reverse,
                           center=center,
                           teardrop_angle=teardrop_angle,
                           teardrop_both_sides=teardrop_both_sides,
                           print_sink_angle=print_sink_angle);
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  counterbore_from_plist
  ─────────────────────────────────────────────────────────────────────────────

  Build `counterbore()` from a property list.

  **Parameters:**
  - `plist`: Property list containing the same keys accepted by `counterbore()`.
  - `center`: Forwarded to `counterbore()`.
 */
module counterbore_from_plist(plist, center=true) {
  plist = with_default(plist, []);
  h = plist_get("h", plist);
  d = plist_get("d", plist);
  bore_d = plist_get("bore_d", plist);
  bore_h = plist_get("bore_h", plist);
  sink = plist_get("sink", plist, false);
  fn = plist_get("fn", plist, 60);
  no_bore = plist_get("no_bore", plist, false);
  autoscale_step = plist_get("autoscale_step", plist,  0.1);
  reverse = plist_get("reverse", plist, false);
  teardrop_angle = plist_get("teardrop_angle", plist);
  teardrop_both_sides = plist_get("teardrop_both_sides", plist, false);
  print_sink_angle = plist_get("print_sink_angle", plist, false);
  counterbore(h=h,
              d=d,
              bore_d=bore_d,
              bore_h=bore_h,
              sink=sink,
              fn=fn,
              no_bore=no_bore,
              autoscale_step=autoscale_step,
              reverse=reverse,
              center=center,
              teardrop_angle=teardrop_angle,
              teardrop_both_sides=teardrop_both_sides,
              print_sink_angle=print_sink_angle);
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  sag_compensated_hole
  ─────────────────────────────────────────────────────────────────────────────

  Create a printable round hole with a small flat added to compensate for sag
  on overhanging edges.

  **Parameters:**
  - `d`: Hole diameter.
  - `h`: Hole depth.
  - `fn`: Fragment count for the cylindrical portion.
  - `compensation`: Extra width of the flat compensation feature.
  - `y_side`: If `true`, place the flat along Y. Otherwise place it along X.
 */
module sag_compensated_hole(d, h, fn=30, compensation=0.4, y_side=true) {
  w = d + compensation;
  hull() {
    translate([0, 0, h / 2]) {
      cube([y_side ? compensation : w, y_side ? w : compensation, h],
           center=true);
    }
    cylinder(d=d,
             h=h,
             $fn=fn);
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  teardrop
  ─────────────────────────────────────────────────────────────────────────────

  Extrude the 2D teardrop profile into a 3D printable hole shape.

  **Parameters:**
  - `d`: Base circle diameter.
  - `r1`: Optional base radius for a counterbore-style shape. When defined, `r2`
          must also be defined.
  - `r2`: Optional tip radius for a counterbore-style shape. When defined, `r1`
          must also be defined.
  - `h`: Extrusion height.
  - `ang`: Apex angle forwarded to `teardrop_2d()`.
  - `fn`: Fragment count for the circular portion.
  - `both_sides`: If `true`, mirror the pointed section to both sides.

  **Example**:
  ```scad
  // Simple teardrop hole
  teardrop(d=5, h=10);

  // Countersunk-style teardrop hole
  teardrop(r1=4, r2=6, h=10);
  ```
 */
module teardrop(d, r1, r2, h, ang=45, fn=30, both_sides=false) {
  if (!is_undef(r1) && !is_undef(r2)) {
    let (height = 0.01) {
      hull() {
        linear_extrude(height=height, center=false) {
          teardrop_2d(d=r1 * 2, ang=ang, both_sides=both_sides, fn=fn);
        }
        translate([0, 0, h - height]) {
          linear_extrude(height=height, center=false) {
            teardrop_2d(d=r2 * 2, ang=ang, both_sides=both_sides, fn=fn);
          }
        }
      }
    }
  } else {
    linear_extrude(height=h, center=false) {
      teardrop_2d(d=d, ang=ang, both_sides=both_sides, fn=fn);
    }
  }
}

// translate([-10, 0, 0]) {
//   counterbore(h=3,
//               d=3,
//               bore_d=6,
//               bore_h=2,
//               sink=true,
//               fn=100,
//               center=false,
//               reverse=true);
// }

// dia = 3;
// bore_dia = 6;
// bore_h = 1;
// rect_size = [20, 30];
// single_hole_d = 8;
// four_corner_holes_size = [40, 60];

// four_corner_holes_size_full_size =
//   four_corner_counterbores_full_size(size=four_corner_holes_size,
//                                      d=dia,
//                                      bore_d=bore_dia,
//                                      bore_h=bore_h);
// gap = 2;

// four_corner_counterbores(size=four_corner_holes_size,
//                          center=false,
//                          spin=30,
//                          d=dia,
//                          bore_d=bore_dia,
//                          h=thickness,
//                          bore_h=bore_h,
//                          reverse=true);
