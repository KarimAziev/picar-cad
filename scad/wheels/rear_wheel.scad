/**
 * Module: Rear wheel without tires.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../parameters.scad>
include <../colors.scad>
use <../util.scad>
use <wheel.scad>
use <tire.scad>

rear_wheel_hub_rad = truncate(rear_wheel_shaft_outer_dia * 0.78);

module rear_wheel(w=wheel_w,
                  d=wheel_dia,
                  thickness=wheel_thickness,
                  rim_h=wheel_rim_h,
                  rim_w=wheel_rim_w,
                  rim_bend=wheel_rim_bend,
                  shaft_offset=wheel_shaft_offset,
                  rear_hub_r=rear_wheel_hub_rad,
                  spokes=rear_wheel_spokes_count,
                  spoke_w=rear_wheel_spoke_w,
                  shaft_d=rear_wheel_shaft_outer_dia,
                  inner_shaft_d=rear_wheel_shaft_inner_dia) {

  inner_d = wheel_inner_d(d, rim_h);
  union() {
    translate([0, 0, -(w + rim_w * 2) * 0.5]) {
      rotation_angle = 90;
      rotate([0, 0, rotation_angle]) {
        wheel_blades(d=inner_d,
                     spokes=spokes,
                     thickness=thickness,
                     rear_hub_r=rear_hub_r,
                     spoke_w=spoke_w);
      }
    }

    translate([0, 0, -w / 2]) {
      shaft_3d(h=w + shaft_offset,
               rear_hub_r=rear_hub_r,
               inner_d=inner_shaft_d);
    }
    wheel(d=d,
          w=w, thickness=thickness,
          rim_h=rim_h,
          rim_w=rim_w,
          rim_bend=rim_bend);
  }
}

module wheel_blades(d=wheel_dia - wheel_rim_h,
                    thickness=wheel_thickness,
                    rear_hub_r=rear_wheel_hub_rad,
                    spokes=rear_wheel_spokes_count,
                    spoke_w=rear_wheel_spoke_w) {
  outradius = d / 2;

  difference() {
    union() {
      translate([0, 0, spoke_w / 2]) {
        linear_extrude(height=spoke_w, center=true) {
          circle(r=rear_hub_r);
        }
      }

      for (i=[0:1:spokes-1]) {
        angle = i * (360 / spokes);

        rotate([0, 0, angle]) {
          translate([0, outradius / 2, 0]) {
            spoke(h=outradius, w=spoke_w);
          }
        }
      }
    }
    linear_extrude(height=spoke_w, center=true) {
      ring_2d(d=d + thickness, w=thickness);
    }
  }
}

module shaft_3d(h,
                rear_hub_r=rear_wheel_hub_rad,
                inner_d=rear_wheel_shaft_inner_dia) {

  difference() {
    linear_extrude(height=h, center=false) {
      circle(r=rear_hub_r);
    }
    translate([0, 0, h - rear_wheel_motor_shaft_height]) {
      notched_circle(d=inner_d,
                     h=rear_wheel_motor_shaft_height + 0.1,
                     cutout_w=rear_wheel_shaft_flat_len,
                     x_cutouts_n=rear_wheel_shaft_flat_count);
    }
  }
}

module spoke(w=10, h=15, thickness=1, top_coef=2.5) {
  translate([-w / 2, -h / 2, 0]) {
    union() {
      linear_extrude(height=thickness) {
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

module rear_wheel_animated(show_tire=true) {
  rotate([0, 0, -360 * $t]) {
    color(jet_black) {
      rear_wheel();
    }
    if (show_tire) {
      color("white") {
        tire();
      }
    }
  }
}

module rear_wheel_shaft_probes(from=3.1,
                               to=3.5,
                               step=0.1) {
  vals = number_sequence(from, to, step);
  offst = (rear_wheel_hub_rad * 2) + 2;
  plate_height = 2;

  union() {
    for (i = [0:len(vals) - 1]) {
      translate([i * offst, 0, 0]) {
        shaft_3d(10, inner_d=vals[i]);
      }
    }
  }

  translate([-offst / 2, -offst / 2, -plate_height]) {
    linear_extrude(height = plate_height, center=false) {
      square([offst * len(vals), offst]);
    }
  }
}

union() {
  rear_wheel_animated(show_tire=false);
}
