/**
 * Module: Wheel Hub
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>

use <../lib/placement.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../placeholders/ball_bearing.scad>
use <../placeholders/bolt.scad>

show_lower_hub = true;
show_bearing   = false;
show_upper_hub = false;
show_bolts     = false;
show_nuts      = false;

// Whether to use locking nut
lock_nut       = true;

function wheel_hub_full_h(bearing_w=wheel_bearing_w,
                          spacer_h=wheel_hub_inner_rim_h,
                          h_tolerance=wheel_hub_h_tolerance)
= spacer_h + (h_tolerance + bearing_w) / 2;

module wheel_hub_base(d=wheel_hub_outer_d,
                      bearing_d=wheel_bearing_outer_d,
                      bearing_w=wheel_bearing_w,
                      h_tolerance=wheel_hub_h_tolerance,
                      spacer_h=wheel_hub_inner_rim_h,
                      spacer_w=wheel_hub_inner_rim_w,
                      bolt_offset=wheel_hub_bolt_offset,
                      bolt_boss_d=wheel_hub_bolt_boss_d,
                      bolt_boss_h=wheel_bolt_boss_h,
                      bolt_d=wheel_hub_bolt_d,
                      bolts_n=wheel_bolts_n,
                      fn,
                      spacer_at_top=false,
                      bolt_pocket_mode=false,
                      show_bolts=false,
                      nut_head_distance,
                      show_nuts=false,
                      lock_nut=false,
                      bolt_head_type="socket",
                      bearing_tolerance=0.1,
                      bolt_h,
                      bolt_cbore_d,
                      bolt_cbore_h,
                      color) {
  fn = with_default(fn, $preview ? 100 : 360);
  base_h = (bearing_w  + h_tolerance) / 2;
  spacer_d = bearing_d - spacer_w * 2;
  bolt_y = (bearing_d / 2) + max(bolt_boss_d, bolt_d) / 2 + bolt_offset;

  has_counterbores = !is_undef(bolt_cbore_d)
    && !is_undef(bolt_cbore_h)
    && bolt_cbore_h > 0
    && bolt_cbore_d > bolt_d;

  module _base() {
    maybe_color(color) {
      union() {
        if (!spacer_at_top) {
          ring(outer_d=d, d=spacer_d, h=spacer_h, fn=fn);
          translate([0, 0, spacer_h]) {
            ring(outer_d=d, d=bearing_d + bearing_tolerance, h=base_h, fn=fn);
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
              let (angle = i * (360 / bolts_n)) {
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
  }

  union() {
    let (full_h = spacer_h + base_h + (bolt_pocket_mode ? 0 :
                                       bolt_boss_h),
         bore_d=bolt_pocket_mode ? bolt_boss_d : 0) {
      difference() {
        _base();
        for (i=[0:1:bolts_n-1]) {
          let (angle = i * (360 / bolts_n)) {
            rotate([0, 0, angle]) {
              translate([0, bolt_y, 0]) {
                counterbore(d=bolt_d,
                            h=full_h,
                            sink=true,
                            reverse=spacer_at_top,
                            bore_d=bore_d,
                            bore_h=bolt_boss_h);

                if (has_counterbores) {
                  counterbore(d=bolt_d,
                              h=full_h,
                              sink=false,
                              reverse=!spacer_at_top,
                              bore_d=bolt_cbore_d,
                              bore_h=bolt_cbore_h);
                }
              }
            }
          }
        }
      }

      if (show_bolts) {
        render() {
          let (bolt_height = with_default(bolt_h,
                                          (spacer_h
                                           + base_h
                                           + (bolt_pocket_mode
                                              ? 0
                                              : bolt_boss_h))),
               z_offset = bolt_height + with_default(bolt_cbore_h, 0)) {
            for (i=[0:1:bolts_n-1]) {
              let (angle = i * (360 / bolts_n),
                   nut_dist = with_default(nut_head_distance, bolt_h)) {
                rotate([0, 0, angle]) {
                  translate([0, bolt_y, 0]) {
                    translate([0, 0, z_offset]) {
                      rotate([180, 0, 0]) {
                        bolt(d=bolt_d,
                             h=bolt_height,
                             head_type=bolt_head_type,
                             nut_head_distance=nut_dist,
                             show_nut=show_nuts,
                             lock_nut=lock_nut);
                      }
                    }
                  }
                }
              }
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

module wheel_bearing(bore_d=wheel_bearing_bore_d,
                     shoulder_d=wheel_bearing_shoulder_d,
                     outer_recess_d=wheel_bearing_outer_recess_d,
                     w=wheel_bearing_w,
                     outer_d=wheel_bearing_outer_d) {
  ball_bearing(bore_d=bore_d,
               shoulder_d=shoulder_d,
               outer_recess_d=outer_recess_d,
               w=w,
               outer_d=outer_d);
}

module wheel_hub_lower(d=wheel_hub_outer_d,
                       color="white",
                       bearing_d=wheel_bearing_outer_d,
                       bearing_w=wheel_bearing_w,
                       h_tolerance=wheel_hub_h_tolerance,
                       spacer_h=wheel_hub_inner_rim_h,
                       spacer_w=wheel_hub_inner_rim_w,
                       bolt_offset=wheel_hub_bolt_offset,
                       bolt_boss_d=wheel_hub_bolt_boss_d,
                       bolt_boss_h=wheel_bolt_boss_h,
                       bolt_d=wheel_hub_bolt_d,
                       bolts_n=wheel_bolts_n,
                       bolt_cbore_d,
                       bolt_cbore_h,
                       show_bolts=false,
                       show_nuts=false,
                       lock_nut=false,
                       bolt_h,
                       nut_head_distance=0,
                       fn) {
  fn = with_default(fn, $preview ? 100 : 360);
  wheel_hub_base(d=d,
                 color=color,
                 bearing_d=bearing_d,
                 bearing_w=bearing_w,
                 h_tolerance=h_tolerance,
                 spacer_h=spacer_h,
                 spacer_w=spacer_w,
                 bolt_offset=bolt_offset,
                 bolt_boss_d=bolt_boss_d,
                 bolt_boss_h=bolt_boss_h,
                 bolt_d=bolt_d,
                 bolts_n=bolts_n,
                 fn=fn,
                 bolt_cbore_d=bolt_cbore_d,
                 bolt_cbore_h=bolt_cbore_h,
                 show_bolts=show_bolts,
                 show_nuts=show_nuts,
                 lock_nut=lock_nut,
                 bolt_h=bolt_h,
                 nut_head_distance=nut_head_distance,
                 spacer_at_top=false,
                 bolt_pocket_mode=true);
}

module wheel_hub_upper(color="white",
                       d=wheel_hub_outer_d,
                       bearing_w=wheel_bearing_w,
                       bearing_d=wheel_bearing_outer_d,
                       h_tolerance=wheel_hub_h_tolerance,
                       spacer_h=wheel_hub_inner_rim_h,
                       spacer_w=wheel_hub_inner_rim_w,
                       bolt_offset=wheel_hub_bolt_offset,
                       bolt_boss_d=wheel_hub_bolt_boss_d,
                       bolt_boss_h=wheel_bolt_boss_h,
                       bolt_d=wheel_hub_bolt_d,
                       bolts_n=wheel_bolts_n,
                       fn) {
  fn = with_default(fn, $preview ? 100 : 360);
  h = wheel_hub_full_h(bearing_w=bearing_w,
                       spacer_h=spacer_h,
                       h_tolerance=h_tolerance);
  translate([0, 0, h]) {
    rotate([180, 0, 0]) {
      wheel_hub_base(d=d,
                     spacer_at_top=false,
                     bolt_pocket_mode=false,
                     color=color,
                     bearing_d=bearing_d,
                     bearing_w=bearing_w,
                     h_tolerance=h_tolerance,
                     spacer_h=spacer_h,
                     spacer_w=spacer_w,
                     bolt_offset=bolt_offset,
                     bolt_boss_d=bolt_boss_d,
                     bolt_boss_h=bolt_boss_h,
                     bolt_d=bolt_d,
                     bolts_n=bolts_n,
                     fn=fn);
    }
  }
}

module wheel_hub_assembly(upper_color=white_smoke_1,
                          lower_color="white",
                          lower_d=wheel_hub_outer_d,
                          upper_d=wheel_hub_outer_d,
                          h_tolerance=wheel_hub_h_tolerance,
                          lower_spacer_h=wheel_hub_inner_rim_h,
                          upper_spacer_h=wheel_hub_inner_rim_h,
                          spacer_w=wheel_hub_inner_rim_w,
                          bolt_offset=wheel_hub_bolt_offset,
                          bolt_boss_d=wheel_hub_bolt_boss_d,
                          bolt_boss_h=wheel_bolt_boss_h,
                          bolt_d=wheel_hub_bolt_d,
                          bolts_n=wheel_bolts_n,
                          bearing_w=wheel_bearing_w,
                          bearing_d=wheel_bearing_outer_d,
                          bearing_bore_d=wheel_bearing_bore_d,
                          bearing_shoulder_d=wheel_bearing_shoulder_d,
                          bearing_outer_recess_d=wheel_bearing_outer_recess_d,
                          fn,
                          bolt_cbore_d,
                          bolt_cbore_h,
                          show_upper_hub=show_upper_hub,
                          show_lower_hub=show_lower_hub,
                          show_bearing=show_bearing,
                          show_bolts=show_bolts,
                          show_nuts=show_nuts,
                          lock_nut=lock_nut,
                          bolt_h,
                          nut_head_distance,
                          assembly_clearance=0.1) {
  fn = with_default(fn, $preview ? 100 : 360);
  lower_h = wheel_hub_full_h(bearing_w=bearing_w,
                             spacer_h=lower_spacer_h,
                             h_tolerance=h_tolerance);
  upper_h = wheel_hub_full_h(bearing_w=bearing_w,
                             spacer_h=upper_spacer_h,
                             h_tolerance=h_tolerance);

  nut_height = find_nut_prop(inner_d=bolt_d, prop="height", lock=lock_nut);
  bolt_h = with_default(bolt_h,
                        lower_h
                        + upper_h
                        + with_default(nut_height, 0)
                        - with_default(bolt_cbore_h, 0));

  nut_head_distance = with_default(nut_head_distance,
                                   lower_h
                                   + upper_h
                                   - with_default(bolt_cbore_h, 0)
                                   + assembly_clearance);

  if (show_upper_hub) {
    translate([0, 0, lower_h + assembly_clearance]) {
      wheel_hub_upper(color=upper_color,
                      d=upper_d,
                      bearing_w=bearing_w,
                      bearing_d=bearing_d,
                      h_tolerance=h_tolerance,
                      spacer_h=upper_spacer_h,
                      spacer_w=spacer_w,
                      bolt_offset=bolt_offset,
                      bolt_boss_d=bolt_boss_d,
                      bolt_boss_h=bolt_boss_h,
                      bolt_d=bolt_d,
                      bolts_n=bolts_n,
                      fn=fn);
    }
  }
  if (show_lower_hub) {
    wheel_hub_lower(color=lower_color,
                    d=lower_d,
                    bearing_d=bearing_d,
                    bearing_w=bearing_w,
                    h_tolerance=h_tolerance,
                    spacer_h=lower_spacer_h,
                    spacer_w=spacer_w,
                    bolt_offset=bolt_offset,
                    bolt_boss_d=bolt_boss_d,
                    bolt_boss_h=bolt_boss_h,
                    bolt_d=bolt_d,
                    bolts_n=bolts_n,
                    fn=fn,
                    bolt_cbore_h=bolt_cbore_h,
                    bolt_cbore_d=bolt_cbore_d,
                    show_bolts=show_bolts,
                    show_nuts=show_nuts,
                    lock_nut=lock_nut,
                    bolt_h=bolt_h,
                    nut_head_distance=nut_head_distance);
  }
  if (show_bearing) {
    translate([0, 0, lower_spacer_h]) {
      wheel_bearing(w=bearing_w,
                    outer_d=bearing_d,
                    bore_d=bearing_bore_d,
                    shoulder_d=bearing_shoulder_d,
                    outer_recess_d=bearing_outer_recess_d);
    }
  }
}

module wheel_hub_upper_printable() {
  translate([0, 0, wheel_hub_full_h()]) {
    rotate([180, 0, 0]) {
      wheel_hub_upper(fn=360);
    }
  }
}

module wheel_hub_lower_printable() {
  wheel_hub_lower(fn=360);
}

module wheel_hub_printable_plate(spacing=5, align=-1) {
  params = calc_cols_params(cols=2, w=wheel_hub_outer_d, gap=spacing);
  total = params[1];
  align_poses = [1, 0,
                 -1, -total,
                 0, -total / 2];

  x = plist_get(align, align_poses, 0);
  y = plist_get(align, align_poses, 0);

  maybe_translate([x, y, 0]) {
    rows_children(rows=2, w=wheel_hub_outer_d, gap=spacing) {
      columns_children(cols=2, w=wheel_hub_outer_d, gap=spacing) {
        let (i = $i) {
          if ((i % 2) == 0) {
            wheel_hub_lower_printable();
          } else {
            wheel_hub_upper_printable();
          }
        }
      }
    }
  }
}

wheel_hub_assembly(lower_spacer_h=wheel_hub_wheel_spacer_h,
                   bolt_cbore_d=wheel_hub_wheel_bolt_bore_d,
                   bolt_cbore_h=wheel_hub_wheel_bolt_bore_h);
