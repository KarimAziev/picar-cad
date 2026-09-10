include <../../scad/suspension/rear_chassis/computed_params.scad>
include <../../scad/suspension/middle_chassis/computed_params.scad>
use <../../scad/lib/plist.scad>
use <../../scad/lib/shapes3d.scad>
use <../../scad/placeholders/rc_gearmotor.scad>
use <../../scad/placeholders/rc_driveshaft.scad>
use <../../scad/placeholders/rc_dogbone.scad>
use <../../scad/suspension/rear_suspension/rear_suspension_chassis.scad>
use <../../scad/suspension/rear_suspension/rear_suspension_slots.scad>
use <../../scad/suspension/rear_chassis/rear_chassis.scad>
use <../../scad/suspension/rear_chassis/rear_chassis_motor_carrier.scad>
use <../../scad/suspension/rear_chassis/rear_chassis_assembly.scad>
use <../../scad/suspension/middle_chassis/middle_chassis.scad>
use <../../scad/suspension/front_chassis/front_chassis_assembly.scad>

part = "rear";
front_spacing = 0;
middle_spacing = 0;
rear_spacing = 0;
motor_spacing = 0;
layout = rear_chassis_layout();

module motor() {
  rear_chassis_motor_position() rc_gearmotor();
}
module shaft() {
  rc_driveshaft_between(plist_get("shaft_start", layout), plist_get("shaft_end", layout));
}
module carrier() {
  rear_chassis_carrier_position() rear_chassis_motor_carrier();
}
if (part == "rear") rear_chassis();
if (part == "carrier") rear_chassis_motor_carrier();
if (part == "first_layer") intersection() {
  rear_chassis();
  cuboid([plist_get("size", layout)[0], plist_get("size", layout)[1], 0.2], anchor=[0, -1, 1]);
}
if (part == "motor") rc_gearmotor();
if (part == "dogbone") rc_dogbone();
if (part == "suspension") rear_suspension_chassis();
if (part == "suspension_slots") rear_suspension_slots();
if (part == "suspension_centered") rear_suspension_chassis(anchor=[0, 0, 1]);
if (part == "suspension_collision") intersection() {
  rear_chassis();
  rear_chassis_suspension_position() rear_suspension_slots();
}
if (part == "dogbone_collision") intersection() {
  rear_chassis_dogbone_position() rc_dogbone();
  union() { rear_chassis(); carrier(); shaft(); }
}
if (part == "shaft") rc_driveshaft(drop=plist_get("shaft_start", layout)[2]
                                        - plist_get("shaft_end", layout)[2]);
if (part == "assembly") rear_chassis_assembly(show_rear_differential_envelope=true);
if (part == "motor_collision") intersection() {
  motor();
  union() { rear_chassis(); carrier(); }
}
if (part == "shaft_collision") intersection() {
  shaft();
  union() { rear_chassis(); carrier(); motor(); }
}
if (part == "joint_collision") intersection() {
  rear_chassis();
  translate([0, middle_chassis_size()[1] - joint_l, 0])
    middle_chassis(anchor=[0, -1, 1]);
}
if (part == "placed_rear" || part == "placed_carrier") front_chassis_assembly(
  show_chassis_front_frame=false, show_chassis_rear_frame=false,
  show_front_chassis_components=false, show_head=false,
  show_middle_chassis=false, show_middle_chassis_components=false,
  show_rear_chassis=part == "placed_rear",
  show_rear_motor_carrier=part == "placed_carrier",
  show_rear_motor=false, show_rear_gearbox=false,
  show_rear_unused_shaft=false, show_rear_driveshaft=false, show_rear_dogbone=false,
  front_chassis_joint_spacing=front_spacing,
  middle_chassis_joint_spacing=middle_spacing,
  rear_chassis_joint_spacing=rear_spacing,
  rear_motor_spacing=motor_spacing);
