include <../../scad/suspension/rear_chassis/computed_params.scad>
use <../../scad/lib/plist.scad>
use <../../scad/lib/shapes3d.scad>
use <../../scad/suspension/front_chassis/front_chassis_controls.scad>
use <../../scad/suspension/front_chassis/front_chassis_assembly.scad>
use <../../scad/suspension/front_chassis/front_chassis_front_frame.scad>
use <../../scad/suspension/front_chassis/front_chassis_head_slots.scad>
use <../../scad/suspension/front_chassis/front_chassis_access_slots.scad>
use <../../scad/suspension/middle_chassis/middle_chassis.scad>
use <../../scad/suspension/middle_chassis/middle_chassis_camera_slots.scad>
use <../../scad/suspension/rear_chassis/rear_chassis_motor_carrier.scad>
use <../../scad/placeholders/rc_gearmotor.scad>

part = "motor_middle_collision";
layout = rear_chassis_layout();
rear_y = -middle_chassis_size()[1] / 2 + joint_l;

if (part == "nose_datums") {
  echo(nose_y=front_chassis_front_frame_start_y(),
       head_y=front_chassis_head_center_y(),
       ribbon_y=front_chassis_head_front_ribbon_y(),
       head_reach=front_chassis_head_front_reach());
}

module motor_group() {
  translate([0, rear_y, 0]) {
    rear_chassis_carrier_position() {
      rear_chassis_motor_carrier();
    }
    rear_chassis_motor_position() {
      rc_gearmotor();
    }
  }
}

if (part == "motor_middle_collision") {
  intersection() {
    motor_group();
    middle_chassis();
  }
}
if (part == "motor_electronics_collision") {
  intersection() {
    motor_group();
    // Full-width component envelopes conservatively include their contents.
    front_y = middle_chassis_component_front_y();
    translate([0, front_y - rpi_len / 2, middle_chassis_thickness]) {
      cuboid([rpi_width, rpi_len, rpi_len]);
    }
    for (side = [-1, 1]) {
      translate([middle_chassis_power_case_center_x(side),
                 front_y - power_case_length / 2, middle_chassis_thickness]) {
        cuboid([max(power_case_width, power_lid_width), power_case_length, power_case_length]);
      }
    }
  }
}
if (part == "controls_steering_collision") {
  intersection() {
    front_chassis_controls();
    front_chassis_assembly(show_chassis_front_frame=false, show_chassis_rear_frame=false,
                           show_front_controls=false, show_head=false,
                           show_middle_chassis=false, show_middle_chassis_components=false,
                           show_rear_chassis=false, show_rear_chassis_components=false);
  }
}
if (part == "motor_mount_land") {
  intersection() {
    middle_chassis(show_motor_slots=false);
    for (x = middle_chassis_center_rail_xs(), y = plist_get("bolt_ys", layout)) {
      translate([x, rear_y + y, 0]) {
        cylinder(d=rear_chassis_mount_bolt_d + rear_chassis_mount_land * 2,
                 h=middle_chassis_thickness, $fn=64);
      }
    }
  }
}
if (part == "camera_slots") {
  middle_chassis_camera_slots();
}
if (part == "camera_slot_obstruction") {
  intersection() {
    middle_chassis_camera_slots();
    middle_chassis();
  }
}
if (part == "head_ribbon_slots") {
  front_chassis_head_ribbon_slots();
}
if (part == "head_mount_slots") {
  front_chassis_head_slots();
}
if (part == "front_ribbon_slot") {
  front_chassis_head_front_ribbon_slot();
}
if (part == "front_ribbon_slot_obstruction") {
  intersection() {
    translate([0, front_chassis_head_center_y(), 0]) {
      front_chassis_head_front_ribbon_slot();
    }
    front_chassis_front_frame(debug=false);
  }
}
if (part == "front_access_openings") {
  // Actual frame cuts: four side trapezoids and one front ribbon passage only.
  difference() {
    front_chassis_front_frame(debug=false, show_access_slots=false);
    front_chassis_front_frame(debug=false, show_access_slots=true);
  }
}
if (part == "bumper_lands") {
  nose_y = front_chassis_front_frame_start_y();
  bolt_y = nose_y - front_bumper_bolt_d / 2 - front_bumper_bolt_pad_y;
  centers = [[0, bolt_y],
             [-front_bumper_bolt_spacing_x / 2, bolt_y - front_bumper_center_bolt_y_offset],
             [front_bumper_bolt_spacing_x / 2, bolt_y - front_bumper_center_bolt_y_offset]];
  intersection() {
    front_chassis_front_frame(debug=false);
    for (p = centers) {
      translate([p[0], p[1], 0]) {
        difference() {
          cylinder(d=front_bumper_bolt_d + front_chassis_head_wire_land * 2,
                   h=front_chassis_thickness, $fn=60);
          translate([0, 0, -front_chassis_joint_boolean_overlap]) {
            cylinder(d=front_bumper_bolt_d,
                     h=front_chassis_thickness + front_chassis_joint_boolean_overlap * 2, $fn=60);
          }
        }
      }
    }
  }
}
if (part == "head_ribbon_slot_obstruction") {
  intersection() {
    translate([0, front_chassis_head_center_y(), 0]) {
      front_chassis_head_ribbon_slots();
    }
    front_chassis_front_frame(debug=false);
  }
}
if (part == "head_ribbon_bridges") {
  ys = front_chassis_head_ribbon_slot_ys();
  intersection() {
    front_chassis_front_frame(debug=false);
    for (row = [1:len(ys) - 1]) {
      translate([0, front_chassis_head_center_y() + (ys[row - 1] + ys[row]) / 2, 0]) {
        cuboid([front_chassis_head_ribbon_slot_w, front_chassis_head_ribbon_slot_gap,
                front_chassis_thickness]);
      }
    }
  }
}
if (part == "chassis") {
  front_chassis_assembly(show_front_chassis_components=false, show_head=false,
                         show_middle_chassis_components=false, show_rear_chassis_components=false);
}
