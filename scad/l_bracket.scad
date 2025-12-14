/**
 * Module: A customizable L-shaped bracket
 *
 * Generates a customizable L-shaped bracket consisting of two main plates:
 * - A horizontal base plate (lying in the XY plane).
 * - A vertical back plate (rotated and attached at a right angle along the Y axis).
 *
 * This module allows flexible extension via child modules for dynamic geometry
 * manipulation such as adding holes, cutouts, or additional features. Child nodes
 * can be assigned to modify either the horizontal or vertical part of the bracket,
 * using one of three supported modification modes:
 *
 * Supported Modes for children_modes:
 * -----------------------------------
 * - "union"        : Adds geometry outside the base shape (e.g., structural additions).
 * - "union_inner"  : Adds geometry within the base shape (e.g., extruded features).
 * - "difference"   : Removes geometry from the base shape (e.g., cutouts or holes).
 *
 * Each child is attached using a tuple: ["<mode>", "<part>"], where:
 * - <mode> is one of the three modes above.
 * - <part> is either "horizontal" or "vertical" to indicate which plate to modify.
 *
 * Parameters:
 * -----------
 * @param size                [x, y, z] - Overall dimensions of the bracket in 3D space.
 *                               x: width along X-axis (shared by both vetical and horizontal plates).
 *                               y: depth along Y-axis (horizontal plate).
 *                               z: height of vertical plate.
 *
 * @param thickness           Numeric - Thickness of the horizontal base plate.
 *
 * @param vertical_thickness  Optional numeric - Thickness of vertical plate.
 *                               Defaults to `thickness` if not provided.
 *
 * @param children_modes      Array of tuples - Defines how child modules modify the part.
 *                               Example: [["union", "horizontal"], ["difference", "vertical"]]
 *
 * @param bracket_color       Color value - Applied to both the horizontal and vertical plates.
 *
 * @param center              Boolean - If true, centers the whole bracket at the origin.
 *                               If false, bracket is placed relative to positive coordinates.
 *
 * @param y_r                 Optional numeric - Corner radius for the horizontal plate.
 *
 * @param z_r                 Optional numeric - Corner radius for the vertical plate.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

use <lib/functions.scad>
use <lib/shapes2d.scad>

module l_bracket(size,
                 thickness=1,
                 vertical_thickness,
                 children_modes=[],
                 bracket_color,
                 center=true,
                 convexity,
                 rotation=90,
                 y_r=undef,
                 z_r=undef) {
  x = size[0];
  y = size[1];
  z = size[2];

  ur = (y_r == undef) ? 0 : y_r;
  lr = (z_r == undef) ? 0 : z_r;
  vertical_thickness = is_undef(vertical_thickness)
    ? thickness
    : vertical_thickness;

  function children_for(mode, target) =
    [for (i = [0:len(children_modes) - 1])
        if (children_modes[i][0] == mode
            && children_modes[i][1] == target) i];

  horizontal_children_union_outer = children_for("union", "horizontal");
  horizontal_children_union_inner = children_for("union_inner", "horizontal");
  horizontal_children_difference = children_for("difference", "horizontal");
  horizontal_children_outer_difference = children_for("difference_outer", "horizontal");

  vertical_children_union_outer = children_for("union", "vertical");
  vertical_children_union_inner = children_for("union_inner", "vertical");
  vertical_children_difference = children_for("difference", "vertical");
  vertical_children_outer_difference = children_for("difference_outer", "vertical");

  translate([center ? 0 : x / 2, center
             ? 0
             : y / 2 + vertical_thickness / 2,
             center ? 0 : thickness / 2]) {
    union() {
      // Horizontal plate (extruded in the XY plane)
      difference() {
        union() {
          color(bracket_color, alpha=1) {
            linear_extrude(height=thickness,
                           center=true,
                           convexity=convexity) {
              difference() {
                union() {
                  rounded_rect_two([x, y], center=true, r=ur);

                  if (non_empty(horizontal_children_union_inner)) {
                    for (i = horizontal_children_union_inner) {
                      if ($children > i) {
                        children(i);
                      }
                    }
                  }
                }
                if (non_empty(horizontal_children_difference)) {
                  for (i = horizontal_children_difference) {
                    if ($children > i) {
                      children(i);
                    }
                  }
                }
              }
            }
          }
          if (non_empty(horizontal_children_union_outer)) {
            for (i = horizontal_children_union_outer) {
              if ($children > i) {
                children(i);
              }
            }
          }
        }
        if (non_empty(horizontal_children_outer_difference)) {
          for (i = horizontal_children_outer_difference) {
            if ($children > i) {
              children(i);
            }
          }
        }
      }

      // Vertical plate attached along the edge
      translate([0,
                 -y / 2,
                 z / 2 - thickness / 2]) {
        rotate([rotation, 0, 0]) {
          difference() {
            union() {
              color(bracket_color, alpha=1) {
                linear_extrude(height=vertical_thickness,
                               center=true,
                               convexity=convexity) {
                  difference() {
                    union() {
                      rounded_rect_two([x, z], center=true, r=lr);
                      if (non_empty(vertical_children_union_inner)) {
                        for (i = vertical_children_union_inner) {
                          if ($children > i) {
                            children(i);
                          }
                        }
                      }
                    }

                    if (non_empty(vertical_children_difference)) {
                      for (i = vertical_children_difference) {
                        if ($children > i) {
                          children(i);
                        }
                      }
                    }
                  }
                }
              }
              if (non_empty(vertical_children_union_outer)) {
                for (i = vertical_children_union_outer) {
                  if ($children > i) {
                    children(i);
                  }
                }
              }
            }
            if (non_empty(vertical_children_outer_difference)) {
              for (i = vertical_children_outer_difference) {
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
}
