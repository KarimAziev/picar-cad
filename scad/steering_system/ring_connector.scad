/**
 * Module: Ring Connector Module
 * This file contains modules for creating detachable connectors in the form of vertical cylinders that slide onto each other.
 *
 * The module created by `upper_ring_connector` fits over the module created by `lower_ring_connector`.
 *
 * Parameters:
 *
 * - d            : Diameter of the main cylinder.
 * - h            : Total height of the cylinder.
 * - connector_h : Height of the connector. This value must not exceed the total
 *   height (h). In the case of upper_ring_connector, it represents the depth of
 *   the cut-out at the bottom of the cylinder, in the case of
 *   lower_ring_connector, it is the height of the cylinder that fits into the
 *   cut-out of the upper_ring_connector. For a matching pair of
 *   upper_ring_connector and lower_ring_connector modules, this parameter needs
 *   to be identical.
 * - connector_d : Diameter of the connector. This value must not exceed the diameter
 *   of the main cylinder (d). In upper_ring_connector, it is the diameter of the
 *   inner cylinder within the cut-out; in lower_ring_connector, it is the diameter
 *   of the hole in the protruding cylinder that fits into the cut-out of the
 *   upper_ring_connector. For a matching pair, this parameter must be the same.
 * - ring_w : Width of the rim surrounding the connector. For a matching pair,
 *   this parameter must be identical. Note that upper_ring_connector accepts an
 *   additional parameter 'tolerance' which increases the width by the specified
 *   value (ring_w + tolerance).
 * - center_dia   : An optional parameter for creating a through-hole along the
 *   entire cylinder.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
use <../util.scad>
use <bracket.scad>
use <shaft.scad>
use <rack_connector.scad>

module upper_ring_connector(d,
                            h,
                            connector_h,
                            connector_d,
                            center_dia,
                            ring_w=1,
                            tolerance=0.4,
                            fn=360,
                            base_color,
                            connector_color) {

  difference() {
    translate([0, 0, h / 2]) {
      if (is_undef(base_color)) {
        linear_extrude(height=h, center=true) {
          circle(r=d / 2, $fn=fn);
        }
      } else {
        color(base_color) {
          linear_extrude(height=h, center=true) {
            circle(r=d / 2, $fn=fn);
          }
        }
      }
    }
    offst = 0.5;
    translate([0, 0, connector_h / 2 - offst / 2]) {
      if (is_undef(connector_color)) {
        linear_extrude(height=connector_h + offst, center=true) {
          ring_2d(r=(connector_d / 2),
                  w=ring_w + tolerance,
                  fn=fn, outer=true);
        }
      } else {
        color(connector_color) {
          linear_extrude(height=connector_h + offst, center=true) {
            ring_2d(r=(connector_d / 2),
                    w=ring_w + tolerance,
                    fn=fn, outer=true);
          }
        }
      }
    }
    if (is_num(center_dia)) {
      height = h + offst;
      translate([0, 0, height / 2 - offst / 2]) {
        linear_extrude(height=height, center=true) {
          circle(r=center_dia / 2, $fn=fn);
        }
      }
    }
  }
}

module lower_ring_connector(d,
                            h,
                            connector_h,
                            connector_d,
                            center_dia,
                            ring_w=1,
                            tolerance=0.4,
                            fn=360) {

  lower_height = h - connector_h;

  difference() {
    union() {
      translate([0, 0, lower_height / 2]) {
        linear_extrude(height=lower_height, center=true) {
          circle(r=d / 2, $fn=fn);
        }
      }
      translate([0, 0, connector_h / 2 + lower_height]) {
        linear_extrude(height=connector_h, center=true) {
          ring_2d(r=connector_d / 2, w=ring_w, fn=fn, outer=true);
        }
      }
    }

    if (is_num(center_dia)) {
      offst = 0.5;
      height = h + offst;
      translate([0, 0, height / 2 - offst / 2]) {
        linear_extrude(height=height, center=true) {
          circle(r=center_dia / 2, $fn=fn);
        }
      }
    }
  }
}

module print_plate(d = 14,
                   h = 19,
                   connector_h = 10,
                   connector_d = 8,
                   center_dia = 2,
                   ring_w = 1.5,
                   step_offset = 5) {

  rotate([180, 0, 0]) {
    translate([d / 2 + step_offset, 0, -h]) {
      color("lightsteelblue") {
        upper_ring_connector(d=d,
                             h=h,
                             connector_h=connector_h,
                             ring_w=ring_w,
                             center_dia = 2,
                             connector_d=connector_d);
      }
    }
  }

  translate([-d / 2 - step_offset, 0, 0]) {
    lower_ring_connector(d=d,
                         h=h,
                         connector_h=connector_h,
                         ring_w=ring_w,
                         center_dia = 2,
                         connector_d=connector_d);
  }
}

module assembly_view(d = 14,
                     h = 19,
                     connector_h = 10,
                     connector_d = 8,
                     center_dia = 2,
                     ring_w = 1.5,
                     animation_z_offset = 5) {

  end_h = h + animation_z_offset;
  base_h = h - connector_h;
  z_offst = $t >= 0.7 ? base_h : end_h + ((base_h - end_h) * $t);

  lower_ring_connector(d=d,
                       h=h,
                       connector_h=connector_h,
                       ring_w=ring_w,
                       center_dia=center_dia,
                       connector_d=connector_d);

  translate([0, 0, z_offst]) {
    upper_ring_connector(d=d,
                         h=h,
                         connector_h=connector_h,
                         ring_w=ring_w,
                         center_dia=center_dia,
                         connector_d=connector_d,
                         base_color=[1, 0, 0, 0.2],
                         connector_color="green");
  }
}

union() {
  print_plate(step_offset=10);
  // assembly_view(animation_z_offset = 5);
}