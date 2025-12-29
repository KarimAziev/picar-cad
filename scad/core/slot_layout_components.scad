include <../parameters.scad>
include <../colors.scad>

use <slot_layout.scad>

use <../placeholders/lipo_pack.scad>
use <../slider.scad>
use <../placeholders/toggle_switch.scad>
use <../placeholders/atc_ato_blade_fuse_holder.scad>;
use <../placeholders/step-down-voltage-d24vxf5.scad>
use <../placeholders/voltmeter.scad>
use <../wire.scad>
use <../lib/functions.scad>
use <../lib/shapes3d.scad>
use <../lib/holes.scad>
use <../lib/placement.scad>
use <../lib/transforms.scad>
use <../lib/shapes2d.scad>
use <../placeholders/bolt.scad>
use <../placeholders/xt90e-m.scad>
use <../lib/plist.scad>
use <../placeholders/atm_fuse_holder.scad>
use <../placeholders/perf_board.scad>
use <../placeholders/rpi_5.scad>

example_slots = [["type", "four_corner_holes",
                  "placeholder", "voltmeter",
                  "gap_before", 0,
                  "gap_after", 4,
                  "align", -1,
                  "slot_size", [0, 27.70],
                  "bore_reverse", true,
                  "rotation", -90,
                  "x_offset", 0,
                  "y_offset", 0,
                  "d", m3_hole_dia,
                  "bore_d", voltmeter_bolt_dia * 2,
                  "bore_h", power_lid_thickness / 2,
                  "sink", false,
                  "display", ["size", [voltmeter_display_w,
                                       voltmeter_display_len,
                                       voltmeter_display_h],
                              "upper_thickness", 1,
                              "upper_color", matte_black,
                              "bottom_color", "white"],
                  "hide_board", false,
                  "hide_display", false,
                  "text", "16.4",
                  "text_props", ["font", "DSEG14 Classic:style=Italic", "size", 6],
                  "pins", ["size", [voltmeter_pin_thickness,
                                    voltmeter_pin_h],
                           "count", voltmeter_pins_count,
                           "total_len", voltmeter_pins_len],
                  "wiring", ["d", voltmeter_wiring_d,
                             "distance",
                             voltmeter_wiring_distance,
                             "path", [[-5, -5, -2],
                                      [-15, -10, -1],
                                      [10, -15, -2],
                                      [20, 0, 0]]],
                  "placeholder_size", [voltmeter_board_w,
                                       voltmeter_board_len,
                                       voltmeter_board_h]],
                 ["type", "custom",
                  "placeholder", "step_down_voltage_regulator",
                  "rotation", -90,
                  "d", step_down_voltage_bolt_hole_dia,
                  "placeholder_size", [step_down_voltage_regulator_len,
                                       step_down_voltage_regulator_w,
                                       step_down_voltage_regulator_thickness],
                  "terminal_size", step_down_voltage_screw_terminal_holes,
                  "slot_size", [step_down_voltage_regulator_len,
                                step_down_voltage_regulator_w,
                                step_down_voltage_regulator_thickness],
                  "bolt_spacing", [35.55, 15.2],
                  "vin_slot_offsets", [5, 0],
                  "vout_slot_offsets", [4, 0],
                  "vin_slot", [50.4, 9.5, 2.0],
                  "vout_slot", [8.4, 8.4, 2.0],
                  "gap_before", 2,
                  "gap_after", 10,
                  "standoff_h", step_down_voltage_regulator_standoff_h,
                  "align", -1,
                  "vin", ["thickness", step_down_voltage_screw_terminal_thickness,
                          "isosceles_trapezoid", step_down_voltage_screw_terminal_isosceles_trapezoid,
                          "base_h", step_down_voltage_screw_terminal_base_h,
                          "top_l", step_down_voltage_screw_terminal_top_l,
                          "top_h", step_down_voltage_screw_terminal_top_h,
                          "contacts_n", step_down_voltage_screw_terminal_contacts_n,
                          "contact_w", step_down_voltage_screw_terminal_contact_w,
                          "contact_h", step_down_voltage_screw_terminal_contact_h,
                          "pitch", step_down_voltage_screw_terminal_pitch,
                          "bolt_spacing", [35.5, 5],
                          "colr", step_down_voltage_screw_terminal_colr,
                          "pin_thickness", step_down_voltage_screw_terminal_pin_thickness,
                          "pin_h", step_down_voltage_screw_terminal_pin_h,
                          "wall_thickness", step_down_voltage_screw_terminal_wall_thickness,],
                  "vout", ["thickness", step_down_voltage_screw_terminal_thickness,
                           "isosceles_trapezoid", step_down_voltage_screw_terminal_isosceles_trapezoid,
                           "base_h", step_down_voltage_screw_terminal_base_h,
                           "top_l", step_down_voltage_screw_terminal_top_l,
                           "top_h", step_down_voltage_screw_terminal_top_h,
                           "contacts_n", step_down_voltage_screw_terminal_contacts_n,
                           "contact_w", step_down_voltage_screw_terminal_contact_w,
                           "contact_h", step_down_voltage_screw_terminal_contact_h,
                           "pitch", step_down_voltage_screw_terminal_pitch,
                           "bolt_spacing", [35.5, 5],
                           "colr", step_down_voltage_screw_terminal_colr,
                           "pin_thickness", step_down_voltage_screw_terminal_pin_thickness,
                           "pin_h", step_down_voltage_screw_terminal_pin_h,
                           "wall_thickness", step_down_voltage_screw_terminal_wall_thickness,]],
                 ["type", "counterbore",
                  "d", 13,
                  "bore_d", 19,
                  "bore_h", 2,
                  "gap_after", 4,
                  "x_offset", 0,
                  "y_offset", 0,
                  "placeholder", "toggle_switch",
                  "placeholder_size",  toggle_switch_size,
                  "thread_h",  toggle_switch_thread_h,
                  "thread_d",  toggle_switch_thread_d,
                  "nut_d",  toggle_switch_nut_d,
                  "nut_bore_h",  toggle_switch_nut_out_h,
                  "lever_dia_1",  toggle_switch_lever_dia_1,
                  "lever_dia_2",  toggle_switch_lever_dia_2,
                  "lever_h",  toggle_switch_lever_h,
                  "terminal_size",  toggle_switch_terminal_size,
                  "thread_border_w",  toggle_switch_thread_border_w,
                  "metallic_head_h",  toggle_switch_metallic_head_h,],
                 ["placeholder", "atm_fuse_holder",
                  "recess_h", 2,
                  "recess_size", [max(atm_fuse_holder_2_body_top_l + 1,
                                      atm_fuse_holder_2_lid_bottom_l + 1),
                                  max(atm_fuse_holder_2_body_thickness + 1,
                                      atm_fuse_holder_2_lid_thickness + 1)],
                  "recess_reverse", false,
                  "recess_corner_rad", 1,
                  "type", "rect",
                  "rotation", 90,
                  "slot_size", [atm_fuse_holder_2_mounting_hole_l + 1,
                                atm_fuse_holder_2_mounting_hole_h + 2],
                  "corner_rad", atm_fuse_holder_2_mounting_hole_r,
                  "placeholder_size", [max(atm_fuse_holder_2_body_top_l,
                                           atm_fuse_holder_2_body_bottom_l)
                                       + 40,
                                       atm_fuse_holder_2_body_thickness],
                  "body", ["size", [atm_fuse_holder_2_body_bottom_l,
                                    atm_fuse_holder_2_body_thickness,
                                    atm_fuse_holder_2_body_h,
                                    atm_fuse_holder_2_body_top_l],
                           "corner_rad", 2,
                           "round_side", "bottom",
                           "rib", ["h", atm_fuse_holder_2_body_rib_h,
                                   "l", atm_fuse_holder_2_body_rib_l,
                                   "n", atm_fuse_holder_2_body_rib_n,
                                   "thickness", atm_fuse_holder_2_body_rib_thickness,
                                   "distance_from_top", 0]],
                  "wiring", ["d", atm_fuse_holder_2_body_wiring_d,
                             "socket_type", "cylinder",
                             "socket_type_len", 5,
                             "color", red_1,
                             "cutted_len", 3,
                             "left_pts", [[25, 0, 0]],
                             "right_pts", [[-25, 0, 0]]],
                  "color", matte_black_2,
                  "show_cap", false,
                  "show_body", true,
                  "cap_collar", ["size", [atm_fuse_holder_2_mounting_hole_l - 2,
                                          atm_fuse_holder_2_mounting_hole_h,
                                          atm_fuse_holder_2_mounting_hole_depth],
                                 "r", atm_fuse_holder_2_mounting_hole_r,
                                 "fuse_holes_spacing", [8, 4],
                                 "fuse_hole_size", [6.0, 1.82],
                                 "fuse_holes_pad_x", 4,
                                 "fuse_holes_pad_y", 0,
                                 "rib_thickness", 1,
                                 "rib_h", 0.8,
                                 "colr", matte_black,
                                 "rib_colr", matte_black_2,
                                 "rib_positions", [0.5]],
                  "cap", ["size", [atm_fuse_holder_2_lid_top_l,
                                   atm_fuse_holder_2_lid_thickness,
                                   atm_fuse_holder_2_lid_h,
                                   atm_fuse_holder_2_lid_bottom_l,],
                          "corner_rad", 2,
                          "round_side", "top",
                          "color", matte_black_2,
                          "rib", ["h", atm_fuse_holder_2_lid_rib_h,
                                  "l", atm_fuse_holder_2_lid_rib_l,
                                  "n", atm_fuse_holder_2_lid_rib_n,
                                  "thickness", atm_fuse_holder_2_lid_rib_thickness,
                                  "distance_from_top", atm_fuse_holder_2_lid_rib_distance]]],
                 ["type", "custom",
                  "placeholder", "xt90e_m",
                  "placeholder_size", xt90e_mounting_panel_size,
                  "slot_size", xt_90_size,
                  "shell_size", xt90e_size,
                  "mounting_panel_size", xt90e_mounting_panel_size,
                  "bolt_spacing", xt_90_bolt_spacing,
                  "align", 1,
                  "gap_before", 5,
                  "mount_spacing", xt90e_mount_spacing,
                  "mount_dia", xt90e_mount_dia,
                  "mount_bore_dia", xt90e_mount_cbore_dia,
                  "mount_bore_h", xt90e_mount_cbore_h,
                  "r_factor", 0.3,
                  "shell_r_factor", 0.5,
                  "contact_d", xt90e_contact_dia,
                  "contact_h", xt90e_contact_h,
                  "contact_wall_h", xt90e_contact_wall_h,
                  "contact_base_h", xt90e_contact_base_h,
                  "contact_thickness", xt90e_contact_thickness,
                  "pin_color", xt90e_pin_color,
                  "pin_spacing", xt90e_pin_spacing,
                  "pin_dia", xt90e_pin_dia,
                  "pin_length", xt90e_pin_length,
                  "pin_thickness", xt90e_pin_thickness,
                  "shell_color", xt90e_shell_color,
                  "bolt_head_type", "pan",
                  "round_side", "bottom",
                  "gnd_wiring_color", matte_black,
                  "gnd_wiring", [[0, 0, 40], [20, 0, 40]],
                  "vcc_wiring", [[0, 0, 40], [20, 0, 40]],
                  "vcc_wiring_color", red_1],
                 ["type", "four_corner_holes",
                  "placeholder", "perf_board",
                  "rotation", 90,
                  "gap_before", 1,
                  "gap_after", 4,
                  "align", -1,
                  "slot_size", [16.0, 76.0],
                  "size", [20, 80, 1.6],
                  "corner_r", 1,
                  "pad_dia", 1.9,
                  "perf_grid_d", 1,
                  "spacing", 0.54,
                  "d", 2.0,
                  "bolt_spacing", [16.0, 76.0],
                  "rows", 28,
                  "cols", 6,
                  "$fn", 100,
                  "bus_pad_rx", 1.9,
                  "bus_pad_ry", 1.0,
                  "bus_pad_cols", 4,
                  "bus_pad_offset",  0.8,
                  "bus_pad_spacing", 0.8,
                  "standoff_h",  2,
                  "perf_color", "green",
                  "pin_color", "silver",
                  "bus_pad_color", "silver",]];

module custom_slot_plist(plist, thickness) {
  placeholder = plist_get("placeholder", plist);

  if (placeholder == "step_down_voltage_regulator") {
    step_down_voltage_regulator(slot_mode=true,
                                plist=plist,
                                slot_thickness=thickness);
  } else if (placeholder == "xt90e_m") {
    xt_90_slot(plist, thickness=thickness);
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
                                  show_atm_fuse_holders=true) {
  bolt_visible_h = with_default(bolt_visible_h, 0);
  placeholder = plist_get("placeholder", plist);
  if (show_voltmeter && placeholder == "voltmeter") {
    voltmeter_from_plist(plist=plist, stand_up=true);
  } else if (show_dc_regulator && placeholder == "step_down_voltage_regulator") {

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
         body_h = with_default(body_size[2], atm_fuse_holder_2_body_h)) {
      translate([0, 0, -body_h - thickness]) {
        atm_fuse_holder_from_spec(plist);
      }
    }
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
              direction=direction) {

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

module example_panel(specs=example_slots,
                     thickness=4,
                     debug,
                     align_to_axle=1,
                     align=0,
                     use_children,
                     extra_padding=4,
                     direction="ttb",
                     bolt_visible_h,
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
  total_size = get_total_size(specs, direction=direction);

  module slots_or_placeholders() {
    translate([-total_size[0] / 2, total_size[1] / 2, 0]) {
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
  }

  if (!use_children) {
    difference() {
      cube_3d([total_size[0] + extra_padding, total_size[1] + extra_padding,
               thickness]);
      slots_or_placeholders();
    }
  } else {
    translate([0, 0, thickness]) {
      slots_or_placeholders();
    }
  }
}

panel_thickness = 4;
example_panel(specs=example_slots,
              thickness=panel_thickness,
              use_children=false);

example_panel(specs=example_slots,
              thickness=panel_thickness,
              bolt_visible_h=panel_thickness,
              use_children=true);