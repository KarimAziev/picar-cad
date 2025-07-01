/**
 * Module: Front and rear wheels without tires.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <parameters.scad>
use <util.scad>

wheel_dia          = 52;
wheel_w            = 22;
wheel_thickness    = 1.5;
wheel_rim_h        = 1.6;
wheel_rim_w        =  1;
wheel_rim_bend     = 0.8;
wheel_shaft_offset = 1.2;
wheel_spokes       =  5;
wheel_spoke_w      = 2.2;
wheel_shaft_d      = 5.4;
wheel_hub_rad      = truncate(wheel_shaft_d * 0.78); // 4.2
wheel_hub_solid_d  = truncate(wheel_hub_rad * 0.9); // 3.7
wheel_tolerance    = 0.3;

module wheel(w=wheel_w,
             d=wheel_dia,
             thickness=wheel_thickness,
             rim_h=wheel_rim_h,
             rim_w=wheel_rim_w,
             rim_bend=wheel_rim_bend,
             shaft_offset=wheel_shaft_offset,
             hub_r=wheel_hub_rad,
             spokes=wheel_spokes,
             spoke_w=wheel_spoke_w,
             hub_solid_d=wheel_hub_solid_d,
             shaft_d=wheel_shaft_d,
             tolerance=wheel_tolerance,
             is_rear=true) {

  inner_d = d - rim_h;
  difference() {
    union() {
      difference() {
        union() {
          linear_extrude(height = w, center = true) {
            circle(r = inner_d / 2, $fn = 360);
          }

          z_offset_parts = [w * 0.5, rim_w * 0.5];
          for (i = [0 : 1]) {
            z = i == 0
              ? z_offset_parts[0] + z_offset_parts[1]
              : -z_offset_parts[0] - z_offset_parts[1];
            bend_z = i == 0 ? -1 : 1;
            translate([0, 0, z]) {
              rad = inner_d / 2 + rim_h;
              inner_rad = rad - rim_bend;

              difference() {
                linear_extrude(height = rim_w, center = true) {
                  circle(r = rad, $fn = 360);
                }

                translate([0, 0, bend_z]) {
                  linear_extrude(height = rim_w) {
                    w = rim_h - rim_bend;
                    ring_2d(r=inner_rad, w=w);
                  }
                }
              }
            }
          }
        }

        linear_extrude(height = w+thickness + rim_bend + rim_h, center = true) {
          circle(r = d / 2 - thickness, $fn = 360);
        }
      }
      translate([0, 0, -w]) {
        wheel_blades(d=inner_d,
                     w=w,
                     spokes=spokes,
                     shaft_offset=shaft_offset,
                     hub_r=hub_r,
                     spoke_w=spoke_w,
                     is_rear=is_rear,
                     hub_solid_d=hub_solid_d,
                     shaft_d=shaft_d);
        translate([0, 0, w * 0.5]) {
          rotation_angle = 90;
          rotate([0, 0, rotation_angle]) {
            star_out_rad = inner_d / 2;
            star_inner_rad = star_out_rad * 0.25;
            if (is_rear) {
              star_3d(r_outer=star_out_rad, n=spokes, r_inner=star_inner_rad);
            } else {
              difference() {
                star_3d(r_outer=star_out_rad, n=spokes, r_inner=star_inner_rad);
                linear_extrude(w, center=true) {
                  circle(r=shaft_d / 2 + tolerance * 0.5);
                }
              }
            }
          }
        }
      }
    }
  }
}

module wheel_blades(d=wheel_dia - wheel_rim_h,
                    w=wheel_w,
                    shaft_offset=wheel_shaft_offset,
                    hub_r=wheel_hub_rad,
                    spokes=wheel_spokes,
                    spoke_w=wheel_spoke_w,
                    hub_solid_d=wheel_hub_solid_d,
                    shaft_d=wheel_shaft_d,
                    is_rear=true) {
  outradius = d / 2;
  inradius = outradius - 0.5;
  height = w / 2;

  translate([0, 0, w * 0.5]) {
    linear_extrude(height=height) {
      difference() {
        union() {
          circle(r=hub_r);

          for (i=[0:1:spokes-1]) {
            angle = i * (360 / spokes);

            rotate([0, 0, angle]) {
              translate([0, inradius/2, 0]) {
                polygon(points=[[-spoke_w/2, -inradius/2],
                                [spoke_w/2, -inradius/2],
                                [0, inradius/2]]);
              }
            }
          }
        }
        shaft_2d();
      }
    }
    if (is_rear) {
      shaft_3d(h=w+shaft_offset,
               hub_r=hub_r,
               solid_d=hub_solid_d,
               d=shaft_d);
    } else {
      linear_extrude(height=w / 2 + shaft_offset) {
        difference() {
          circle(r=hub_r, $fn=360);
          circle(r=hub_r / 2, $fn=360);
        }
      }
    }
  }
}

module front_and_rear_wheels(w=wheel_w,
                             d=wheel_dia,
                             thickness=wheel_thickness,
                             rim_h=wheel_rim_h,
                             rim_w=wheel_rim_w,
                             rim_bend=wheel_rim_bend,
                             shaft_offset=wheel_shaft_offset,
                             hub_r=wheel_hub_rad,
                             spokes=wheel_spokes,
                             spoke_w=wheel_spoke_w,
                             hub_solid_d=wheel_hub_solid_d,
                             tolerance=wheel_tolerance,
                             shaft_d=wheel_shaft_d,
                             y_distance=5,
                             x_distance=5,
                             front_n=1,
                             rear_n=1) {
  union() {
    if (front_n > 0) {
      for (i = [0:front_n - 1]) {
        y_offst = i == 0 ? 0 : (wheel_dia + y_distance) * i;
        translate([wheel_dia * 0.5 + x_distance, y_offst, 0]) {
          wheel(w=w,
                d=d,
                thickness=thickness,
                rim_h=rim_h,
                rim_w=rim_w,
                rim_bend=rim_bend,
                shaft_offset=shaft_offset,
                hub_r=hub_r,
                spokes=wheel_spokes,
                spoke_w = spoke_w,
                hub_solid_d=hub_solid_d,
                tolerance=tolerance,
                shaft_d=shaft_d,
                is_rear=false);
        }
      }
    }

    if (rear_n > 0) {
      for (i = [0:rear_n - 1]) {
        y_offst = i == 0 ? 0 : (wheel_dia + y_distance) * i;
        translate([-wheel_dia * 0.5 - x_distance, y_offst, 0]) {
          wheel(w = w,
                d = d,
                thickness = thickness,
                rim_h = rim_h,
                rim_w = rim_w,
                rim_bend = rim_bend,
                shaft_offset=shaft_offset,
                hub_r=hub_r,
                spokes=wheel_spokes,
                spoke_w = spoke_w,
                hub_solid_d=hub_solid_d,
                tolerance=tolerance,
                shaft_d=shaft_d,
                is_rear=true);
        }
      }
    }
  }
}

module shaft_3d(h,
                hub_r=wheel_hub_rad,
                d=wheel_shaft_d,
                solid_d=wheel_hub_solid_d,
                tolerance=wheel_tolerance,
                front_offset=0) {
  translate([0, 0, front_offset]) {
    linear_extrude(height=h) {
      difference() {
        circle(r=hub_r);
        shaft_2d(d=d, solid_d=solid_d, tolerance=tolerance);
      }
    }
  }
}

module shaft_2d(d=wheel_shaft_d,
                solid_d=wheel_hub_solid_d,
                tolerance=wheel_tolerance) {
  tol = tolerance / 2;
  shaft_rad = d / 2 + tol;
  solid_w = solid_d / 2 + tol;

  difference() {
    translate([0, 0, 0]) {
      circle(r=shaft_rad);
    }
    translate([0, shaft_rad * 2 - solid_w / 2, 0]) {
      square(shaft_rad * 2, center=true);
    }
    translate([0, -shaft_rad * 2 + solid_w / 2, 0]) {
      square(shaft_rad * 2, center=true);
    }
  }
}

front_and_rear_wheels(front_n=2, rear_n=2);
