include <../../colors.scad>
include <../../steering_params.scad>

use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>

color = cobalt_blue_metallic;

module knuckle_ball_stud_housing(od=knuckle_ball_stud_mount_outer_d,
                                 base_h=knuckle_ball_stud_house_h,
                                 sphere_h=knuckle_ball_stud_sphere_h,
                                 hole_d=knuckle_ball_stud_mount_hole_d,
                                 ball_stud_d=knuckle_ball_stud_ball_d,
                                 sphere_hole_size=knuckle_ball_stud_sphere_hole_size,
                                 stopper_d=knuckle_ball_stud_stopper_d,
                                 stopper_offset=2,
                                 color=cobalt_blue_metallic) {

  module _cap() {
    difference() {
      intersection() {
        sphere(d=od, $fn=300);
        cube_3d([od, od, sphere_h]);
      }
      translate([0, 0, -0.5]) {
        linear_extrude(height=sphere_h + 1, center=false) {
          rounded_rect(size=sphere_hole_size,
                       center=true,
                       fn=300,
                       r_factor=0.5);
        }
      }
    }
  }

  difference() {
    maybe_color(color) {
      union() {
        cylinder(d=od,
                 h=base_h,
                 $fn=300);
        translate([0, 0, base_h]) {
          _cap();
        }
      }
    }
    translate([0, 0, base_h + stopper_d / 2 - ball_stud_d - stopper_offset]) {
      rotate([90, 0, 0]) {
        cylinder(d=stopper_d, h=od + 1, center=true, $fn=300);
      }
    }
    translate([0, 0, -0.5]) {
      cylinder(d=hole_d,
               h=base_h + 1,
               $fn=300);
    }
  }
}

knuckle_ball_stud_housing();
