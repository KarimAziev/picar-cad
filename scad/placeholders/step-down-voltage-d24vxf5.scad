/**
 * Module: Placeholder for Step Down Voltage Regulator (Pololu D24VXF5)
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>
include <../power_lid_parameters.scad>

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
                                                "position", [-step_down_voltage_screw_terminal_holes[0] / 2
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
                                   "wall_thickness", step_down_voltage_screw_terminal_wall_thickness];

module step_down_voltage_regulator(plist = [],
                                   bolt_visible_h=2,
                                   show_bolt=true,
                                   show_terminal_vout=true,
                                   slot_mode=false,
                                   slot_thickness=2,
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
              cuboid([length,
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
                standoffs_stack(d=bolt_dia,
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

/**
  ─────────────────────────────────────────────────────────────────────────────
  step_down_input_ports
  ─────────────────────────────────────────────────────────────────────────────
  Return the two input solder-hole centers on the PCB top.
  **Parameters:**
  - `pl`: Hardware and mounting plist accepted by step_down_mount_props.
  **Returns:** XYZ points in the mounted board frame, ordered local -Y, +Y.
 */
function step_down_input_ports(pl=[]) =
  let (pitch = plist_get("terminal_size", pl, step_down_voltage_screw_terminal_holes),
       board = plist_get("placeholder_size", pl,
                         [step_down_voltage_regulator_len,
                          step_down_voltage_regulator_w,
                          step_down_voltage_regulator_thickness]),
       mount = step_down_mount_props(pl))
  [for (side = [-1, 1])
      [-pitch[0] / 2, side * pitch[1] / 2,
       plist_get("standoff_h", mount) + board[2]]];

// Conservative XY reach of a populated terminal about the board origin.
function _step_down_terminal_reach(pl, board, input=false) =
  let (r = plist_get("rotation_z", pl, input ? 90 : -90),
       w = screw_terminal_width_from_plist(pl),
       t = plist_get("thickness", pl),
       quarter = abs(r) == 90,
       x = (input ? -1 : 1) * (board[0] / 2
                               - (quarter ? t : w) / 2 - plist_get("x_offset", pl, 0)),
       y = (quarter ? 0 : board[1] / 2 - t / 2)
       - plist_get("y_offset", pl, 0))
  [abs(x) + (abs(cos(r)) * w + abs(sin(r)) * t) / 2,
   abs(y) + (abs(sin(r)) * w + abs(cos(r)) * t) / 2];

/**
  ─────────────────────────────────────────────────────────────────────────────
  step_down_mount_props
  ─────────────────────────────────────────────────────────────────────────────
  Resolve the populated regulator envelope and standoff mounting pattern.
  **Parameters:**
  - `pl`: Regulator plist; `wire_d` adds an optional central wiring passage.
  **Returns:** Centered XY `size`, `bolt_spacing`, `bolt_d`, `bore_d`, `bore_h`,
  `sink`, `standoff_h` and `wire_d`.
  Includes terminal offsets/rotations, pin clearance and mounting screw heads.
  Mounting recesses use `step_down_voltage_regulator_cbore_d`,
  `step_down_voltage_regulator_cbore_h` and
  `step_down_voltage_regulator_use_countersunk`.
 */
function step_down_mount_props(pl=[]) =
  let (board = plist_get("placeholder_size", pl,
                         [step_down_voltage_regulator_len,
                          step_down_voltage_regulator_w,
                          step_down_voltage_regulator_thickness]),
       pitch = plist_get("bolt_spacing", pl, [35.55, 15.2]),
       d = plist_get("d", pl, step_down_voltage_bolt_hole_dia),
       h = standoff_real_h(plist_get("standoff_h", pl,
                                     step_down_voltage_regulator_standoff_h), d),
       terminals = [for (input = [true, false])
           let (t = plist_merge(default_dc_screw_terminal_props,
                                plist_get(input ? "vin" : "vout", pl, [])))
             if (plist_get(input ? "show_terminal_vin" : "show_terminal_vout",
                           t, !input))
               [t, _step_down_terminal_reach(t, board, input)]],
       wire_d = plist_get("wire_d", pl, 0),
       mount_d = max(2 * d, step_down_voltage_regulator_cbore_d),
       size = [max(concat([board[0], pitch[0] + mount_d, wire_d],
                          [for (t = terminals) 2 * t[1][0]])),
               max(concat([board[1], pitch[1] + mount_d, wire_d],
                          [for (t = terminals) 2 * t[1][1]])),
               h + board[2] + max(concat([step_down_voltage_power_inductor_size[2]],
                                         [for (c = step_down_voltage_can_capacitors)
                                             plist_get("base_h", c) + plist_get("h", c)],
                                         [for (t = terminals)
                                             plist_get("base_h", t[0]) + plist_get("top_h", t[0])]))])
  assert(board[0] >= step_down_voltage_regulator_len
         && board[1] >= step_down_voltage_regulator_w && board[2] > 0,
         "Regulator PCB must contain its fixed component layout")
  assert(min(pitch) > 0 && d > 0 && wire_d >= 0 && h > 0,
         "Invalid regulator mount dimensions")
  assert(pitch[0] + d <= board[0] && pitch[1] + d <= board[1],
         "Regulator holes must fit inside its PCB")
  assert(len([for (t = terminals)
                 if (plist_get("pin_h", t[0]) > h + board[2]) 1]) == 0,
         "Regulator terminal pins need taller standoffs")
  ["size", size,
   "bolt_spacing", pitch,
   "bolt_d", d,
   "bore_d", step_down_voltage_regulator_cbore_d,
   "bore_h", step_down_voltage_regulator_cbore_h,
   "sink", step_down_voltage_regulator_use_countersunk,
   "standoff_h", h,
   "wire_d", wire_d];

/**
  ─────────────────────────────────────────────────────────────────────────────
  step_down_mount
  ─────────────────────────────────────────────────────────────────────────────
  Render a regulator on standoffs or its parent mounting cutouts.
  **Parameters:**
  - `pl`: Hardware plist accepted by step_down_mount_props.
  - `parent_t`: Parent thickness below Z=0.
  - `anchor`: Shared envelope anchor; centered on XY by default.
  - `slot_mode`: Emit mounting holes and optional center wire passage.
  - `show_hardware`: Display regulator and standoffs in solid mode.
 */
module step_down_mount(pl=[],
                       parent_t=3,
                       anchor=[0, 0, 1],
                       slot_mode=false,
                       show_hardware=true) {
  p = step_down_mount_props(pl);
  with_anchor(anchor, plist_get("size", p), centered=true) {
    if (slot_mode) {
      pcb_mount_slots(p, parent_t);
    } else if (show_hardware) {
      step_down_voltage_regulator(pl, bolt_visible_h=parent_t, show_bolt=false);
    }
  }
}

step_down_voltage_regulator(center=true,
                            stand_up=true,
                            slot_mode=false);
