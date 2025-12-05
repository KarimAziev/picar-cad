/**
 * Module: Screw Terminal
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
use <../lib/shapes3d.scad>
use <../lib/trapezoids.scad>
use <../lib/placement.scad>

function screw_terminal_width(base_w, pitch, contacts_n, contact_w, wall_thickness)=
  let (needed_contacts_span = (contacts_n <= 1)
       ? contact_w
       : (contact_w + (contacts_n - 1) * pitch),

       side_margin = max(0.8, wall_thickness))
  is_undef(base_w)
  ? (needed_contacts_span + 2 * side_margin)
  : base_w;

module screw_terminal(base_w = undef,            // overall base width (optional)
                      base_h = 6.8,              // base height (Z)
                      thickness = 7.6,           // body depth (Y)
                      top_l = 5.50,              // top trapezoid top side length
                      top_h = 3.2,               // top trapezoid height
                      contacts_n = 2,            // number of contact boxes
                      contact_w = 3.5,           // contact box width (X)
                      contact_h = 4.47,          // contact box height (Z)
                      pitch = 4.5,              // center-to-center spacing (X)
                      colr = medium_blue_2,
                      pin_thickness = 0.4,       // lower thin pin cross/width
                      pin_h = 3.9,               // lower thin pin height
                      wall_thickness = 0.6,  // wall offset from base top
                      center=true,
                      isosceles_trapezoid=false) {

  effective_base_w = screw_terminal_width(base_w,
                                          pitch=pitch,
                                          contacts_n=contacts_n,
                                          contact_w=contact_w,
                                          wall_thickness=wall_thickness);

  x_start = -((contacts_n - 1) * pitch) / 2;

  translate([center ? 0 : effective_base_w / 2, center ? 0 : thickness / 2, 0]) {
    difference() {

      union() {
        color(colr, alpha=1) {
          difference() {
            union() {
              cube_3d(size = [effective_base_w, thickness, base_h]);

              if (!isosceles_trapezoid) {
                translate([0, -thickness / 4, 0]) {
                  cube_3d(size = [effective_base_w, thickness / 2, base_h + top_h]);
                }
              }

              translate([-effective_base_w / 2, 0, top_h / 2 + base_h]) {
                rotate([90, 0, 90]) {
                  linear_extrude(height = effective_base_w, center = false) {
                    trapezoid_rounded_top(t = top_l,
                                          b = thickness,
                                          h = top_h,
                                          center = true);
                  }
                }
              }
            }
            for (i = [0 : contacts_n - 1]) {
              cx = x_start + i * pitch;

              translate([cx, 0, wall_thickness]) {

                cylinder(h = base_h + top_h, d = contact_w, $fn = 30);
              }
            }
          }
        }

        color(metallic_silver_6, alpha = 1) {
          for (i = [0 : contacts_n - 1]) {
            cx = x_start + i * pitch;

            translate([cx, 0.01, wall_thickness]) {
              cube_3d([contact_w, thickness, contact_h]);
            }

            translate([cx, 0, wall_thickness]) {
              difference() {
                cylinder(h = base_h + top_h / 2, d = contact_w, $fn = 30);
                rotate([0, 0, i * 30]) {
                  translate([0, 0, base_h + top_h / 2 - top_h + 0.1]) {
                    cube_3d([0.4, contact_w, top_h]);
                  }
                }
              }
            }

            translate([cx - pin_thickness / 2, 0 - pin_thickness / 2,
                       -pin_h + wall_thickness]) {
              cube_3d([pin_thickness, pin_thickness, pin_h], center = false);
            }
          }
        }
      }

      for (i = [0 : contacts_n - 1]) {
        cx = x_start + i * pitch;

        translate([cx, 0.1, wall_thickness]) {
          cube_3d([contact_w, thickness, contact_h / 2]);
        }
      }
    }
  }
}

screw_terminal(contacts_n=2, center=false);
