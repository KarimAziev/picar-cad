/**
 * Module: Placeholder for Step Down Voltage Regulator (Polulu D24VXF5)
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../parameters.scad>
include <../colors.scad>

use <smd_chip.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/holes.scad>
use <../lib/transforms.scad>
use <screw_terminal.scad>

// [x, y, z, round_radius]
step_down_voltage_power_inductor_size                = [7.15, 7.4, 3.7, 0.8];
step_down_voltage_smd_chip_w                         = 5;
step_down_voltage_smd_chip_l                         = 3;
step_down_voltage_smd_chip_h                         = 1.55;
step_down_voltage_smd_chip_j_lead_l                  = 1;
step_down_voltage_power_regulator_y_distance         = 1.7;
step_down_voltage_screw_terminal_thickness           = 5.8;
step_down_voltage_screw_terminal_base_h              = 6.8;              // base height (Z)

step_down_voltage_screw_terminal_top_l               = 4.50;              // top trapezoid top side length
step_down_voltage_screw_terminal_top_h               = 3.2;               // top trapezoid height
step_down_voltage_screw_terminal_contacts_n          = 2;            // number of contact boxes
step_down_voltage_screw_terminal_contact_w           = 3.5;           // contact box width (X)
step_down_voltage_screw_terminal_contact_h           = 4.47;          // contact box height (Z)
step_down_voltage_screw_terminal_pitch               = 4.5;              // center-to-center spacing (X)
step_down_voltage_screw_terminal_colr                = medium_blue_2;
step_down_voltage_screw_terminal_pin_thickness       = 0.4;       // lower thin pin cross/width
step_down_voltage_screw_terminal_pin_h               = 3.9;               // lower thin pin height
step_down_voltage_screw_terminal_wall_thickness      = 0.6;  // wall offset from base top
step_down_voltage_screw_terminal_isosceles_trapezoid = true;

// [[wight, len, height, j-lead-len, [translate_x, translate_y, translate_z], [rotation_x, rotation_y, rotation_z]]..]
step_down_voltage_smd_chips_specs                    = [[4.6, 3.3, 1.58, 1, [-0.15, -9.0, 0], [0, 0, 0]],
                                                        [4.6, 3.2, 1.58, 1, [-0.9, -8.7, 0], [0, 0, 90]],
                                                        [4.6, 3.3, 1.58, 1, [-13.7, -8.7, 0], [0, 0, 0]],
                                                        [4.6, 3.3, 1.58, 1, [-3.50, -4.0, 0], [0, 0, 0]],];

// [[wight, len, height, j-lead-len, [translate_x, translate_y, translate_z], center_color]..]
step_down_voltage_surface_mount_chips_specs          = [[2.0, 3.3, 2.5, 0.9,
                                                         [-5.75, 3.2, 0], brown_2],
                                                        [1.95, 3.3, 2.5, 0.8,
                                                         [-3.6, 3.2, 0], brown_2],
                                                        [1.05, 1.75, 1.6, 0.2,
                                                         [-5.2, -3.8, 0], brown_2],
                                                        [1.05, 1.8, 1.6, 0.2,
                                                         [-6.7, -3.8, 0], matte_black],
                                                        [1.05, 1.8, 1.6, 0.2,
                                                         [-8.0, -4.3, 0], matte_black],
                                                        [1.05, 1.75, 1.6, 0.2,
                                                         [-7.0, -8.3, 0], brown_2],
                                                        [1.05, 1.75, 1.6, 0.2,
                                                         [14.54, -7.0, 0], brown_2],
                                                        [1.05, 1.75, 1.6, 0.2,
                                                         [14.72, 6.9, 0], brown_2],
                                                        [1.05, 1.75, 1.6, 0.2,
                                                         [-13.05, -1.2, 0], matte_black],
                                                        [1.05, 1.75, 1.6, 0.2,
                                                         [2.66, -1.2, 0], matte_black],
                                                        [1.35, 2.07, 2.1, 0.3,
                                                         [2.36, 6.0, 0], brown_2],
                                                        [1.35, 1.95, 2.1, 0.3,
                                                         [2.36, 2.9, 0], brown_2],
                                                        [1.45, 1.75, 1.8, 0.3,
                                                         [1.19, -1.1, 0], matte_black],
                                                        [1.85, 3.3, 2.6, 0.5,
                                                         [12.66, -1.78, 0], brown_2],
                                                        [1.85, 3.3, 2.5, 0.5,
                                                         [12.66, -6.45, 0], brown_2],
                                                        [3.3, 1.85, 2.5, 0.5,
                                                         [-9.96, -1.7, 0], brown_2],
                                                        [2.0, 1.45, 1.8, 0.5,
                                                         [-12.26, -3.7, 0], matte_black],
                                                        [1.8, 1.15, 1.6, 0.5,
                                                         [1.86, -3.4, 0], brown_2],
                                                        [1.8, 1.15, 1.6, 0.5,
                                                         [-2.86, -4.4, 0], matte_black],
                                                        [1.8, 1.10, 1.6, 0.5,
                                                         [2.8, 8.9, 0], brown_2],
                                                        [1.8, 1.10, 1.6, 0.5,
                                                         [-0.6, 6.7, 0], matte_black],
                                                        [1.60, 1.10, 1.6, 0.5,
                                                         [0.0, 2.1, 0], brown_2],
                                                        [1.60, 1.10, 1.6, 0.5,
                                                         [0.0, 5.1, 0], brown_2],
                                                        [1.70, 1.10, 1.6, 0.5,
                                                         [-5.3, 6.3, 0], matte_black],
                                                        [1.70, 1.10, 1.6, 0.5,
                                                         [-0.0, 3.5, 0], matte_black],
                                                        [1.70, 1.10, 1.6, 0.5,
                                                         [-6.0, -1.5, 0], brown_2],
                                                        [1.70, 1.10, 1.6, 0.5,
                                                         [-5.55, -0.2, 0], brown_2]];

module step_down_voltage_surface_mount_chip(spec) {
  let (w = spec[0],
       l=spec[1],
       h=spec[2],
       j_led_l=spec[3],
       translate_spec=is_undef(spec[4]) ? [0, 0, 0] : spec[4],
       r=0.1,
       color_spec=is_undef(spec[5]) ? brown_2 : spec[5]) {

    translate(translate_spec) {
      if (l > w) {
        let (inner_l = l - j_led_l * 2) {

          color(color_spec, alpha=1) {
            linear_extrude(height=h, center=false) {
              square(size=[w, inner_l], center=true);
            }
          }

          color(metallic_silver_1, alpha=1) {
            mirror_copy([0, 1, 0]) {
              translate([0, inner_l / 2 + j_led_l / 2, 0]) {
                linear_extrude(height=h, center=false) {
                  rounded_rect([w, j_led_l + r], center=true, r=r);
                }
              }
            }
          }
        }
      }  else {
        let (inner_w = w - (j_led_l * 2)) {
          color(color_spec, alpha=1) {
            linear_extrude(height=h, center=false) {
              square(size=[inner_w, l], center=true);
            }
          }

          color(metallic_silver_1, alpha=1) {
            mirror_copy([1, 0, 0]) {
              translate([inner_w / 2 + j_led_l / 2, 0, 0]) {
                linear_extrude(height=h, center=false) {
                  rounded_rect([j_led_l + r, l], center=true, r=r);
                }
              }
            }
          }
        }
      }
    }
  }
}

module step_down_voltage_standoffs(standoff_h=step_down_voltage_regulator_standoff_h) {
  mirror_copy([0, 1, 0]) {
    mirror_copy([1, 0, 0]) {
      color("gold", alpha=1) {
        dia = step_down_voltage_bolt_hole_dia + 0.4;
        translate([-step_down_voltage_regulator_len / 2
                   + step_down_voltage_bolt_hole_dia / 2
                   + step_down_voltage_bolt_x_distance,
                   -step_down_voltage_regulator_w / 2
                   + step_down_voltage_bolt_y_distance,
                   -standoff_h]) {
          cylinder(h = step_down_voltage_regulator_thickness + standoff_h,
                   r = dia / 2,
                   center = false, $fn=20);
        }
      }
    }
  }
}

module step_down_voltage_smd_chip(w=step_down_voltage_smd_chip_w,
                                  l=step_down_voltage_smd_chip_l,
                                  j_led_len=step_down_voltage_smd_chip_j_lead_l,
                                  h=step_down_voltage_smd_chip_h) {
  smd_chip(length=l,
           w=w - j_led_len * 2,
           j_lead_n=4,
           j_lead_thickness=0.4,
           total_w=w,
           h=h,
           center=false);
}

module power_inductor(w=step_down_voltage_power_inductor_size[0],
                      l=step_down_voltage_power_inductor_size[1],
                      h=step_down_voltage_power_inductor_size[2],
                      r=step_down_voltage_power_inductor_size[3]) {
  color(metallic_silver_8, alpha=1) {
    linear_extrude(height=h, center=false) {
      rounded_rect(size=[w, l], r=r);
    }
  }
}

module step_down_voltage_regulator(standoff_h=5,
                                   show_terminal_vin=false,
                                   show_terminal_vout=true) {
  bolt_dia = step_down_voltage_bolt_hole_dia + 0.4;
  z_offst = step_down_voltage_regulator_thickness / 2;

  union() {
    translate([0, 0, z_offst]) {
      difference() {
        color("green", alpha=1) {
          cube([step_down_voltage_regulator_len,
                step_down_voltage_regulator_w,
                step_down_voltage_regulator_thickness + 0.5], center=true);
        }
        step_down_voltage_standoffs();

        let (h = 10) {
          translate([0, 0, -h / 2]) {
            linear_extrude(height=h, center=false, convexity=2) {
              four_corner_holes_2d(size=step_down_voltage_screw_terminal_holes,
                                   hole_dia=bolt_dia,
                                   center=true);
            }
          }
        }
      }
    }

    if (show_terminal_vout) {
      translate([step_down_voltage_regulator_len / 2
                 - step_down_voltage_screw_terminal_thickness / 2,
                 0,
                 step_down_voltage_regulator_thickness]) {
        rotate([0, 0, -90]) {
          screw_terminal(thickness=step_down_voltage_screw_terminal_thickness,
                         isosceles_trapezoid=step_down_voltage_screw_terminal_isosceles_trapezoid,
                         base_h=step_down_voltage_screw_terminal_base_h,
                         top_l=step_down_voltage_screw_terminal_top_l,
                         top_h=step_down_voltage_screw_terminal_top_h,
                         contacts_n=step_down_voltage_screw_terminal_contacts_n,
                         contact_w=step_down_voltage_screw_terminal_contact_w,
                         contact_h=step_down_voltage_screw_terminal_contact_h,
                         pitch=step_down_voltage_screw_terminal_pitch,
                         colr=step_down_voltage_screw_terminal_colr,
                         pin_thickness=step_down_voltage_screw_terminal_pin_thickness,
                         pin_h=step_down_voltage_screw_terminal_pin_h,
                         wall_thickness=step_down_voltage_screw_terminal_wall_thickness);
        }
      }
    }
    if (show_terminal_vin) {
      translate([-step_down_voltage_regulator_len / 2
                 + step_down_voltage_screw_terminal_thickness / 2,
                 0,
                 step_down_voltage_regulator_thickness]) {
        rotate([0, 0, 90]) {
          screw_terminal(thickness=step_down_voltage_screw_terminal_thickness,
                         isosceles_trapezoid=step_down_voltage_screw_terminal_isosceles_trapezoid,
                         base_h=step_down_voltage_screw_terminal_base_h,
                         top_l=step_down_voltage_screw_terminal_top_l,
                         top_h=step_down_voltage_screw_terminal_top_h,
                         contacts_n=step_down_voltage_screw_terminal_contacts_n,
                         contact_w=step_down_voltage_screw_terminal_contact_w,
                         contact_h=step_down_voltage_screw_terminal_contact_h,
                         pitch=step_down_voltage_screw_terminal_pitch,
                         colr=step_down_voltage_screw_terminal_colr,
                         pin_thickness=step_down_voltage_screw_terminal_pin_thickness,
                         pin_h=step_down_voltage_screw_terminal_pin_h,
                         wall_thickness=step_down_voltage_screw_terminal_wall_thickness);
        }
      }
    }

    if (!is_undef(standoff_h) && standoff_h > 0) {
      translate([0, 0, -0.1]) {
        step_down_voltage_standoffs();
      }
    }

    translate([0, 0, z_offst]) {
      translate([3.3, -step_down_voltage_regulator_w / 2 +
                 step_down_voltage_power_regulator_y_distance, 0]) {
        power_inductor();
      }

      for (item = step_down_voltage_surface_mount_chips_specs) {
        step_down_voltage_surface_mount_chip(spec=item);
      }

      for (spec = step_down_voltage_smd_chips_specs) {
        let (w = spec[0],
             l=spec[1],
             h=spec[2],
             j_led_l=spec[3],
             translate_spec=is_undef(spec[4]) ? [0, 0, 0] : spec[4],
             rotation_spec=spec[5]) {
          translate(translate_spec) {
            if (rotation_spec) {
              rotate(rotation_spec) {
                step_down_voltage_smd_chip(w=w, l=l, h=h, j_led_len=j_led_l);
              }
            } else {
              step_down_voltage_smd_chip(w=w, l=l, h=h, j_led_len=j_led_l);
            }
          }
        }
      }

      // electrolytic capacitors (the cylindrical “can” caps)
      mirror_copy([1, 0, 0]) {
        let (d=7,
             h=2.58,
             chamfer=d / 6,
             cube_y=d - chamfer * 2,
             x_dist = 2.6,
             y_dist = 2.6,
             cyl_h = 6.85,
             cyl_cutout_w = d * 0.9) {
          translate([step_down_voltage_screw_terminal_holes[0] / 2 - d / 2
                     - bolt_dia / 2
                     - x_dist,
                     step_down_voltage_regulator_w / 2
                     - d / 2
                     - y_dist,
                     0]) {
            union() {
              color(matte_black, alpha=1) {
                linear_extrude(height=h, center=false) {
                  chamfered_square(size=d, chamfer=chamfer);
                }
                translate([-d / 2, -cube_y / 2 + chamfer, 0]) {
                  cube([d, cube_y, h]);
                }
              }
              color(metallic_silver_1, alpha=1) {
                cylinder(h=cyl_h - 0.01, d=d, $fn=80);
              }
              color(matte_black) {
                translate([0, 0, cyl_h - 1]) {
                  difference() {
                    cylinder(h=1, d=d - 0.1, $fn=80);
                    notched_circle(h=1 + 0.1, d=d + 0.1,
                                   x_cutouts_n=0,
                                   y_cutouts_n=1,
                                   cutout_w=cyl_cutout_w);
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

step_down_voltage_regulator(show_terminal_vin=false, show_terminal_vout=true);
