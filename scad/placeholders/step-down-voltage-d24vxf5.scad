/**
 * Module: Placeholder for Step Down Voltage Regulator (Pololu D24V90F5)
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>
include <../power_lid_parameters.scad>

use <../lib/functions.scad>
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

module step_down_voltage_regulator(plist=step_down_voltage_plist,
                                   size_key="placeholder_size",
                                   bolt_visible_h=2,
                                   show_bolt=true,
                                   show_terminal_vout=true,
                                   show_terminal_vin=true,
                                   slot_mode=false,
                                   slot_thickness=2,
                                   center=true,
                                   show_standoff=true,
                                   stand_up=true) {
  assert(plist_is(plist) && len(plist) > 0, "Supply a hardware specification");

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

  placeholder_size = plist_get(size_key,
                               plist,
                               [step_down_voltage_regulator_len,
                                step_down_voltage_regulator_w,
                                step_down_voltage_regulator_thickness]);

  standoff_h = plist_get("standoff_h",
                         plist,
                         step_down_voltage_regulator_standoff_h);

  inductor = plist_get("inductor", plist);

  length = placeholder_size[0];
  w = placeholder_size[1];
  thickness = placeholder_size[2];
  bolt_dia = plist_get("d", plist, step_down_voltage_bolt_hole_dia);
  terminal_hole_dia = plist_get("terminal_hole_d",
                                plist,
                                step_down_voltage_bolt_hole_dia + 0.4);

  vin = step_down_terminal_props(plist_get("vin", plist),
                                 placeholder_size,
                                 input=true);
  vout = step_down_terminal_props(plist_get("vout", plist),
                                  placeholder_size);
  screw_terminal_vin_pl = plist_get("plist", vin);
  screw_terminal_vout_pl = plist_get("plist", vout);
  show_terminal_vin = plist_get("show_terminal_vin",
                                screw_terminal_vin_pl,
                                true);
  show_terminal_vout = plist_get("show_terminal_vout",
                                 screw_terminal_vout_pl,
                                 true);
  surface_mount_chips = plist_get("surface_mount_chips", plist, []);;
  can_capacitors = plist_get("can_capacitors", plist, []);;

  smd_chip_specs = plist_get("smd_chip_specs", plist, []);

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
            translate(plist_get("pos", vout)) {
              rotate([0, 0, plist_get("rotation", vout)]) {
                screw_terminal_from_plist(screw_terminal_vout_pl,
                                          center=true);
              }
            }
          }
          if (show_terminal_vin) {
            translate(plist_get("pos", vin)) {
              rotate([0, 0, plist_get("rotation", vin)]) {
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
            if (inductor) {
              let (inductor_size = plist_get("size", inductor),
                   inductor_offsets = plist_get("offsets", inductor, [0, 0])) {
                translate([with_default(inductor_offsets[0], 0),
                           -w / 2 +
                           with_default(inductor_offsets[1], 0),
                           0]) {
                  shielded_power_inductor(size=inductor_size,
                                          r=step_down_voltage_power_inductor_size[3]);
                }
              }
            }

            for (item = surface_mount_chips) {
              step_down_voltage_surface_mount_chip(spec=item);
            }

            for (spec=smd_chip_specs) {
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

            for (pl = can_capacitors) {
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
function step_down_input_ports(pl=step_down_voltage_plist) =
  assert(plist_is(pl) && len(pl) > 0, "Supply a hardware specification")
  let (pitch = plist_get("terminal_size", pl, step_down_voltage_screw_terminal_holes),
       board = plist_get("placeholder_size", pl,
                         [step_down_voltage_regulator_len,
                          step_down_voltage_regulator_w,
                          step_down_voltage_regulator_thickness]),
       mount = step_down_mount_props(pl))
  [for (side = [-1, 1])
    [-pitch[0] / 2, side * pitch[1] / 2,
     plist_get("standoff_h", mount) + board[2]]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  step_down_component_footprints
  ─────────────────────────────────────────────────────────────────────────────

  Return lid-access footprints for the regulator's populated power components.

  **Parameters:**
  - `pl`: Regulator specification accepted by `step_down_voltage_regulator`.

  **Returns:**
  [center_xy, size_xy] pairs in the centered board frame, ordered inductor,
  capacitor cans, then `smd_chip_specs` packages including their lead span.
  Omitted components contribute no footprint. Chip rotations follow the
  placeholder's XYZ Euler convention; footprints are axis-aligned projections.
 */
function step_down_component_footprints(pl=step_down_voltage_plist) =
  assert(plist_is(pl) && len(pl) > 0, "Supply a hardware specification")
  let (board = plist_get("placeholder_size", pl,
                         [step_down_voltage_regulator_len,
                          step_down_voltage_regulator_w,
                          step_down_voltage_regulator_thickness]),
       inductor = plist_get("inductor", pl, []))
  concat(len(inductor) > 0
         ? [let (size = plist_get("size", inductor),
                 offsets = plist_get("offsets", inductor, [0, 0]))
           [[with_default(offsets[0], 0) + size[0] / 2,
             -board[1] / 2 + with_default(offsets[1], 0) + size[1] / 2],
            [size[0], size[1]]]]
         : [],
         [for (cap = plist_get("can_capacitors", pl, []))
           let (pos = plist_get("position", cap), d = plist_get("d", cap))
           [[pos[0], pos[1]], [d, d]]],
         [for (chip = plist_get("smd_chip_specs", pl, []))
           let (pos = with_default(chip[4], [0, 0, 0]),
                rotation = with_default(chip[5], [0, 0, 0]),
                corners = [for (x = [0, chip[1]], y = [0, chip[0]],
                                z = [0, chip[2]])
                  rotate_euler_xyz([x, y, z], rotation) + pos],
                lo = [for (i = [0, 1]) min([for (c = corners) c[i]])],
                hi = [for (i = [0, 1]) max([for (c = corners) c[i]])])
           [(lo + hi) / 2, hi - lo]]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  step_down_terminal_props
  ─────────────────────────────────────────────────────────────────────────────

  Resolve a regulator terminal's placement and footprint.

  **Parameters:**
  - `pl`: Terminal specification from the regulator's `vin` or `vout` group.
  - `board`: PCB [X length, Y width, thickness].
  - `input`: Select the input end (-X); false selects the output end (+X).

  **Returns:**
  `plist` contains the resolved terminal specification. `pos` is its base center
  in the centered XY board frame, with Z measured from the PCB underside.
  `rotation` is its Z angle; `size` is its rotated, axis-aligned XY footprint.
 */
function step_down_terminal_props(pl, board, input=false) =
  assert(plist_is(pl) && len(pl) > 0, "Supply a hardware specification")
  let (terminal = pl,
       r = plist_get("rotation_z", terminal, input ? 90 : -90),
       w = screw_terminal_width_from_plist(terminal),
       t = plist_get("thickness", terminal),
       quarter = abs(r) == 90,
       x = (input ? -1 : 1) * (board[0] / 2
                               - (quarter ? t : w) / 2
                               - plist_get("x_offset", terminal, 0)),
       y = (quarter ? 0 : board[1] / 2 - t / 2)
           - plist_get("y_offset", terminal, 0))
  ["plist", terminal,
   "pos", [x, y, board[2]],
   "rotation", r,
   "size", [abs(cos(r)) * w + abs(sin(r)) * t,
            abs(sin(r)) * w + abs(cos(r)) * t]];

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
function step_down_mount_props(pl=step_down_voltage_plist) =
  assert(plist_is(pl) && len(pl) > 0, "Supply a hardware specification")
  let (board = plist_get("placeholder_size", pl,
                         [step_down_voltage_regulator_len,
                          step_down_voltage_regulator_w,
                          step_down_voltage_regulator_thickness]),
       pitch = plist_get("bolt_spacing", pl, [35.55, 15.2]),
       d = plist_get("d", pl, step_down_voltage_bolt_hole_dia),
       h = standoff_real_h(plist_get("standoff_h", pl,
                                     step_down_voltage_regulator_standoff_h), d),
       terminals = [for (input = [true, false])
         let (t = plist_get(input ? "vin" : "vout", pl))
             if (plist_get(input ? "show_terminal_vin" : "show_terminal_vout",
                           t, !input))
               let (props = step_down_terminal_props(t, board, input),
                    pos = plist_get("pos", props),
                    size = plist_get("size", props))
           [t, [abs(pos[0]), abs(pos[1])] + size / 2]],
       wire_d = plist_get("wire_d", pl, 0),
       mount_d = max(2 * d, step_down_voltage_regulator_cbore_d),
       size = [max(concat([board[0], pitch[0] + mount_d, wire_d],
                          [for (t = terminals) 2 * t[1][0]])),
               max(concat([board[1], pitch[1] + mount_d, wire_d],
                          [for (t = terminals) 2 * t[1][1]])),
               h + board[2] + max(concat([step_down_voltage_power_inductor_size[2]],
                                         [for (c = plist_get("can_capacitors", pl))
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

  ```scad
  step_down_voltage_regulator(center=true, stand_up=true, slot_mode=false);
  ```
 */

module step_down_mount(pl=step_down_voltage_plist,
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

step_down_voltage_regulator(step_down_voltage_plist);