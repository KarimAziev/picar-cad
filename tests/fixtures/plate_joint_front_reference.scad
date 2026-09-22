include <../../scad/parameters.scad>
include <../../scad/steering_params.scad>
include <../../scad/suspension/front_chassis/computed_params.scad>
use <../../scad/suspension/front_chassis/front_chassis_joint.scad>
use <../../scad/components/plate_joint/plate_joint.scad>

part = "male";
module reference() {
  if (part == "male") {
    front_chassis_joint_male(color=undef, bolt_xs=[]);
  } else {
    front_chassis_joint_female(color=undef, bolt_xs=[], include_pin_holes=true);
  }
}
module candidate() {
  plate_joint(plate_h=front_chassis_thickness, bolt_d=front_chassis_joint_bolt_d,
              w=joint_w, l=joint_l, rail_w=joint_rail_w,
              bolt_n_center=0, include_pin_holes=true, mode=part);
}
// Compare the actual geometry, including rails, fit and reinforcing passages.
// Bolts are excluded because the new component intentionally defaults to no bore.
difference() {
  candidate();
  reference();
}
difference() {
  reference();
  candidate();
}
