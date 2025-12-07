include <../colors.scad>
include <../parameters.scad>

module pin_header_item(base_size,
                       pin_colr=metallic_yellow_1,
                       base_colr=matte_black,
                       pin_size,
                       z_offset=0) {
  header_x = base_size[0];
  header_y = base_size[1];

  pin_x = pin_size[0];
  pin_y = pin_size[1];
  pin_height = pin_size[2];

  union() {

    color(base_colr) {
      cube(base_size);
    }
    color(pin_colr) {
      translate([(header_x - pin_x) / 2,
                 (header_y - pin_y) / 2,
                 -z_offset]) {
        cube([pin_x, pin_y, pin_height]);
      }
    }
  }
}

module pin_headers(cols,
                   rows,
                   header_width,
                   header_height,
                   header_y_width,
                   pin_height,
                   p,
                   z_offset=0,
                   center=false) {
  header_y_width = is_undef(header_y_width) ? header_width : header_y_width ;
  total_x = header_width * rows;
  total_y = header_y_width * cols;

  translate([center ? -total_x / 2 : 0, center ? - total_y / 2 : 0, 0]) {

    for (y = [0 : (cols -1)]) {
      for (x = [0 : (rows  - 1)]) {
        translate([header_width * x, header_y_width * y, 0]) {
          union() {
            pin_header_item(base_size=[header_width, header_y_width, header_height],
                            pin_size=[p, p, pin_height],
                            z_offset=z_offset);
          }
        }
      }
    }
  }
}

rotate([0, 0, 0]) {
  pin_headers(cols=20,
              rows=1,
              header_width=rpi_pin_header_width,
              header_height=rpi_pin_header_height,
              pin_height=rpi_pin_height,
              z_offset=0.5,
              center=true,
              p=0.65);
}
