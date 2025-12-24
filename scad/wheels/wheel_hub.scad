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

use <../lib/shapes2d.scad>

function wheel_hub_full_height(h, inner_rim_h) = h + inner_rim_h * 2;
function wheel_hub_width(d, outer_d) = (outer_d - d) / 2;
function wheel_hub_bolts_offset(d,
                                bolts_dia,
                                bolt_boss_w,
                                inner_rim_w,
                                tolerance=0.4,
                                center,
                                out_d) = center
  ? (d / 2) + (((out_d - d) / 2) / 2)
  :  (d / 2 + (bolts_dia + bolt_boss_w) / 2) + 1;

/**
 * Creates a half-hub of the specified height featuring bolt boss pockets for
 * added functionality. It is intended for use as part of the wheel, but it can
 * also serve as a standalone component.
 */
module wheel_hub_lower(d=wheel_hub_d,
                       outer_d=wheel_hub_outer_d,
                       h=wheel_hub_h,
                       outer_ring_dia=wheel_hub_outer_ring_d,
                       inner_rim_h=wheel_hub_inner_rim_h,
                       inner_rim_w=wheel_hub_inner_rim_w,
                       bolts_dia=wheel_hub_bolt_dia,
                       bolts_n=wheel_bolts_n,
                       bolt_boss_h=wheel_bolt_boss_h,
                       bolt_boss_w=wheel_bolt_boss_w,
                       center_bolts=true,
                       tolerance=0.4) {
  union() {
    difference() {
      wheel_hub_part(d=d,
                     outer_d=outer_d,
                     h=h,
                     inner_rim_h=inner_rim_h,
                     inner_rim_w=inner_rim_w,
                     bolts_dia=bolts_dia,
                     bolts_n=bolts_n,
                     bolt_boss_w=bolt_boss_w,
                     upper_d=outer_ring_dia,
                     center_bolts=center_bolts);
      translate([0, 0, -bolt_boss_h / 2]) {
        bolt_bosses_pockets(h=bolt_boss_h + 0.4,
                            y=wheel_hub_bolts_offset(d,
                                                     bolts_dia,
                                                     bolt_boss_w,
                                                     inner_rim_w,
                                                     center=center_bolts,
                                                     out_d=outer_ring_dia),
                            d=bolts_dia + bolt_boss_w + tolerance,
                            n=bolts_n,
                            w=bolt_boss_w,
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
 * Creates a mountable half-hub from the specified height with bolt boss
 * pockets.
 */
module wheel_hub_upper(d=wheel_hub_d,
                       outer_d=wheel_hub_outer_ring_d,
                       h=wheel_hub_h,
                       inner_rim_h=wheel_hub_inner_rim_h,
                       inner_rim_w=wheel_hub_inner_rim_w,
                       bolts_dia=wheel_hub_bolt_dia,
                       bolts_n=wheel_bolts_n,
                       bolt_boss_h=wheel_bolt_boss_h,
                       bolt_boss_w=wheel_bolt_boss_w,
                       center_bolts=true) {
  difference() {
    union() {
      wheel_hub_part(d=d,
                     outer_d=outer_d,
                     h=h,
                     inner_rim_h=inner_rim_h,
                     inner_rim_w=inner_rim_w,
                     bolts_dia=bolts_dia,
                     bolts_n=bolts_n,
                     bolt_boss_w=bolt_boss_w,
                     center_bolts=center_bolts);
      translate([0, 0, bolt_boss_h / 2]) {
        bolt_bosses(h=bolt_boss_h,
                    y=wheel_hub_bolts_offset(d,
                                             bolts_dia,
                                             bolt_boss_w,
                                             inner_rim_w,
                                             center=center_bolts,
                                             out_d=outer_d),
                    d=bolts_dia,
                    n=bolts_n,
                    w=bolt_boss_w);
      }
    }
    translate([0, 0, -wheel_hub_h]) {
      linear_extrude(height=wheel_hub_h + 1, center=false, convexity=2) {
        ring_2d(d=wheel_hub_outer_ring_d - wheel_thickness * 2 +
                wheel_bolt_boss_w,
                fn=100,
                outer=true,
                w=wheel_thickness * 2);
      }
    }
  }
}

/**
 * Creates a hub geometry with a central ring and bolt holes.
 */
module wheel_hub(d=wheel_hub_d,
                 outer_d=wheel_hub_outer_d,
                 h=wheel_hub_h,
                 inner_rim_h=wheel_hub_inner_rim_h,
                 inner_rim_w=wheel_hub_inner_rim_w,
                 bolts_dia=wheel_hub_bolt_dia,
                 bolts_n=wheel_bolts_n,
                 bolt_boss_w=wheel_bolt_boss_w,
                 center_bolts=true,
                 upper_d) {
  // Calculate the ring width and full height including inner rims.
  w = wheel_hub_width(d, outer_d);
  full_h = wheel_hub_full_height(h, inner_rim_h);

  union() {
    linear_extrude(height=full_h, center=true, convexity=2) {
      difference() {
        ring_2d(r=d / 2, w=w, fn=360, outer=true);

        // Create bolt holes evenly distributed along the hub perimeter.
        for (i=[0:1:bolts_n-1]) {
          angle = i * (360 / bolts_n);
          rotate([0, 0, angle]) {
            y = wheel_hub_bolts_offset(d,
                                       bolts_dia,
                                       bolt_boss_w,
                                       inner_rim_w,
                                       center=center_bolts,
                                       out_d=is_undef(upper_d)
                                       ? outer_d
                                       : upper_d);
            translate([0, y, 0]) {
              circle(r=bolts_dia / 2, $fn=360);
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
                      bolts_dia=wheel_hub_bolt_dia,
                      bolts_n=wheel_bolts_n,
                      bolt_boss_w=wheel_bolt_boss_w,
                      center_bolts=true,
                      upper_d) {
  full_h = wheel_hub_full_height(h, inner_rim_h);
  difference() {
    wheel_hub(d=d,
              outer_d=outer_d,
              h=h,
              inner_rim_h=inner_rim_h,
              inner_rim_w=inner_rim_w,
              bolts_dia=bolts_dia,
              bolts_n=bolts_n,
              bolt_boss_w=bolt_boss_w,
              upper_d=upper_d,
              center_bolts=center_bolts);

    translate([0, 0, full_h / 2]) {
      linear_extrude(height = full_h, center = true) {
        circle(r=outer_d);
      }
    }
  }
}

module bolt_bosses(r, w=1, d, h, n, y, fn=360) {
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

module bolt_bosses_pockets(r, w=1, d, h, n, y, fn) {
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
  //   wheel_hub_lower(bolt_boss_h=wheel_bolt_boss_h, center_bolts=true);
  // }
  translate([wheel_hub_outer_d / 2, 0, 0]) {
    wheel_hub_upper(bolt_boss_h=wheel_bolt_boss_h, center_bolts=true);
  }
}
