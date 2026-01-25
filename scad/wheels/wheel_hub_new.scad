include <../parameters.scad>

use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../placeholders/ball_bearing.scad>
use <../placeholders/bolt.scad>

function wheel_hub_full_h(bearing_h=wheel_bearing_w,
                          rim_h=wheel_hub_inner_rim_h,
                          tolerance=wheel_hub_h_tolerance)
= rim_h + (tolerance + bearing_h) / 2;

module wheel_hub_base(bearing_d=wheel_bearing_outer_d,
                      d=wheel_hub_outer_d,
                      bearing_w=wheel_bearing_w,
                      tolerance=wheel_hub_h_tolerance,
                      spacer_h=wheel_hub_inner_rim_h,
                      spacer_w=wheel_hub_inner_rim_w,
                      spacer_at_top=false,
                      bolt_pocket_mode=false,
                      bolt_offset=wheel_hub_bolt_offset,
                      bolt_boss_d=wheel_hub_bolt_boss_d,
                      bolt_boss_h=wheel_bolt_boss_h,
                      bolt_d=wheel_hub_bolt_d,
                      bolts_n=wheel_bolts_n,
                      fn=100,
                      color) {
  base_h = (bearing_w  + tolerance) / 2;
  spacer_d = bearing_d - spacer_w * 2;
  bolt_y = (bearing_d / 2) + max(bolt_boss_d, bolt_d) / 2 + bolt_offset;

  module _base() {
    maybe_color(color) {
      union() {
        if (!spacer_at_top) {
          ring(outer_d=d, d=spacer_d, h=spacer_h, fn=fn);
          translate([0, 0, spacer_h]) {
            ring(outer_d=d, d=bearing_d, h=base_h, fn=fn);
          }
        } else {
          ring(outer_d=d, d=bearing_d, h=base_h, fn=fn);
          translate([0, 0, base_h]) {
            ring(outer_d=d, d=spacer_d, h=spacer_h, fn=fn);
          }
        }

        if (!bolt_pocket_mode) {
          let (full_h = spacer_h + base_h) {
            for (i=[0:1:bolts_n-1]) {
              angle = i * (360 / bolts_n);

              rotate([0, 0, angle]) {
                translate([0, bolt_y, full_h]) {
                  cylinder(d2=bolt_d, d1=bolt_boss_d, h=bolt_boss_h, $fn=fn);
                }
              }
            }
          }
        }
      }
    }
  }

  union() {
    let (full_h = spacer_h + base_h + (bolt_pocket_mode ? 0 :
                                       bolt_boss_h),
         bore_d=bolt_pocket_mode ? bolt_boss_d : 0) {
      difference() {
        _base();
        for (i=[0:1:bolts_n-1]) {
          angle = i * (360 / bolts_n);

          rotate([0, 0, angle]) {
            translate([0, bolt_y, 0]) {
              counterbore(d=bolt_d,
                          h=full_h,
                          sink=true,
                          reverse=spacer_at_top,
                          bore_d=bore_d,
                          bore_h=bolt_boss_h);
            }
          }
        }
      }
      if ($children > 0) {
        translate([0, 0, spacer_at_top ? base_h : spacer_h]) {
          children();
        }
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
  linear_extrude(height=h, center=true, convexity=2) {
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

module wheel_bearing() {
  ball_bearing(bore_d=wheel_bearing_bore_d,
               shoulder_d=wheel_bearing_shoulder_d,
               outer_recess_d=wheel_bearing_outer_recess_d,
               w=wheel_bearing_w,
               outer_d=wheel_bearing_outer_d);
}

module wheel_hub_lower(d=wheel_hub_outer_d, color="white") {

  wheel_hub_base(color=color, bolt_pocket_mode=true, d=d);
}

module wheel_hub_upper(color="white", d=wheel_hub_outer_d) {
  h = wheel_hub_full_h();
  translate([0, 0, h]) {

    rotate([180, 0, 0]) {
      wheel_hub_base(d=d, spacer_at_top=false, color=color);
    }
  }
}

module wheel_hub_assembly(color="white",
                          lower_d=wheel_hub_outer_d,
                          upper_d=wheel_hub_outer_d,
                          show_upper_hub=true,
                          show_lower_hub=true,
                          show_bearing=true) {
  if (show_upper_hub) {
    h = wheel_hub_full_h();
    translate([0, 0, h]) {
      wheel_hub_upper(color=color,
                      d=upper_d);
    }
  }
  if (show_lower_hub) {
    wheel_hub_lower(color=color,
                    d=lower_d);
  }
  if (show_bearing) {
    translate([0, 0, wheel_hub_inner_rim_h]) {
      wheel_bearing();
    }
  }
}

module wheel_hub_upper_printable() {
  translate([0, 0, wheel_hub_full_h()]) {

    rotate([180, 0, 0]) {
      wheel_hub_upper();
    }
  }
}

module wheel_hub_lower_printable() {
  wheel_hub_lower();
}

// wheel_hub_assembly(color="white");
// wheel_hub_assembly(show_upper_hub=false,
//                    show_lower_hub=false,
//                    show_bearing=false);

wheel_hub_upper_printable();

// translate([wheel_hub_outer_d + 5, 0, 0]) {

//   wheel_hub_lower_printable();
// }