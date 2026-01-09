/**
 * Module: Placeholder for Step Down Voltage Regulator (Polulu D24VXF5)
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../colors.scad>
include <../parameters.scad>
include <../power_lid_parameters.scad>

use <../lib/holes.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <screw_terminal.scad>
use <smd/can_capacitor.scad>
use <smd/power_inductor.scad>
use <smd/smd_chip.scad>
use <standoff.scad>

// [x, y, z, round_radius]

step_down_voltage_can_capacitors            = [["d", 7,
                                                "base_h", 2.58,
                                                "h", 6.85,
                                                "marking_color", matte_black,
                                                "can_color", metallic_silver_1,
                                                "text_rows", ["47", "HFT", "S92"],
                                                "position",
                                                [-step_down_voltage_screw_terminal_holes[0] / 2
                                                 - step_down_voltage_bolt_hole_dia / 2
                                                 + 8.3,
                                                 4.4,
                                                 0],
                                                "x_offset", 2.6,
                                                "y_offset", 2.6,
                                                "rotation", 0],
                                               ["d", 7,
                                                "base_h", 2.58,
                                                "h", 6.85,
                                                "marking_color", cobalt_blue_metallic,
                                                "position", [step_down_voltage_screw_terminal_holes[0] / 2
                                                             + step_down_voltage_bolt_hole_dia / 2
                                                             - 8.3,
                                                             4.4, 0],
                                                "can_color", metallic_silver_1,
                                                "text_rows", ["F28F", "330", "6.3V"],
                                                "x_offset", 2.6,
                                                "y_offset", 2.6,
                                                "rotation", 0]];

// [[wight, len, height, j-lead-len, [translate_x, translate_y, translate_z], [rotation_x, rotation_y, rotation_z]]..]
step_down_voltage_smd_chips_specs           = [[4.6, 3.3, 1.58, 1, [-0.15, -9.0, 0], [0, 0, 0]],
                                               [4.6, 3.2, 1.58, 1, [-0.9, -8.7, 0], [0, 0, 90]],
                                               [4.6, 3.3, 1.58, 1, [-13.7, -8.7, 0], [0, 0, 0]],
                                               [4.6, 3.3, 1.58, 1, [-3.50, -4.0, 0], [0, 0, 0]],];

// [[wight, len, height, j-lead-len, [translate_x, translate_y, translate_z], center_color]..]
step_down_voltage_surface_mount_chips_specs = [[2.0, 3.3, 2.5, 0.9,
                                                [-5.75, 3.2, 0], brown_2],
                                               [1.95, 3.3, 2.5, 0.8,
                                                [-3.6, 3.2, 0], brown_2],
                                               [1.05, 1.75, 1.6, 0.2,
                                                [-5.2, -3.8, 0], brown_2],
                                               [1.05, 1.8, 1.6, 0.2,
                                                [-6.7, -3.8, 0], matte_black],
                                               [1.05, 1.8, 1.6, 0.2,
                                                [-8.0, -4.3, 0], matte_black],
                                               [1.05, 1.75, 1.6, 0.2,
                                                [-7.0, -8.3, 0], brown_2],
                                               [1.05, 1.75, 1.6, 0.2,
                                                [14.54, -7.0, 0], brown_2],
                                               [1.05, 1.75, 1.6, 0.2,
                                                [14.72, 6.9, 0], brown_2],
                                               [1.05, 1.75, 1.6, 0.2,
                                                [-13.05, -1.2, 0], matte_black],
                                               [1.05, 1.75, 1.6, 0.2,
                                                [2.66, -1.2, 0], matte_black],
                                               [1.35, 2.07, 2.1, 0.3,
                                                [2.36, 6.0, 0], brown_2],
                                               [1.35, 1.95, 2.1, 0.3,
                                                [2.36, 2.9, 0], brown_2],
                                               [1.45, 1.75, 1.8, 0.3,
                                                [1.19, -1.1, 0], matte_black],
                                               [1.85, 3.3, 2.6, 0.5,
                                                [12.66, -1.78, 0], brown_2],
                                               [1.85, 3.3, 2.5, 0.5,
                                                [12.66, -6.45, 0], brown_2],
                                               [3.3, 1.85, 2.5, 0.5,
                                                [-9.96, -1.7, 0], brown_2],
                                               [2.0, 1.45, 1.8, 0.5,
                                                [-12.26, -3.7, 0], matte_black],
                                               [1.8, 1.15, 1.6, 0.5,
                                                [1.86, -3.4, 0], brown_2],
                                               [1.8, 1.15, 1.6, 0.5,
                                                [-2.86, -4.4, 0], matte_black],
                                               [1.8, 1.10, 1.6, 0.5,
                                                [2.8, 8.9, 0], brown_2],
                                               [1.8, 1.10, 1.6, 0.5,
                                                [-0.6, 6.7, 0], matte_black],
                                               [1.60, 1.10, 1.6, 0.5,
                                                [0.0, 2.1, 0], brown_2],
                                               [1.60, 1.10, 1.6, 0.5,
                                                [0.0, 5.1, 0], brown_2],
                                               [1.70, 1.10, 1.6, 0.5,
                                                [-5.3, 6.3, 0], matte_black],
                                               [1.70, 1.10, 1.6, 0.5,
                                                [-0.0, 3.5, 0], matte_black],
                                               [1.70, 1.10, 1.6, 0.5,
                                                [-6.0, -1.5, 0], brown_2],
                                               [1.70, 1.10, 1.6, 0.5,
                                                [-5.55, -0.2, 0], brown_2]];

module step_down_voltage_surface_mount_chip(spec) {
  let (w = spec[0],
       l=spec[1],
       h=spec[2],
       j_led_l=spec[3],
       translate_spec=is_undef(spec[4]) ? [0, 0, 0] : spec[4],
       r=0.1,
       color_spec=is_undef(spec[5]) ? brown_2 : spec[5]) {

    translate(translate_spec) {
      if (l > w) {
        let (inner_l = l - j_led_l * 2) {

          color(color_spec, alpha=1) {
            linear_extrude(height=h, center=false) {
              square(size=[w, inner_l], center=true);
            }
          }

          color(metallic_silver_1, alpha=1) {
            mirror_copy([0, 1, 0]) {
              translate([0, inner_l / 2 + j_led_l / 2, 0]) {
                linear_extrude(height=h, center=false) {
                  rounded_rect([w, j_led_l + r], center=true, r=r);
                }
              }
            }
          }
        }
      }  else {
        let (inner_w = w - (j_led_l * 2)) {
          color(color_spec, alpha=1) {
            linear_extrude(height=h, center=false) {
              square(size=[inner_w, l], center=true);
            }
          }

          color(metallic_silver_1, alpha=1) {
            mirror_copy([1, 0, 0]) {
              translate([inner_w / 2 + j_led_l / 2, 0, 0]) {
                linear_extrude(height=h, center=false) {
                  rounded_rect([j_led_l + r, l], center=true, r=r);
                }
              }
            }
          }
        }
      }
    }
  }
}

module step_down_voltage_smd_chip(w=step_down_voltage_smd_chip_w,
                                  l=step_down_voltage_smd_chip_l,
                                  j_led_len=step_down_voltage_smd_chip_j_lead_l,
                                  h=step_down_voltage_smd_chip_h,
                                  j_lead_n=4,
                                  j_lead_thickness=0.4) {
  smd_chip(length=l,
           w=w - j_led_len * 2,
           j_lead_n=j_lead_n,
           j_lead_thickness=j_lead_thickness,
           total_w=w,
           h=h,
           center=false);
}

default_dc_screw_terminal_props = ["thickness", step_down_voltage_screw_terminal_thickness,
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
                                   "wall_thickness", step_down_voltage_screw_terminal_wall_thickness,];
module step_down_voltage_regulator(plist = [],
                                   bolt_visible_h=power_lid_thickness,
                                   show_bolt=true,
                                   show_terminal_vout=true,
                                   slot_mode=false,
                                   slot_thickness=power_lid_thickness,
                                   center=true,
                                   show_standoff=true,
                                   stand_up=true) {

  terminal_size = plist_get("terminal_size",
                            plist,
                            step_down_voltage_screw_terminal_holes);

  bolt_spacing = plist_get("bolt_spacing",
                           plist,
                           [35.55, 15.2]);

  vin_slot_offsets = plist_get("vin_slot_offsets",
                               plist,
                               [5, 0]);

  vin_slot_round_side = plist_get("vin_slot_round_side",
                                  plist,
                                  "right");

  vout_slot_round_side = plist_get("vout_slot_round_side",
                                   plist,
                                   "all");

  vout_slot_offsets = plist_get("vout_slot_offsets",
                                plist,
                                [4, 0]);

  vin_slot_size = plist_get("vin_slot",
                            plist,
                            [30.4, 9.5, 2.0]);

  vout_slot_size = plist_get("vout_slot",
                             plist,
                             [8.4, 8.4, 2.0]);

  placeholder_size = plist_get("placeholder_size",
                               plist,
                               [step_down_voltage_regulator_len,
                                step_down_voltage_regulator_w,
                                step_down_voltage_regulator_thickness]);

  standoff_h = plist_get("standoff_h",
                         plist,
                         step_down_voltage_regulator_standoff_h);

  length = placeholder_size[0];
  w = placeholder_size[1];
  thickness = placeholder_size[2];
  bolt_dia = plist_get("d", plist, step_down_voltage_bolt_hole_dia);
  terminal_hole_dia = plist_get("terminal_hole_d",
                                plist,
                                step_down_voltage_bolt_hole_dia + 0.4);

  screw_terminal_vin_pl = plist_merge(default_dc_screw_terminal_props,
                                      plist_get("vin", plist, []));
  show_terminal_vin = plist_get("show_terminal_vin",
                                screw_terminal_vin_pl,
                                false);
  vin_x_offset = plist_get("x_offset", screw_terminal_vin_pl, 0);

  vin_y_offset = plist_get("y_offset", screw_terminal_vin_pl, 0);
  vin_thickness = plist_get("thickness", screw_terminal_vin_pl, 0);
  vin_rotation_z = plist_get("rotation_z", screw_terminal_vin_pl, 90);
  vin_width = screw_terminal_width_from_plist(screw_terminal_vin_pl);

  screw_terminal_vout_pl = plist_merge(default_dc_screw_terminal_props,
                                       plist_get("vout", plist, []));

  vout_x_offset = plist_get("x_offset", screw_terminal_vout_pl, 0);
  vout_y_offset = plist_get("y_offset", screw_terminal_vout_pl, 0);
  vout_thickness = plist_get("thickness", screw_terminal_vout_pl, 0);
  vout_rotation_z = plist_get("rotation_z", screw_terminal_vout_pl, -90);
  vout_width = screw_terminal_width_from_plist(screw_terminal_vout_pl);
  vout_rotated = (abs(vout_rotation_z) == 90);
  vin_rotated = (abs(vin_rotation_z) == 90);
  show_terminal_vout= plist_get("show_terminal_vout",
                                screw_terminal_vout_pl,
                                true);

  z_offst = thickness / 2;

  standoffs = calc_standoff_params(min_h=standoff_h, d=bolt_dia);

  h = len(standoffs[1]) > 0 ? sum(standoffs[1]) : 0;

  standoff_real_h = len(standoffs[1]) > 0 ? sum(standoffs[1]) : 0;

  translate([center ? 0 : length / 2,
             center ? 0 : w / 2,
             0]) {
    if (slot_mode) {
      union() {
        four_corner_children(size=bolt_spacing, center=true) {
          counterbore(d=bolt_dia, h=slot_thickness);
          if ($x_i == 0 && $y_i == 0) {
            translate([-vin_slot_size[0] + vin_slot_offsets[0],
                       bolt_spacing[1] / 2 - vin_slot_size[1] / 2 +
                       vin_slot_offsets[1],
                       0]) {
              rect_slot(size=vin_slot_size,
                        h=slot_thickness,
                        side=vin_slot_round_side,
                        center=false,
                        r=vin_slot_size[2]);
            }
          } else if ($x_i == 1 && $y_i == 0) {
            translate([-vout_slot_size[0] / 2 + vout_slot_offsets[0],
                       bolt_spacing[1] / 2 - vout_slot_size[1] / 2 -
                       vout_slot_offsets[1],
                       0]) {
              rect_slot(size=vout_slot_size,
                        h=slot_thickness,
                        center=false,
                        side=vout_slot_round_side,
                        r=vout_slot_size[2]);
            }
          }
        }
      }
    } else {
      translate([0, 0, stand_up ? with_default(standoff_real_h, 0) : 0]) {
        union() {
          difference() {
            color("green", alpha=1) {
              cube_3d([length,
                       w,
                       thickness],
                      center=true);
            }
            four_corner_children(size=bolt_spacing, center=true) {
              counterbore(d=bolt_dia + 0.3, h=thickness);
            }
            four_corner_children(size=terminal_size, center=true) {
              counterbore(d=terminal_hole_dia, h=thickness);
            }
          }

          if (show_terminal_vout) {
            translate([(length / 2 - ((abs(vout_rotation_z) == 90)
                                      ? vout_thickness / 2
                                      : vout_width / 2)) - vout_x_offset,
                       (!vout_rotated ? (w / 2 - vout_thickness / 2) : 0)
                       - vout_y_offset,
                       thickness]) {
              rotate([0, 0, vout_rotation_z]) {
                screw_terminal_from_plist(screw_terminal_vout_pl,
                                          center=true);
              }
            }
          }
          if (show_terminal_vin) {
            translate([-(length / 2 - ((abs(vin_rotation_z) == 90)
                                       ? vin_thickness / 2
                                       : vin_width / 2)) + vin_x_offset,
                       (!vin_rotated ? (w / 2 - vin_thickness / 2) : 0)
                       - vin_y_offset,
                       thickness]) {
              rotate([0, 0, vin_rotation_z]) {
                screw_terminal_from_plist(screw_terminal_vin_pl,
                                          center=true);
              }
            }
          }

          if (show_standoff && !is_undef(standoff_h) && standoff_h > 0) {
            translate([0, 0, -standoff_real_h]) {
              four_corner_children(size=bolt_spacing, center=true) {
                standoffs_stack(d=bolt_dia + 0.3,
                                show_bolt=show_bolt,
                                nut_pos=standoff_h,
                                bolt_visible_h=bolt_visible_h,
                                min_h=standoff_h);
              }
            }
          }

          translate([0, 0, z_offst]) {
            translate([3.3,
                       -w / 2 +
                       step_down_voltage_power_regulator_y_distance,
                       0]) {
              shielded_power_inductor(size=[step_down_voltage_power_inductor_size[0],
                                            step_down_voltage_power_inductor_size[1],
                                            step_down_voltage_power_inductor_size[2]],
                                      r=step_down_voltage_power_inductor_size[3]);
            }

            for (item = step_down_voltage_surface_mount_chips_specs) {
              step_down_voltage_surface_mount_chip(spec=item);
            }

            for (spec = step_down_voltage_smd_chips_specs) {
              let (w = spec[0],
                   l=spec[1],
                   h=spec[2],
                   j_led_l=spec[3],
                   translate_spec=is_undef(spec[4]) ? [0, 0, 0] : spec[4],
                   rotation_spec=spec[5]) {
                translate(translate_spec) {
                  if (rotation_spec) {
                    rotate(rotation_spec) {
                      step_down_voltage_smd_chip(w=w,
                                                 l=l,
                                                 h=h,
                                                 j_led_len=j_led_l);
                    }
                  } else {
                    step_down_voltage_smd_chip(w=w,
                                               l=l,
                                               h=h,
                                               j_led_len=j_led_l);
                  }
                }
              }
            }

            for (pl = step_down_voltage_can_capacitors) {
              let (pos = plist_get("position", pl, [])) {
                translate(pos) {
                  can_capacitor_from_plist(pl);
                }
              }
            }
          }
        }
      }
    }
  }
}

step_down_voltage_regulator(center=true,
                            stand_up=true,
                            slot_mode=false);
