include <../steering_params.scad>

use <bulkhead/front_bulkhead_housing.scad>
use <knuckle/knuckle.scad>
use <wishbone_arms/lower_arm.scad>

show_lower_arm             = true;
show_upper_arm             = true;
show_knuckle_bushing       = true;
show_knuckle_inner_bearing = true;
show_knuckle_outer_bearing = true;
show_knuckle_tie_rod       = true;

module front_suspension_assembly(show_lower_arm=show_lower_arm,
                                 show_upper_arm=show_upper_arm,
                                 show_knuckle_bushing=show_knuckle_bushing,
                                 show_knuckle_inner_bearing=show_knuckle_inner_bearing,
                                 show_knuckle_outer_bearing=show_knuckle_outer_bearing,
                                 show_knuckle_tie_rod=show_knuckle_tie_rod) {
  barrel_size = lower_arm_mount_cutout_size();
  barrel_y_start = front_bulkhead_len - front_bulkhead_barrel_y_offset
    - barrel_size[1];
  bulkhead_full_w = front_bulkhead_w + front_bulkhead_barrel_hinge_w * 2;
  bolt_stud_y_pos = lower_arm_ball_stud_y_pos();

  lower_arm_offset = lower_arm_hinge_barrel_hole_offset
    + front_bulkhead_barrel_pin_hole_offset
    + lower_arm_hinge_barrel_hole_d;

  union() {
    front_bulkhead_housing(center_y=false);

    translate([0,
               bolt_stud_y_pos
               - lower_arm_lower_hinge_barrel_h
               + barrel_y_start,
               knuckle_total_len / 2
               - knuckle_ball_stud_mount_outer_d / 2
               + front_bulkhead_h / 2]) {

      translate([-bulkhead_full_w / 2 + lower_arm_offset,
                 0,
                 0]) {
        knuckle_left(show_lower_arm=show_lower_arm,
                     show_upper_arm=show_upper_arm,
                     show_knuckle_bushing=show_knuckle_bushing,
                     show_knuckle_inner_bearing=show_knuckle_inner_bearing,
                     show_knuckle_outer_bearing=show_knuckle_outer_bearing,
                     show_knuckle_tie_rod=show_knuckle_tie_rod);
      }
      translate([bulkhead_full_w / 2 - lower_arm_offset,
                 0,
                 0]) {
        knuckle_right(show_lower_arm=show_lower_arm,
                      show_upper_arm=show_upper_arm,
                      show_knuckle_bushing=show_knuckle_bushing,
                      show_knuckle_inner_bearing=show_knuckle_inner_bearing,
                      show_knuckle_outer_bearing=show_knuckle_outer_bearing,
                      show_knuckle_tie_rod=show_knuckle_tie_rod);
      }
    }
  }
}

front_suspension_assembly();