include <../../scad/parameters.scad>
include <../../scad/rc_params.scad>
include <../../scad/suspension/front_chassis/computed_params.scad>

use <../../scad/components/plate_joint/plate_joint.scad>
use <../../scad/suspension/front_chassis/front_chassis_joint.scad>

part = "male";
module reference() {
  if (part == "male") {
    front_chassis_joint_male(color=undef, bolt_xs=[]);
  } else {
    front_chassis_joint_female(color=undef, bolt_xs=[], include_pin_holes=true);
  }
}
module candidate() {
  plate_joint(plate_h=chassis_thickness,
              bolt_d=front_chassis_joint_bolt_d,
              w=joint_w,
              l=joint_l,
              rail_w=joint_rail_w,
              clearance=front_chassis_joint_clearance,
              axial_clearance=front_chassis_joint_axial_clearance,
              bolt_n_center=0,
              include_pin_holes=true,
              pin_use_pad=false,
              mode=part);
}
// Compare the actual geometry, including rails, fit and reinforcing passages.
// Bolt patterns and recesses are checked separately from the mating profile.
difference() {
  candidate();
  reference();
}
difference() {
  reference();
  candidate();
}
