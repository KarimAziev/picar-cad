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

rear_wheel_hub_rad = wheel_rear_shaft_outer_dia / 2;

module rear_wheel(w=wheel_w,
                  d=wheel_dia,
                  thickness=wheel_thickness,
                  rim_h=wheel_rim_h,
                  rim_w=wheel_rim_w,
                  rim_bend=wheel_rim_bend,
                  shaft_offset=wheel_rear_shaft_protrusion_height,
                  spokes=wheel_rear_spokes_count,
                  spoke_w=wheel_rear_wheel_spoke_w,
                  shaft_hole_d=wheel_rear_shaft_inner_dia,
                  shaft_d=wheel_rear_shaft_outer_dia,
                  shaft_hole_height=wheel_rear_motor_shaft_height) {

  rear_hub_r = shaft_d / 2;

  inner_d = wheel_inner_d(d, rim_h);
  shaft_full_h = w + shaft_offset;
  shaft_top_z =  shaft_full_h - w / 2;

  difference() {
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
        linear_extrude(height=shaft_full_h,
                       center=false) {
          circle(r=rear_hub_r);
        }
      }

      wheel(d=d,
            w=w,
            thickness=thickness,
            rim_h=rim_h,
            rim_w=rim_w,
            rim_bend=rim_bend);
    }
    translate([0, 0, shaft_top_z -
               (shaft_hole_height + 0.4)]) {
      notched_circle(d=shaft_hole_d,
                     h=shaft_hole_height + 0.8,
                     cutout_w=wheel_rear_shaft_flat_len,
                     x_cutouts_n=wheel_rear_shaft_flat_count,
                     center=false);
    }

    // a small hole to better visually indicate the flat part
    if (wheel_rear_shaft_flat_len <= 2
        && wheel_rear_shaft_flat_count <= 1) {
      hole_h = 2;
      square_center_x =
        notched_circle_square_center_x(r=shaft_hole_d / 2,
                                       cutout_w=wheel_rear_shaft_flat_len);

      translate([square_center_x + 0.4, 0, shaft_top_z
                 - hole_h / 2]) {
        linear_extrude(height=hole_h, center=false) {
          square([1, wheel_rear_shaft_flat_len + 0.4], center=true);
        }
      }
    }
  }
}

module shaft_3d(h=wheel_w + wheel_rear_shaft_protrusion_height,
                rear_hub_r=rear_wheel_hub_rad,
                shaft_hole_height=wheel_rear_motor_shaft_height,
                inner_d=wheel_rear_shaft_inner_dia) {

  difference() {
    linear_extrude(height=h, center=false) {
      circle(r=rear_hub_r);
    }
    translate([0, 0, h - shaft_hole_height]) {
      notched_circle(d=inner_d,
                     h=shaft_hole_height + 0.4,
                     cutout_w=wheel_rear_shaft_flat_len,
                     x_cutouts_n=wheel_rear_shaft_flat_count);
    }
  }
}

module wheel_blades(d=wheel_dia - wheel_rim_h,
                    thickness=wheel_thickness,
                    rear_hub_r=rear_wheel_hub_rad,
                    spokes=wheel_rear_spokes_count,
                    spoke_w=wheel_rear_wheel_spoke_w) {
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
    linear_extrude(height=spoke_w,
                   center=true,
                   convexity=2) {
      ring_2d(d=d + thickness, w=thickness);
    }
  }
}

module spoke(w=10,
             h=15,
             thickness=1,
             top_coef=2.5,
             fn=360) {
  spoke_top = w / top_coef;
  half_of_h = h / 2;
  half_of_w = w / 2;
  double_h = h * 2;
  double_w = w * 2;
  inner_w = w / 4;
  translate([-half_of_w, -half_of_h, 0]) {
    union() {
      linear_extrude(height=thickness) {
        intersection() {
          trapezoid(b=w, h=h, t=spoke_top, center=false);
          translate([w / 2, 0, 0]) {
            circle(r=h, $fn=fn);
          }
        }
      }
      hull() {
        translate([half_of_w - (inner_w / 2), 0, 0]) {
          linear_extrude(height=thickness) {
            intersection() {
              trapezoid(b=inner_w, h=h, t=((inner_w / 2) / top_coef),
                        center=false);
              translate([inner_w / 2, 0, 0]) {
                circle(r=h, $fn=fn);
              }
            }
          }
        }

        translate([half_of_w + thickness / 4, w, 0]) {
          rotate([180, 90, 0]) {
            linear_extrude(height=thickness / 2) {
              translate([0, w]) {
                difference() {
                  trapezoid(b=w, h=double_h,
                            t=double_w / top_coef,
                            center=true);
                  translate([0, -h]) {
                    square([double_w, double_h]);
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

module rear_wheel_animated(show_tire=true) {
  rotate([0, 0, -360 * $t]) {
    color(jet_black) {
      rear_wheel();
    }
    if (show_tire) {
      color(black_1) {
        tire();
      }
    }
  }
}

module rear_wheel_shaft_probes(from=3.0,
                               to=3.2,
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
  // rear_wheel_animated(show_tire=true);
  rear_wheel();
  // rear_wheel_shaft_probes();
}
