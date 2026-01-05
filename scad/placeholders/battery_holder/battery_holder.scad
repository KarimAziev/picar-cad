/**
 * Module: Battery holder
 *
 * Supports two mount types:
 *
 * - intercell: holes between the cells
 * - under_cell: holes under each cell
 *
 * Supports two terminal types:
 *
 * - coil_spring: a helical spring
 * - solder_tab: external connection style-tabs meant to be soldered
 *
 * Supports two side-wall styles:
 *
 * - skeleton (open frame)
 * - enclosed
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../colors.scad>
include <../../parameters.scad>

use <../../lib/functions.scad>
use <../../lib/transforms.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/plist.scad>
use <../battery.scad>
use <../bolt.scad>
use <contact.scad>
use <side_wall.scad>

// Where mounting holes are placed
panel_mount_type      = "intercell"; // [under_cell: Under each cell, intercell: Between the cells]

contact_terminal_type = "solder_tab"; // [coil_spring: Circular contact with a helical spring, solder_tab: Squared external connection-style tabs]

side_wall_cutout_type = "skeleton"; // [enclosed: Enclosed, skeleton: Skeleton]

// Number of batteries to use
batteries_count       = 2; // [0:1:6]

/* [Assembly] */
show_battery          = false;
show_contact          = true;

show_bolt             = true;
show_nut              = true;
lock_nut              = false;

default_battery_dia   = battery_dia;

function _battery_holder_full_len(front_rear_thickness, battery_len) =
  battery_len + front_rear_thickness * 2;

function _battery_holder_single_width(inner_thickness, battery_dia) =
  battery_dia + inner_thickness * 2;

function _battery_holder_full_w(inner_thickness, count, battery_dia) =
  let (single_width =
       _battery_holder_single_width(inner_thickness=inner_thickness,
                                    battery_dia=battery_dia),
       total_w = single_width * count)
  total_w;

function battery_holder_full_size(inner_thickness,
                                  side_thickness,
                                  count,
                                  front_rear_thickness,
                                  battery_dia,
                                  battery_len,
                                  terminal_type) =
  let (solder_len =
       (contact_terminal_type == "solder_tab"
        ? solder_tab_outer_len(battery_dia=battery_dia,
                               front_rear_thickness=front_rear_thickness)
        : 0),
       length =
       _battery_holder_full_len(front_rear_thickness=front_rear_thickness,
                                battery_len=battery_len),
       full_len = length + solder_len * 2,
       base_width = _battery_holder_full_w(inner_thickness=inner_thickness,
                                           count=count,
                                           battery_dia=battery_dia),
       full_w = base_width + side_thickness * 2)

  [full_w, full_len];

module battery_holder_with_mounting_holes_positions(count,
                                                    bolt_spacing,
                                                    inner_thickness,
                                                    battery_dia,
                                                    mount_type) {
  single_width = _battery_holder_single_width(inner_thickness,
                                              battery_dia=battery_dia);
  total_w = single_width * count;

  if (mount_type == "intercell") {
    y_size = is_num(bolt_spacing) ? bolt_spacing : bolt_spacing[1];

    if (count > 1) {
      translate([-total_w / 2, 0, 0]) {
        for (i = [0:count - 2]) {
          let (n = i + 1,
               v = single_width * n) {

            translate([v, 0, 0]) {
              for (y_ind = [0, 1]) {
                y_pos = -y_size / 2 + y_ind * y_size;

                translate([0, y_pos]) {
                  children();
                }
              }
            }
          }
        }
      }
    }
  } else {
    if (count > 0) {
      x_size = is_num(bolt_spacing) ? bolt_spacing : bolt_spacing[0];
      translate([-total_w / 2 - single_width / 2, 0, 0]) {

        for (i = [0:count - 1]) {
          let (n = i + 1,
               v = single_width * n) {

            translate([v, 0, 0]) {
              children();
            }
          }
        }
      }
    }
  }
}

module battery_holder(battery_len=battery_height,
                      battery_dia=default_battery_dia,
                      count=batteries_count,
                      terminal_type=contact_terminal_type,
                      side_wall_type=side_wall_cutout_type,
                      mount_type=panel_mount_type,
                      bolt_dia=smd_battery_holder_bolt_dia,
                      bolt_spacing=smd_battery_holder_bolt_spacing,
                      inner_thickness=smd_battery_holder_inner_thickness,
                      bottom_thickness=smd_battery_holder_bottom_thickness,
                      side_thickness=smd_battery_holder_side_thickness,
                      front_rear_thickness=smd_battery_holder_front_rear_thickness,
                      inner_cutout_h=smd_battery_holder_inner_side_h,
                      intercell_reces_size=smd_battery_holder_bolt_recess_size,
                      through_hole_distance=chassis_thickness,
                      color=matte_black,
                      contact_color=metallic_yellow_1,
                      bolt_head_type="round",
                      bolt_visible_h=2,
                      show_battery=show_battery,
                      show_contact=show_contact,
                      show_bolt=show_bolt,
                      show_nut=show_nut,
                      lock_nut=lock_nut,
                      slot_thickness=chassis_thickness,
                      slot_mode=false,
                      center=true) {
  battery_len = with_default(battery_len, battery_height);
  battery_dia = with_default(battery_dia, default_battery_dia);
  count = with_default(count, batteries_count);
  terminal_type = with_default(terminal_type, contact_terminal_type);
  side_wall_type = with_default(side_wall_type, side_wall_cutout_type);
  mount_type = with_default(mount_type, panel_mount_type);
  bolt_dia = with_default(bolt_dia, smd_battery_holder_bolt_dia);
  bolt_spacing = with_default(bolt_spacing, smd_battery_holder_bolt_spacing);
  inner_thickness = with_default(inner_thickness,
                                 smd_battery_holder_inner_thickness);
  bottom_thickness = with_default(bottom_thickness,
                                  smd_battery_holder_bottom_thickness);
  side_thickness = with_default(side_thickness,
                                smd_battery_holder_side_thickness);
  front_rear_thickness = with_default(front_rear_thickness,
                                      smd_battery_holder_front_rear_thickness);
  inner_cutout_h = with_default(inner_cutout_h,
                                smd_battery_holder_inner_side_h);
  intercell_reces_size = with_default(intercell_reces_size,
                                      smd_battery_holder_bolt_recess_size);
  through_hole_distance = with_default(through_hole_distance,
                                       chassis_thickness);
  color = with_default(color, matte_black);
  contact_color = with_default(contact_color, metallic_yellow_1);
  bolt_head_type = with_default(bolt_head_type, "round");
  bolt_visible_h = with_default(bolt_visible_h, 2);

  slot_thickness = with_default(slot_thickness, chassis_thickness);

  is_skeleton = side_wall_type == "skeleton";
  is_intercell = mount_type == "intercell";

  height = is_skeleton ? battery_dia * 0.83 : battery_dia * 0.9;

  inner_cutout_size = is_intercell ?
    [0.5 * battery_dia, 1.02 * battery_len]
    : undef;

  side_cutout_depths = side_wall_get_cutout_depths(battery_dia=battery_dia,
                                                   type=side_wall_type);

  max_side_cutout_h = max(side_cutout_depths);

  full_size = battery_holder_full_size(inner_thickness=inner_thickness,
                                       side_thickness=side_thickness,
                                       count=count,
                                       front_rear_thickness=front_rear_thickness,
                                       battery_dia=battery_dia,
                                       battery_len=battery_len,
                                       terminal_type=terminal_type);

  single_width = _battery_holder_single_width(inner_thickness=inner_thickness,
                                              battery_dia=battery_dia);
  total_w = _battery_holder_full_w(inner_thickness=inner_thickness,
                                   count=count,
                                   battery_dia=battery_dia);
  holder_l = battery_len + front_rear_thickness * 2;

  module _with_cell_position(center_x=false, center_y=false) {
    translate([-total_w / 2, -holder_l / 2, 0]) {
      for (i = [0 : count - 1]) {
        $i = i;
        translate([i * single_width + (center_x ? single_width / 2 : 0),
                   center_y ? holder_l / 2 : 0,
                   0]) {
          children();
        }
      }
    }
  }

  module terminal_contact(use_spring=false) {
    battery_holder_contact(terminal_type=terminal_type,
                           battery_len=battery_len,
                           battery_dia=battery_dia,
                           holder_height=height,
                           bottom_thickness=bottom_thickness,
                           front_rear_thickness=front_rear_thickness,
                           use_spring=use_spring,
                           contact_color=contact_color);
  }

  if (count > 0) {
    translate([center ? 0 : total_w / 2 + side_thickness,
               center ? 0 : full_size[1] / 2,
               0]) {

      if (slot_mode) {
        battery_holder_with_mounting_holes_positions(count=count,
                                                     bolt_spacing=bolt_spacing,
                                                     inner_thickness=inner_thickness,
                                                     battery_dia=battery_dia,
                                                     mount_type=mount_type) {
          union() {
            translate([0, 0, -0.1]) {
              cylinder(d=bolt_dia,
                       h=slot_thickness + 0.1,
                       $fn=160);
            }
          }
        }
      } else {
        union() {
          difference() {
            union() {
              _with_cell_position(center_x=false,
                                  center_y=false) {
                battery_holder_single_cell(full_width=single_width,
                                           holder_l=holder_l,
                                           height=height,
                                           battery_dia=battery_dia,
                                           battery_len=battery_len,
                                           terminal_type=terminal_type,
                                           bottom_thickness=bottom_thickness,
                                           front_rear_thickness=front_rear_thickness,
                                           inner_cutout_size=inner_cutout_size,
                                           mount_type=mount_type,
                                           color=color,
                                           center=false);
              }
            }

            translate([0, 0, inner_cutout_h]) {
              cube_3d(size=[total_w - side_thickness * 2,
                            battery_len,
                            height]);
            }

            mirror_copy([1, 0, 0]) {
              translate([total_w / 2 - inner_thickness + 0.1,
                         0,
                         height - max_side_cutout_h]) {
                cube_3d([inner_thickness * 2 + 0.2,
                         battery_len,
                         height + bottom_thickness + 1]);
              }
            }

            battery_holder_with_mounting_holes_positions(count=count,
                                                         bolt_spacing=bolt_spacing,
                                                         inner_thickness=inner_thickness,
                                                         battery_dia=battery_dia,
                                                         mount_type=mount_type) {
              union() {
                if (is_intercell) {
                  translate([0, 0, intercell_reces_size[2]]) {
                    cube_3d(size=[intercell_reces_size[0],
                                  intercell_reces_size[1],
                                  height]);
                  }
                }

                translate([0, 0, -0.1]) {
                  cylinder(d=bolt_dia,
                           h=height + 0.1,
                           $fn=20);
                }
              }
            }
          }

          mirror_copy([1, 0, 0]) {
            color(color, alpha=1) {
              translate([total_w / 2 + side_thickness / 2,
                         -battery_len / 2 - front_rear_thickness,
                         0]) {

                battery_holder_side_wall(type=side_wall_type,
                                         front_rear_thickness=front_rear_thickness,
                                         battery_len=battery_len,
                                         battery_dia=height,
                                         side_wall_thickness=side_thickness);
              }
            }
          }

          if (show_contact) {
            _with_cell_position(center_x=true, center_y=true) {
              let (spring_pos = $i % 2 == 0 ? "top" : "bottom") {
                translate([0,
                           holder_l / 2 - front_rear_thickness + 0.01,
                           0.05]) {
                  terminal_contact(use_spring=spring_pos == "top");
                }

                translate([0,
                           -holder_l / 2 + front_rear_thickness + 0.01,
                           0.05]) {
                  rotate([0, 0, 180]) {
                    terminal_contact(use_spring=spring_pos == "bottom");
                  }
                }
              }
            }
          }

          if (show_battery) {
            _with_cell_position(center_x=true, center_y=true) {
              translate([0, battery_len / 2, battery_dia / 2]) {
                rotate([90, 0, 0]) {
                  battery(d=battery_dia, h=battery_len);
                }
              }
            }
          }

          if (show_bolt) {
            let (blt_h = round(bottom_thickness
                               + slot_thickness
                               + bolt_visible_h),
                 bolt_h = blt_h % 2 == 0 ? blt_h : blt_h + 1) {
              translate([0, 0, -bolt_h + bottom_thickness]) {
                battery_holder_with_mounting_holes_positions(count=count,
                                                             bolt_spacing=bolt_spacing,
                                                             battery_dia=battery_dia,
                                                             inner_thickness=inner_thickness,
                                                             mount_type=mount_type) {
                  bolt(d=bolt_dia,
                       h=bolt_h,
                       head_type=bolt_head_type,
                       nut_head_distance=through_hole_distance,
                       show_nut=show_nut,
                       lock_nut=lock_nut);
                }
              }
            }
          }
        }
      }
    }
  }
}

module battery_holder_single_cell(full_width,
                                  holder_l,
                                  height,
                                  battery_dia,
                                  battery_len,
                                  terminal_type,
                                  mount_type,
                                  bottom_thickness=battery_holder_thickness,
                                  front_rear_thickness,
                                  center=false,
                                  inner_cutout_size,
                                  tolerance=1,
                                  spring_color,
                                  contact_hole_d,
                                  color) {
  full_dia = battery_dia + tolerance;
  max_inner_cutout_len = with_default(inner_cutout_size, [0, 0])[1];

  union() {
    translate([center ? 0 : full_width / 2, center ? 0 : holder_l / 2, 0]) {
      color(color, alpha=1) {
        difference() {
          cube_3d(size=[full_width, holder_l, height]);
          if (terminal_type == "solder_tab") {
            mirror_copy([0, 1, 0]) {
              translate([0, -holder_l / 2 + front_rear_thickness / 2, 0]) {
                solder_tab_cutout(battery_dia=battery_dia,
                                  holder_height=height,
                                  front_rear_thickness=front_rear_thickness,
                                  contact_hole_d=contact_hole_d);
              }
            }
          }

          if (!is_undef(inner_cutout_size)) {
            translate([0, 0, -0.2]) {
              cube_3d(size=[inner_cutout_size[0],
                            inner_cutout_size[1],
                            height + 0.2]);
            }
            translate([0, 0, bottom_thickness]) {
              cube_3d(size=[inner_cutout_size[0],
                            holder_l - front_rear_thickness * 2,
                            height + 0.2]);
            }
          }

          if (mount_type == "intercell") {
            translate([0, 0, full_dia / 2 + bottom_thickness]) {

              rotate([90, 0, 0]) {
                cylinder(d=full_dia,
                         h=max(battery_len + 1,
                               max_inner_cutout_len,
                               holder_l - front_rear_thickness * 2) + 0.01,
                         center=true,
                         $fn=10);
              }
            }
          } else {
            translate([0, 0, bottom_thickness]) {
              cube_3d([battery_dia,
                       max(battery_len + 1,
                           max_inner_cutout_len,
                           holder_l - front_rear_thickness * 2) + 0.01,
                       height]);
            }
          }
        }
      }
    }
  }
}

module battery_holder_cell(plist,
                           align_x = -1,
                           align_y = -1,
                           thickness=2,
                           cell_size,
                           spin,
                           slot_mode=false,
                           center=false) {
  plist = with_default(plist, []);
  battery_len = plist_get("battery_len", plist, battery_height);
  battery_dia = plist_get("battery_dia", plist, battery_dia);
  count = plist_get("count", plist, batteries_count);
  inner_thickness = plist_get("inner_thickness",
                              plist,
                              smd_battery_holder_inner_thickness);
  side_wall_type = plist_get("side_wall_type", plist, side_wall_cutout_type);
  mount_type = plist_get("mount_type", plist, panel_mount_type);
  terminal_type = plist_get("terminal_type", plist, contact_terminal_type);
  bolt_dia = plist_get("bolt_dia", plist, smd_battery_holder_bolt_dia);
  bolt_spacing = plist_get("bolt_spacing",
                           plist,
                           smd_battery_holder_bolt_spacing);
  intercell_reces_size = plist_get("intercell_reces_size",
                                   plist,
                                   smd_battery_holder_bolt_recess_size);
  bottom_thickness = plist_get("bottom_thickness",
                               plist,
                               smd_battery_holder_bottom_thickness);
  side_thickness = plist_get("side_thickness",
                             plist,
                             smd_battery_holder_side_thickness);
  inner_cutout_h = plist_get("inner_cutout_h",
                             plist,
                             smd_battery_holder_inner_side_h);
  front_rear_thickness = plist_get("front_rear_thickness",
                                   plist,
                                   smd_battery_holder_front_rear_thickness);
  color = plist_get("color", plist, matte_black);
  show_battery = plist_get("show_battery", plist, show_battery);
  show_contact = plist_get("show_contact", plist, show_contact);
  show_bolt = plist_get("show_bolt", plist, show_bolt);
  show_nut = plist_get("show_nut", plist, show_nut);
  lock_nut = plist_get("lock_nut", plist, false);
  bolt_head_type = plist_get("bolt_head_type", plist, "round");
  bolt_visible_h = plist_get("bolt_visible_h", plist, 2);
  through_hole_distance = plist_get("through_hole_distance",
                                    plist,
                                    chassis_thickness);
  contact_color = plist_get("contact_color", plist, metallic_yellow_1);

  full_size = battery_holder_full_size(inner_thickness=inner_thickness,
                                       side_thickness=side_thickness,
                                       count=count,
                                       front_rear_thickness=front_rear_thickness,
                                       battery_dia=battery_dia,
                                       battery_len=battery_len,
                                       terminal_type=terminal_type);

  module holder_or_slot() {
    battery_holder(battery_len=battery_len,
                   battery_dia=battery_dia,
                   count=count,
                   inner_thickness=inner_thickness,
                   side_wall_type=side_wall_type,
                   mount_type=mount_type,
                   terminal_type=terminal_type,
                   bolt_dia=bolt_dia,
                   bolt_spacing=bolt_spacing,
                   intercell_reces_size=intercell_reces_size,
                   bottom_thickness=bottom_thickness,
                   side_thickness=side_thickness,
                   inner_cutout_h=inner_cutout_h,
                   front_rear_thickness=front_rear_thickness,
                   color=color,
                   show_battery=show_battery,
                   show_contact=show_contact,
                   show_bolt=show_bolt,
                   show_nut=show_nut,
                   lock_nut=lock_nut,
                   bolt_head_type=bolt_head_type,
                   bolt_visible_h=bolt_visible_h,
                   through_hole_distance=through_hole_distance,
                   slot_mode=slot_mode,
                   slot_thickness=thickness,
                   contact_color=contact_color,
                   center=center);
  }

  if (center) {
    maybe_rotate([0, 0, spin]) {
      holder_or_slot();
    }
  } else {
    align_children_with_spin(parent_size=cell_size,
                             size=full_size,
                             align_x=align_x,
                             align_y=align_y,
                             spin=spin) {
      holder_or_slot();
    }
  }
}

spin = 0;
battery_holder_cell(center=false, spin=spin);
// battery_holder_cell(center=false, spin=spin, slot_mode=true);
