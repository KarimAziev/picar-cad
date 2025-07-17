/**
 * Module: Rear wheel without tires.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../parameters.scad>
use <../util.scad>
use <wheel.scad>
use <tire.scad>

rear_wheel_hub_rad     = truncate(wheel_shaft_d * 0.78);
rear_wheel_hub_solid_d = truncate(rear_wheel_hub_rad * 0.9);

module rear_wheel(w=wheel_w,
                  d=wheel_dia,
                  thickness=wheel_thickness,
                  rim_h=wheel_rim_h,
                  rim_w=wheel_rim_w,
                  rim_bend=wheel_rim_bend,
                  shaft_offset=wheel_shaft_offset,
                  rear_hub_r=rear_wheel_hub_rad,
                  spokes=wheel_spokes,
                  spoke_w=wheel_spoke_w,
                  hub_solid_d=rear_wheel_hub_solid_d,
                  shaft_d=wheel_shaft_d,
                  tolerance=wheel_tolerance) {

  inner_d = d - rim_h;
  union() {
    wheel(d=d,
          w=w, thickness=thickness,
          rim_h=rim_h,
          rim_w=rim_w,
          rim_bend=rim_bend);

    translate([0, 0, -w * 0.5]) {
      rotation_angle = 90;
      rotate([0, 0, rotation_angle]) {
        star_out_rad = inner_d / 2;
        star_inner_rad = star_out_rad * 0.25;
        wheel_blades(d=inner_d,
                     spokes=spokes,
                     shaft_offset=shaft_offset,
                     rear_hub_r=rear_hub_r,
                     spoke_w=spoke_w);
      }
    }
    shaft_3d(h=w + shaft_offset,
             rear_hub_r=rear_hub_r,
             solid_d=hub_solid_d,
             d=shaft_d);
  }
}

module wheel_blades(d=wheel_dia - wheel_rim_h,
                    shaft_offset=wheel_shaft_offset,
                    rear_hub_r=rear_wheel_hub_rad,
                    spokes=wheel_spokes,
                    spoke_w=wheel_spoke_w) {
  outradius = d / 2;
  union() {
    translate([0, 0, spoke_w / 2]) {
      linear_extrude(height=spoke_w, center=true) {
        circle(r=rear_hub_r);
      }
    }

    for (i=[0:1:spokes-1]) {
      angle = i * (360 / spokes);

      rotate([0, 0, angle]) {
        translate([0, outradius/2, 0]) {
          spoke(h=outradius / 2 + rear_hub_r * 2, w=spoke_w);
        }
      }
    }
  }
}

module shaft_3d(h,
                rear_hub_r=rear_wheel_hub_rad,
                d=wheel_shaft_d,
                solid_d=rear_wheel_hub_solid_d,
                tolerance=wheel_tolerance) {
  translate([0, 0, h * 0.5]) {
    linear_extrude(height=h, center=true) {
      difference() {
        circle(r=rear_hub_r);
        shaft_2d(d=d, solid_d=solid_d, tolerance=tolerance);
      }
    }
  }
}

module shaft_2d(d=wheel_shaft_d,
                solid_d=rear_wheel_hub_solid_d,
                tolerance=wheel_tolerance) {
  tol = tolerance / 2;
  shaft_rad = d / 2 + tol;
  solid_w = solid_d / 2 + tol;

  difference() {
    circle(r=shaft_rad);
    translate([0, shaft_rad * 2 - solid_w / 2, 0]) {
      square(shaft_rad * 2, center=true);
    }
    translate([0, -shaft_rad * 2 + solid_w / 2, 0]) {
      square(shaft_rad * 2, center=true);
    }
  }
}

module spoke(w=10, h=15, thickness=1, top_coef=2.5) {
  translate([-w / 2, -h / 2, 0]) {

    union() {
      linear_extrude(height = thickness) {
        trapezoid(b=w, h=h, t=w / top_coef);
      }
      hull() {
        inner_w = w / 4;
        translate([(w / 2) - (inner_w / 2), 0, 0]) {
          linear_extrude(height = thickness) {
            trapezoid(b=inner_w, h=h, t=((inner_w / 2) / top_coef));
          }
        }

        translate([w / 2 + thickness / 4, (w * 2) * 0.5, 0]) {
          rotate([180, 90, 0]) {
            difference() {
              linear_extrude(height = thickness / 2) {
                translate([0, w]) {
                  difference() {
                    trapezoid(b=w, h=h * 2, t=(w * 2) / top_coef, center=true);
                    translate([0, -h]) {
                      square([w * 2, h * 2]);
                    }
                    translate([-w, 0]) {
                      square([w, h]);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

module rear_wheel_animated() {
  rotate([0, 0, -360 * $t]) {
    color("#343434") {
      rear_wheel();
    }
    color("white") {
      tire();
    }
  }
}

union() {
  rear_wheel_animated();
}
