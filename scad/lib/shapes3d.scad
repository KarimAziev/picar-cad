/**
 * Module: Utility modules that simplify common 3D geometric constructions.
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
use <functions.scad>
use <shapes2d.scad>
use <transforms.scad>

module rounded_cube(size,
                    r=undef,
                    center=true,
                    z_center=false,
                    fn=36,
                    r_factor=0.02) {
  rad = is_undef(r) ? (min(size[0], size[1], size[2])) * r_factor : r;

  x = size[0] - rad * 2;
  y = size[1] - rad * 2;
  z = size[2] - rad * 2;
  translate([(center ? 0 : x / 2),
             (center ? 0 : y / 2),
             (z_center ? 0 : z / 2)
             + rad]) {
    offset_3d(r=rad, fn=fn) {
      cube([x, y, z], center=true);
    }
  }
}

module cube_3d(size, center=true) {
  if (center) {
    translate([0, 0, size[2] / 2]) {
      cube(size, center=center);
    }
  } else {
    cube(size, center=false);
  }
}

module cylinder_cut(h=10, r=5, cut_w=1, center=true, fn) {
  difference() {
    cylinder(h=h, r=r, center=center, $fn=fn);

    d = r * 2;
    translate([d - cut_w * 0.5, 0, 0]) {
      cube([d, d, h + 1], center=center);
    }
    translate([-d + cut_w * 0.5, 0, 0]) {
      cube([d, d, h + 1], center=center);
    }
  }
}

module star_3d(n=5, r_outer=20, r_inner=10, h=2) {
  linear_extrude(height=h, center=false) {
    star_2d(n=n, r_outer=r_outer, r_inner=r_inner);
  }
}

module notched_circle(d,
                      cutout_w,
                      h,
                      x_cutouts_n=1,
                      y_cutouts_n=0,
                      center=false,
                      convexity=1,
                      fn=360) {
  square_center_x = notched_circle_square_center_x(r=d / 2, cutout_w=cutout_w);
  linear_extrude(h=h, center=center, convexity=convexity) {
    difference() {
      circle(r=d / 2, $fn=fn);
      if (x_cutouts_n > 0) {
        for (i = [1:x_cutouts_n]) {
          translate([i == 1 ? square_center_x : -square_center_x, 0]) {
            square([cutout_w, cutout_w], center=true);
          }
        }
      }
      if (y_cutouts_n > 0) {
        for (i = [1:y_cutouts_n]) {
          translate([0, i == 1 ? square_center_x : -square_center_x]) {
            square([cutout_w, cutout_w], center=true);
          }
        }
      }
    }
  }
}

/**
 * Draws a rounded rectangular through-hole with an optional rectangular
 * counter-pocket (recess).
 * Parameters:
 *   size: [width_x, length_y, ...] - size of the main rounded rectangle. The
 *         corner radius is provided separately in r.
 *   recess_size: optional [recess_x, recess_y] - size of the recess. If undefined,
 *               no recess is created.
 *   r: corner radius for the rounded rectangle (applies to both main hole and
 *      the recess when recess_size is provided).
 *   thickness: total extrusion depth (depth of the main hole).
 *   recess_thickness: optional depth for the recess. If omitted, a reasonable
 *                    default (roughly thickness / 2.2, clamped to >= 1) is used.
 *   recess_reverse: boolean (default false). If true, the recess is located at
 *                  the opposite face along Z (i.e. near the top instead of at Z=0).
 *   center: boolean. If true the shapes are centered on X and Y; otherwise they
 *           are positioned with a corner at the origin.
 *
 * Behaviour:
 * - The main rounded rectangle is extruded through the full thickness.
 * - If recess_size is present a second rounded rectangle of recess_size is
 *   extruded by recess_thickness and positioned either at Z=0 or at the opposite
 *   face depending on recess_reverse.
 */

module rounded_rect_recess(size,
                           recess_size,
                           r,
                           thickness,
                           recess_thickness,
                           recess_reverse=false,
                           center=false) {
  recess_t = is_undef(recess_thickness)
    ? max(1, thickness / 2.2)
    : recess_thickness;
  recess_size = recess_size && recess_size[0] && recess_size[1] ? recess_size : undef;
  recess_z = recess_reverse ? thickness - recess_t : 0;
  translate([center
             ? 0
             : max(size[0], is_undef(recess_size) ? 0 : recess_size[0]) / 2,
             center ? 0 : max(size[1], is_undef(recess_size) ? 0 : recess_size[1]) / 2,
             0]) {
    union() {
      linear_extrude(height=thickness,
                     center=false) {
        rounded_rect(size=[size[0], size[1]],
                     r=r,
                     center=true);
      }

      if (recess_size) {
        translate([0, 0, recess_z]) {
          linear_extrude(height=recess_t,
                         center=false) {
            rounded_rect(size=[recess_size[0],
                               recess_size[1]],
                         r=r,
                         center=true);
          }
        }
      }
    }
  }
}

module cube_center_y(size) {
  translate([0, -size[1] / 2, 0]) {
    cube(size);
  }
}

module cube_center_x(size) {
  translate([-size[0] / 2, 0, 0]) {
    cube(size);
  }
}

module cube_border(size,
                   h,
                   border_w=0.5,
                   inner=true,
                   r=0,
                   center=false,
                   fn,
                   r_factor=0.3,
                   round_side) {
  linear_extrude(height=is_undef(h) ? size[2] : h,
                 center=false,
                 convexity=2) {
    rect_border(size=[size[0], size[1]],
                border_w=border_w,
                inner=inner,
                r=r,
                center=center,
                fn=fn,
                r_factor=r_factor,
                round_side=round_side);
  }
}
