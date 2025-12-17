/**
 * Module: Buttons and fusers holder
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <control_panel.scad>
use <fuse_panel.scad>
use <../lib/functions.scad>
use <../lib/shapes2d.scad>
use <../lib/transforms.scad>
use <../placeholders/standoff.scad>
use <../lib/holes.scad>

function panel_stack_size() =
  let (fusers_size = fuse_panel_size(),
       buttons_size = control_panel_size())
  [max(fusers_size[0], buttons_size[0]),
   max(fusers_size[1], buttons_size[1])];

function panel_stack_screw_size() =
  let (fusers_size = fuse_panel_screw_size(),
       buttons_size = control_panel_bolt_size())
  [max(fusers_size[0], buttons_size[0]),
   max(fusers_size[1], buttons_size[1])];

module panel_stack(show_fusers=true,
                   show_standoff=true,
                   show_buttons=true,
                   show_buttons_panel=true,
                   show_fuse_panel=true,
                   center=false,
                   show_lid=true,
                   y_axle=true,
                   panel_color=white_snow_1) {
  size = panel_stack_size();
  screws_size = panel_stack_screw_size();
  w = size[0];
  l = size[1];

  maybe_translate([0, y_axle ? 0 : center ? 0 : w, 0]) {
    maybe_rotate([0, 0, y_axle ? 0 : -90]) {
      if (show_buttons_panel && show_fuse_panel) {
        translate([center ? 0 : w / 2, center ? 0 : l / 2, 0]) {
          let (max_lid_h = fuse_panel_max_lid_height(),
               standoff_params =
               calc_standoff_params(d=panel_stack_bolt_dia,
                                    min_h=max_lid_h),
               standoff_extra_height = sum(standoff_params[1])) {

            fuse_panel(show_fusers=show_fusers,
                       show_standoff=true,
                       screws_size=screws_size,
                       size=size,
                       panel_color=panel_color,
                       show_lid=show_lid,
                       center=true) {
              four_corner_children(size=screws_size,
                                   center=true,) {
                standoffs_stack(d=panel_stack_bolt_dia,
                                min_h=max_lid_h,
                                thread_at_top=true);
              }
              translate([0, 0, standoff_extra_height]) {
                control_panel(center=true,
                              show_buttons=show_buttons,
                              show_standoff=true,
                              panel_color=panel_color,
                              size=size,
                              screws_size=screws_size);
              }
            }
          }
        }
      } else if (show_fuse_panel) {
        fuse_panel(show_fusers=show_fusers,
                   show_standoff=show_standoff,
                   screws_size=screws_size,
                   show_lid=show_lid,
                   panel_color=panel_color,
                   center=center,
                   size=size);
      } else if (show_buttons_panel) {
        control_panel(show_buttons=show_buttons,
                      show_standoff=show_standoff,
                      screws_size=screws_size,
                      center=center,
                      panel_color=panel_color,
                      size=size);
      }
    }
  }
}

module panel_stack_screw_holes(y_axle=true, center=false) {
  size = panel_stack_size();
  screws_size = panel_stack_screw_size();
  w = size[0];
  l = size[1];

  maybe_translate([0, y_axle ? 0 : center ? 0 : w, 0]) {
    maybe_rotate([0, 0, y_axle ? 0 : -90]) {
      translate([center ? 0 : w / 2, center ? 0 : l / 2, 0]) {
        four_corner_children(size=screws_size,
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
                               spacing=2) {
  size = panel_stack_size();
  screws_size = panel_stack_screw_size();

  if (show_buttons_panel && show_fuse_panel) {
    translate([size[0] / 2 + spacing, 0, 0]) {
      control_panel(show_buttons=false,
                    show_standoff=false,
                    screws_size=screws_size,
                    center=true,
                    size=size);
    }
    translate([-size[0] / 2 - spacing, 0, 0]) {
      fuse_panel(show_fusers=false,
                 show_standoff=false,
                 screws_size=screws_size,
                 size=size,
                 center=true);
    }
  } else if (show_fuse_panel) {
    fuse_panel(show_standoff=false,
               screws_size=screws_size,
               center=true,
               size=size);
  } else if (show_buttons_panel) {
    control_panel(show_buttons=show_buttons,
                  show_standoff=false,
                  screws_size=screws_size,
                  center=true,
                  size=size);
  }
}

// buttons_fusers_panels(show_buttons_panel=true,
//                       show_fuse_panel=true);

// panel_stack_print_plate(show_buttons_panel=false);
panel_stack(show_buttons_panel=true,
            show_fuse_panel=true,
            y_axle=false,
            center=false);

// panel_stack_screw_holes(y_axle=false,
//                         center=false);