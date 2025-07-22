/**
 * Module: Robot head for two Raspberry Pi Camera Module 2 units.

 * This module defines the robot head component designed to support two Raspberry Pi Camera Module 2 units.
 *
 * It features a main mounting plate, connector plates, a upper plate, and side panels.
 *
 * The head mount design assumes it will be attached via the side panel's mounting hole on the servo assembly.
 * (See also head_assembly.scad).
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
use <../util.scad>

cam_center_offset            = 13;

cam_centers                  = [[0, -cam_center_offset],
                                [0, cam_center_offset]];
upper_connector_width        = head_upper_plate_width * 0.7;

upper_connector_height       = 4;

lower_connector_width        = head_upper_plate_width * 0.6;
lower_connector_height       = 2;

// Don't try to find a lot of sense in the calculations of the side panel polygon, this is an aesthetic choice.
side_panel_top               = -head_side_panel_height * (4/15);
side_panel_curve_start       = head_side_panel_width * (1/2.1);
side_panel_notch_y           = -head_side_panel_height * (7/14.2);
side_panel_bottom            = head_side_panel_height * (1/4.9);
side_panel_curve_end         = head_side_panel_height * (3/4.0);

side_panel_extra_slot_width  = head_side_panel_width * 0.8;
side_panel_extra_slot_height = 2;
side_panel_extra_slot_ypos   = [-9, +0.2];

extra_holes_offset           = 4;

hole_row_offsets             = [extra_holes_offset * 2];

x_positions                  = [head_side_panel_width * 0.25,
                                head_side_panel_width * 0.5,
                                head_side_panel_width * 0.75];

tilt_angle                   = atan2((-side_panel_curve_end)
                                     - (-side_panel_bottom),
                                     side_panel_curve_start
                                     - head_side_panel_width);

module head_front_plate() {
  difference() {
    cube([head_plate_width,
          head_plate_height,
          head_plate_thickness],
         center=true);

    for (i = [0: len(cam_centers) - 1]) {
      c = cam_centers[i];

      translate([c[0], c[1], 0]) {
        cube([head_camera_lens_width,
              head_camera_lens_height,
              head_plate_thickness + 0.1],
             center=true);

        for (dx = [1, -1]) {
          for (dy = [1, -1]) {
            x = dx * camera_screw_offset_x;
            y = dy == 1
              ? camera_screw_offset_y_top
              : camera_screw_offset_y;

            translate([x, y, 0]) {
              cylinder(h = head_plate_thickness + 0.1,
                       r = camera_screw_dia / 2,
                       center=true,
                       $fn=50);
            }
          }
        }
      }
    }
  }
}

module connector_plate_up(y_offset) {
  y = head_plate_height / 2 + (upper_connector_height * 0.5);
  translate([0, y, -head_plate_thickness * 0.48]) {
    linear_extrude(height = head_plate_thickness) {
      difference() {
        square([upper_connector_width, upper_connector_height],
               center=true);
        d = upper_connector_height * 0.5;
        translate([0, -d * 0.55, 0]) {
          circle(d=d, $fn=40);
        }
      }
    }
  }
}

module connector_plate_down() {
  y_offst = -(head_plate_height * 0.5);
  translate([0, y_offst, -head_plate_thickness / 2]) {
    linear_extrude(height = head_plate_thickness) {
      difference() {
        rounded_rect([lower_connector_width, lower_connector_height],
                     r=lower_connector_height / 2, center=true);
        translate([0, (lower_connector_height * 0.5)]) {
          square([lower_connector_width, lower_connector_height],
                 center = true);
        }
      }
    }
  }
}

module head_upper_plate_geometry() {
  difference() {
    translate([-head_upper_plate_width / 2,
               -head_upper_plate_height,
               0]) {
      cube([head_upper_plate_width,
            head_upper_plate_height,
            head_plate_thickness], center = false);
    }

    slot_width = (head_upper_plate_width) * 0.8;
    slot_height = 2;

    slot_centers = [-head_upper_plate_height * 0.2,
                    -head_upper_plate_height * 0.5,
                    -head_upper_plate_height * 0.8];

    for (center_y = slot_centers) {
      translate([0, center_y, 0]) {
        translate([-slot_width/2, 0, -1.1]) {
          cube([slot_width,
                slot_height,
                head_plate_thickness + upper_connector_height * 0.5],
               center=false);
        }
      }
    }

    circle_dia = 3;
    circle_rad = circle_dia / 2;

    for (cc = [-8, 0, 8])
      translate([cc, -head_upper_plate_height/3, 0]) {
        cylinder(h = head_plate_thickness
                 + upper_connector_height * 0.5,
                 r = circle_rad, center=true, $fn=50);
      }
  }
}

module head_upper_plate() {
  translate([0, head_upper_plate_height + upper_connector_height,
             head_plate_thickness / 2]) {
    rotate([90, 0, 0]) {
      head_upper_plate_geometry();
    }
  }
}

function side_panel_servo_center() =
  [head_side_panel_width / 2.0, -head_side_panel_height / 2.0];

module side_panel_extra_slots_2d() {
  for (slot_y = side_panel_extra_slot_ypos) {
    translate([(head_side_panel_width - side_panel_extra_slot_width) / 2,
               slot_y]) {
      square([side_panel_extra_slot_width, side_panel_extra_slot_height]);
    }
  }

  for (off = hole_row_offsets) {
    if (off >= 0) {
      dotted_screws_line_y(x_positions,
                           y=side_panel_extra_slot_ypos[1] + off,
                           d=3);
    }
    else {
      dotted_screws_line_y(x_positions,
                           y=side_panel_extra_slot_ypos[0] + off,
                           d=3);
    }
  }

  dotted_screws_line_y([head_side_panel_width * 0.50,
                        head_side_panel_width * 0.66,
                        head_side_panel_width * 0.85],
                       y=extra_holes_offset * 5,
                       d=3);
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
    polygon(points = [[0, -side_panel_top],
                      [side_panel_curve_start, -side_panel_notch_y],
                      [head_side_panel_width, -side_panel_notch_y],
                      [head_side_panel_width, -side_panel_bottom],
                      [side_panel_curve_start, -side_panel_curve_end],
                      [0, -side_panel_curve_end]]);

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
      mirror([1,0,0]) {
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
