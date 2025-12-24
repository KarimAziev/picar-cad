include <../parameters.scad>

use <../lib/shapes2d.scad>
use <../lib/holes.scad>
use <../lib/transforms.scad>

module perf_grid(cols, rows, d, pad_d, spacing, h, $fn=100) {
  step = spacing + pad_d;
  total_x = cols * pad_d + (cols - 1) * spacing;
  total_y = rows * pad_d + (rows - 1) * spacing;

  translate([-total_x/2, -total_y/2, 0]) {
    for (i = [0 : cols - 1]) {
      let (x = i * step + pad_d / 2) {
        for (j = [0 : rows - 1]) {
          let (y = j * step + pad_d / 2) {
            translate([x, y, 0]) {
              difference() {
                cylinder(r = pad_d / 2, h = h, $fn = $fn);
                translate([0, 0, -0.5]) {
                  cylinder(r = d / 2, h = h + 1, $fn = $fn);
                }
              }
            }
          }
        }
      }
    }
  }
}

module perf_board(size=[20, 80, 1.6],
                  corner_r=1,
                  pad_dia=1.9,
                  d=1,
                  spacing=0.54,
                  bolt_d=2.0,
                  bolt_spacing=power_lid_breadboard_bolt_spacing,
                  rows=28,
                  cols=6,
                  $fn=100,
                  bus_pad_rx=1.9,
                  bus_pad_ry=1.0,
                  bus_pad_cols=4,
                  bus_pad_offset = 0.8,
                  bus_pad_spacing=0.8,
                  perf_color="green",
                  pin_color="silver",
                  bus_pad_color="silver") {
  x = size[0];
  y = size[1];
  z = size[2];

  difference() {
    union() {
      color(perf_color, alpha=1) {
        difference() {
          linear_extrude(height=z, center=false) {
            rounded_rect([x, y], center=true, r=corner_r, fn=$fn);
          }
        }
      }
      if (cols > 0 && rows > 0 && pad_dia > 0) {
        color(pin_color, alpha=1) {
          translate([0, 0, -0.05]) {
            perf_grid(d=d,
                      cols=cols,
                      rows=rows,
                      h=z + 0.1,
                      pad_d=pad_dia,
                      spacing=spacing,
                      $fn=$fn);
          };
        }
      }
      if (bus_pad_cols > 0) {
        color(bus_pad_color, alpha=1) {
          mirror_copy([0, 1, 0]) {
            let (step = bus_pad_spacing + bus_pad_rx,
                 total_x = bus_pad_cols * bus_pad_rx + (bus_pad_cols - 1)
                 * bus_pad_spacing) {
              translate([-total_x / 2, y / 2 -
                         (bus_pad_ry + bus_pad_rx) / 2,
                         -0.05]) {
                linear_extrude(height=z + 0.1, center=false) {
                  for (i = [0 : bus_pad_cols - 1]) {
                    let (bx = i * step + bus_pad_rx / 2) {
                      translate([bx, -bus_pad_offset, 0]) {
                        capsule(y=bus_pad_ry,
                                d=bus_pad_rx,
                                center=true);
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
    translate([0, 0, -0.1]) {
      linear_extrude(height=z + 0.2, center=false) {
        four_corner_holes_2d(size=bolt_spacing, hole_dia=bolt_d,
                             center=true);
      }
    }
  }
}

perf_board(size=[20, 80, 1.6],
           corner_r=1,
           pad_dia=1.9,
           d=1,
           spacing=0.54,
           bolt_d=2.0,
           bolt_spacing=power_lid_breadboard_bolt_spacing,
           rows=28,
           cols=6,
           $fn=100,
           bus_pad_rx=1.9,
           bus_pad_ry=1.0,
           bus_pad_cols=4,
           bus_pad_offset = 0.8,
           bus_pad_spacing=0.8,
           perf_color="green",
           pin_color="silver",
           bus_pad_color="silver");
