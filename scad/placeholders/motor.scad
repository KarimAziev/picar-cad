include <../parameters.scad>
use <../util.scad>

motor_shaft_color     = "#e6e6e6";
gearbox_color         = "#ffde1a";
motor_can_color       = "silver";
endcap_color          = "#191919";

gearbox_body_main_len = 37;
gearbox_height        = 22.6;
gearbox_side_height   = 19.5;
motor_body_neck_len   = 11.4;
motor_can_len         = 9.6;
endcap_len            = 8.5;
motor_shaft_len       = 35;

gearbox_neck_rad      = gearbox_height / 2;
motor_can_rad         = gearbox_neck_rad  * 0.9;
endcap_rad            = gearbox_neck_rad  * 0.86;

module motor_can(h=motor_can_len, r=motor_can_rad, cutted_w=4) {
  translate([0, 0, -motor_body_neck_len * 0.5]) {
    union() {
      union() {
        full_len = h + motor_body_neck_len;
        color(motor_can_color) {
          cylinder_cutted(h=full_len, r=r, cutted_w=cutted_w);
        }

        translate([0, 0, full_len * 0.5]) {
          color(motor_can_color) {
            cylinder(h = endcap_len, r = 1.6, center = false);
          }
          color(endcap_color) {
            cylinder_cutted(h=endcap_len, r=endcap_rad, cutted_w=cutted_w);
            head_h = 6;
            translate([0, 0, head_h * 0.5]) {
              cylinder_cutted(h=head_h, r=5, cutted_w=2);
            }
          }
        }
      }
    }
  }
}

module motor_gearbox() {
  color(gearbox_color) {
    linear_extrude(height = gearbox_side_height, center=true) {
      difference() {
        rounded_rect_two([gearbox_height, gearbox_body_main_len], r=3, center=true);
        offst_a = 7.8;
        offst_b = 1.6;
        offst_c = 3.0;
        for (x = [[-offst_a, offst_b, -offst_c], [offst_a, -offst_b, -offst_c]]) {
          translate([x[0], -gearbox_body_main_len * 0.5 + 6, 0]) {
            circle(r = m3_hole_dia / 2, $fn=60);
            translate([x[1], x[2], 0]) {
              circle(r = m25_hole_dia / 2, $fn=60);
            }
          }
        }
      }
    }
  }
}

module motor() {
  difference() {
    union() {
      rotate([0, 0, 90]) {
        motor_gearbox();
      }

      translate([gearbox_body_main_len * 0.5 + motor_body_neck_len * 0.5, 0, 0]) {
        rotate([0, 90, 0]) {
          union() {
            color(gearbox_color) {
              difference() {
                cylinder_cutted(h=motor_body_neck_len, r=gearbox_neck_rad, cutted_w=5);
                cube([gearbox_side_height, 5, 2], center=true);
              }
            }

            translate([0, 0, motor_can_len]) {
              motor_can();
            }
          }
        }
      }

      translate([-gearbox_body_main_len * 0.5 + 12, 0, 0]) {
        rotate([0, 0, 90]) {
          color(motor_shaft_color) {
            difference() {
              cylinder_cutted(h=motor_shaft_len, r=2.8, cutted_w=2);
              cylinder(h = motor_shaft_len + 1, r = 0.7, center = true, $fn=60);
            }
          }
        }
        translate([10, 0, 10]) {
          color(gearbox_color) {
            cylinder(h=2, r=2, $fn=50, center=true);
          }
        }
      }

      translate([-gearbox_body_main_len * 0.5 - 2.4, 0, 0]) {
        difference() {
          x = 5;
          y = 5;
          z = 3;
          color(gearbox_color) {
            cube([x, y, z], center=true);
          }

          cylinder(h = z + 1, r = 1.5, center = true, $fn=60);
        }
      }
    }
  }
}

motor();