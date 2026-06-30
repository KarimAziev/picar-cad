
include <../colors.scad>
include <../parameters.scad>

use <xt90e-m.scad>

module xt60e(shell_size=xt60be_size,
             mounting_panel_size=xt60be_mounting_panel_size,
             mount_spacing=xt60be_mount_spacing,
             mount_dia=xt60be_mount_dia,
             mount_bore_dia=xt60be_mount_cbore_dia,
             mount_bore_h=xt60be_mount_cbore_h,
             r_factor=0.3,
             shell_r_factor=0.5,
             contact_d=xt60be_contact_dia,
             contact_h=xt60be_contact_h,
             contact_wall_h=xt60be_contact_wall_h,
             contact_base_h=xt60be_contact_base_h,
             contact_thickness=xt60be_contact_thickness,
             pin_color=xt60be_pin_color,
             pin_spacing=xt60be_pin_spacing,
             pin_dia=xt60be_pin_dia,
             pin_length=xt60be_pin_length,
             pin_thickness=xt60be_pin_thickness,
             shell_color=xt60be_shell_color,
             bolt_visible_h=power_lid_thickness + 4,
             bolt_head_type="pan",
             round_side="bottom",
             bolt_through_h=power_lid_thickness,
             gnd_wiring_color=matte_black,
             gnd_wiring,
             vcc_wiring,
             vcc_wiring_color=red_1,
             echo_bolts_info=false,
             standup=false,
             show_bolt=true,
             show_nut=true,
             center=true) {
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
        echo_bolts_info=echo_bolts_info,
        standup=standup,
        show_bolt=show_bolt,
        show_nut=show_nut,
        center=center);
}

xt60e();

translate([20, 0, 0]) {

  xt90e();
}