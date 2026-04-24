/**
 * Module: Parametric slider
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include  <../colors.scad>
include  <../parameters.scad>

use <shapes2d.scad>
use <transforms.scad>
use <trapezoids.scad>

function slider_calc_trapezoid_top_width(width, height, angle) =
  max(0, width - 2 * height * tan(angle));

function slider_carriege_full_width(w, wall) = w + (wall * 2);

/**
   ─────────────────────────────────────────────────────────────────────────────
   slider_carriage
   ─────────────────────────────────────────────────────────────────────────────
    Creates a slider carriage with a base and an internal trapezoid or dovetail cutout.

   **Example**:
   ```scad
    // Slider carriage with dovetail rib
    slider_carriage(l=30,
                     base_h=10,
                     w=20,
                     h=15,
                     wall=4,
                     angle=10,
                     r=2,
                     trapezoid_rad=1,
                     use_dovetail_rib=true, // false for trapezoid
                     center_x=true,
                     center_y=true,
                     center_z=true);
     // Slider carriage with trapezoid cutout
     slider_carriage(l=30,
                     base_h=10,
                     w=20,
                     h=15,
                     wall=4,
                     angle=10,
                     r=2,
                     trapezoid_rad=1,
                     use_dovetail_rib=false, // false for trapezoid
                     center_x=true,
                     center_y=true,
                     center_z=true);

   ```
*/
module slider_carriage(l=30,
                       base_h=10,
                       h,
                       w,
                       wall=4,
                       angle=0,
                       r=0,
                       trapezoid_rad=0,
                       use_dovetail_rib=false,
                       center_x=false,
                       center_y=false,
                       center_z=false) {
  rect_w = slider_carriege_full_width(w, wall);
  full_h = h + base_h;

  translate([center_x ? -rect_w / 2 : 0,
             center_y ? -full_h / 2 : 0,
             0]) {
    linear_extrude(height=l, center=center_z) {
      difference() {
        rounded_rect([rect_w, full_h], r=r, center=false);
        translate([rect_w / 2 - w / 2, full_h - h + trapezoid_rad / 2, 0]) {
          if (use_dovetail_rib) {
            dovetail_rib(w=w,
                         h=h,
                         angle=angle,
                         r=trapezoid_rad);
          } else {
            slider_trapezoid(w=w,
                             h=h,
                             angle=angle,
                             r=trapezoid_rad);
          }
        }
      }
    }
  }
}

/**
   ─────────────────────────────────────────────────────────────────────────────
   slider_dovetail_rail_2d
   ─────────────────────────────────────────────────────────────────────────────

   Creates a 2D dovetail rail profile with a base.

   **Example**:
   ```scad
   slider_dovetail_rail_2d(base_w=20,
                               base_h=5,
                               w=15,
                               h=10,
                               angle=15,
                               r=1,
                               center=true);
   ```
*/
module slider_dovetail_rail_2d(base_w,
                               base_h,
                               base_angle=0,
                               base_r=0,
                               w,
                               h,
                               angle=0,
                               r=0,
                               center=false,
                               reverse=false,
                               center_x,
                               center_y,
                               use_dovetail_rib,
                               edge_land,
                               relief_depth) {

  w_top = slider_calc_trapezoid_top_width(width=w,
                                          height=h,
                                          angle=angle);

  center_x = is_undef(center_x) ? center : center_x;
  center_y = is_undef(center_y) ? center : center_y;

  module _main() {
    if (!use_dovetail_rib) {
      trapezoid_rounded_top(b=reverse ? w_top : w,
                            t=reverse ? w : w_top,
                            h=h,
                            r=r,
                            center=true);
    } else {
      dovetail_rib(w=w,
                   h=h,
                   angle=angle,
                   r_top=r,
                   r_bottom=0,
                   center=true);
    }
  }

  translate([center_x ? 0 : max(base_w, w) / 2, center_y ? 0 : base_h / 2, 0]) {
    union() {
      translate([0, base_h / 2 + h / 2, 0]) {
        if (!is_undef(edge_land) && !is_undef(relief_depth)) {
          dovetail_rib_relief_cutter_2d(edge_land=edge_land,
                                        relief_depth=relief_depth,
                                        angle=angle) {
            _main();
          }
        } else {
          _main();
        }
      }
      slider_trapezoid(w=base_w,
                       h=base_h,
                       angle=base_angle,
                       r=base_r,
                       center=true);
    }
  }
}

/**
   ─────────────────────────────────────────────────────────────────────────────
   slider_dovetail_rail
   ─────────────────────────────────────────────────────────────────────────────

   Creates a dovetail rail profile with a rectangular base. It consists of two parts:
   - the base rectangular part
   - trapezoid above the base.


   **Example**:
   ```scad
   slider_dovetail_rail(l=10,
                        base_w=20,
                        base_h=5,
                        w=15,
                        h=10,
                        angle=15,
                        r=1,
                        center=true);
   ```
*/
module slider_dovetail_rail(l,
                            base_w,
                            base_h,
                            base_angle=0,
                            base_r=0,
                            w,
                            h,
                            angle=0,
                            r=0,
                            reverse=false,
                            center=false,
                            center_x,
                            center_y,
                            convexity=2,
                            use_dovetail_rib) {

  linear_extrude(height=l, center=false, convexity=convexity) {
    slider_dovetail_rail_2d(base_h=base_h,
                            base_w=base_w,
                            h=h,
                            w=w,
                            angle=angle,
                            base_angle=base_angle,
                            r=r,
                            base_r=base_r,
                            center=center,
                            reverse=reverse,
                            center_x=center_x,
                            center_y=center_y,
                            use_dovetail_rib=use_dovetail_rib);
  }
}

/**
   ─────────────────────────────────────────────────────────────────────────────
   slider_trapezoid
   ─────────────────────────────────────────────────────────────────────────────

   Creates a trapezoid shape with rounded corners.

   **Example**:
   ```scad
   slider_trapezoid(w=20,
                    h=15,
                    angle=10,
                    r=2,
                    center=true);
   ```
*/
module slider_trapezoid(w,
                        h,
                        r=0,
                        angle=0,
                        center=false) {
  w_top = slider_calc_trapezoid_top_width(width=w, height=h, angle=angle);
  trapezoid_rounded(b=w,
                    t=w_top,
                    h=h,
                    r=r,
                    center=center);
}

/**
   ─────────────────────────────────────────────────────────────────────────────
   dovetail_rib
   ─────────────────────────────────────────────────────────────────────────────

   Creates a 2D dovetail rib shape with rounded corners.

   **Example**:
   ```scad
   dovetail_rib(w=20,
                h=15,
                angle=10,
                r=2,
                center=false);
   ```
*/
module dovetail_rib(w,
                    h,
                    r=0,
                    r_top,
                    r_bottom,
                    angle=0,
                    center=false,
                    center_x,
                    center_y,
                    fn) {

  fn = is_undef(fn) ? ($preview ? 30 : 40) : fn;

  half_of_h = h / 2;
  w_top = slider_calc_trapezoid_top_width(width=w,
                                          height=half_of_h,
                                          angle=angle);

  center_x = is_undef(center_x) ? center : center_x;
  center_y = is_undef(center_y) ? center : center_y;

  if (!is_undef(r_top) && !is_undef(r_bottom)) {
    translate([center_x ? 0 : w / 2,
               center_y ? -half_of_h : 0,
               0]) {
      union() {
        translate([0, half_of_h / 2 + half_of_h - 0.1, 0]) {
          trapezoid_rounded_top(b=w_top,
                                t=w,
                                h=half_of_h + 0.1,
                                r=r_top,
                                center=true);
        }
        translate([0, half_of_h / 2, 0]) {
          trapezoid_rounded_bottom(b=w,
                                   t=w_top,
                                   h=half_of_h,
                                   r=r_bottom,
                                   center=true);
        }
      }
    }
  } else {
    translate([center_x ? -w / 2 : 0,
               center_y ? 0 : half_of_h,
               0]) {
      mirror_copy([0, 1, 0]) {
        trapezoid_rounded_top(b=w_top,
                              t=w,
                              h=half_of_h,
                              r=r,
                              center=false);
      }
    }
  }
}
/**
  ─────────────────────────────────────────────────────────────────────────────
  dovetail_rib_relief_cutter_2d
  ─────────────────────────────────────────────────────────────────────────────

  Creates a 2D relief cutter shape for a dovetail rib. It consists of two parts:
- an offset of the original shape by the relief depth, which creates the relief area
- an offset of the original shape by the edge land, which creates the area that will be
cut by the relief cutter.

  **Parameters**:

  `edge_land`:    The distance from the original shape to the edge of the relief
                  cutter. This is the area that will be cut by the relief cutter.
  `relief_depth`: The depth of the relief cut. This determines how much material
                  will be removed to create the relief.
  `angle`:        The angle of the dovetail rib. This is used to calculate the parallel
                  distance for the relief cut based on the relief depth.

  **Note:** Children must be centered for the module to work correctly, as it relies on offsets to create the relief cutter shape.

  **Example**:
  ```scad

  ang = 30;
  module my_dovetail() {
    dovetail_rib(w=20,
                 h=15,
                 angle=ang,
                 r=2,
                 center=true);
  }

  linear_extrude(height=10, center=false) {
    dovetail_rib_relief_cutter_2d(edge_land=0.45,
                                  relief_depth=0.15,
                                  angle=ang) {
      my_dovetail();
    }
  }
  // debug
  #linear_extrude(height=10, center=false) {
    my_dovetail();
  }

  ```
  */
module dovetail_rib_relief_cutter_2d(edge_land,
                                     relief_depth,
                                     angle) {

  assert(is_num(relief_depth), "Relief depth must be a number");
  assert(is_num(edge_land), "Edge land must be a number");
  assert(is_num(edge_land), "Angle must be a number");
  assert(relief_depth >= 0, "Relief depth must be 0 or positive");

  assert(edge_land >= 0, "Edge land must be 0 or positive");
  assert(angle >= 0 && angle <= 90, "Angle must be between 0 and 90 degrees");

  d_parallel = relief_depth / cos(angle);

  intersection() {
    offset(r=d_parallel) {
      children();
    }

    offset(r=-edge_land) {
      offset(r=edge_land) {
        children();
      }
    }
  }
}

// dovetail_rib(w=20,
//              h=15,
//              angle=10,
//              r=2,
//              center=false);

// slider_dovetail_rail_2d(base_w=25,
//                         base_h=5,
//                         w=15,
//                         h=10,
//                         angle=15,
//                         r=0,
//                         center=true,
//                         reverse=true,
//                         use_dovetail_rib=true);

// slider_carriage(l=30,
//                 base_h=10,
//                 w=20,
//                 h=15,
//                 wall=4,
//                 angle=10,
//                 r=2,
//                 trapezoid_rad=1,
//                 use_dovetail_rib=false, // false for trapezoid
//                 center_x=true,
//                 center_y=true,
//                 center_z=true);

// slider_dovetail_rail_2d(base_w=20,
//                         base_h=5,
//                         w=15,
//                         h=10,
//                         angle=15,
//                         center=true,
//                         reverse=true);

// slider_trapezoid(w=20,
//                  h=15,
//                  angle=10,
//                  r=2,
//                  center=true);

// dovetail_rib(w=20,
//              h=15,
//              angle=10,
//              r_top=1,
//              r_bottom=0.5,
//              center=true,
//              center_y=false);