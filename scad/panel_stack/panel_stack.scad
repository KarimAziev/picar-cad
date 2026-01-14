/**
 * Module: Buttons and fuses holder
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/holes.scad>
use <../lib/shapes2d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../placeholders/standoff.scad>
use <control_panel.scad>
use <fuse_panel.scad>

function panel_stack_size() =
  let (fuses_size = fuse_panel_size(),
       buttons_size = control_panel_size())
  [max(fuses_size[0], buttons_size[0]),
   max(fuses_size[1], buttons_size[1])];

function panel_stack_bolt_spacing() =
  let (fuses_size = fuse_panel_bolt_spacing(),
       buttons_size = control_panel_bolt_size())
  [max(fuses_size[0], buttons_size[0]),
   max(fuses_size[1], buttons_size[1])];

module panel_stack(show_fuses=true,
                   show_standoff=true,
                   show_buttons=true,
                   show_buttons_panel=true,
                   show_fuse_panel=true,
                   center=false,
                   show_cap=true,
                   y_axle=true,
                   panel_color=white_snow_1) {
  size = panel_stack_size();
  bolt_spacing = panel_stack_bolt_spacing();
  w = size[0];
  l = size[1];

  maybe_translate([0, y_axle ? 0 : center ? 0 : w, 0]) {
    maybe_rotate([0, 0, y_axle ? 0 : -90]) {
      if (show_buttons_panel && show_fuse_panel) {
        translate([center ? 0 : w / 2, center ? 0 : l / 2, 0]) {
          fuse_panel(show_fuses=show_fuses,
                     show_standoff=true,
                     bolt_spacing=bolt_spacing,
                     size=size,
                     panel_color=panel_color,
                     show_cap=show_cap,
                     show_bolt=true,
                     center=true) {
            translate([0, 0, 0]) {
              control_panel(center=true,
                            show_buttons=show_buttons,
                            show_standoff=true,
                            panel_color=panel_color,
                            size=size,
                            bolt_spacing=bolt_spacing);
            }
          }
        }
      } else if (show_fuse_panel) {
        fuse_panel(show_fuses=show_fuses,
                   show_standoff=show_standoff,
                   bolt_spacing=bolt_spacing,
                   show_cap=show_cap,
                   show_nut=true,
                   show_bolt=true,
                   panel_color=panel_color,
                   center=center,
                   size=size);
      } else if (show_buttons_panel) {
        control_panel(show_buttons=show_buttons,
                      show_standoff=show_standoff,
                      bolt_spacing=bolt_spacing,
                      show_nut=true,
                      show_bolt=true,
                      center=center,
                      panel_color=panel_color,
                      size=size);
      }
    }
  }
}

module panel_stack_bolt_holes(y_axle=true, center=false) {
  size = panel_stack_size();
  bolt_spacing = panel_stack_bolt_spacing();
  w = size[0];
  l = size[1];

  maybe_translate([0, y_axle ? 0 : center ? 0 : w, 0]) {
    maybe_rotate([0, 0, y_axle ? 0 : -90]) {
      translate([center ? 0 : w / 2, center ? 0 : l / 2, 0]) {
        four_corner_children(size=bolt_spacing,
                             center=true) {
          counterbore(h=chassis_thickness,
                      d=panel_stack_bolt_dia,
                      bore_d=panel_stack_bolt_cbore_dia,
                      bore_h=chassis_counterbore_h);
        }
      }
    }
  }
}

module panel_stack_print_plate(show_buttons_panel=true,
                               show_fuse_panel=true,
                               align_x=0,
                               align_y=0,
                               spacing=2) {
  size = panel_stack_size();
  bolt_spacing = panel_stack_bolt_spacing();

  x = ((show_buttons_panel && show_fuse_panel)
       ? (size[0]) + spacing
       : size[0] / 2) * align_x;

  y = (size[1] / 2) * align_y;

  translate([x, y, 0]) {
    if (show_buttons_panel && show_fuse_panel) {
      translate([size[0] / 2 + spacing, 0, 0]) {
        control_panel(show_buttons=false,
                      show_standoff=false,
                      bolt_spacing=bolt_spacing,
                      center=true,
                      size=size);
      }
      translate([-size[0] / 2 - spacing, 0, 0]) {
        fuse_panel(show_fuses=false,
                   show_standoff=false,
                   bolt_spacing=bolt_spacing,
                   size=size,
                   center=true);
      }
    } else if (show_fuse_panel) {
      fuse_panel(show_standoff=false,
                 bolt_spacing=bolt_spacing,
                 center=true,
                 size=size);
    } else if (show_buttons_panel) {
      control_panel(show_buttons=false,
                    show_standoff=false,
                    bolt_spacing=bolt_spacing,
                    center=true,
                    size=size);
    }
  }
}

// buttons_fuses_panels(show_buttons_panel=true,
//                      show_fuse_panel=true);

panel_stack_print_plate(show_buttons_panel=true,
                        show_fuse_panel=true,
                        align_x=-1,
                        align_y=1);
// panel_stack(show_buttons_panel=true,
//             show_fuse_panel=true,
//             y_axle=false,
//             center=false);

// panel_stack_bolt_holes(y_axle=false,
//                         center=false);
