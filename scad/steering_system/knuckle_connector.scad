include <../parameters.scad>
include <../colors.scad>
use <../util.scad>

module knuckle_connector(knuckle_color=blue_grey_carbon,
                         outer_d,
                         inner_d,
                         h,
                         length,
                         border_w=border_w,
                         fn=100) {

  ring_w = (outer_d - inner_d) / 2;
  offst = outer_d / 2;
  notch_width = calc_notch_width(max(knuckle_dia, outer_d),
                                 min(knuckle_dia, outer_d));

  union() {
    color(knuckle_color) {
      linear_extrude(height=h, center=false) {
        difference() {
          translate([0, -offst, 0]) {
            difference() {
              square([notch_width + border_w + length, outer_d], center=false);

              translate([0, offst, 0]) {
                circle(d=knuckle_dia, $fn=fn);
              }
            }
          }
        }
      }
    }

    translate([notch_width + length + border_w, 0, 0]) {
      union() {
        color(knuckle_color) {
          linear_extrude(height=h, center=false) {
            translate([0, -outer_d / 2, 0]) {
              difference() {
                square([offst, outer_d], center=false);
                translate([offst, outer_d / 2, 0]) {
                  circle(d=inner_d, $fn=360);
                }
              }
            }
          }
        }
        translate([offst, 0, 0]) {
          color(knuckle_color) {
            linear_extrude(height=h) {
              ring_2d(r=inner_d / 2,
                      w=ring_w,
                      fn=360,
                      outer=true);
            }
          }
          children();
        }
      }
    }
  }
}
