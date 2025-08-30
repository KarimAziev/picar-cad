/**
 * Module: Knuckle Connector
 *
 * This file defines modules for rendering a rounded connector with an inner
 * cylindrical notch on one side and a hole on the other side. The side with
 * the notch is intended to wrap around a cylinder, while the opposite side
 * can be used to hold bearings or other shafts.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <../util.scad>

module knuckle_connector(parent_dia,
                         outer_d,
                         inner_d,
                         h,
                         length,
                         border_w,
                         fn=100,
                         connector_color=blue_grey_carbon,
                         children_modes=[]) {

  offst = outer_d / 2;

  notch_width = calc_notch_width(max(parent_dia, outer_d),
                                 min(parent_dia, outer_d));

  full_len = notch_width + length + border_w;

  function children_for(mode) =
    [for (i = [0:len(children_modes) - 1])
        if (children_modes[i] == mode) i];

  union_children = children_for("union");
  difference_children = children_for("difference");
  union_inner_children = children_for("union_inner");
  difference_outer_children = children_for("difference_outer");

  union() {
    color(connector_color) {
      linear_extrude(height=h, center=false) {
        difference() {
          translate([0, -offst, 0]) {
            difference() {
              square([full_len, outer_d], center=false);
              translate([0, offst, 0]) {
                circle(d=parent_dia, $fn=fn);
              }
            }
          }
        }
      }
    }

    translate([full_len - 0.01, 0, 0]) {
      if ($children == 0) {
        knuckle_connector_outer(h=h,
                                outer_d=outer_d,
                                inner_d=inner_d,
                                x_offst=offst,
                                connector_color=connector_color);
      } else {
        difference() {
          union() {
            difference() {
              union() {
                knuckle_connector_outer(h=h,
                                        outer_d=outer_d,
                                        inner_d=inner_d,
                                        x_offst=offst,
                                        connector_color=connector_color);
                if (non_empty(union_inner_children)) {
                  for (i = union_inner_children) {
                    if ($children > i) {
                      children(i);
                    }
                  }
                }
              }
              if (non_empty(difference_children)) {
                for (i = difference_children) {
                  if ($children > i) {
                    children(i);
                  }
                }
              }
            }
            if (non_empty(union_children)) {
              for (i = union_children) {
                if ($children > i) {
                  children(i);
                }
              }
            }
          }
          if (non_empty(difference_outer_children)) {
            for (i = difference_outer_children) {
              if ($children > i) {
                children(i);
              }
            }
          }
        }
      }
    }
  }
}

module knuckle_connector_outer(h,
                               outer_d,
                               inner_d,
                               x_offst,
                               connector_color,
                               ring_fn=360) {
  ring_w = (outer_d - inner_d) / 2;
  union() {
    color(connector_color) {
      linear_extrude(height=h, center=false) {
        translate([0, -outer_d / 2, 0]) {
          difference() {
            square([x_offst, outer_d], center=false);
            translate([x_offst, outer_d / 2, 0]) {
              circle(d=inner_d, $fn=360);
            }
          }
        }
      }
    }
    translate([x_offst, 0, 0]) {
      color(connector_color) {
        linear_extrude(height=h, convexity=2) {
          ring_2d(r=inner_d / 2,
                  w=ring_w,
                  fn=ring_fn,
                  outer=true);
        }
      }
    }
  }
}
