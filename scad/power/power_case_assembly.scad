/**
 * Module: Power Case assembly guide.
 * To see the assembly steps, toggle each variable one by one.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>
include <../power_lid_parameters.scad>

use <../components/closable_box/sliding_box.scad>
use <../lib/placement.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/text.scad>
use <../lib/transforms.scad>
use <../placeholders/bolt.scad>
use <../placeholders/lipo_pack.scad>
use <../placeholders/standoff.scad>
use <common.scad>
use <power_case.scad>
use <power_case_rail.scad>
use <power_lid.scad>
use <power_socket_case.scad>

show_socket_case                  = true;

// Insert the socket jack for the XT90E-M male connector and fasten it with bolts.
show_socket                       = false;
// Connect the XT90E-M male connector to the fuse holders.
show_socket_case_atm_fuse_holders = false;

// Slide the socket case lid into place.
show_socket_case_lid              = false;

// Now mount the power case onto the socket-case lid.
show_power_case                   = false;
// Insert the bolts.
show_bottom_bolts                 = false;
// Show the required bolt length and diameter.
show_bottom_bolts_info            = true;
// Tighten the bolts.
bottom_bolts_down                 = false;

// From the bottom, fasten the bolts to the standoffs.
show_standoffs                    = false;
// Attach your Turnigy Rapid (or other LiPo) pack.
show_lipo_pack                    = false;

// Uncheck the previous variables to see only the power-lid assembly.
show_lid                          = false;
// Connect your step-down voltage regulator.
show_lid_dc_regulator             = false;
// Connect the step-down voltage regulator to the fuse holders.
show_atm_fuse_holders             = false;
// Connect your voltmeters.
show_lid_voltmeter                = false;
// Connect your perfboard, if any.
show_perf_board                   = false;

// Fasten everything with bolts.
show_lid_bolts                    = false;

// Connect your custom slots, if any.
// Show if defined in power_lid_left_slots or power_lid_right_slots.
show_lid_ato_fuse                 = false;
// Show XT90E if defined in power_lid_left_slots or power_lid_right_slots.
show_lid_xt90e                    = false;
// Show if defined in power_lid_left_slots or power_lid_right_slots.
show_lid_switch_button            = false;

// ASSEMBLY END
slot_mode                         = false;
case_color                        = white_snow_1;

module power_case_assembly(slot_mode=slot_mode,
                           standoff_h=power_case_standoff_h,
                           standoff_thread_h=power_case_standoff_thread_h,
                           case_color=case_color,
                           alpha=1,
                           show_power_case=show_power_case,
                           show_lipo_pack=show_lipo_pack,
                           show_standoffs=show_standoffs,
                           show_socket_case_atm_fuse_holders
                           =show_socket_case_atm_fuse_holders,
                           show_socket_case_lid=show_socket_case_lid,
                           show_socket=show_socket,
                           show_socket_case=show_socket_case,
                           show_lid_xt90e=show_lid_xt90e,
                           show_lid = show_lid,
                           show_lid_dc_regulator=show_lid_dc_regulator,
                           show_lid_ato_fuse=show_lid_ato_fuse,
                           show_lid_voltmeter=show_lid_voltmeter,
                           show_lid_bolts=show_lid_bolts,
                           show_bottom_bolts=show_bottom_bolts,
                           show_atm_fuse_holders=show_atm_fuse_holders,
                           show_perf_board=show_perf_board,
                           bolt_spacing=power_case_bottom_bolt_spacing,
                           bolt_offsets=[power_case_bolt_spacing_offset_x,
                                         power_case_bolt_spacing_offset_y],
                           show_bottom_bolts_info=show_bottom_bolts_info,
                           bottom_bolts_down=bottom_bolts_down,
                           slot_thickness=chassis_thickness,
                           slot_bore_h=chassis_counterbore_h,
                           socket_size=power_socket_case_size,
                           socket_lid_thickness=power_socket_case_lid_thickness,
                           socket_rim_h=power_socket_case_rim_h) {
  standoff_z = standoff_thread_h + slot_bore_h;
  standoff_full_h = standoff_thread_h + standoff_h;

  full_socket_h = sliding_box_full_height(size=socket_size,
                                          lid_thickness=socket_lid_thickness,
                                          rim_h=socket_rim_h);

  module _case() {
    power_case(case_color=case_color,
               alpha=alpha,
               bolt_spacing=bolt_spacing,
               bolt_offsets=bolt_offsets);
  }

  module _lipo_pack() {
    translate([0,
               0,
               show_power_case
               ? power_case_bottom_thickness + 0.1
               : 0]) {
      lipo_pack();
    }
  }

  module _lid() {
    translate([0,
               0,
               show_power_case
               ? power_case_height + power_lid_height
               : show_lipo_pack
               ? lipo_pack_height + power_lid_height
               : show_standoffs && !show_socket_case
               ? power_lid_thickness
               : power_lid_height]) {
      rotate([180, 0, 0]) {
        power_lid(show_switch_button=show_lid_switch_button,
                  show_dc_regulator=show_lid_dc_regulator,
                  lid_color=case_color,
                  show_ato_fuse=show_lid_ato_fuse,
                  show_voltmeter=show_lid_voltmeter,
                  show_bolt=show_lid_bolts,
                  show_xt90e=show_lid_xt90e,
                  show_perf_board=show_perf_board,
                  show_atm_fuse_holders=show_atm_fuse_holders,
                  left_columns = power_lid_left_slots,
                  right_columns = power_lid_right_slots);
      }
    }
  }

  module _bottom_bolts() {
    bolt_h = show_socket_case
      ? round(full_socket_h
              + power_case_bottom_thickness) + 1
      : power_case_bottom_thickness + 2;

    d = power_case_bottom_bolt_dia;

    with_power_case_mounting_holes() {
      translate([0, 0, power_case_bottom_thickness]) {
        let (x_i = $x_i,
             y_i = $y_i,
             is_left = x_i == 0,
             is_top = y_i == 0,
             max_dia = max(power_case_bottom_cbore_dia, d)) {

          if (show_bottom_bolts_info) {
            translate([is_left ? max_dia : -max_dia,
                       0,
                       0]) {
              bolt_info_text(d=d,
                             h=bolt_h,
                             ["halign", is_top ? "left" : "right",
                              "color", red_1,
                              "size", 2.5,
                              "font", "Liberation Sans:style=Bold",
                              "valign", "bottom",
                              "rotation", [0, 0, 90]]);
            }
          }
        }
      }
    }

    translate([0,
               0,
               bottom_bolts_down
               ? power_case_bottom_thickness
               - bolt_h
               - power_case_bottom_cbore_h
               : power_case_bottom_thickness]) {
      with_power_case_mounting_holes() {
        bolt(d=power_case_bottom_bolt_dia,
             head_type=power_case_bottom_bolt_head_type,
             h=bolt_h);
      }
    }
  }

  module _stack() {
    on_standoffs = show_standoffs && !show_socket_case;
    maybe_translate([0, 0, on_standoffs ? -standoff_z : 0]) {
      maybe_translate([0,
                       0,
                       on_standoffs ? standoff_full_h : 0]) {

        if (show_power_case) {
          _case();
        }
        if (show_lipo_pack) {
          _lipo_pack();
        }

        if (show_lid) {
          _lid();
        }

        if (show_bottom_bolts) {
          _bottom_bolts();
        }
      }

      if (on_standoffs) {
        with_power_case_mounting_holes() {
          standoff(body_h=standoff_h,
                   thread_at_top=false,
                   show_bolt=false,
                   show_nut=true,
                   thread_h=standoff_thread_h);
        }
      }
    }
  }

  if (slot_mode) {
    with_power_case_mounting_holes(bolt_spacing=bolt_spacing,
                                   offsets=bolt_offsets) {
      counterbore(d=power_case_bottom_bolt_dia,
                  h=slot_thickness,
                  bore_h=slot_bore_h,
                  bore_d=power_case_bottom_cbore_dia,
                  autoscale_step=0.1,
                  sink=false,
                  reverse=false);
    }
  } else if (show_socket_case) {
    power_socket_case(show_standoffs=show_standoffs,
                      case_color=case_color,
                      standoff_h=standoff_h,
                      assembly=true,
                      assembly_debug=false,
                      show_lid=show_socket_case_lid,
                      lid_thickness=socket_lid_thickness,
                      size=socket_size,
                      show_socket=show_socket,
                      show_atm_fuse_holders=show_socket_case_atm_fuse_holders,
                      standoff_thread_h=standoff_thread_h) {
      _stack();
    }
  } else {
    _stack();
  }
}

power_case_assembly();
