/**
 * Module: Placeholder for XT90E-M male connector.
 *
 * The Amass XT90E-M is a 2-pin DC power connector, part of the popular XT90 series.
 *
 * The "E" in XT90E-M signifies its design for external/enlarged mounting,
 * allowing it to be securely fixed onto the housing of a device, providing a
 * stable, non-slip connection that resists accidental disconnections.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <../lib/holes.scad>
use <../lib/shapes3d.scad>
use <../lib/shapes2d.scad>
use <../lib/transforms.scad>
use <bolt.scad>
use <xt90.scad>
use <../lib/plist.scad>
use <../lib/slots.scad>

module xt90e_mounting_pattern(h,
                              spacing,
                              d,
                              bore_d,
                              bore_h,
                              reverse=true,
                              y_offset=0) {
  translate([0, y_offset, 0]) {
    four_corner_children(size=[0, spacing], center=true) {
      counterbore(h=h,
                  d=d,
                  bore_d=bore_d,
                  bore_h=bore_h,
                  reverse=reverse,
                  sink=true);
    }
  }
}

module xt90e_mounting_panel(size=xt90e_mounting_panel_size,
                            slot_size=xt_90_size,
                            r_factor=0.3,
                            slot_r_factor=0.5,
                            bolt_dia=xt90e_mount_dia,
                            bolt_bore_d=xt90e_mount_cbore_dia,
                            bolt_bore_h=xt90e_mount_cbore_h,
                            bolt_spacing=xt90e_mount_spacing,
                            center=true,
                            show_bolt=false,
                            bolt_head_type="pan",
                            round_side="top",
                            bolt_visible_h=4,
                            bolt_through_h=power_lid_thickness,
                            show_nut=true) {
  w = size[0];
  length = size[1];
  thickness = size[2];

  translate([center ? 0 : w / 2, center ? 0 : length / 2, 0]) {
    union() {
      difference() {
        linear_extrude(height=thickness,
                       center=false,
                       convexity=2) {
          difference() {

            rounded_rect([w, length],
                         center=true,
                         r_factor=r_factor);
            rounded_rect_two(slot_size,
                             side=round_side,
                             center=true,
                             r_factor=slot_r_factor);
          }
        }

        xt90e_mounting_pattern(h=thickness,
                               spacing=bolt_spacing,
                               d=bolt_dia,
                               bore_d=bolt_bore_d,
                               bore_h=bolt_bore_h);
      }
      if (show_bolt) {
        let (h = thickness + bolt_visible_h + bolt_through_h) {
          translate([0, 0, h]) {
            four_corner_children(size=[0, bolt_spacing], center=true) {
              rotate([180, 0, 0]) {
                bolt(d=bolt_dia,
                     head_type=bolt_head_type,
                     h=h,
                     nut_head_distance=thickness + bolt_through_h,
                     show_nut=show_nut);
              }
            }
          }
        }
      }
    }
  }
}

module xt90e(shell_size=xt90e_size,
             mounting_panel_size=xt90e_mounting_panel_size,
             mount_spacing=xt90e_mount_spacing,
             mount_dia=xt90e_mount_dia,
             mount_bore_dia=xt90e_mount_cbore_dia,
             mount_bore_h=xt90e_mount_cbore_h,
             r_factor=0.3,
             shell_r_factor=0.5,
             contact_d=xt90e_contact_dia,
             contact_h=xt90e_contact_h,
             contact_wall_h=xt90e_contact_wall_h,
             contact_base_h=xt90e_contact_base_h,
             contact_thickness=xt90e_contact_thickness,
             pin_color=xt90e_pin_color,
             pin_spacing=xt90e_pin_spacing,
             pin_dia=xt90e_pin_dia,
             pin_length=xt90e_pin_length,
             pin_thickness=xt90e_pin_thickness,
             shell_color=xt90e_shell_color,
             bolt_visible_h=power_lid_thickness + 4,
             bolt_head_type="pan",
             round_side="bottom",
             bolt_through_h=power_lid_thickness,
             gnd_wiring_color=matte_black,
             gnd_wiring,
             vcc_wiring,
             vcc_wiring_color=red_1,
             standup=false,
             show_bolt=true,
             show_nut=true,
             center=true) {

  max_w = max(mounting_panel_size[0], shell_size[0]);
  max_len = max(mounting_panel_size[1], shell_size[1]);
  max_h = max(mounting_panel_size[2], shell_size[2]);

  translate([center ? 0 : max_w / 2,
             center ? 0 : max_len / 2,
             standup ? mounting_panel_size[2] : 0]) {
    union() {
      color(shell_color, alpha=1) {
        xt90_shell(size=shell_size,
                   r_factor=shell_r_factor,
                   thickness=mounting_panel_size[2],
                   round_side=round_side,
                   pin_length=pin_length,
                   center=true);
        xt90e_mounting_panel(size=mounting_panel_size,
                             slot_size=shell_size,
                             r_factor=r_factor,
                             slot_r_factor=shell_r_factor,
                             bolt_dia=mount_dia,
                             round_side=round_side,
                             bolt_bore_d=mount_bore_dia,
                             bolt_bore_h=mount_bore_h,
                             bolt_spacing=mount_spacing,
                             bolt_head_type=bolt_head_type,
                             bolt_visible_h=bolt_visible_h,
                             bolt_through_h=bolt_through_h,
                             show_bolt=show_bolt,
                             show_nut=show_nut,
                             center=true);
      };

      translate([0, pin_spacing - pin_dia, 0]) {
        xt90_contact_pin(pin_d=pin_dia,
                         pin_h=pin_length,
                         pin_color=pin_color,
                         pin_thickness=pin_thickness,
                         contact_thickness=contact_thickness,
                         contact_d=contact_d,
                         contact_h=contact_h + max_h - pin_length,
                         contact_wall_h=contact_wall_h,
                         wiring_color=round_side == "bottom" ? vcc_wiring_color
                         : gnd_wiring_color,
                         wiring=round_side == "bottom" ? vcc_wiring : gnd_wiring,
                         contact_base_h=contact_base_h);
      }
      translate([0, -pin_spacing + pin_dia, 0]) {
        xt90_contact_pin(pin_d=pin_dia,
                         pin_h=pin_length,
                         pin_color=pin_color,
                         pin_thickness=pin_thickness,
                         contact_thickness=contact_thickness,
                         contact_d=contact_d,
                         contact_h=contact_h + max_h - pin_length,
                         contact_wall_h=contact_wall_h,
                         wiring_color=round_side == "bottom"
                         ? gnd_wiring_color
                         : vcc_wiring_color,
                         wiring=round_side == "bottom" ? gnd_wiring : vcc_wiring,
                         contact_base_h=contact_base_h);
      }
    }
  }
}

module xt_90_slot(spec, thickness=power_lid_thickness, center=false) {
  slot_size = plist_get("slot_size", spec, undef);
  d = plist_get("mount_dia", spec, undef);
  bolt_spacing = plist_get("bolt_spacing", spec);
  bore_d = plist_get("bore_d", spec, undef);
  bore_h = plist_get("bore_h", spec, undef);
  full_size = four_corner_counterbores_full_size(size=bolt_spacing,
                                                 d=d,
                                                 bore_d=bore_d,
                                                 bore_h=bore_h);

  full_x = max(full_size[0], slot_size[0]);
  full_y = max(full_size[1], slot_size[1]);

  translate([center ? 0 : full_x / 2, center ? 0 : full_y / 2, 0]) {
    union() {
      rect_slot(size=slot_size,
                h=thickness,
                center=true,
                side=plist_get("round_side", spec, "bottom"),
                r_factor=plist_get("r_factor", spec, 0.5));
      four_corner_counterbores(size=bolt_spacing,
                               center=true,
                               d=d,
                               h=thickness);
    }
  }
}

module xt90e_m_from_plist(plist,
                          standup=false,
                          show_bolt=true,
                          bolt_visible_h = 4,
                          bolt_through_h = power_lid_thickness,
                          show_nut=true,
                          center=true) {
  plist = with_default(plist,[]);
  shell_size = plist_get("shell_size", plist, xt90e_size);
  mounting_panel_size = plist_get("placeholder_size",
                                  plist,
                                  xt90e_mounting_panel_size);
  mount_spacing = plist_get("mount_spacing", plist, xt90e_mount_spacing);
  mount_dia = plist_get("mount_dia", plist, xt90e_mount_dia);
  mount_bore_dia = plist_get("mount_bore_dia", plist, xt90e_mount_cbore_dia);
  mount_bore_h = plist_get("mount_bore_h", plist, xt90e_mount_cbore_h);
  r_factor = plist_get("r_factor", plist, 0.3);
  shell_r_factor = plist_get("shell_r_factor", plist, 0.5);
  contact_d = plist_get("contact_d", plist, xt90e_contact_dia);
  contact_h = plist_get("contact_h", plist, xt90e_contact_h);
  contact_wall_h = plist_get("contact_wall_h", plist, xt90e_contact_wall_h);
  contact_base_h = plist_get("contact_base_h", plist, xt90e_contact_base_h);
  contact_thickness = plist_get("contact_thickness",
                                plist,
                                xt90e_contact_thickness);
  pin_color = plist_get("pin_color", plist, xt90e_pin_color);
  pin_spacing = plist_get("pin_spacing", plist, xt90e_pin_spacing);
  pin_dia = plist_get("pin_dia", plist, xt90e_pin_dia);
  pin_length = plist_get("pin_length", plist, xt90e_pin_length);
  pin_thickness = plist_get("pin_thickness", plist, xt90e_pin_thickness);
  shell_color = plist_get("shell_color", plist, xt90e_shell_color);
  bolt_head_type = plist_get("bolt_head_type", plist, "pan");
  round_side = plist_get("round_side", plist, "bottom");
  gnd_wiring_color = plist_get("gnd_wiring_color", plist, matte_black);
  gnd_wiring = plist_get("gnd_wiring", plist, []);
  vcc_wiring = plist_get("vcc_wiring", plist, []);
  vcc_wiring_color = plist_get("vcc_wiring_color", plist, red_1);

  xt90e(shell_size=shell_size,
        mounting_panel_size=mounting_panel_size,
        mount_spacing=mount_spacing,
        mount_dia=mount_dia,
        mount_bore_dia=mount_bore_dia,
        mount_bore_h=mount_bore_h,
        r_factor=r_factor,
        shell_r_factor=shell_r_factor,
        contact_d=contact_d,
        contact_h=contact_h,
        contact_wall_h=contact_wall_h,
        contact_base_h=contact_base_h,
        contact_thickness=contact_thickness,
        pin_color=pin_color,
        pin_spacing=pin_spacing,
        pin_dia=pin_dia,
        pin_length=pin_length,
        pin_thickness=pin_thickness,
        shell_color=shell_color,
        bolt_visible_h=bolt_visible_h,
        bolt_head_type=bolt_head_type,
        round_side=round_side,
        bolt_through_h=bolt_through_h,
        gnd_wiring_color=gnd_wiring_color,
        gnd_wiring=gnd_wiring,
        vcc_wiring=vcc_wiring,
        vcc_wiring_color=vcc_wiring_color,
        standup=standup,
        show_bolt=show_bolt,
        show_nut=show_nut,
        center=center);
}

module xt_90_slot_or_placeholder(spec,
                                 thickness=power_lid_thickness,
                                 center=false) {
  slot_size = plist_get("slot_size", spec, undef);
  d = plist_get("mount_dia", spec, undef);
  bolt_spacing = plist_get("bolt_spacing", spec);
  bore_d = plist_get("bore_d", spec, undef);
  bore_h = plist_get("bore_h", spec, undef);
  full_size = four_corner_counterbores_full_size(size=bolt_spacing,
                                                 d=d,
                                                 bore_d=bore_d,
                                                 bore_h=bore_h);

  full_x = max(full_size[0], slot_size[0]);
  full_y = max(full_size[1], slot_size[1]);

  translate([center ? 0 : full_x / 2, center ? 0 : full_y / 2, 0]) {
    union() {
      rect_slot(size=slot_size,
                h=thickness,
                center=true,
                side=plist_get("round_side", spec, "bottom"),
                r_factor=plist_get("r_factor", spec, 0.5));
      four_corner_counterbores(size=bolt_spacing,
                               center=true,
                               d=d,
                               h=thickness);
    }
  }
}

// xt90e_m_from_plist(plist=["type", "custom",
//                           "placeholder", "xt90e_m",
//                           "placeholder_size", xt90e_mounting_panel_size,
//                           "slot_size", xt_90_size,
//                           "shell_size", xt90e_size,
//                           "mounting_panel_size", xt90e_mounting_panel_size,
//                           "bolt_spacing", xt_90_bolt_spacing,
//                           "align", 1,
//                           "gap_before", 5,
//                           "mount_spacing", xt90e_mount_spacing,
//                           "mount_dia", xt90e_mount_dia,
//                           "mount_bore_dia", xt90e_mount_cbore_dia,
//                           "mount_bore_h", xt90e_mount_cbore_h,
//                           "r_factor", 0.3,
//                           "shell_r_factor", 0.5,
//                           "contact_d", xt90e_contact_dia,
//                           "contact_h", xt90e_contact_h,
//                           "contact_wall_h", xt90e_contact_wall_h,
//                           "contact_base_h", xt90e_contact_base_h,
//                           "contact_thickness", xt90e_contact_thickness,
//                           "pin_color", xt90e_pin_color,
//                           "pin_spacing", xt90e_pin_spacing,
//                           "pin_dia", xt90e_pin_dia,
//                           "pin_length", xt90e_pin_length,
//                           "pin_thickness", xt90e_pin_thickness,
//                           "shell_color", xt90e_shell_color,
//                           "bolt_head_type", "pan",
//                           "round_side", "bottom",
//                           "gnd_wiring_color", matte_black,
//                           "gnd_wiring", [[0, 0, 40]],
//                           "vcc_wiring", [[0, 0, 40]],
//                           "vcc_wiring_color", red_1],
//                    standup=false,
//                    bolt_visible_h=10,
//                    center=false,
//                    bolt_through_h=5);

xt_90_slot(["type", "custom",
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
            "gnd_wiring", [[0, 0, 40]],
            "vcc_wiring", [[0, 0, 40]],
            "vcc_wiring_color", red_1]);
