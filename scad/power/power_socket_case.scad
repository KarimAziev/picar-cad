/**
 * Case for an XT90E-M male socket (on the front panel) and an ATM fuse holder
 * (on the side wall). It has a removable lid, onto which the battery case is
 * then mounted.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
include <../power_lid_parameters.scad>

use <../core/slot_layout.scad>
use <../core/slot_layout_components.scad>
use <../components/closable_box/sliding_box.scad>
use <../placeholders/standoff.scad>
use <../placeholders/xt90e-m.scad>
use <../lib/plist.scad>
use <../lib/shapes3d.scad>
use <../lib/shapes2d.scad>
use <../lib/transforms.scad>
use <../lib/holes.scad>
use <../lib/text.scad>
use <../lib/debug.scad>
use <../lib/slots.scad>
use <power_socket_lid.scad>
use <common.scad>

show_atm_fuse_holders      = false;
show_socket                = false;
show_bolt                  = false;
show_lid                   = false;
show_nut                   = false;
show_box                   = true;
assembly                   = true;
show_standoffs             = true;
assembly_debug             = true;
case_color                 = blue_grey_carbon;

default_bolt_visible_h     = chassis_thickness - chassis_counterbore_h;
default_rail_top_thickness = power_socket_case_rail_top_thickness;

module power_socket_side_slots(specs=power_socket_case_side_panel_slots,
                               thickness=power_socket_case_side_thickness,
                               debug,
                               align_to_axle=0,
                               align=0,
                               use_children,
                               bolt_visible_h=power_socket_case_side_thickness,
                               show_switch_button=true,
                               show_dc_regulator=true,
                               show_ato_fuse=true,
                               show_voltmeter=true,
                               show_xt90e=true,
                               show_perf_board=true,
                               show_atm_fuse_holders=true,
                               show_bolt=true,
                               show_nut=true,
                               show_standoff=true) {
  direction="btt";

  module slots_or_placeholders() {
    slot_layout_components(specs=specs,
                           thickness=thickness,
                           debug=debug,
                           align_to_axle=align_to_axle,
                           align=align,
                           bolt_visible_h=bolt_visible_h,
                           use_children=use_children,
                           direction=direction,
                           show_bolt=show_bolt,
                           show_nut=show_nut,
                           show_switch_button=show_switch_button,
                           show_dc_regulator=show_dc_regulator,
                           show_ato_fuse=show_ato_fuse,
                           show_voltmeter=show_voltmeter,
                           show_xt90e=show_xt90e,
                           show_perf_board=show_perf_board,
                           show_standoff=show_standoff,
                           show_atm_fuse_holders=show_atm_fuse_holders);
  }

  if (!use_children) {
    slots_or_placeholders();
  } else {
    translate([0, 0, thickness]) {
      slots_or_placeholders();
    }
  }
}

module power_socket_case(jack_plist=power_socket_case_jack_plist,
                         size=power_socket_case_size,
                         case_color=case_color,
                         standoff_h=power_case_standoff_h,
                         standoff_thread_h=power_case_standoff_thread_h,
                         side_thickness=power_socket_case_side_thickness,
                         bottom_thickness=power_socket_case_bottom_thickness,
                         front_thickness=power_socket_case_front_thickness,
                         slot_mode=false,
                         assembly=assembly,
                         bolt_visible_h=default_bolt_visible_h,
                         assembly_debug=assembly_debug,
                         standoff_thread_h=power_case_standoff_thread_h,
                         show_standoffs=show_standoffs,
                         show_atm_fuse_holders=show_atm_fuse_holders,
                         show_socket=show_socket,
                         show_bolt=show_bolt,
                         show_lid=show_lid,
                         show_nut=show_nut,
                         show_box=show_box,
                         fn=power_socket_case_fn,
                         corner_rad=power_socket_case_corner_rad,
                         rim_h=power_socket_case_rim_h,
                         rim_w=power_socket_case_rim_w,
                         include_rim_sizing=power_socket_case_use_rim_sizing,
                         use_inner_round=power_socket_case_use_inner_round,
                         rim_front_w=power_socket_case_rim_front_w,
                         latch_h=power_socket_case_latch_h,
                         latch_l=power_socket_case_latch_l,
                         lid_thickness=power_socket_case_lid_thickness,
                         rail_thickness=power_socket_case_rail_thickness,
                         rail_top_thickness=default_rail_top_thickness,
                         rail_tolerance=power_socket_case_rail_tolerance,
                         hook_h=power_socket_case_hook_h,
                         hook_l=power_socket_case_hook_l,
                         slot_thickness=chassis_thickness,
                         slot_bore_h=chassis_counterbore_h,
                         spacing=10) {
  mounting_panel_size = plist_get("placeholder_size",
                                  jack_plist,
                                  xt90e_mounting_panel_size);
  mounting_panel_h = mounting_panel_size[0];
  mounting_panel_thickness = mounting_panel_size[2];

  full_h = sliding_box_full_height(size=size,
                                   lid_thickness=lid_thickness,
                                   rim_h=rim_h);

  w = size[0];
  l = size[1];
  h = size[2];

  module lid_box() {
    power_socket_case_lid(size=size,
                          color=case_color,
                          side_thickness=side_thickness,
                          front_thickness=front_thickness,
                          lid_thickness=lid_thickness,
                          debug=assembly_debug,
                          rail_thickness=rail_thickness,
                          rail_tolerance=rail_tolerance,
                          rail_top_thickness=rail_top_thickness,
                          fn=fn,
                          corner_rad=corner_rad,
                          rim_h=rim_h,
                          rim_w=rim_w,
                          include_rim_sizing=include_rim_sizing,
                          use_inner_round=use_inner_round,
                          rim_front_w=rim_front_w,
                          hook_h=hook_h,
                          hook_l=hook_l);
  }

  module socket_case() {
    difference() {
      color(case_color) {
        box(size=size,
            side_thickness=side_thickness,
            bottom_thickness=bottom_thickness,
            corner_rad=corner_rad,
            use_inner_round=use_inner_round,
            rim_h=rim_h,
            fn=fn,
            include_rim_sizing=include_rim_sizing,
            front_thickness=front_thickness,
            rim_w=rim_w,
            rim_front_w=rim_front_w,
            latch_h=latch_h,
            latch_l=latch_l);
      }

      translate([0, -l / 2, h / 2]) {
        rotate([-90, 90, 0]) {
          xt_90_slot(jack_plist,
                     thickness=front_thickness + rim_front_w,
                     center=true);
        }
      }

      with_power_case_mounting_holes() {
        counterbore(d=power_case_bottom_bolt_dia,
                    h=slot_thickness,
                    sink=false,
                    reverse=false);
      }

      translate([0, l / 2 - front_thickness - rim_front_w, h / 2]) {
        rotate([-90, 90, 0]) {
          xt_90_slot(jack_plist,
                     thickness=front_thickness + rim_front_w,
                     center=true);
        }
      }

      let (slot_w = side_thickness + rim_w) {
        translate([0, 0, bottom_thickness]) {
          translate([-w / 2, 0, 0]) {
            rotate([90, 0, 90]) {
              power_socket_side_slots(use_children=false,
                                      thickness=slot_w);
            }
          }
          translate([w / 2 - slot_w, 0, 0]) {
            rotate([90, 0, 90]) {
              power_socket_side_slots(use_children=false,
                                      thickness=slot_w);
            }
          }
        }
      }

      four_corner_children(power_socket_bolt_lid_mounting_spacing,
                           center=true) {
        counterbore(d=power_case_bottom_bolt_dia,
                    h=bottom_thickness,
                    sink=false,
                    reverse=false);
      }
    }
  }

  if (slot_mode) {
    with_power_case_mounting_holes() {
      counterbore(d=power_case_bottom_bolt_dia,
                  h=slot_thickness,
                  bore_h=slot_bore_h,
                  bore_d=power_case_bottom_cbore_dia,
                  autoscale_step=0.1,
                  sink=false,
                  reverse=false);
    }
  } else {
    standoff_z = standoff_thread_h + slot_bore_h;

    standoff_full_h = standoff_thread_h + standoff_h;

    translate([0, 0, show_standoffs ? -standoff_z : 0]) {
      translate([0, 0, show_standoffs ? standoff_full_h : 0]) {
        union() {
          if (show_box) {
            socket_case();
          }

          if (show_socket) {
            translate([0,
                       -l / 2
                       - mounting_panel_thickness,
                       mounting_panel_h / 2]) {
              rotate([-90, 90, 0]) {
                xt90e_m_from_plist(jack_plist,
                                   standup=false,
                                   bolt_visible_h=5,
                                   show_bolt=show_bolt,
                                   bolt_through_h=front_thickness,
                                   show_nut=show_nut,
                                   center=true);
              }
            }
          }

          if (show_atm_fuse_holders) {
            let (slot_w = side_thickness + rim_w) {
              translate([0, 0, bottom_thickness]) {
                translate([w / 2 - slot_w, 0, 0]) {
                  rotate([90, 0, 90]) {
                    power_socket_side_slots(show_atm_fuse_holders=true,
                                            thickness=slot_w,
                                            use_children=true);
                  }
                }
              }
            }
          }

          if (assembly && show_lid) {
            let (t = $t,
                 pulse = 1 - abs(1 - 2*t),
                 ax = assembly ? (l < w ? -w : 0) : 0,
                 ay = assembly ? (l >= w ? -l : 0) : 0,
                 tx = ax * pulse,
                 ty = ay * pulse) {
              translate([$t > 0 ? tx : 0,
                         $t > 0 ? ty : 0,
                         h + lid_thickness +
                         (is_undef(rim_h) ? 0 : rim_h)]) {
                rotate([0, 180, 0]) {
                  debug_highlight(debug=assembly_debug) {
                    lid_box();
                  }
                }
              }
            }
          } else if (show_lid) {
            translate([show_box ? w + spacing : 0, 0, 0]) {
              lid_box();
            }
          }

          translate([0,
                     0,
                     (show_box && show_lid)
                     ? full_h
                     : show_box
                     ? h
                     : show_lid
                     ? lid_thickness
                     : 0]) {
            children();
          }
        }
      }
      if (show_standoffs) {
        with_power_case_mounting_holes() {
          standoff(body_h=standoff_h,
                   thread_at_top=false,
                   show_bolt=false,
                   show_nut=true,
                   bolt_visible_h=bolt_visible_h,
                   thread_h=standoff_thread_h);
        }
      }
    }
  }
}

power_socket_case() {
  //  cube([10, 20, 5]);
}
