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

function calculate_params_from_dia(d=bracket_bearing_outer_d, center_dia, tolerance=ring_connector_tolerance) =
  let (center_d = is_num(center_dia) ? max(center_dia, 0.3 * d) : 0.3 * d,
       ring_w = ((d - center_d) / 4) - tolerance * 2,
       connector_d = center_d + ring_w * 4)
  [connector_d, ring_w, tolerance];

module upper_ring_connector(d=bracket_bearing_outer_d,
                            h=knuckle_bracket_connector_height,
                            connector_h=rack_bracket_connector_h,
                            center_dia,
                            tolerance=ring_connector_tolerance,
                            fn=360,
                            base_color,
                            connector_color,
                            center=true) {
  params = calculate_params_from_dia(d=d, center_dia=center_dia, tolerance=tolerance);
  connector_d = params[0];
  ring_w = params[1];

  difference() {
    translate([0, 0, h / 2]) {
      if (is_undef(base_color)) {
        linear_extrude(height=h, center=center) {
          circle(r=d / 2, $fn=fn);
        }
      } else {
        color(base_color) {
          linear_extrude(height=h, center=center) {
            circle(r=d / 2, $fn=fn);
          }
        }
      }
    }
    offst = 0.5;
    translate([0, 0, connector_h / 2 - offst / 2]) {
      if (is_undef(connector_color)) {
        linear_extrude(height=connector_h + offst, center=center) {
          ring_2d(r=(connector_d / 2) - tolerance,
                  w=ring_w + tolerance,
                  fn=fn, outer=true);
        }
      } else {
        color(connector_color) {
          linear_extrude(height=connector_h + offst, center=center) {
            ring_2d(r=(connector_d / 2) - tolerance,
                    w=ring_w + tolerance,
                    fn=fn, outer=true);
          }
        }
      }
    }
    if (is_num(center_dia)) {
      height = h + offst;
      translate([0, 0, height / 2 - offst / 2]) {
        linear_extrude(height=height, center=center) {
          circle(r=center_dia / 2, $fn=fn);
        }
      }
    }
  }
}

module lower_ring_connector(d=bracket_bearing_outer_d,
                            h=knuckle_bracket_connector_height,
                            connector_h=rack_bracket_connector_h,
                            center_dia,
                            center=true,
                            tolerance=ring_connector_tolerance,
                            fn=360) {
  params = calculate_params_from_dia(d=d, center_dia=center_dia, tolerance=tolerance);
  connector_d = params[0];
  connector_rad = (connector_d / 2);
  ring_w = max(params[1] - tolerance, 0.5);

  lower_height = h - connector_h;

  difference() {
    union() {
      translate([0, 0, lower_height / 2]) {
        linear_extrude(height=lower_height, center=center) {
          circle(r=d / 2, $fn=fn);
        }
      }
      translate([0, 0, connector_h / 2 + lower_height]) {
        linear_extrude(height=connector_h, center=center) {
          ring_2d(r=connector_rad, w=ring_w, fn=fn, outer=true);
        }
      }
    }

    if (is_num(center_dia)) {
      offst = 0.5;
      height = h + offst;
      translate([0, 0, height / 2 - offst / 2]) {
        linear_extrude(height=height, center=center) {
          circle(r=center_dia / 2, $fn=fn);
        }
      }
    }
  }
}

module print_plate(d=bracket_bearing_outer_d,
                   h=knuckle_bracket_connector_height,
                   connector_h=rack_bracket_connector_h,
                   center_dia=m2_hole_dia,
                   step_offset = 5) {

  rotate([180, 0, 0]) {
    translate([d / 2 + step_offset, 0, -h]) {
      color("lightsteelblue") {
        upper_ring_connector(d=d,
                             h=h,
                             connector_h=connector_h,
                             center_dia=center_dia);
      }
    }
  }

  translate([-d / 2 - step_offset, 0, 0]) {
    lower_ring_connector(d=d,
                         h=h,
                         connector_h=connector_h,
                         center_dia=center_dia);
  }
}

module assembly_view(d=bracket_bearing_outer_d,
                     h=knuckle_bracket_connector_height,
                     connector_h=rack_bracket_connector_h,
                     center_dia=m2_hole_dia,
                     animation_z_offset = 5) {

  end_h = h + animation_z_offset;
  base_h = h - connector_h;
  z_offst = $t >= 0.7 ? base_h : end_h + ((base_h - end_h) * $t);

  lower_ring_connector(d=d,
                       h=h,
                       connector_h=connector_h,
                       center_dia=center_dia);

  translate([0, 0, z_offst]) {
    upper_ring_connector(d=d,
                         h=h,
                         connector_h=connector_h,
                         center_dia=center_dia,
                         base_color=[1, 0, 0, 0.2]);
  }
}

union() {
  print_plate(step_offset=2);
  // assembly_view(animation_z_offset = 5);
}