/**
 * Module: Front and rear wheels without tires.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../parameters.scad>
use <../util.scad>

module star_2d(n = 5, r_outer = 20, r_inner = 10) {
  pts = [for (i = [0 : 2*n - 1])
      let (angle = 360 / (2*n) * i,
           r = (i % 2 == 0) ? r_outer : r_inner)
        [r * cos(angle), r * sin(angle)]];
  polygon(points = pts);
}

module star_3d(n=5, r_outer=20, r_inner=10, h=2) {
  linear_extrude(height=h, center=false) {
    star_2d(n=n, r_outer=r_outer, r_inner=r_inner);
  }
}

module wheel_blades(d=55, w=25, wheel_shaft_offset=1.2, hub_r=4.2, steps=10, spokes=5, spoke_w = 1.2, rear=true) {
  outradius = d / 2;
  inradius = outradius - 0.5;

  function get_angle(point, steps) = point * (360/steps);
  function get_x(point, steps) = outradius * cos(get_angle(point, steps));
  function get_y(point, steps) = outradius * sin(get_angle(point, steps));

  pts = [for (i=[0:1:steps]) [get_x(i, steps), get_y(i, steps)]];

  translate([0, 0, w * 0.5]) {
    linear_extrude(height=w / 2) {
      difference() {
        union() {
          circle(r=hub_r);

          for (i=[0:1:spokes-1]) {
            angle = i * (360 / spokes);

            rotate([0, 0, angle])
              translate([0, inradius/2, 0]) {
              polygon(points=[[-spoke_w/2, -inradius/2],
                              [spoke_w/2, -inradius/2],
                              [0, inradius/2]]);
            }
          }
        }
        shaft();
      }
    }
    if (rear) {
      shaft_offset(w + wheel_shaft_offset, hub_rad=hub_r);
    } else {
      translate([0, 0, -2]) {
        linear_extrude(height=w / 2 + wheel_shaft_offset) {
          difference() {
            circle(r=hub_r, $fn=360);
            circle(r=hub_r / 2, $fn=360);
          }
        }
      }
    }
  }
}

module shaft_offset(h, hub_rad) {
  translate([0, 0, -2]) {
    linear_extrude(height=h) {
      difference() {
        circle(r=hub_rad);
        shaft();
      }
    }
  }
}

module shaft(d=5.4, solid_d=3.7, tolerance=0.3) {
  shaftradius = d / 2;
  solidwidth = solid_d / 2;

  sr = shaftradius + tolerance / 2;
  sw = solidwidth + tolerance / 2;

  difference() {
    translate([0, 0, -2]) {
      circle(r=sr);
    }
    translate([0, sr * 2 - sw / 2, 0]) {
      square(sr * 2, center=true);
    }
    translate([0, -sr * 2 + sw / 2, 0]) {
      square(sr * 2, center=true);
    }
  }
}

module wheel(w = 22, d = 52, is_rear=true, thickness = 1.5, rim_h = 1, rim_w = 0.4, rim_bend = 0.5, spokes=5) {
  inner_d = d - rim_h;
  union() {
    difference() {
      union() {
        linear_extrude(height = w, center = true) {
          circle(r = inner_d / 2, $fn = 360);
        }

        z_offset_parts = [w * 0.5, rim_w * 0.5];
        for (i = [0 : 1]) {
          z = i == 0 ? z_offset_parts[0] + z_offset_parts[1] : -z_offset_parts[0] - z_offset_parts[1];
          translate([0, 0, z]) {
            difference() {
              linear_extrude(height = rim_w, center = true) {
                circle(r = inner_d / 2 + rim_h, $fn = 360);
              }

              linear_extrude(height = rim_w + 1, center = true) {
                circle(r = inner_d / 2 + rim_h - rim_bend, $fn = 360);
              }
            }
          }
        }
      }

      linear_extrude(height = w + 1, center = true) {
        circle(r = inner_d / 2 - thickness, $fn = 360);
      }
    }
    translate([0, 0, -w]) {
      wheel_blades(d=inner_d, w=w, rear=is_rear, spokes=spokes);
      translate([0, 0, w * 0.5]) {
        rotate([0, 0, 17]) {
          if (is_rear) {
            star_3d(r_outer=inner_d / 2, n=spokes);
          } else {
            difference() {
              star_3d(r_outer=inner_d / 2, n=spokes);
              front_shaft();
              cylinder(h=w, r=4, center=true);
            }
          }
        }
      }
    }
  }
}

module front_wheel(w = 22, d = 52,
                   thickness = 1.5,
                   rim_h = 1,
                   rim_w = 0.4,
                   rim_bend = 0.5) {
  wheel(w=w,d=d,
        thickness=thickness,
        rim_h=rim_h,
        rim_w=rim_w,
        rim_bend=rim_bend,
        is_rear=false);
}

module front_shaft(shaft_d=5.4, solid_d=3.7, tolerance=0.3) {
  translate([0, 0, -2]) {
    circle(r=shaft_d + tolerance * 0.5);
  }
}

union() {
  color("white") {
    wheel(w=24);
  }
}
