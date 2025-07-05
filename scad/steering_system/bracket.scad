include <../parameters.scad>
use <../util.scad>
use <../placeholders/servo.scad>

module bracket_part_2d(size=bracket_size,
                       thickness=bracket_thickness,
                       screws_dia=bracket_screws_dia) {
  x = size[0];
  y = size[1];
  difference() {
    rad = screws_dia / 2;
    rounded_rect_two([x, y], r=x / 2);
    translate([x / 2, y - screws_dia, 0]) {
      circle(r=rad, $fn=360);
    }
  }
}

module bracket(size=bracket_size,
               thickness=bracket_thickness,
               screws_dia=bracket_screws_dia) {
  linear_extrude(height = bracket_thickness, center=true) {
    union() {
      size_a = [size[0], size[2]];
      size_b = [size[0], size[1]];
      bracket_part_2d(size=size_a, thickness=thickness, screws_dia=screws_dia);

      rotate([0, 0, -90]) {
        rounded_rect_two(size=[size[0], size[0]], r=size[0] / 2);
      }
      translate([size[0], 0, 0]) {
        rotate([0, 0, 180]) {
          rounded_rect_two(size=[size[0], size[0]], r=size[0] / 2);
        }
      }
      translate([0, -size[0], 0]) {
        rotate([0, 0, 90]) {
          bracket_part_2d(size=size_b, thickness=thickness, screws_dia=screws_dia);
        }
      }
    }
  }
}
