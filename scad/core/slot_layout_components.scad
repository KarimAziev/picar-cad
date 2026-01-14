include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/holes.scad>
use <../lib/placement.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slider.scad>
use <../lib/transforms.scad>
use <../lib/wire.scad>
use <../placeholders/atc_ato_blade_fuse_holder.scad>;
use <../placeholders/atm_fuse_holder/atm_fuse_holder.scad>
use <../placeholders/bolt.scad>
use <../placeholders/lipo_pack.scad>
use <../placeholders/perf_board.scad>
use <../placeholders/rpi_5.scad>
use <../placeholders/step-down-voltage-d24vxf5.scad>
use <../placeholders/toggle_switch.scad>
use <../placeholders/voltmeter.scad>
use <../placeholders/xt90e-m.scad>
use <slot_layout.scad>

module custom_slot_plist(plist, thickness) {
  placeholder = plist_get("placeholder", plist);

  if (placeholder == "step_down_voltage_regulator") {
    step_down_voltage_regulator(slot_mode=true,
                                plist=plist,
                                center=true,
                                slot_thickness=thickness);
  } else if (placeholder == "xt90e_m") {
    xt_90_slot(plist,
               thickness=thickness,
               center=true);
  }
}

module slot_placeholders_assembly(plist,
                                  thickness,
                                  bolt_visible_h,
                                  show_bolt=true,
                                  show_nut=true,
                                  show_switch_button=true,
                                  show_dc_regulator=true,
                                  show_ato_fuse=true,
                                  show_voltmeter=true,
                                  show_xt90e=true,
                                  show_standoff=true,
                                  show_perf_board=true,
                                  show_atm_fuse_holders=true,
                                  show_smd_battery_holder=true) {
  bolt_visible_h = with_default(bolt_visible_h, 0);
  placeholder = plist_get("placeholder", plist);
  if (show_voltmeter && placeholder == "voltmeter") {
    voltmeter_from_plist(plist=plist,
                         stand_up=true);
  } else if (show_dc_regulator
             && placeholder == "step_down_voltage_regulator") {

    step_down_voltage_regulator(slot_mode=false,
                                bolt_visible_h=bolt_visible_h,
                                show_bolt=show_bolt,
                                plist=plist,
                                stand_up=true);
  } else if (show_xt90e && placeholder == "xt90e_m") {
    let (mounting_panel_size = plist_get("placeholder_size",
                                         plist,
                                         xt90e_mounting_panel_size),
         h = mounting_panel_size[2]) {
      translate([0, 0, h]) {
        rotate([180, 0, 0]) {
          xt90e_m_from_plist(plist,
                             standup=false,
                             bolt_visible_h=bolt_visible_h,
                             show_bolt=show_bolt,
                             bolt_through_h=thickness,
                             show_nut=show_nut);
        }
      }
    }
  } else if (show_atm_fuse_holders && placeholder == "atm_fuse_holder") {
    let (body_size = plist_get("size", plist_get("body", plist, [])),
         body_h = with_default(body_size[2], atm_fuse_holder_body_h)) {
      translate([0, 0, -body_h - thickness]) {
        atm_fuse_holder_from_spec(plist);
      }
    }
  } else if (show_smd_battery_holder && placeholder == "smd_battery_holder") {
    smd_battery_holder_from_plist(plist);
  } else if (show_ato_fuse && placeholder == "ato_fuse_holder") {
  } else if (show_switch_button && placeholder == "toggle_switch") {

    let (size = plist_get("placeholder_size", plist, toggle_switch_size),
         terminal_size = plist_get("terminal_size",
                                   plist,
                                   toggle_switch_terminal_size),
         nut_bore_h = plist_get("nut_bore_h", plist,
                                toggle_switch_nut_out_h)) {
      translate([0,
                 0,
                 -size[2] - terminal_size[2] - thickness
                 + nut_bore_h - 0.1]) {

        toggle_switch_from_plist(plist, center_x=true, center_y=true);
      }
    }
  } else if (show_perf_board && placeholder == "perf_board") {
    perf_bord_from_plist(plist,
                         bolt_visible_h=bolt_visible_h,
                         stand_up=true,
                         show_bolt=show_bolt,
                         show_standoff=show_standoff,
                         show_nut=show_nut);
  }
}

module slot_layout_components(specs,
                              thickness,
                              center,
                              debug,
                              align_to_axle=1,
                              align=0,
                              use_children,
                              direction="ttb",
                              bolt_visible_h,
                              show_bolt=true,
                              show_nut=true,
                              show_switch_button=true,
                              show_dc_regulator=true,
                              show_ato_fuse=true,
                              show_voltmeter=true,
                              show_xt90e=true,
                              show_perf_board=true,
                              show_standoff=true,
                              show_atm_fuse_holders=true) {
  slot_layout(specs=specs,
              thickness=thickness,
              debug=debug,
              align=align,
              align_to_axle=align_to_axle,
              use_children=use_children,
              direction=direction,
              center=center) {

    plist = $spec;
    custom_slot_mode = $custom;

    if (custom_slot_mode) {
      custom_slot_plist(plist, thickness=thickness);
    } else {
      slot_placeholders_assembly(plist=plist,
                                 thickness=thickness,
                                 bolt_visible_h=bolt_visible_h,
                                 show_bolt=show_bolt,
                                 show_nut=show_nut,
                                 show_switch_button=show_switch_button,
                                 show_dc_regulator=show_dc_regulator,
                                 show_ato_fuse=show_ato_fuse,
                                 show_voltmeter=show_voltmeter,
                                 show_xt90e=show_xt90e,
                                 show_standoff=show_standoff,
                                 show_perf_board=show_perf_board,
                                 show_atm_fuse_holders=show_atm_fuse_holders);
    }
  }
}
