/**
 * Module: Robot head for two Raspberry Pi Camera Module 3 units.

 * This module defines the robot head component designed to support two
 * Raspberry Pi Camera Module 3 units.
 *
 * It features a main mounting plate, connector plates, a upper plate, and side
 * panels.
 *
 * The head mount design assumes it will be attached via the side panel's
 * mounting hole on the servo assembly.

 * This file also supports mounting the IR LED case used with the modified
 * Waveshare Infrared LED Light Board.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/holes.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/transforms.scad>
use <../placeholders/bolt.scad>
use <../placeholders/camera.scad>
use <../placeholders/servo_horn.scad>
use <ir_case.scad>

show_camera             = false;
show_camera_bolts       = false;
show_camera_nuts        = false;
show_ir_case            = false;
show_ir_case_bolts      = false;
show_ir_case_nuts       = false;
show_ir_led             = false;
show_ir_case_rail       = false;
show_ir_case_rail_bolts = false;
show_ir_case_rail_nuts  = false;

show_servo_horn         = false;
show_servo_horn_screws  = false;
show_servo_horn_bolt    = false;
servo_horn_single       = false;
servo_horn_screw_side   = "horizontal";

echo_bolts_info         = true;

tilt_angle              = atan2((-head_side_panel_curve_end)
                                - (-head_side_panel_bottom),
                                head_side_panel_curve_start
                                - head_side_panel_width);

side_panel_points       = [[0, -head_side_panel_top],
                           [head_side_panel_curve_start, -
                            head_side_panel_notch_y],
                           [head_side_panel_width, -head_side_panel_notch_y],
                           [head_side_panel_width, -head_side_panel_bottom],
                           [head_side_panel_curve_start,
                            -head_side_panel_curve_end],
                           [0, -head_side_panel_curve_end]];

function side_panel_servo_center() =
  [head_side_panel_width / 2.0, -head_side_panel_height / 2.0];

function camera_final_y(i) =
  (i == 0 ? 0 : sum([for (j = [0 : i - 1]) head_cameras[j][0][1]]))
  + i * head_cameras_y_distance;

module head_front_camera(spec,
                         i,
                         do_cut=true,
                         do_place_camera=false,
                         echo_bolts_info=echo_bolts_info,
                         show_bolts=true,
                         show_nuts=true) {
  slot_size       = spec[0];
  bolt_hole_y    = spec[1];
  bolt_spacing = spec[2];
  final_y         = camera_final_y(i);

  hole_r = slot_size[0] / 2;

  hole_y_pos = bolt_spacing[1] / 2 + head_camera_bolt_dia / 2
    + bolt_hole_y;

  translate([-hole_r, final_y, 0]) {
    if (do_cut) {
      square(slot_size, center=false);

      translate([hole_r,
                 hole_y_pos,
                 0]) {
        four_corner_holes_2d(size = bolt_spacing,
                             center = true,
                             d = head_camera_bolt_dia,
                             fn = 360);
      }
    }

    if (do_place_camera) {
      board_color = is_undef(spec[3]) ? green_2 : spec[3];
      translate([slot_size[0] / 2,
                 bolt_spacing[1] / 2 + head_camera_bolt_dia / 2
                 + bolt_hole_y
                 + camera_h / 2
                 - camera_holes_size[1] / 2
                 - camera_bolt_hole_dia / 2
                 - camera_holes_distance_from_top,
                 0]) {
        rotate([0, 0, 180]) {
          camera_module(board_color=board_color);
        }
      }
    }

    let (nut_spec = find_nut_spec(inner_d=head_camera_bolt_dia,
                                  lock=false),
         nut_h = plist_get("height", nut_spec, 2),
         bolt_h = ceil(camera_thickness + head_plate_thickness + nut_h),
         bolt_d = snap_bolt_d(head_camera_bolt_dia)) {
      if (echo_bolts_info) {
        echo(str("Camera bolt: M", bolt_d, "x", bolt_h, "mm"));
      }
      if (show_bolts) {
        translate([hole_r,
                   hole_y_pos,
                   head_plate_thickness + camera_thickness - bolt_h]) {
          four_corner_children(size = bolt_spacing,
                               center = true) {
            bolt(h=bolt_h,
                 show_nut=show_nuts,
                 nut_head_distance=head_plate_thickness
                 + camera_thickness,
                 d=head_camera_bolt_dia);
          }
        }
      }
    }
  }
}

module head_front_plate(show_camera=false,
                        head_color="white",
                        show_nuts=false,
                        show_bolts=false) {
  cameras_len = len(head_cameras);
  single_camera_y_shift = cameras_len > 1
    ? 0
    : head_cameras_y_distance / 2;

  // plate cutouts
  translate([0, 0, -head_plate_thickness]) {
    color(head_color, alpha=1) {
      linear_extrude(height = head_plate_thickness, center = false) {
        difference() {
          translate([0, head_plate_height / 2, 0])
            square([head_plate_width, head_plate_height], center = true);

          translate([0, single_camera_y_shift, 0]) {
            for (i = [0 : cameras_len - 1])
              head_front_camera(spec=head_cameras[i],
                                i=i,
                                show_bolts=false,
                                show_nuts=false,
                                do_cut=true,
                                do_place_camera=false);
          }
        }
      }
    }
  }

  if ((show_camera || show_bolts || show_nuts) && cameras_len > 0) {
    translate([0,
               single_camera_y_shift,
               -head_plate_thickness - camera_thickness]) {
      for (i = [0 : cameras_len - 1])
        head_front_camera(spec=head_cameras[i],
                          i=i,
                          show_nuts=show_nuts,
                          show_bolts=show_bolts,
                          do_cut=false,
                          do_place_camera=show_camera);
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
                     r=head_lower_connector_height / 2,
                     center=true);
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
      dotted_bolts_line_y(head_extra_side_slots_x_positions,
                          y=head_side_panel_extra_slot_ypos[1] + off,
                          d=head_extra_slots_dia);
    }
    else {
      dotted_bolts_line_y(head_extra_side_slots_x_positions,
                          y=head_side_panel_extra_slot_ypos[0] + off,
                          d=head_extra_slots_dia);
    }
  }

  dotted_bolts_line_y([head_side_panel_width * 0.50,
                       head_side_panel_width * 0.66,
                       head_side_panel_width * 0.85],
                      y=head_extra_holes_offset * 5,
                      d=head_extra_slots_dia);
}

module side_panel_with_servo_horn_center_position() {
  centers = side_panel_servo_center();

  translate(centers) {
    children();
  }
}

module side_panel_servo_horn(show_servo_horn_screws=show_servo_horn_screws,
                             show_servo_horn_bolt=show_servo_horn_bolt,
                             servo_horn_single=servo_horn_single,
                             servo_horn_screw_side=servo_horn_screw_side) {
  translate([0, head_side_panel_curve_end, head_plate_thickness]) {

    side_panel_with_servo_horn_center_position() {
      rotate([0, 0, tilt_angle]) {
        translate([0,
                   0,
                   -servo_horn_ring_height
                   + servo_horn_arm_z_offset]) {
          servo_horn(center=true,
                     show_screws=show_servo_horn_screws,
                     single=servo_horn_single,
                     show_bolt=false,
                     screw_side=servo_horn_screw_side);
        }

        if (show_servo_horn_bolt) {
          translate([0, 0, - servo_horn_ring_height]) {
            bolt(d=servo_horn_center_hole_dia,
                 head_type="pan",
                 bolt_color=matte_black,
                 h=servo_horn_ring_height + head_plate_thickness);
          }
        }
      }
    }
  }
}

module side_panel_servo_horn_slot_2d(offst_from_center_hole=2.0,
                                     screws_gap=0.5) {

  angle_cos = cos(tilt_angle);
  angle_sin = sin(tilt_angle);
  step = head_servo_horn_screw_dia + screws_gap;
  amount = floor((head_side_panel_height / 2) / step);

  side_panel_with_servo_horn_center_position() {
    circle(d = head_servo_mount_dia, $fn = 360);

    for (dir = [-1, 1]) {
      group_offst = (dir < 0
                     ? -head_servo_horn_screw_dia / 2 - offst_from_center_hole
                     : head_servo_horn_screw_dia / 2 + offst_from_center_hole);

      for (i = [1 : (amount/2)]) {
        base_offst = i * step * dir;
        x = (group_offst + base_offst) * angle_cos;
        y = (group_offst + base_offst) * angle_sin;

        translate([x, y, 0]) {
          circle(r = head_servo_horn_screw_dia/2, $fn = 360);
        }
      }
    }
  }
}

module side_panel_2d() {
  difference() {
    translate([0, head_side_panel_curve_end, 0]) {
      difference() {
        polygon(points=side_panel_points);
        side_panel_servo_horn_slot_2d();
        side_panel_extra_slots_2d();
      }
    }

    head_panel_ir_case_bolt_holes();
  }
}

module side_panel_3d(show_servo_horn=false,
                     show_servo_horn_screws=show_servo_horn_screws,
                     show_servo_horn_bolt=show_servo_horn_bolt,
                     servo_horn_single=servo_horn_single,
                     servo_horn_screw_side=servo_horn_screw_side,
                     pan_color="white") {
  color(pan_color, alpha=1) {
    linear_extrude(height=head_plate_thickness) {
      side_panel_2d();
    }
  }
  if (show_servo_horn) {
    side_panel_servo_horn(show_servo_horn_screws=show_servo_horn_screws,
                          show_servo_horn_bolt=show_servo_horn_bolt,
                          servo_horn_single=servo_horn_single,
                          servo_horn_screw_side=servo_horn_screw_side);
  }
}

module side_panel(is_left=true,
                  show_servo_horn=show_servo_horn,
                  show_servo_horn_screws=show_servo_horn_screws,
                  show_servo_horn_bolt=show_servo_horn_bolt,
                  servo_horn_single=servo_horn_single,
                  servo_horn_screw_side=servo_horn_screw_side,
                  pan_color="white") {
  offsets = [head_plate_width / 2,
             -head_plate_height / 2];

  if (is_left) {
    translate([-offsets[0], offsets[1], 0]) {
      mirror([1, 0, 0]) {
        rotate([0, 90, 0]) {
          side_panel_3d(show_servo_horn=show_servo_horn,
                        pan_color=pan_color,
                        show_servo_horn_screws=show_servo_horn_screws,
                        show_servo_horn_bolt=show_servo_horn_bolt,
                        servo_horn_single=servo_horn_single,
                        servo_horn_screw_side=servo_horn_screw_side);
        }
      }
    }
  } else {
    translate([offsets[0], offsets[1], 0]) {
      rotate([0, 90, 0]) {
        side_panel_3d(show_servo_horn=show_servo_horn,
                      pan_color=pan_color,
                      show_servo_horn_screws=show_servo_horn_screws,
                      show_servo_horn_bolt=show_servo_horn_bolt,
                      servo_horn_single=servo_horn_single,
                      servo_horn_screw_side=servo_horn_screw_side);
      }
    }
  }
}
module head_panel_ir_case_bolt_holes() {
  for (spec = ir_case_head_bolts_side_panel_positions) {
    translate([spec[0] + ir_case_bolt_dia / 2
               + head_plate_thickness,
               spec[1] +
               head_side_panel_height,
               0]) {
      circle(r=ir_case_bolt_dia / 2, $fn=360);
      for (x=ir_case_bolt_pan_holes_x_offsets) {
        translate([x, 0, 0]) {
          circle(r=ir_case_bolt_dia / 2, $fn=360);
        }
      }
    }
  }
}
module head_ir_case(ir_case_color=jet_black,
                    ir_rail_color=cobalt_blue_metallic,
                    show_ir_led=show_ir_led,
                    show_ir_case_rail=show_ir_case_rail,
                    show_ir_case_bolts=show_ir_case_bolts,
                    show_ir_case_nuts=show_ir_case_nuts,
                    show_ir_case_rail_bolts=show_ir_case_rail_bolts,
                    show_ir_case_rail_nuts=show_ir_case_rail_nuts,
                    echo_bolts_info=echo_bolts_info) {
  spec = ir_case_head_bolts_side_panel_positions[0];
  bolt_rad = ir_case_bolt_dia / 2;
  ir_case_x = head_plate_width / 2
    + head_plate_thickness
    + ir_case_l_bracket_len;
  ir_case_y = (head_side_panel_curve_end / 2)
    - ir_case_slider_y_pos() + spec[1] + bolt_rad;
  ir_case_z = (-ir_case_l_bracket_h - ir_case_full_thickness() / 2)
    + ir_case_l_bracket_h / 2 + bolt_rad + head_plate_thickness
    + spec[0];
  translate([ir_case_x,
             ir_case_y,
             ir_case_z]) {
    ir_case_assembly(show_rail=show_ir_case_rail,
                     case_color=ir_case_color,
                     rail_color=ir_rail_color,
                     show_ir_led=show_ir_led,
                     show_ir_case_nuts=show_ir_case_nuts,
                     show_ir_case_bolts=show_ir_case_bolts,
                     show_ir_case_rail_bolts=show_ir_case_rail_bolts,
                     show_ir_case_rail_nuts=show_ir_case_rail_nuts,
                     mount_thickness=head_plate_thickness,
                     echo_bolts_info=echo_bolts_info);
  }
}
module head_mount(head_color="white",
                  ir_case_color=jet_black,
                  ir_rail_color=jet_black,
                  show_camera=show_camera,
                  show_ir_case=show_ir_case,
                  show_ir_led=show_ir_led,
                  show_ir_case_rail=show_ir_case_rail,
                  show_ir_case_bolts=show_ir_case_bolts,
                  show_ir_case_nuts=show_ir_case_nuts,
                  show_ir_case_rail_bolts=show_ir_case_rail_bolts,
                  show_ir_case_rail_nuts=show_ir_case_rail_nuts,
                  show_camera_nuts=show_camera_nuts,
                  show_camera_bolts=show_camera_bolts,
                  show_servo_horn=show_servo_horn,
                  show_servo_horn_screws=show_servo_horn_screws,
                  show_servo_horn_bolt=show_servo_horn_bolt,
                  servo_horn_single=servo_horn_single,
                  servo_horn_screw_side=servo_horn_screw_side) {

  module _head_ir_case() {
    head_ir_case(ir_rail_color=ir_rail_color,
                 ir_case_color=ir_case_color,
                 show_ir_led=show_ir_led,
                 show_ir_case_rail=show_ir_case_rail,
                 show_ir_case_bolts=show_ir_case_bolts,
                 show_ir_case_nuts=show_ir_case_nuts,
                 show_ir_case_rail_bolts=show_ir_case_rail_bolts,
                 show_ir_case_rail_nuts=show_ir_case_rail_nuts);
  }
  rotate([0, 180, 0]) {
    union() {
      translate([0, head_plate_height / 2, 0]) {
        rotate([0, 0, 180]) {
          head_front_plate(show_camera=show_camera,
                           head_color=head_color,
                           show_nuts=show_camera_nuts,
                           show_bolts=show_camera_bolts);
        }
      }
      color(head_color, alpha=1) {
        connector_plate_up();
        connector_plate_down();
        head_upper_plate();
        side_panel(is_left=true);
      }
      side_panel(is_left=false,
                 show_servo_horn=show_servo_horn,
                 show_servo_horn_screws=show_servo_horn_screws,
                 show_servo_horn_bolt=show_servo_horn_bolt,
                 servo_horn_single=servo_horn_single,
                 servo_horn_screw_side=servo_horn_screw_side,
                 pan_color=head_color);
    }
  }

  if (show_ir_case || show_ir_case_rail || show_ir_led) {
    if (is_ir_case_bracket_enabled("both")) {
      mirror_copy([1, 0, 0]) {
        _head_ir_case();
      }
    } else if (is_ir_case_bracket_enabled("left")) {
      _head_ir_case();
    } else if (is_ir_case_bracket_enabled("right")) {
      ir_case_x = -head_plate_width / 2 - ir_case_width
        - head_plate_thickness - ir_case_l_bracket_len;
      translate([ir_case_x - head_plate_width / 2
                 - head_plate_thickness
                 - ir_case_l_bracket_len,
                 0,
                 0]) {
        _head_ir_case();
      }
    }
  }
}

module head_mount_printable() {
  head_mount(show_camera=false,
             show_camera_bolts=false,
             show_camera_nuts=false,
             show_ir_case=false,
             show_ir_case_bolts=false,
             show_ir_case_nuts=false,
             show_ir_led=false,
             show_ir_case_rail=false,
             show_ir_case_rail_bolts=false,
             show_ir_case_rail_nuts=false,
             show_servo_horn=false);
}

head_mount();
