include <../colors.scad>
include <../parameters.scad>
include <../steering_params.scad>

use <../lib/debug.scad>
use <../lib/functions.scad>
use <../lib/placement.scad>
use <../lib/slider.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../placeholders/dservo.scad>
use <bellcrank/bellcrank_slots.scad>
use <bellcrank_steering_slots.scad>
use <bulkhead/front_bulkhead_chassis.scad>
use <bulkhead/front_bulkhead_housing.scad>
use <steering_servo_bracket/steering_servo_chassis_slots.scad>
use <wishbone_arms/lower_arm.scad>

connector_rail_angle    = 30;
connector_rail_corner_r = 0;

bellcrank_params        = bellcrank_steering_servo_position();
bellcrank_x_dist        = abs(bellcrank_params[0]);
bellcrank_y_dist        = bellcrank_params[1];
bellcrank_zone_y_len    = bellcrank_params[2];

bellcrank_mount_d       = max(bellcrank_idler_od,
                              upper_chassis_bellcrank_bolt_d,
                              upper_chassis_bellcrank_bolt_bore_d);

bellcrank_mount_r       = bellcrank_mount_d / 2;

servo_slot_min_w        = dsservo_height_after_flange() + bellcrank_x_dist;

bulkhead_barrel_size    = lower_arm_mount_cutout_size();
bulkhead_barrel_len     = bulkhead_barrel_size[1]
                           - front_bulkhead_barrel_hinge_clearance;
bulkhead_transition_len = front_bulkhead_len
                           - bulkhead_barrel_len
                           - front_bulkhead_barrel_y_offset;

bulkhead_base_size = front_bulkhead_base_size(outer_spacing=front_bulkhead_mount_bolt_spacing_1,
                                              d=front_bulkhead_mount_bolt_d,
                                              padding_x=chassis_center_mount_padding_x,
                                              padding_y=chassis_center_mount_padding_y);
bulkhead_size_x         = bulkhead_base_size[0];
bulkhead_size_y         = bulkhead_base_size[1];

bellcrank_x             = chassis_bellcrank_spacing / 2;

connector_w             = (bellcrank_x + bellcrank_mount_r) * 2;

connector_l             = abs(bellcrank_y_dist) - bellcrank_mount_r;

connector_rail_w        = chassis_bellcrank_spacing - bellcrank_mount_r;

connector_bolt_spacing  = chassis_bellcrank_spacing;

connector_bolt_d        = 3;

module front_chassis_connector(color=white_off_1) {
  difference() {
    translate([-connector_w / 2, -connector_l, upper_chassis_t]) {
      rotate([-90, 0, 0]) {
        maybe_color(color) {
          slider_dovetail_rail(l=connector_l,
                               base_w=connector_w,
                               base_h=upper_chassis_t / 3,
                               w=connector_rail_w,
                               h=upper_chassis_t / 2,
                               angle=connector_rail_angle,
                               r=connector_rail_corner_r,
                               center=false);
        }
      }
    }
    translate([0, -connector_l / 2, upper_chassis_t / 2]) {
      four_corner_counterbores(size=[connector_bolt_spacing, 0],
                               d=connector_bolt_d,
                               h=upper_chassis_t / 2);
    }
  }
}

module front_chassis_connector_slot(color=white_off_1) {
  difference() {
    translate([0, -connector_l, 0]) {
      difference() {
        translate([-connector_w / 2, 0, 0]) {
          maybe_color(color) {
            cube([connector_w, connector_l, upper_chassis_t]);
          }
        }
        translate([-connector_w / 2, -0.5, upper_chassis_t + 0.1]) {
          rotate([-90, 0, 0]) {
            slider_dovetail_rail(l=connector_l + 1,
                                 base_w=connector_w,
                                 base_h=upper_chassis_t / 3 + 0.1,
                                 w=connector_rail_w,
                                 h=(upper_chassis_t / 2) + 0.1,
                                 angle=connector_rail_angle,
                                 r=connector_rail_corner_r,
                                 center=false);
          }
        }
      }
    }
    translate([0, -connector_l / 2, 0]) {
      four_corner_counterbores(size=[connector_bolt_spacing, 0],
                               d=connector_bolt_d,
                               h=upper_chassis_t);
    }
  }
}

module front_chassis_front_frame(debug=false, color=white_smoke_1) {
  pts = [[0, bulkhead_size_y + bulkhead_transition_len],
         [bulkhead_size_x / 2, bulkhead_size_y + bulkhead_transition_len],
         [bulkhead_size_x / 2, bulkhead_transition_len],
         [bellcrank_x,
          -bellcrank_y_distance_from_bulkhead + bellcrank_mount_r],
         [bellcrank_x + bellcrank_mount_r,
          -bellcrank_y_distance_from_bulkhead],
         [bellcrank_x + bellcrank_mount_r,
          -bellcrank_y_distance_from_bulkhead - bellcrank_mount_r],
         [0,
          -bellcrank_y_distance_from_bulkhead - bellcrank_mount_r]];

  union() {
    difference() {
      maybe_color(color) {
        linear_extrude(height=upper_chassis_t, center=false, convexity=2) {
          offset_vertices_2d(r=0) {
            mirror_copy([1, 0, 0]) {
              polygon(pts);
            }
          }
        }
      }
      front_bulk_head_housing_slots_non_center_y();
      translate([0,
                 -bellcrank_y_distance_from_bulkhead,
                 0]) {
        bellcrank_steering_slots();
      }
    }
    translate([0, -bellcrank_y_distance_from_bulkhead - bellcrank_mount_r, 0]) {
      front_chassis_connector();
    }
  }

  if (debug) {
    translate([0, 0, upper_chassis_t + 0.1]) {
      debug_polygon_text(pts, font_size=4);
      mirror([1, 0, 0]) {
        debug_polygon_text(pts, rotation=[0, 180, 0], font_size=4);
      }
    }
  }
}

module front_chassis_rear_frame(debug=false, color=white_smoke_1) {

  pts = [[0, -bellcrank_y_distance_from_bulkhead + bellcrank_y_dist],
         [bellcrank_x + bellcrank_mount_r,
          -bellcrank_y_distance_from_bulkhead + bellcrank_y_dist],
         [bellcrank_x + bellcrank_mount_r,
          -bellcrank_y_distance_from_bulkhead - bellcrank_mount_r],
         [servo_slot_min_w,
          -bellcrank_y_distance_from_bulkhead + bellcrank_y_dist],
         [servo_slot_min_w,
          -bellcrank_y_distance_from_bulkhead + bellcrank_zone_y_len
          - connector_l],
         [bellcrank_x + bellcrank_mount_r,
          -bellcrank_y_distance_from_bulkhead + bellcrank_zone_y_len
          - connector_l],

         [bellcrank_x + bellcrank_mount_r,
          -bellcrank_y_distance_from_bulkhead + bellcrank_zone_y_len],

         [0, -bellcrank_y_distance_from_bulkhead + bellcrank_zone_y_len]];

  union() {
    translate([0, -bellcrank_y_distance_from_bulkhead - bellcrank_mount_r, 0]) {
      front_chassis_connector_slot();
    }
    difference() {
      maybe_color(color) {
        linear_extrude(height=upper_chassis_t, center=false, convexity=2) {
          mirror_copy([1, 0, 0]) {
            polygon(pts);
          }
        }
      }
      front_bulk_head_housing_slots_non_center_y();
      translate([0,
                 -bellcrank_y_distance_from_bulkhead,
                 0]) {
        bellcrank_steering_slots();
      }
    }
    translate([0,
               -bellcrank_y_distance_from_bulkhead + bellcrank_zone_y_len,
               0]) {
      front_chassis_connector_slot();
    }
  }

  if (debug) {
    translate([0, 0, upper_chassis_t + 0.1]) {
      debug_polygon_text(pts);
      mirror_copy([1, 0, 0]) {
        debug_polygon_text(pts, rotation=[0, 180, 0]);
      }
    }
  }
}

translate([0, 20, 0]) {
  front_chassis_front_frame();
}
front_chassis_rear_frame();
