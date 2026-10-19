/**
  * Module: Front bumper fit, anchors and printable mesh fixtures.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../scad/parameters.scad>
include <../../scad/rc_params.scad>

use <../../scad/head/head_neck.scad>
use <../../scad/lib/transforms.scad>
use <../../scad/suspension/front_chassis/front_frame_util.scad>
use <../../scad/suspension/front_chassis/head_frame/front_chassis_head_frame.scad>
use <../../scad/suspension/front_bumper/common.scad>
use <../../scad/suspension/front_bumper/front_bumper_top_plate.scad>
use <../../scad/suspension/front_bumper/front_bumper_foam.scad>
use <../../scad/suspension/front_bumper/front_bumper_assembly.scad>

part = "plate";
variant = false;
anchor = [1, 1, 1];
slot = false;
head_pan = 0;
head_tilt = 0;
reverse_bolts = front_bumper_reverse_bolts;
pl = variant ? ["foam_h", 16, "post_d", 9, "bolt_l", 30] : [];

module placed_bumper() {
  translate(front_bumper_position(pl)) {
    front_bumper_assembly(pl);
  }
}

if (part == "head_frame") {
  front_chassis_head_frame();
} else if (part == "plate") {
  front_bumper_top_plate(pl, anchor=anchor, slot_mode=slot);
} else if (part == "foam") {
  front_bumper_foam(pl, anchor=anchor, slot_mode=slot);
} else if (part == "mutual") {
  intersection() {
    translate(front_bumper_position(pl, "plate")) {
      front_bumper_top_plate(pl);
    }
    translate(front_bumper_position(pl, "foam")) {
      front_bumper_foam(pl);
    }
  }
} else if (part == "frame") {
  intersection() {
    placed_bumper();
    front_chassis_head_frame();
  }
} else if (part == "head") {
  intersection() {
    placed_bumper();
    translate([0, front_chassis_head_center_y(), front_chassis_head_mount_z()]) {
      head_neck(center_pan_servo_slot=true,
                 pan_servo_rotation=head_pan,
                 tilt_servo_rotation=head_tilt);
    }
  }
} else if (part == "bores") {
  intersection() {
    union() {
      placed_bumper();
      front_chassis_head_frame();
    }
    for (pos = front_chassis_bumper_mount_positions()) {
      translate([pos[0], pos[1], -1]) {
        cylinder(d=front_bumper_bolt_d - 0.02, h=60, $fn=48);
      }
    }
  }
} else if (part == "support") {
  // A 0.2 mm skin beneath each post must be fully supported by the deck.
  difference() {
    translate(front_bumper_position(pl, "plate") - [0, 0, 0.2]) {
      difference() {
        intersection() {
          front_bumper_top_plate(pl);
          cube([200, 100, 0.2]);
        }
        // Ignore the faceting tolerance at the nominal clearance-hole rim.
        for (pos = front_bumper_mount_positions(pl, "plate")) {
          translate(pos - [0, 0, 0.01]) {
            cylinder(d=front_bumper_bolt_d + 0.05, h=0.22, $fn=64);
          }
        }
      }
    }
    front_chassis_head_frame();
  }
} else if (part == "print_plate") {
  size = front_bumper_size(pl, "plate");
  translate([0, size[1], size[2]]) {
    rotate([180, 0, 0]) {
      front_bumper_top_plate(pl);
    }
  }
}

module bumper_hardware() {
  difference() {
    front_bumper_top_plate(pl, show_bolts=true, reverse_bolts=reverse_bolts);
    front_bumper_top_plate(pl, show_bolts=false);
  }
}

if (part == "hardware") {
  bumper_hardware();
} else if (part == "hardware_frame") {
  intersection() {
    translate(front_bumper_position(pl, "plate")) {
      bumper_hardware();
    }
    front_chassis_head_frame();
  }
} else if (part == "plate_direction_difference") {
  difference() {
    front_bumper_top_plate(pl, reverse_bolts=true);
    front_bumper_top_plate(pl, reverse_bolts=false);
  }
  difference() {
    front_bumper_top_plate(pl, reverse_bolts=false);
    front_bumper_top_plate(pl, reverse_bolts=true);
  }
}
