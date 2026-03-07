include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>

use <../../lib/functions.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../lib/trapezoids.scad>

function front_bulkhead_base_size(outer_spacing=front_bulkhead_mount_bolt_spacing_1,
                                  d=front_bulkhead_mount_bolt_d,
                                  padding_x=chassis_center_mount_padding_x,
                                  padding_y=chassis_center_mount_padding_y) =
  let (size_x=outer_spacing[0] + d + padding_x,
       size_y=outer_spacing[1] + d + padding_y)
  [size_x, size_y];

module front_bulkhead_chassis_mount_slots(outer_spacing=front_bulkhead_mount_bolt_spacing_1,
                                          inner_spacing=front_bulkhead_mount_bolt_spacing_2,
                                          d=front_bulkhead_mount_bolt_d,
                                          h=front_bulkhead_h,
                                          padding=front_bulkhead_mount_bolt_padding,
                                          center_x=true,
                                          center_y=true) {

  maybe_translate([center_x ? -outer_spacing[0] / 2 - d / 2 : 0,
                   center_y ? -outer_spacing[1] / 2 - d / 2 : 0,
                   0]) {
    four_corner_counterbores(size=outer_spacing,
                             d=d,
                             h=h,
                             sink=true,
                             center=false);

    translate([0, outer_spacing[1] - inner_spacing[1] - d - padding, 0]) {
      four_corner_counterbores(size=inner_spacing,
                               d=d,
                               h=h,
                               sink=true,
                               center=false);
    }
  }
}

module front_bulkhead_chassis(outer_spacing=front_bulkhead_mount_bolt_spacing_1,
                              d=front_bulkhead_mount_bolt_d,
                              padding_x=chassis_center_mount_padding_x,
                              padding_y=chassis_center_mount_padding_y,
                              transition_w=chassis_center_transition_w,
                              transition_len=chassis_center_transition_len,
                              h=upper_chassis_t) {

  size = front_bulkhead_base_size(outer_spacing=outer_spacing,
                                  d=d,
                                  padding_x=padding_x,
                                  padding_y=padding_y);
  size_x = size[0];
  size_y = size[1];

  translate([0, size_y / 2 + transition_len, 0]) {
    union() {
      difference() {
        linear_extrude(height=h, center=false) {
          rounded_rect(size,
                       r=1,
                       side="top",
                       center=true);
        }

        front_bulkhead_chassis_mount_slots(center_x=true,
                                           center_y=true,
                                           outer_spacing=outer_spacing,
                                           h=h,
                                           d=d);
      }
      translate([0, -size_y / 2 - transition_len / 2, 0]) {
        linear_extrude(height=h, center=false) {
          trapezoid(b=transition_w, h=transition_len, t=size_x, center=true);
        }
      }
    }
  }
}

front_bulkhead_chassis();