/**
 * Module: Robot head for two Raspberry Pi Camera Module 2 units.

 * This module defines the robot head component designed to support two
 * Raspberry Pi Camera Module 2 units.
 *
 * It features a main mounting plate, connector plates, a upper plate, and side
 * panels.
 *
 * The head mount design assumes it will be attached via the side panel's
 * mounting hole on the servo assembly.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
use <../util.scad>

tilt_angle = atan2((-head_side_panel_curve_end)
                   - (-head_side_panel_bottom),
                   head_side_panel_curve_start
                   - head_side_panel_width);

function side_panel_servo_center() =
  [head_side_panel_width / 2.0, -head_side_panel_height / 2.0];

module head_front_plate() {
  translate([0, head_plate_height / 2, 0]) {
    rotate([0, 0, 180]) {
      translate([0, 0, -head_plate_thickness]) {
        linear_extrude(height = head_plate_thickness, center=false) {
          difference() {
            translate([0, head_plate_height / 2, 0]) {
              square([head_plate_width, head_plate_height], center=true);
            }

            translate([0, len(head_cameras) > 1 ? 0 :
                       head_cameras_y_distance / 2, 0]) {
              for (i = [0 : len(head_cameras)-1]) {
                let (spec               = head_cameras[i],
                     hole_size          = spec[0],
                     screw_hole_y       = spec[1],
                     screw_hole_size    = spec[2],
                     prev_heights       = [for (j = [0 : i-1])
                         head_cameras[j][0][1]],
                     prev_y_holes       = [for (j = [0 : i])
                         head_cameras[j][2]],
                     prev_height        = i == 0 ? 0 : sum(prev_heights),
                     y                  = prev_height,
                     final_y            = y + (i * head_cameras_y_distance))

                  translate([-hole_size[0] / 2, final_y, 0]) {
                  square(hole_size, center = false);

                  translate([hole_size[0] / 2, screw_hole_size[1] / 2
                             + head_camera_screw_dia / 2
                             + screw_hole_y, 0]) {
                    four_corner_holes_2d(size=screw_hole_size, center = true,
                                         hole_dia=head_camera_screw_dia,
                                         fn_val=160);
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

module connector_plate_up() {
  y = head_plate_height / 2 + (head_upper_connector_height * 0.5);
  translate([0, y, -head_upper_connector_len]) {
    linear_extrude(height = head_upper_connector_len) {
      difference() {
        square([head_upper_connector_width, head_upper_connector_height],
               center=true);
        d = head_upper_connector_height * 0.5;
        translate([0, head_upper_connector_height / 2 - d, 0]) {
          circle(d=d, $fn=40);
        }
      }
    }
  }
}

module connector_plate_down() {
  y_offst = -(head_plate_height * 0.5);
  translate([0, y_offst, -head_plate_thickness]) {
    linear_extrude(height = head_plate_thickness) {
      difference() {
        rounded_rect([head_lower_connector_width, head_lower_connector_height],
                     r=head_lower_connector_height / 2, center=true);
        translate([0, (head_lower_connector_height * 0.5)]) {
          square([head_lower_connector_width, head_lower_connector_height],
                 center = true);
        }
      }
    }
  }
}

module head_top_plate() {
  slot_w = head_top_slot_size[0];
  slot_h = head_top_slot_size[1];
  hole_rad = head_top_plate_extra_slots_dia / 2;
  step = head_top_slots_y_distance + slot_h;
  lines_amount = floor(head_upper_plate_height / step);
  slot_x = (head_upper_plate_width - slot_w) / 2;

  linear_extrude(height=head_plate_thickness, center=false) {
    union() {
      difference() {
        square([head_upper_plate_width, head_upper_plate_height], center=false);
        if (lines_amount > 0) {
          translate([0, head_upper_plate_height * 0.2, 0]) {
            for (i = [0 : lines_amount - 1]) {
              let (s = i * step) {
                translate([slot_x, s, 0]) {
                  square([slot_w, slot_h], center=false);
                  if (i > 0) {
                    translate([slot_w / 2, 0, 0]) {
                      for (x = head_top_holes_x_positions) {
                        translate([x, -hole_rad - slot_h / 2, 0]) {
                          circle(r=hole_rad, $fn=10);
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
  }
}

module head_upper_plate() {
  translate([-head_upper_plate_width / 2,
             head_plate_height / 2 + head_upper_connector_height
             + head_plate_thickness,
             -head_upper_plate_height]) {
    rotate([90, 0, 0]) {
      head_top_plate();
    }
  }
}

module side_panel_extra_slots_2d() {
  for (slot_y = head_side_panel_extra_slot_ypos) {
    translate([(head_side_panel_width - head_side_panel_extra_slot_width) / 2,
               slot_y]) {
      square([head_side_panel_extra_slot_width,
              head_side_panel_extra_slot_height]);
    }
  }

  for (off = head_hole_row_offsets) {
    if (off >= 0) {
      dotted_screws_line_y(head_extra_side_slots_x_positions,
                           y=head_side_panel_extra_slot_ypos[1] + off,
                           d=head_extra_slots_dia);
    }
    else {
      dotted_screws_line_y(head_extra_side_slots_x_positions,
                           y=head_side_panel_extra_slot_ypos[0] + off,
                           d=head_extra_slots_dia);
    }
  }

  dotted_screws_line_y([head_side_panel_width * 0.50,
                        head_side_panel_width * 0.66,
                        head_side_panel_width * 0.85],
                       y=head_extra_holes_offset * 5,
                       d=head_extra_slots_dia);
}

module side_panel_servo_slots(offst_from_center_hole=2.0,
                              screws_distance=0.5) {
  centers = side_panel_servo_center();

  angle_cos = cos(tilt_angle);
  angle_sin = sin(tilt_angle);
  step = head_servo_screw_dia + screws_distance;
  amount = floor((head_side_panel_height / 2) / step);

  translate(centers) {
    circle(d = head_servo_mount_dia, $fn = 360);

    for (dir = [-1, 1]) {
      group_offst = (dir < 0
                     ? -head_servo_screw_dia / 2 - offst_from_center_hole
                     : head_servo_screw_dia / 2 + offst_from_center_hole);

      for (i = [1 : (amount/2)]) {
        base_offst = i * step * dir;
        x = (group_offst + base_offst) * angle_cos;
        y = (group_offst + base_offst) * angle_sin;

        translate([x, y, 0]) {
          circle(r = head_servo_screw_dia/2, $fn = 360);
        }
      }
    }
  }
}

module side_panel_2d() {
  difference() {
    polygon(points = [[0, -head_side_panel_top],
                      [head_side_panel_curve_start, -head_side_panel_notch_y],
                      [head_side_panel_width, -head_side_panel_notch_y],
                      [head_side_panel_width, -head_side_panel_bottom],
                      [head_side_panel_curve_start, -head_side_panel_curve_end],
                      [0, -head_side_panel_curve_end]]);

    side_panel_servo_slots();
    side_panel_extra_slots_2d();
  }
}

module side_panel_3d() {
  linear_extrude(height = head_plate_thickness) {
    side_panel_2d();
  }
}

module side_panel(is_left=true) {
  offsets = [head_plate_width / 2,
             head_plate_height / 4];

  if (is_left) {
    translate([-offsets[0], offsets[1], 0]) {
      mirror([1, 0, 0]) {
        rotate([0, 90, 0]) {
          side_panel_3d();
        }
      }
    }
  } else {
    translate([offsets[0], offsets[1], 0]) {
      rotate([0, 90, 0]) {
        side_panel_3d();
      }
    }
  }
}

module head_mount() {
  rotate([0, 180, 0]) {
    union() {
      head_front_plate();
      connector_plate_up();
      connector_plate_down();
      head_upper_plate();
      side_panel(true);
      side_panel(false);
    }
  }
}

color("white") {
  head_mount();
}
