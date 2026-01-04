
include <../../parameters.scad>
include <../../colors.scad>
use <../../lib/shapes3d.scad>
use <../../lib/functions.scad>
use <../../lib/transforms.scad>
use <../../lib/trapezoids.scad>
use <../spring.scad>

contact_width_factor = 0.362;
contact_thickness    = 0.6;

terminal_type        = "solder_tab"; // [coil_spring, solder_tab]

function solder_tab_contact_mount_w(battery_dia,
                                    contact_hole_d=1)
= max(contact_width_factor * battery_dia, contact_hole_d + 2);

function solder_tab_contact_mount_outer_size(battery_dia,
                                             contact_hole_d=1,
                                             thickness=contact_thickness)
= let (contact_w = max(contact_width_factor * battery_dia, with_default(contact_hole_d, 1) + 2))
  [contact_w, contact_w * 0.69, with_default(thickness, contact_thickness)];

function solder_tab_outer_len(battery_dia,
                              contact_hole_d=1,
                              thickness=contact_thickness,
                              front_rear_thickness)
= let (outer_size = solder_tab_contact_mount_outer_size(battery_dia=battery_dia,
                                                        contact_hole_d=contact_hole_d,
                                                        thickness=thickness))
  outer_size[1] + front_rear_thickness / 2;

module battery_holder_solder_tab_cutout(battery_dia,
                                        thickness,
                                        holder_height,
                                        front_rear_thickness,
                                        contact_hole_d=1,
                                        inc_step=4) {
  contact_hole_d = with_default(contact_hole_d, 1);
  thickness = with_default(thickness, contact_thickness);
  inc_step = with_default(inc_step, 4);
  holder_height = with_default(holder_height, battery_dia);
  contact_w = solder_tab_contact_mount_w(battery_dia=battery_dia,
                                         contact_hole_d=contact_hole_d);
  outer_size = [contact_w * 0.5,
                (front_rear_thickness / 2) - 0.5,
                holder_height];

  contact_mount_bottom_size =
    solder_tab_contact_mount_outer_size(battery_dia=battery_dia,
                                        contact_hole_d=contact_hole_d);
  inner_cutout_size = [contact_w * 0.92,
                       (front_rear_thickness / 2),
                       max(1, holder_height - 2)];

  hook_trapezoid_bottom = 0.2 * holder_height;
  hook_trapezoid_top = 0.79 * hook_trapezoid_bottom;

  outer_bottom_cutout_size = [hook_trapezoid_bottom,
                              inner_cutout_size[1],
                              inner_cutout_size[2]];

  inner_hook_cutout_size = [hook_trapezoid_bottom,
                            hook_trapezoid_top,
                            0.5]; // trapezoid bottom, top and height
  outer_hook_cutout_size = [hook_trapezoid_bottom,
                            hook_trapezoid_top,
                            1.5]; // trapezoid bottom, top and height

  half_of_front_thickness = front_rear_thickness / 2;
  half_of_inner_cutout_h = inner_cutout_size[2] / 2;

  outer_hook_y_position = outer_size[2] / 2;
  inner_hook_y_position = inner_cutout_size[2] - inner_hook_cutout_size[0]/ 2;

  outer_thickness = outer_size[1] + inc_step;
  inner_thickness = inner_cutout_size[1] + inc_step;
  bottom_outer_thickness = outer_bottom_cutout_size[1] + inc_step;

  module contact_cutout_base(size,
                             hook_cutout_size,
                             hook_y_position,
                             inc_step=0) {
    b = hook_cutout_size[0];
    t = hook_cutout_size[1];
    h = hook_cutout_size[2];
    w = size[0];
    thickness = size[1];
    union() {
      translate([0, 0, inc_step != 0 ? (-inc_step / 2) : 0]) {
        cube_3d(size=[size[0], thickness, size[2] + inc_step]);
      }
      mirror_copy([1, 0, 0]) {
        translate([-h / 2 - w / 2, 0, hook_y_position]) {
          rotate([0, 90, 90]) {
            linear_extrude(height=thickness, center=true) {
              trapezoid(b=b, t=t, h=h, center=true);
            }
          }
        }
      }
    }
  }

  union() {
    cube([contact_w,
          thickness,
          holder_height + 1],
         center=true);
    translate([0,
               -inner_cutout_size[1] / 2
               + front_rear_thickness / 2
               + inc_step / 2,
               holder_height - inner_cutout_size[2]]) {
      contact_cutout_base(size=[inner_cutout_size[0],
                                inner_thickness,
                                inner_cutout_size[2]
                                + inc_step],
                          hook_cutout_size=inner_hook_cutout_size,
                          hook_y_position=inner_hook_y_position);
    }
    translate([0,
               outer_size[1] / 2 - front_rear_thickness / 2 - inc_step / 2,
               0]) {
      contact_cutout_base(size=[outer_size[0],
                                outer_thickness,
                                outer_size[2] + inc_step],
                          hook_cutout_size=outer_hook_cutout_size,
                          hook_y_position=outer_hook_y_position);
    }
    translate([0,
               outer_bottom_cutout_size[1] / 2
               - front_rear_thickness / 2
               - inc_step / 2,
               -inc_step]) {
      cube_3d(size=[outer_bottom_cutout_size[0],
                    bottom_outer_thickness,
                    outer_bottom_cutout_size[2] + inc_step]);
    }
  }
}

module battery_holder_solder_tab_contact(battery_dia=battery_dia,
                                         thickness=contact_thickness,
                                         holder_height=smd_battery_holder_height,
                                         front_rear_thickness,
                                         contact_hole_d=1,
                                         angle = 0) {

  holder_height = with_default(holder_height, battery_dia);
  width = solder_tab_contact_mount_w(battery_dia=battery_dia,
                                     contact_hole_d=contact_hole_d);
  outer_size = [width * 0.5,
                (front_rear_thickness / 2) - 0.5,
                holder_height];

  contact_mount_bottom_size =
    solder_tab_contact_mount_outer_size(battery_dia=battery_dia,
                                        contact_hole_d=contact_hole_d);
  inner_cutout_size = [width * 0.92,
                       (front_rear_thickness / 2),
                       max(1, holder_height - 2)];

  hook_trapezoid_bottom = 0.2 * holder_height;
  hook_trapezoid_top = 0.79 * hook_trapezoid_bottom;

  inner_hook_cutout_size = [hook_trapezoid_bottom,
                            hook_trapezoid_top,
                            0.5]; // trapezoid bottom, top and height
  outer_hook_cutout_size = [hook_trapezoid_bottom,
                            hook_trapezoid_top,
                            1.5]; // trapezoid bottom, top and height

  half_of_front_thickness = front_rear_thickness / 2;
  half_of_inner_cutout_h = inner_cutout_size[2] / 2;

  outer_hook_cutout_y_position = outer_size[2] / 2;
  inner_hook_cutout_y_position = inner_cutout_size[2]
    - inner_hook_cutout_size[0] / 2;

  bbox = rot_x_bbox_align([width, thickness,
                           half_of_inner_cutout_h],
                          angle=angle);

  union() {
    hull() {
      translate([0, bbox[2] + thickness, holder_height - bbox[5]]) {
        rotate([-angle, 0, 0]) {
          translate([0, 0, 0]) {
            cube_center_x([width, thickness, half_of_inner_cutout_h]);
          }
        }
      }
      translate([0, 0, holder_height - bbox[5] * 2]) {
        rotate([angle, 0, 0]) {
          translate([0, 0, 0]) {
            cube_center_x([width, thickness, half_of_inner_cutout_h]);
          }
        }
      }
    }

    translate([0, 0, holder_height - inner_cutout_size[2]]) {
      cube_center_x([width, thickness, inner_cutout_size[2]]);
    }

    translate([0, thickness, 0]) {
      translate([0, 0, holder_height - thickness]) {
        cube_center_x([width, half_of_front_thickness, thickness]);
      }
      translate([0, half_of_front_thickness, 0]) {
        cube_center_x([width, thickness, holder_height]);
        translate([0, thickness, 0]) {
          cube_center_x([outer_size[0], half_of_front_thickness, thickness]);
          translate([0, half_of_front_thickness, 0]) {
            difference() {
              cube_center_x(contact_mount_bottom_size);
              translate([0, contact_mount_bottom_size[1] / 2, -0.5]) {
                cylinder(r=contact_hole_d / 2, h=thickness + 1);
              }
            }
          }
        }
      }
    }
  }
}

module battery_holder_contact(terminal_type=terminal_type,
                              battery_len=battery_height,
                              battery_dia=battery_dia,
                              thickness=contact_thickness,
                              holder_height=smd_battery_holder_height,
                              bottom_thickness=1.2,
                              front_rear_thickness=smd_battery_holder_front_rear_thickness,
                              use_spring=true,
                              contact_color,
                              coil_spring_d,
                              spring_color,
                              contact_hole_d=1) {
  is_solder_tab = terminal_type == "solder_tab";
  coil_spring_d = min(5, with_default(0.27 * battery_dia));
  thickness = with_default(thickness, contact_thickness);
  contact_hole_d = with_default(contact_hole_d, 1);

  contact_color = with_default(contact_color, metallic_yellow_1);

  battery_y_center_pos = battery_dia / 2 + bottom_thickness;

  union() {
    if (is_solder_tab) {
      color(contact_color, alpha=1) {
        battery_holder_solder_tab_contact(battery_dia=battery_dia,
                                          thickness=thickness,
                                          holder_height=holder_height,
                                          front_rear_thickness=front_rear_thickness,
                                          contact_hole_d=contact_hole_d);
      }
    } else {
      translate([0,
                 -thickness,
                 battery_y_center_pos]) {
        color(contact_color, alpha=1) {
          rotate([-90, 0, 0]) {
            cylinder(d=coil_spring_d,
                     h=front_rear_thickness + thickness * 2);
          }
        }
        if (use_spring) {
          spring_len = min(8, 0.1 * battery_len);
          spring_d1 = battery_dia * 0.6;
          spring_d2 = spring_d1 * 0.5;
          color(with_default(spring_color, metallic_silver_1), alpha=1) {
            rotate([90, 0, 0]) {
              spring(d1=spring_d1,
                     d2=spring_d2,
                     wire=thickness,
                     turns=spring_len,
                     pitch=spring_len * 0.3);
            }
          }
        }
      }
    }
  }
}

battery_holder_contact();
