/**
  * Module: The rear-mountable part of the front chassis that holds the steering servo.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../parameters.scad>
include <../../rc_params.scad>
include <computed_params.scad>

use <../../lib/debug.scad>
use <../../lib/functions.scad>
use <../../lib/polygon_util.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>
use <../bellcrank_steering_slots.scad>
use <../steering_servo_bracket/steering_servo_chassis_slots.scad>
use <front_chassis_controls.scad>
use <front_chassis_joint.scad>
use <front_chassis_ribbon_slots.scad>

front_chassis_rear_frame_debug = true;
show_front_controls_slots      = true;

function front_chassis_pts(width=front_chassis_rear_frame_w) =
  let (half_of_main_w = width / 2)
  [[0, y_front_chassis_rear_frame_joint_1_start],
   [front_frame_x_end, y_front_chassis_rear_frame_joint_1_start],
   [half_of_main_w, y_front_chassis_rear_frame_main_start],
   [half_of_main_w, front_chassis_y_joint_2_end],
   [0, front_chassis_y_joint_2_end]];

module front_chassis_rear_frame(debug=front_chassis_rear_frame_debug,
                                color=white_smoke_1,
                                debug_color=green_2,
                                debug_font="Gill Sans:style=Bold",
                                width=front_chassis_rear_frame_w,
                                show_ribbon_slots=true) {
  assert(width >= front_chassis_required_width(),
         "Frame width cannot exclude the front hardware");
  pts = front_chassis_pts(width);

  module _debug(rotation) {
    let (x_size = polygon_x_len(pts) * 2,
         font_size = constraint(x_size * 0.15, 2, 5)) {
      debug_polygon_text(pts,
                         rotation=rotation,
                         font_size=font_size,
                         font=debug_font,
                         offset_x=font_size,
                         offset_x_exclude=[0, len(pts) - 1],
                         color=debug_color);
    }
  }

  difference() {
    maybe_color(color) {
      union() {
        linear_extrude(height=chassis_thickness,
                       center=false,
                       convexity=2) {
          mirror_copy([1, 0, 0]) {
            offset_vertices_2d(r=front_chassis_rear_frame_corner_r) {
              polygon(pts);
            }
          }
        }
        // remove rounded part at the top center
        translate(concat(take(pts[0], 2), [0])) {
          cuboid(size=[front_chassis_rear_frame_corner_r * 2,
                       front_chassis_rear_frame_corner_r,
                       chassis_thickness],
                 anchor=[0, -1, 1]);
        }
        // remove rounded part at the end
        translate([0, front_chassis_y_joint_2_end, 0]) {
          cuboid(size=[width,
                       front_chassis_rear_frame_corner_r,
                       chassis_thickness],
                 anchor=[0, 1, 1]);
        }
      }
    }

    translate([0, y_front_chassis_rear_frame_joint_1_start, 0]) {
      front_chassis_joint_female(slot_mode=true);
    }

    front_chassis_rpi(slot_mode=true);
    if (show_ribbon_slots) {
      front_chassis_ribbon_slots();
    }

    translate([0, y_front_chassis_rear_frame_main_start, 0]) {
      front_chassis_pin_joint_holes(center=true,
                                    direction=1,
                                    use_pad=false,
                                    pad_side="bottom");
    }
    translate([0, -bellcrank_y_distance_from_bulkhead, 0]) {
      bellcrank_steering_with_servo_position() {
        steering_servo_chassis_slots(center_y=false,
                                     sink="countersunk");
      }
    }

    translate([0, front_chassis_y_joint_2_end + joint_l, 0]) {
      front_chassis_body_joint(mode="female", w=width, slot_mode=true);
    }
  }

  if (debug) {
    translate([0, 0, chassis_thickness + 0.1]) {
      _debug();
      mirror([1, 0, 0]) {
        _debug(rotation=[0, 180, 0]);
      }
    }
  }
}

module front_chassis_rear_frame_printable(debug=false, color=white_smoke_1) {
  front_chassis_rear_frame(debug=$preview ? debug : false, color=color);
}

front_chassis_rear_frame();
