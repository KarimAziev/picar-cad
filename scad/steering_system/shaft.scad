include <../parameters.scad>
use <../util.scad>
use <../placeholders/servo.scad>

module shaft(d=knuckle_shaft_dia, h=knuckle_shaft_len) {
  rotate([0, 90, 0]) {
    linear_extrude(height=h, center=true) {
      circle(r=d / 2, $fn=120);
    }
  }
}

module bent_cylinder(r=5, upper_horiz_len=15, vertical_len=23, lower_horiz_len=20, bend_r=5, $fn=64) {
  union() {
    translate([upper_horiz_len + r * 2, 0, -r]) {
      rotate([0, 90, 0]) {
        cylinder(h = upper_horiz_len, r = r, center = false, $fn=$fn);
      }
    }

    translate([upper_horiz_len + r * 2, 0, 0]) {
      rotate([90, 0, 180]) {
        rotate_extrude(angle = -90, $fn = $fn)
          translate([bend_r, 0]) {
          circle(r = r, $fn = $fn);
        }
      }
    }

    translate([upper_horiz_len + bend_r, 0, 0]) {
      cylinder(h = vertical_len, r = r, center = false, $fn=$fn);
      translate([-lower_horiz_len - r, 0, vertical_len + r]) {
        rotate([0, 90, 0]) {
          cylinder(h = lower_horiz_len, r = r, center = false, $fn=$fn);
        }
      }
      translate([- bend_r, 0, vertical_len]) {
        rotate([90, 0, 0]) {
          rotate_extrude(angle = 90, $fn = $fn)
            translate([bend_r, 0]) {
            circle(r = r, $fn = $fn);
          }
        }
      }
    }
  }
}

bent_cylinder();