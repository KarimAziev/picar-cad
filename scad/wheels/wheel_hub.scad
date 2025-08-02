/**
 * Module: Wheel hub for 608ZZ bearing.
 *
 * Here are the two main modules. The first, `wheel_hub_lower`, creates the lower
 * part of the hub into which the 608ZZ bearing is inserted, followed by the
 * `wheel_hub_upper`. Then, both modules are secured with M3 bolts.
 *
 * The `wheel_hub_lower` can be used either as a standalone component or as part
 * of the wheel.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../parameters.scad>
use <../util.scad>

function wheel_hub_full_height(h, inner_rim_h) = h + inner_rim_h * 2;
function wheel_hub_width(d, outer_d) = (outer_d - d) / 2;
function wheel_hub_screws_offset(d,
                                 screws_dia,
                                 screw_boss_w,
                                 inner_rim_w,
                                 tolerance=0.4,
                                 center,
                                 out_d) = center
  ? (d / 2) + (((out_d - d) / 2) / 2)
  :  (d / 2 + (screws_dia + screw_boss_w) / 2) + 1;

/**
 * Creates a half-hub of the specified height featuring screw boss pockets for
 * added functionality. It is intended for use as part of the wheel, but it can
 * also serve as a standalone component.
 */
module wheel_hub_lower(d=wheel_hub_d,
                       outer_d=wheel_hub_outer_d,
                       h=wheel_hub_h,
                       outer_ring_dia=wheel_hub_outer_ring_d,
                       inner_rim_h=wheel_hub_inner_rim_h,
                       inner_rim_w=wheel_hub_inner_rim_w,
                       screws_dia=wheel_hub_screws,
                       screws_n=wheel_screws_n,
                       screw_boss_h=wheel_screw_boss_h,
                       screw_boss_w=wheel_screw_boss_w,
                       center_screws=true,
                       tolerance=0.4,
                       upper_d) {
  full_h = wheel_hub_full_height(h, inner_rim_h);
  w = wheel_hub_width(d, outer_d);
  union() {
    difference() {
      wheel_hub_part(d=d,
                     outer_d=outer_d,
                     h=h,
                     inner_rim_h=inner_rim_h,
                     inner_rim_w=inner_rim_w,
                     screws_dia=screws_dia,
                     screws_n=screws_n,
                     screw_boss_h=screw_boss_h,
                     screw_boss_w=screw_boss_w,
                     upper_d=outer_ring_dia,
                     center_screws=center_screws);
      translate([0, 0, -screw_boss_h / 2]) {
        screw_bosses_pockets(h=screw_boss_h + 0.4,
                             y=wheel_hub_screws_offset(d,
                                                       screws_dia,
                                                       screw_boss_w,
                                                       inner_rim_w,
                                                       center=center_screws,
                                                       out_d=outer_ring_dia),
                             d=screws_dia + screw_boss_w + tolerance,
                             n=screws_n,
                             w=screw_boss_w,
                             fn=360);
      }
    }
    linear_extrude(height = 2, center = true, convexity=2) {
      ring_2d(r=(outer_ring_dia / 2) + 0.4,
              w=(outer_d - outer_ring_dia) / 2 - 0.4,
              fn=360,
              outer=true);
    }
  }
}

/**
 * Creates a mountable half-hub from the specified height with screw boss
 * pockets.
 */
module wheel_hub_upper(d=wheel_hub_d,
                       outer_d=wheel_hub_outer_ring_d,
                       h=wheel_hub_h,
                       inner_rim_h=wheel_hub_inner_rim_h,
                       inner_rim_w=wheel_hub_inner_rim_w,
                       screws_dia=wheel_hub_screws,
                       screws_n=wheel_screws_n,
                       screw_boss_h=wheel_screw_boss_h,
                       screw_boss_w=wheel_screw_boss_w,
                       center_screws=true) {
  difference() {
    union() {
      wheel_hub_part(d=d,
                     outer_d=outer_d,
                     h=h,
                     inner_rim_h=inner_rim_h,
                     inner_rim_w=inner_rim_w,
                     screws_dia=screws_dia,
                     screws_n=screws_n,
                     screw_boss_h=screw_boss_h,
                     screw_boss_w=screw_boss_w,
                     center_screws=center_screws);
      translate([0, 0, screw_boss_h / 2]) {
        screw_bosses(h=screw_boss_h,
                     y=wheel_hub_screws_offset(d,
                                               screws_dia,
                                               screw_boss_w,
                                               inner_rim_w,
                                               center=center_screws,
                                               out_d=outer_d),
                     d=screws_dia,
                     n=screws_n,
                     w=screw_boss_w);
      }
    }
    translate([0, 0, -wheel_hub_h]) {
      linear_extrude(height=wheel_hub_h + 1, center=false, convexity=2) {
        ring_2d(d=wheel_hub_outer_ring_d - wheel_thickness * 2 +
                wheel_screw_boss_w,
                fn=100,
                outer=true,
                w=wheel_thickness * 2);
      }
    }
  }
}

/**
 * Creates a hub geometry with a central ring and screw holes.
 */
module wheel_hub(d=wheel_hub_d,
                 outer_d=wheel_hub_outer_d,
                 h=wheel_hub_h,
                 inner_rim_h=wheel_hub_inner_rim_h,
                 inner_rim_w=wheel_hub_inner_rim_w,
                 screws_dia=wheel_hub_screws,
                 screws_n=wheel_screws_n,
                 screw_boss_h=wheel_screw_boss_h,
                 screw_boss_w=wheel_screw_boss_w,
                 center_screws=true,
                 upper_d) {
  // Calculate the ring width and full height including inner rims.
  w = wheel_hub_width(d, outer_d);
  full_h = wheel_hub_full_height(h, inner_rim_h);

  union() {
    linear_extrude(height=full_h, center=true, convexity=2) {
      difference() {
        ring_2d(r=d / 2, w=w, fn=360, outer=true);

        // Create screw holes evenly distributed along the hub perimeter.
        for (i=[0:1:screws_n-1]) {
          angle = i * (360 / screws_n);
          rotate([0, 0, angle]) {
            y = wheel_hub_screws_offset(d,
                                        screws_dia,
                                        screw_boss_w,
                                        inner_rim_w,
                                        center=center_screws,
                                        out_d=is_undef(upper_d)
                                        ? outer_d
                                        : upper_d);
            translate([0, y, 0]) {
              circle(r=screws_dia / 2, $fn=360);
            }
          }
        }
      }
    }

    base_z_ofst = [full_h / 2, inner_rim_h / 2];
    for (direction = [-1, 1]) {
      z = direction > 0 ? base_z_ofst[0] - base_z_ofst[1]
        : -base_z_ofst[0] + base_z_ofst[1];
      translate([0, 0, z]) {
        linear_extrude(height=inner_rim_h,
                       center=true,
                       convexity=2) {
          ring_2d(r=d / 2, w=inner_rim_w, fn=360, outer=false);
        }
      }
    }
  }
}

/**
 * Creates a mountable half hub from the specified height.
 */
module wheel_hub_part(d=wheel_hub_d,
                      outer_d=wheel_hub_outer_d,
                      h=wheel_hub_h,
                      inner_rim_h=wheel_hub_inner_rim_h,
                      inner_rim_w=wheel_hub_inner_rim_w,
                      screws_dia=wheel_hub_screws,
                      screws_n=wheel_screws_n,
                      screw_boss_h=wheel_screw_boss_h,
                      screw_boss_w=wheel_screw_boss_w,
                      center_screws=true,
                      upper_d) {
  full_h = wheel_hub_full_height(h, inner_rim_h);
  difference() {
    wheel_hub(d=d,
              outer_d=outer_d,
              h=h,
              inner_rim_h=inner_rim_h,
              inner_rim_w=inner_rim_w,
              screws_dia=screws_dia,
              screws_n=screws_n,
              screw_boss_h=screw_boss_h,
              screw_boss_w=screw_boss_w,
              upper_d=upper_d,
              center_screws=center_screws);

    translate([0, 0, full_h / 2]) {
      linear_extrude(height = full_h, center = true) {
        circle(r=outer_d);
      }
    }
  }
}

module screw_bosses(r, w=1, d, h, n, y, fn=360) {
  r = is_undef(r) ? d / 2 : r;
  linear_extrude(height=h,
                 center=true,
                 convexity=2) {
    for (i=[0:1:n-1]) {
      angle = i * (360 / n);

      rotate([0, 0, angle]) {
        translate([0, y, 0]) {
          ring_2d(r=r, w=w, fn=fn, outer=true);
        }
      }
    }
  }
}

module screw_bosses_pockets(r, w=1, d, h, n, y, fn) {
  r = is_undef(r) ? d / 2 : r;
  linear_extrude(height=h, center=true) {
    for (i=[0:1:n-1]) {
      angle = i * (360 / n);

      rotate([0, 0, angle]) {
        translate([0, y, 0]) {
          circle(r=r + w, $fn=fn);
        }
      }
    }
  }
}

union() {
  // translate([wheel_hub_outer_d / 2, 0, 0]) {
  //   wheel_hub_lower(screw_boss_h=wheel_screw_boss_h, center_screws=true);
  // }
  translate([wheel_hub_outer_d / 2, 0, 0]) {
    wheel_hub_upper(screw_boss_h=wheel_screw_boss_h, center_screws=true);
  }
}
