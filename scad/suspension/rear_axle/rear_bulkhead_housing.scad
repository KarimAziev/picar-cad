include <../../rc_params.scad>
include <arm_hub_params.scad>

use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>
use <../bulkhead/front_bulkhead.scad>
use <../bulkhead/front_bulkhead_housing.scad>
use <../bulkhead/suspension_arm_pad.scad>
use <rear_lower_arm.scad>

rear_bulkhead_housing_slot_size             = [23.45, 21.76];
rear_bulkhead_housing_recess_size           = [27.46, 22.42, front_bulkhead_housing_h - 1.6];
rear_bulkhead_housing_recess_thickness      = 1.7;
rear_bulkhead_housing_recess_r              = "20%";

rear_bulkhead_rear_suspension_pad_thickness = 8;

rear_bulkhead_dogbone_wheel_z               = 6.6;
rear_bulkhead_dogbone_wheel_hole_z          = 11;
rear_bulkhead_dogbone_motor_bearing_d       = 10;

rear_bulkhead_thickness                     = 2.6;

module rear_bulkhead_housing(slot_size=rear_bulkhead_housing_slot_size,
                             recess_size=rear_bulkhead_housing_recess_size,
                             recess_thickness=rear_bulkhead_housing_recess_thickness,
                             recess_r=rear_bulkhead_housing_recess_r) {
  render() {

    difference() {
      front_bulkhead_housing(center_y=true,
                             show_front_lower_arm=false,
                             show_front_lower_arm_pin=false,
                             show_front_lower_arm_ball_stud=false,
                             show_front_lower_pin_e_clip=false);
      translate([0, 0, recess_thickness]) {
        cuboid(size=[recess_size[0], recess_size[1], front_bulkhead_housing_h],
               r=recess_r);
      }
      translate([0, 0, -0.1]) {
        cuboid(size=[slot_size[0], slot_size[1], front_bulkhead_housing_h + 0.2]);
      }
    }
  }
}

module rear_bulkhead() {
  bulkhead_h = front_bulkhead_shock_tower_mount_offset
               + front_shock_tower_bolt_spacing[1];
  render() {
    difference() {
      front_bulkhead(motor_shaft_bearing_d=rear_bulkhead_dogbone_motor_bearing_d);
      translate([0,
                 0,
                 rear_bulkhead_dogbone_wheel_z]) {
        cyl(d=rear_bulkhead_dogbone_wheel_hole_z,
            h=front_bulkhead_w + front_bulkhead_shock_tower_mount_thickness * 2 + 1,
            orientation="hlw");
      }

      translate([0, 0, -rear_bulkhead_thickness]) {
        cuboid(size=[front_bulkhead_w - rear_bulkhead_thickness * 2, front_bulkhead_len - rear_bulkhead_thickness * 2,
                     bulkhead_h - rear_bulkhead_thickness * 2],
               r_factor=0.5,
               axis="y",
               side="top");
      }
    }
  }
}

module rear_bulkhead_housing_with_arms_and_pad(slot_size=rear_bulkhead_housing_slot_size,
                                               recess_size=rear_bulkhead_housing_recess_size,
                                               recess_thickness=rear_bulkhead_housing_recess_thickness,
                                               recess_r=rear_bulkhead_housing_recess_r) {
  union() {
    rear_bulkhead_housing(slot_size=slot_size,
                          recess_size=recess_size,
                          recess_thickness=recess_thickness,
                          recess_r=recess_r);

    // note, the rear_suspension_mount has corresponding slot for the center hook:
    // see rear_suspension_arm_pad_rect_slot_size in, rear_suspension_arm_pad_bulkhead_slot_dist in scad/suspension/rear_suspension/rear_suspension_params.scad
    translate([0,
               -front_bulkhead_len / 2
               - front_suspension_arm_pad_thickness,
               front_suspension_arm_pad_pin_hole_pad_r * 2 + front_upper_arm_hinge_barrel_hole_d]) {

      rotate([-90, 0, 0]) {
        suspension_arm_pad();
      }
    }

    translate([0,
               front_bulkhead_len / 2,
               front_suspension_arm_pad_pin_hole_pad_r * 2 + front_upper_arm_hinge_barrel_hole_d]) {

      rotate([-90, 0, 0]) {
        suspension_arm_pad(debug=false,
                           hook_h=0,
                           hook_lower_corner_r=0,
                           thickness=rear_bulkhead_rear_suspension_pad_thickness);
      }
    }

    mirror_copy([1, 0, 0]) {
      // bad harcode, because this is just example, of course, should be calculated
      translate([18, 0, 0]) {
        rotate([180, 0, 0]) {
          rear_lower_arm(rear_lower_arm_spec, anchor=[1, 0, -1]);
        }
      }
    }

    translate([0, 0, front_bulkhead_housing_h]) {
      rear_bulkhead();
    }
  }
}

rear_bulkhead_housing_with_arms_and_pad();
