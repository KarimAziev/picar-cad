use <util.scad>;

wheels_distance  = 120;
wheel_height     = 20;
wheel_screws_dia = 3;
body_screws_dia  = 3;
body_width       = 40;
body_height      = 40;
top_plate_height = 15;
top_plate_width  = 55;

module wheels_bottom_plate_body() {
  union() {
    difference() {
      square([body_width, body_height], center=true);
      hole_base_offset = body_width/2;
      hole_body_offset = 4;
      hole_x_offset = hole_base_offset - hole_body_offset;
      hole_y_offset = -(body_height / 2);

      for (offst = [-hole_x_offset, hole_x_offset]) {
        dotted_lines_fill_y(y_length=body_height,
                            starts=[offst, hole_y_offset + body_screws_dia],
                            y_offset=2,
                            r=body_screws_dia/2);
      }
      translate([0, body_height * 0.4]) {
        square([body_width * 0.5, 4 * 2], center=true);
      }

      translate([0, body_height * 0.15]) {
        square([body_width * 0.5, 6], center=true);
      }

      step = 7;
      amount = floor((body_height/2) / step) + 1;

      for (i = [0:amount-1]) {
        translate([0, 0 + -i * step + -1]) {
          rounded_rect([body_width * 0.5, 4], r=2, center=true);
        }
      }
    }
    top_body_connector();
  }
}

module top_body_connector() {
  translate([0, -body_height * 0.5]) {
    square([body_width * 0.4, 3], center=true);
  }
}

module wheels_connector_plate_bottom() {
  difference() {
    rounded_rect([wheels_distance, wheel_height], r=wheel_height/2, center=true);

    neckline_width=wheels_distance / 1.8;
    neckline_height=wheel_height;

    translate([0, -wheel_height * 0.75, 0]) {
      rounded_rect([neckline_width, neckline_height], center=true);
    }

    translate([0, wheel_height * 0.2, 0]) {
      rounded_rect([wheels_distance*0.5, wheel_height*0.13], r=1, center=true);
    }
    line_w = 10;
    line_h = 4;

    for (x = [-wheels_distance/2 + 4, wheels_distance/2 - 4]) {
      translate([x, 0, 0]) {
        circle(r=wheel_screws_dia/2, $fn=360);
        if (x < 0) {
          translate([wheel_screws_dia + line_w/2, 0, 0]) {
            square([line_w, line_h], center = true);
          }
        } else {
          translate([-wheel_screws_dia - line_w/2, 0, 0]) {
            square([line_w, line_h], center = true);
          }
        }
      }
    }

    step = 10;
    amount = floor(wheel_height / step);
    cutoff_w = wheels_distance * 0.7;

    for (i = [0:amount-1]) {
      translate([0, 0 + -i * step]) {
        rounded_rect([cutoff_w, 4], r=2, center=true);
      }
    }

    translate([0, 9]) {
      rounded_rect([cutoff_w, 4], r=2, center=true);
    }
  }
}

module wheels_bottom_plate_top() {
  difference() {
    rounded_rect([top_plate_width, top_plate_height], center=true);
    translate([0, top_plate_height * 0.1, 0]) {
      square([top_plate_width * 0.8, top_plate_height * 0.4], center = true);
    }
    for (x = [-top_plate_width/2 + 4, top_plate_width/2 - 4]) {
      translate([x, -top_plate_height * 0.3, 0]) {
        circle(r=wheel_screws_dia/2, $fn=360);
      }
    }
  }
}

module wheels_down_plate() {
  union(){
    translate([0, body_height * 0.75, 0]) {
      wheels_bottom_plate_top();
    }
    wheels_bottom_plate_body();
    translate([0, -body_height * 0.75, 0]) {
      wheels_connector_plate_bottom();
    }
  }
}

color("white"){
  wheels_down_plate();
}
