/**
 * Module: Front wheel without tires.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../colors.scad>
include <../parameters.scad>

use <../lib/shapes3d.scad>
use <../lib/transforms.scad>
use <../placeholders/ball_bearing.scad>
use <../placeholders/bearing.scad>
use <../placeholders/bolt.scad>
use <tire.scad>
use <wheel.scad>
use <wheel_hub.scad>

show_bearing         = false;
show_upper_hub       = false;
show_extra_lower_hub = false;
show_extra_bearing   = false;
show_extra_upper_hub = false;
show_wheel_hub_bolts = false;
show_wheel_hub_nuts  = false;
show_tire            = false;

// Whether to use locking nut
wheel_hub_lock_nut   = true;

module front_wheel(w=wheel_w,
                   d=wheel_dia,
                   thickness=wheel_thickness,
                   rim_h=wheel_rim_h,
                   rim_w=wheel_rim_w,
                   rim_bend=wheel_rim_bend,
                   hub_d=wheel_hub_outer_d,
                   upper_hub_d=wheel_hub_outer_d,
                   bearing_d=wheel_bearing_outer_d,
                   bearing_w=wheel_bearing_w,
                   bearing_bore_d=wheel_bearing_bore_d,
                   bearing_shoulder_d=wheel_bearing_shoulder_d,
                   bearing_outer_recess_d=wheel_bearing_outer_recess_d,
                   hub_spacer_h=wheel_hub_inner_rim_h,
                   h_tolerance=wheel_hub_h_tolerance,
                   hub_spacer_w=wheel_hub_inner_rim_w,
                   bolts_dia=wheel_hub_bolt_dia,
                   bolts_n=wheel_bolts_n,
                   lower_spacer_h=wheel_hub_wheel_spacer_h,
                   lower_extra_spacer_h=wheel_hub_inner_rim_h,
                   bolt_boss_h=wheel_bolt_boss_h,
                   bolt_boss_d=wheel_hub_bolt_boss_d,
                   bolt_offset=wheel_hub_bolt_offset,
                   bolt_cbore_d=wheel_hub_wheel_bolt_bore_d,
                   bolt_cbore_h=wheel_hub_wheel_bolt_bore_h,
                   wheel_hub_assembly_clearance=0.1,
                   bearing_n=wheel_hub_n,
                   show_tire=show_tire,
                   show_upper_hub=show_upper_hub,
                   show_extra_lower_hub=show_extra_lower_hub,
                   show_extra_upper_hub=show_extra_upper_hub,
                   show_bearing=show_bearing,
                   show_extra_bearing=show_extra_bearing,
                   show_wheel_hub_bolts=show_wheel_hub_bolts,
                   show_wheel_hub_nuts=show_wheel_hub_nuts,
                   wheel_hub_lock_nut=wheel_hub_lock_nut,
                   center_z=true,
                   wheel_color="white",
                   hub_color="white") {

  inner_d = wheel_inner_d(d, rim_h);
  hub_h = wheel_hub_full_h(bearing_w=bearing_w,
                           spacer_h=hub_spacer_h,
                           h_tolerance=h_tolerance);

  base_hub_lower_h = wheel_hub_full_h(bearing_w=bearing_w,
                                      spacer_h=lower_spacer_h,
                                      h_tolerance=h_tolerance);

  base_hub_h = base_hub_lower_h + hub_h;

  nut_height = find_nut_prop(inner_d=bolts_dia,
                             prop="height",
                             lock=wheel_hub_lock_nut);

  bolt_h = ((bearing_n - 1) * ((hub_h * 2) + wheel_hub_assembly_clearance))
    + base_hub_h
    + wheel_hub_assembly_clearance
    + with_default(nut_height, 0)
    - with_default(bolt_cbore_h, 0);

  nut_head_distance = bolt_h - with_default(bolt_cbore_h, 0)
    - (bearing_n * wheel_hub_assembly_clearance);

  z_center = w / 2 + rim_w;

  maybe_translate([0, 0, center_z ? 0 : max(wheel_tire_width / 2, z_center)]) {
    union() {
      translate([0, 0, -z_center]) {
        translate([0, 0, z_center]) {
          color(wheel_color) {
            wheel(d=d,
                  w=w,
                  thickness=thickness,
                  rim_h=rim_h,
                  rim_w=rim_w,
                  rim_bend=rim_bend);
          }
        }

        for (i = [0 : bearing_n - 1]) {
          let (is_base = i == 0,
               show_bolts = is_base && show_wheel_hub_bolts,
               show_nuts = is_base && show_wheel_hub_nuts,
               lower_d = is_base ? inner_d : hub_d,
               lower_spacer_h=is_base ? lower_spacer_h : lower_extra_spacer_h,
               show_bearing=is_base ? show_bearing : show_extra_bearing,
               show_upper_hub=is_base ? show_upper_hub : show_extra_upper_hub,
               show_lower_hub=is_base || show_extra_lower_hub,
               z_offset = is_base ? 0 : (base_hub_h + ((hub_h * (i - 1)) * 2))) {

            translate([0, 0, z_offset]) {
              wheel_hub_assembly(show_lower_hub=show_lower_hub,
                                 lower_d=lower_d,
                                 upper_d=upper_hub_d,
                                 upper_spacer_h=hub_spacer_h,
                                 spacer_w=hub_spacer_w,
                                 lower_spacer_h=lower_spacer_h,
                                 bolt_d=bolts_dia,
                                 bolts_n=bolts_n,
                                 bolt_boss_h=bolt_boss_h,
                                 bolt_boss_d=bolt_boss_d,
                                 bolt_offset=bolt_offset,
                                 show_bearing=show_bearing,
                                 show_upper_hub=show_upper_hub,
                                 upper_color=hub_color,
                                 lower_color=hub_color,
                                 bearing_w=bearing_w,
                                 bearing_d=bearing_d,
                                 bearing_bore_d=bearing_bore_d,
                                 bearing_shoulder_d=bearing_shoulder_d,
                                 bearing_outer_recess_d=bearing_outer_recess_d,
                                 h_tolerance=h_tolerance,
                                 show_bolts=show_bolts,
                                 show_nuts=show_nuts,
                                 lock_nut=wheel_hub_lock_nut,
                                 nut_head_distance=nut_head_distance,
                                 bolt_h=bolt_h,
                                 assembly_clearance=wheel_hub_assembly_clearance,
                                 bolt_cbore_h=is_base ? bolt_cbore_h : undef,
                                 bolt_cbore_d=is_base ? bolt_cbore_d : undef);
            }
          }
        }
      }

      if (show_tire) {
        color(black_1) {
          tire();
        }
      }
    }
  }
}

module front_wheel_animated(show_bearing=show_bearing,
                            show_upper_hub=show_upper_hub,
                            show_extra_lower_hub=show_extra_lower_hub,
                            show_extra_bearing=show_extra_bearing,
                            show_extra_upper_hub=show_extra_upper_hub,
                            show_wheel_hub_bolts=show_wheel_hub_bolts,
                            show_wheel_hub_nuts=show_wheel_hub_nuts,
                            show_tire=show_tire) {
  rotate([0, 0, -360 * $t]) {
    front_wheel(show_bearing=show_bearing,
                show_upper_hub=show_upper_hub,
                show_extra_lower_hub=show_extra_lower_hub,
                show_extra_bearing=show_extra_bearing,
                show_extra_upper_hub=show_extra_upper_hub,
                show_wheel_hub_bolts=show_wheel_hub_bolts,
                show_wheel_hub_nuts=show_wheel_hub_nuts,
                show_tire=show_tire);
    color(black_1) {
      tire();
    }
  }
}

union() {
  front_wheel(center_z=false);
}
