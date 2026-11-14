/**
  * Module: Hardware placeholder presets.
  *
  * Copy a complete specification or use plist_merge at the configuration site
  * to customize a named preset. Dimensions are millimeters.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../parameters.scad>


pcb_button_plist        = ["size", [4.5, 3.3, 3],
                           "button_h", 1.36,
                           "button_d", 1.8,
                           "color", matte_black,
                           "button_color", metallic_yellow_silver,
                           "orientation", "wlh",
                           "anchor", [0, 0, 1]];

pci_connector_plist     = ["size", [16, 2, 2.5],
                           "latch_pad", 3.66,
                           "latch_thickness", 0.4,
                           "color", metallic_yellow_silver_2,
                           "latch_color", jet_black,
                           "orientation", "lwh",
                           "anchor", [0, 0, 1]];

// Undef base_w derives the width from the contact count, pitch and side walls.
screw_terminal_plist    = ["base_w", undef,
                           "base_h", 6.8,
                           "thickness", 7.6,
                           "top_l", 5.5,
                           "top_h", 3.2,
                           "contacts_n", 2,
                           "contact_w", 3.5,
                           "contact_h", 4.47,
                           "pitch", 4.5,
                           "colr", medium_blue_2,
                           "pin_thickness", 0.4,
                           "pin_h", 0,
                           "wall_thickness", 0.6,
                           "isosceles_trapezoid", false];

// Undef border dimensions omit the inset border; undef marking omits text.
// Undef mark_size fits the body, and undef mark_color uses pad_color.
smd_resistor_plist      = ["placeholder_size", [3.2, 1.4, 0.4],
                           "border_color", "white",
                           "body_h", 0.1,
                           "border_w", undef,
                           "border_p", 0.2,
                           "body_color", matte_black,
                           "fillet_factor", 0.2,
                           "pad_color", "lightyellow",
                           "pad_factor_x", 0.6,
                           "pad_factor_y", 1.1,
                           "marking", undef,
                           "mark_color", undef,
                           "mark_size", undef,
                           "mark_font", "Liberation Sans:style=Bold",
                           "mark_spacing", 0.8,
                           "use_inner_round", false];

ceramic_capacitor_plist = ["placeholder_size", [3.4, 1.4, 1.2],
                           "border_color", "white",
                           "body_h", 0.01,
                           "border_w", undef,
                           "border_p", undef,
                           "body_color", metallic_gold_2,
                           "fillet_factor", 0,
                           "pad_color", "lightyellow",
                           "pad_factor_x", 0.7,
                           "pad_factor_y", 1.01,
                           "marking", undef,
                           "mark_color", undef,
                           "mark_size", undef,
                           "mark_font", "Liberation Sans:style=Bold",
                           "mark_spacing", 0.8,
                           "use_inner_round", false];

schottky_diode_plist    = ["placeholder_size", [3.4, 1.4, 0.4],
                           "border_color", "white",
                           "body_h", 0.01,
                           "border_w", undef,
                           "border_p", undef,
                           "body_color", matte_black,
                           "fillet_factor", 0.2,
                           "pad_color", "lightyellow",
                           "pad_factor_x", 0.6,
                           "pad_factor_y", 1.1,
                           "marking", undef,
                           "mark_color", undef,
                           "mark_size", undef,
                           "mark_font", "Liberation Sans:style=Bold",
                           "mark_spacing", 0.8,
                           "use_inner_round", false];

battery_holder_plist    = ["battery_len", battery_length,
                           "battery_dia", battery_dia,
                           "count", battery_holder_cell_count,
                           "terminal_type", battery_holder_terminal_type,
                           "side_wall_type", battery_holder_side_wall_type,
                           "mount_type", battery_holder_mount_type,
                           "bolt_dia", battery_holder_bolt_dia,
                           "bolt_spacing", battery_holder_bolt_spacing,
                           "inner_thickness", battery_holder_inner_thickness,
                           "bottom_thickness", battery_holder_bottom_thickness,
                           "side_thickness", battery_holder_side_thickness,
                           "front_rear_thickness", battery_holder_front_rear_thickness,
                           "inner_cutout_h", battery_holder_divider_wall_h,
                           "intercell_reces_size", battery_holder_bolt_recess_size,
                           "through_hole_distance", chassis_thickness,
                           "tab_contact_hole_d", battery_holder_tab_hole_d,
                           "contact_hole_d", battery_holder_tab_hole_d,
                           "tab_contact_slot_pad_len", battery_holder_tab_slot_extra_len,
                           "tab_contact_slot_pad_w", battery_holder_tab_slot_extra_w,
                           "reverse", false,
                           "color", matte_black,
                           "contact_color", metallic_yellow_1,
                           "bolt_head_type", "pan",
                           "bolt_visible_h", 2,
                           "show_battery", false,
                           "show_contact", true,
                           "show_bolt", undef,
                           "show_nut", undef,
                           "lock_nut", undef,
                           "bolt_color", undef,
                           "battery_color", undef];

xt90e_m_plist           = ["shell_size", xt90e_size,
                           "placeholder_size", xt90e_mounting_panel_size,
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
                           "gnd_wiring", [],
                           "vcc_wiring", [],
                           "vcc_wiring_color", red_1];
