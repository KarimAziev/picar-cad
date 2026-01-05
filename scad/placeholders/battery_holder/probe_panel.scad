include <../../colors.scad>
include <../../parameters.scad>
use <battery_holder.scad>
use <../../lib/shapes3d.scad>

// Where mounting holes are placed
panel_mount_type                 = "intercell"; // [under_cell: Under each cell, intercell: Between the cells]

contact_terminal_type            = "solder_tab"; // [coil_spring: Circular contact with a helical spring, solder_tab: Squared external connection-style tabs]

side_wall_cutout_type            = "skeleton"; // [enclosed: Enclosed, skeleton: Skeleton]

/* [Solder tab parameters] */
tab_contact_slot_default_pad_len = 5;
tab_contact_slot_default_pad_w   = 5;
tab_contact_default_hole_d       = 1;

// Number of batteries to use
batteries_count                  = 2; // [0:1:6]

bolt_dia                         = battery_holder_bolt_dia;
bolt_spacing                     = battery_holder_bolt_spacing;

slot_thickness                   = 2;

panel_padding                    = 2;

module probe_panel(tab_contact_hole_d=tab_contact_default_hole_d,
                   tab_contact_slot_pad_len=tab_contact_slot_default_pad_len,
                   tab_contact_slot_pad_w=tab_contact_slot_default_pad_w,
                   battery_dia=battery_dia,
                   battery_len=battery_length,
                   terminal_type=contact_terminal_type,
                   side_wall_type=side_wall_cutout_type,
                   mount_type=panel_mount_type,
                   side_thickness=battery_holder_side_thickness,
                   front_rear_thickness=battery_holder_front_rear_thickness,
                   slot_thickness=slot_thickness,
                   panel_padding=panel_padding,
                   bolt_dia=bolt_dia,
                   count=batteries_count,
                   bolt_spacing=bolt_spacing,
                   inner_thickness=battery_holder_inner_thickness) {
  full_size = battery_holder_full_size(inner_thickness=inner_thickness,
                                       side_thickness=side_thickness,
                                       count=count,
                                       front_rear_thickness=front_rear_thickness,
                                       battery_dia=battery_dia,
                                       battery_len=battery_len,
                                       terminal_type=terminal_type,
                                       contact_hole_d=tab_contact_hole_d,
                                       tab_contact_slot_pad_len=tab_contact_slot_pad_len);
  panel_size = [full_size[0] + panel_padding * 2,
                full_size[1] + panel_padding * 2,
                slot_thickness];
  difference() {
    cube_3d(panel_size);
    battery_holder(tab_contact_hole_d=tab_contact_hole_d,
                   tab_contact_slot_pad_len=tab_contact_slot_pad_len,
                   tab_contact_slot_pad_w=tab_contact_slot_pad_w,
                   terminal_type=terminal_type,
                   side_wall_type=side_wall_type,
                   mount_type=mount_type,
                   count=count,
                   bolt_dia=bolt_dia,
                   bolt_spacing=bolt_spacing,
                   slot_thickness=slot_thickness,
                   slot_mode=true,
                   center=true);
  }
}

probe_panel();