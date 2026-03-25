include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>

use <../../lib/functions.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../lib/trapezoids.scad>
use <../wishbone_arms/lower_arm.scad>

function front_bulkhead_base_size(outer_spacing=front_bulkhead_mount_bolt_spacing_1,
                                  d=front_bulkhead_mount_bolt_d,
                                  padding_x=chassis_center_mount_padding_x,
                                  padding_y=chassis_center_mount_padding_y) =
  let (size_x=outer_spacing[0] + d + padding_x,
       size_y=outer_spacing[1] + d + padding_y)
  [size_x, size_y];

module front_bulk_head_housing_slots_non_center_y(barrel_y_offset=front_bulkhead_barrel_y_offset,
                                                  hinge_clearance=front_bulkhead_barrel_hinge_clearance) {
  barrel_size = lower_arm_mount_cutout_size();
  barrel_len = barrel_size[1] - hinge_clearance;

  bolt_spacing_max_y = max(front_bulkhead_mount_bolt_spacing_1[1],
                           front_bulkhead_mount_bolt_spacing_2[1]);

  full_bolt_spacing_y = bolt_spacing_max_y + front_bulkhead_mount_bolt_d;
  translate([0,
             front_bulkhead_len / 2
             - full_bolt_spacing_y
             - barrel_y_offset
             - barrel_len / 2 + full_bolt_spacing_y / 2
             + front_bulkhead_len / 2,
             0]) {
    front_bulkhead_chassis_mount_slots(center_y=false);
  }
}

module front_bulkhead_chassis_mount_slots(outer_spacing=front_bulkhead_mount_bolt_spacing_1,
                                          inner_spacing=front_bulkhead_mount_bolt_spacing_2,
                                          d=front_bulkhead_mount_bolt_d,
                                          h=front_bulkhead_mount_h,
                                          padding=front_bulkhead_mount_bolt_padding,
                                          center_x=true,
                                          center_y=true) {

  front_bulkhead_chassis_with_slots_positions(outer_spacing=outer_spacing,
                                              inner_spacing=inner_spacing,
                                              d=d,
                                              padding=padding,
                                              center_x=center_x,
                                              center_y=center_y) {
    counterbore(d=d, h=h, sink=true);
  }
}

module front_bulkhead_chassis_with_slots_positions(outer_spacing=front_bulkhead_mount_bolt_spacing_1,
                                                   inner_spacing=front_bulkhead_mount_bolt_spacing_2,
                                                   d=front_bulkhead_mount_bolt_d,
                                                   padding=front_bulkhead_mount_bolt_padding,
                                                   center_x=true,
                                                   center_y=true) {

  maybe_translate([center_x ? -outer_spacing[0] / 2 - d / 2 : 0,
                   center_y ? -outer_spacing[1] / 2 - d / 2 : 0,
                   0]) {
    let (size=outer_spacing,
         full_size = four_corner_counterbores_full_size(size=size,
                                                        d=d),

         full_x = full_size[0],
         full_y = full_size[1]) {
      $full_x = full_x;
      $full_y = full_y;
      translate([full_x / 2, full_y / 2, 0]) {
        four_corner_children(size=size,
                             center=true) {
          $outer = true;
          children();
        }
      }
    }

    translate([0, outer_spacing[1] - inner_spacing[1] - d - padding, 0]) {

      let (size=inner_spacing,
           full_size = four_corner_counterbores_full_size(size=size,
                                                          d=d),

           full_x = full_size[0],
           full_y = full_size[1]) {
        $full_x = full_x;
        $full_y = full_y;
        translate([full_x / 2, full_y / 2, 0]) {
          four_corner_children(size=size,
                               center=true) {

            $outer = false;
            children();
          };
        }
      }
    }
  }
}

module front_bulkhead_chassis(outer_spacing=front_bulkhead_mount_bolt_spacing_1,
                              d=front_bulkhead_mount_bolt_d,
                              padding_x=chassis_center_mount_padding_x,
                              padding_y=chassis_center_mount_padding_y,
                              barrel_y_offset=front_bulkhead_barrel_y_offset,
                              transition_w=chassis_center_transition_w,
                              hinge_clearance=front_bulkhead_barrel_hinge_clearance,
                              h=upper_chassis_t) {

  barrel_size = lower_arm_mount_cutout_size();
  barrel_len = barrel_size[1] - hinge_clearance;
  transition_len = front_bulkhead_len - barrel_len - barrel_y_offset;

  size = front_bulkhead_base_size(outer_spacing=outer_spacing,
                                  d=d,
                                  padding_x=padding_x,
                                  padding_y=padding_y);
  size_x = size[0];
  size_y = size[1];

  difference() {
    translate([0, size_y / 2 + transition_len, 0]) {
      union() {
        difference() {
          linear_extrude(height=h, center=false) {
            rounded_rect(size,
                         r=1,
                         side="top",
                         center=true);
          }

          // front_bulkhead_chassis_mount_slots(center_x=true,
          //                                    center_y=true,
          //                                    outer_spacing=outer_spacing,
          //                                    h=h,
          //                                    d=d);
        }
        translate([0, -size_y / 2 - transition_len / 2, 0]) {
          linear_extrude(height=h, center=false) {
            trapezoid(b=transition_w, h=transition_len, t=size_x, center=true);
          }
        }
      }
    }
    front_bulk_head_housing_slots_non_center_y();
  }
}

front_bulkhead_chassis();
