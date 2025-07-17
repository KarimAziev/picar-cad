include <../parameters.scad>
include <../colors.scad>
use <../util.scad>
use <bracket.scad>
use <shaft.scad>

use <rack_connector.scad>
use <bearing_shaft.scad>
use <bearing_connector.scad>
use <../wheels/wheel_hub.scad>
use <../wheels/front_wheel.scad>

module knuckle_mount(show_wheels=false, knuckle_color=blue_grey_carbon, knuckle_color_alpha=0.6, knuckle_shaft_color=onyx) {
  union() {
    border_w = (knuckle_dia - knuckle_bearing_outer_dia) / 2;
    color(knuckle_color, alpha=knuckle_color_alpha) {
      linear_extrude(height=knuckle_height, center=false) {
        ring_2d_outer(r = knuckle_bearing_outer_dia / 2,
                      w = border_w, fn=360);
      }
    }

    notch_width = calc_notch_width(knuckle_dia, knuckle_shaft_dia);
    d = knuckle_shaft_dia;
    upper_horiz_len = knuckle_shaft_upper_horiz_len;
    lower_horiz_len = knuckle_shaft_lower_horiz_len;
    r = d / 2;

    translate([0, 0, -knuckle_shaft_vertical_len]) {
      union() {
        translate([0, -knuckle_dia / 2 + notch_width / 2, 0]) {
          vertical_len=knuckle_shaft_vertical_len + notch_width;
          translate([0, 0, vertical_len + r]) {
            color(knuckle_shaft_color) {
              rotate([90, 0, 0]) {
                cylinder(h = upper_horiz_len, r = r, center = false, $fn=$fn);
              }
            }

            translate([0, -upper_horiz_len, -r]) {
              color(knuckle_shaft_color) {
                rotate([90, 0, -90]) {
                  rotate_extrude(angle = 90, $fn = $fn)
                    translate([r, 0]) {
                    circle(r = r, $fn = $fn);
                  }
                }
              }
            }
            translate([0, -upper_horiz_len - r, -vertical_len - r]) {
              color(knuckle_shaft_color) {
                cylinder(h = vertical_len, r = r, center = false, $fn=$fn);
              }

              translate([0, r, 0]) {
                rotate([-0, 90, 0]) {
                  color(knuckle_shaft_color) {
                    rotate_extrude(angle = -90, $fn = $fn)
                      translate([r, 0]) {
                      circle(r = r, $fn = $fn);
                    }
                  }
                }
                translate([0, 0, -r]) {
                  rotate([-90, 0, 0]) {
                    color(knuckle_shaft_color) {
                      cylinder(h = upper_horiz_len + knuckle_dia / 2, r = r, center = false, $fn=$fn);
                    }
                  }
                  translate([r, upper_horiz_len + knuckle_dia / 2, 0]) {
                    color(knuckle_shaft_color) {
                      rotate([0, 0, 90]) {
                        rotate_extrude(angle = 90, $fn = $fn)
                          translate([r, 0]) {
                          circle(r = r, $fn = $fn);
                        }
                      }
                    }

                    translate([0, r, 0]) {
                      rotate([0, 90, 0]) {
                        color(knuckle_shaft_color) {
                          cylinder(h = lower_horiz_len, r = r, center = false, $fn=$fn);
                        }

                        if (show_wheels) {
                          wheel_offst = wheel_w > lower_horiz_len ? lower_horiz_len : wheel_w + (wheel_w - lower_horiz_len);
                          translate([0, 0, wheel_offst]) {
                            front_wheel_animated();
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    color(knuckle_color) {
      rotate([0, 0, knuckle_bracket_connector_angle]) {
        extra_w = calc_notch_width(knuckle_dia, knuckle_bracket_connector_len);

        translate([knuckle_dia / 2 - border_w,
                   0,
                   knuckle_bracket_connector_height]) {
          linear_extrude(height = knuckle_bracket_connector_height, center=false) {
            difference() {
              square([border_w, bracket_bearing_outer_d], center=true);
              translate([-knuckle_dia / 2, 0, 0]) {
                circle(d=knuckle_dia, $fn=60);
              }
            }
          }
          translate([knuckle_bracket_connector_len / 2, 0, 0]) {
            union() {
              linear_extrude(height = knuckle_bracket_connector_height, center=false) {
                difference() {
                  square([knuckle_bracket_connector_len, bracket_bearing_outer_d], center=true);
                  translate([knuckle_bracket_connector_len / 2, 0, 0]) {
                    circle(d=bracket_bearing_d, $fn=360);
                  }
                }
              }

              translate([knuckle_bracket_connector_len / 2, 0, 0]) {
                bearing_upper_connector();
              }
            }
          }
        }
      }
    }
  }
}

module print_plate() {
  rotate([180, 0, 0]) {
    offst = knuckle_shaft_lower_horiz_len +
      knuckle_dia +
      knuckle_shaft_upper_horiz_len +
      knuckle_bracket_connector_height +
      knuckle_shaft_dia;
    translate([offst / 2, 0, 0]) {
      knuckle_mount();
    }
    translate([-offst / 2, 0, 0]) {
      mirror([1, 0, 0]) {
        knuckle_mount();
      }
    }
  }
}

module assembly_plate() {
  offst = knuckle_shaft_lower_horiz_len +
    knuckle_dia +
    knuckle_shaft_upper_horiz_len +
    knuckle_bracket_connector_height +
    knuckle_shaft_dia;
  translate([offst / 2, 0, 0]) {
    knuckle_mount(show_wheels=true);
  }
  translate([-offst / 2, 0, 0]) {
    mirror([1, 0, 0]) {
      knuckle_mount(show_wheels=true);
    }
  }
}

union() {
  // assembly_plate();
  // print_plate();
  rotate([180, 0, 0]) {
    mirror([1, 0, 0]) {
      knuckle_mount();
    }
  }
}
