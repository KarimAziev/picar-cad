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
                               center=false) {

  w_top = slider_calc_trapezoid_top_width(width=w,
                                          height=h,
                                          angle=angle);

  translate([center ? 0 : base_w / 2, center ? 0 : base_h / 2, 0]) {
    union() {
      translate([0, base_h / 2 + h / 2, 0]) {
        trapezoid_rounded_top(b=w,
                              t=w_top,
                              h=h,
                              r=r,
                              center=true);
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

   Creates a dovetail rail profile with a base.

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
                            center=false) {

  linear_extrude(height=l, center=false, convexity=2) {
    slider_dovetail_rail_2d(base_h=base_h,
                            base_w=base_w,
                            h=h,
                            w=w,
                            angle=angle,
                            base_angle=base_angle,
                            r=r,
                            base_r=base_r,
                            center=center);
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
                    center=false);
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
                    angle=0,
                    center=false) {
  half_of_h = h / 2;
  w_top = slider_calc_trapezoid_top_width(width=w,
                                          height=half_of_h,
                                          angle=angle);

  translate([center ? -w / 2 : 0,
             center ? 0 : half_of_h,
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
