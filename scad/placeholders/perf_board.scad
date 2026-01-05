include <../parameters.scad>

use <../lib/shapes2d.scad>
use <../lib/holes.scad>
use <../lib/transforms.scad>
use <../lib/plist.scad>
use <standoff.scad>

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
                  perf_grid_d=1,
                  spacing=0.54,
                  bolt_d=2.0,
                  bolt_spacing=[16.0, 76.0],
                  rows=28,
                  cols=6,
                  $fn=100,
                  bus_pad_rx=1.9,
                  bus_pad_ry=1.0,
                  bus_pad_cols=4,
                  bus_pad_offset = 0.8,
                  bus_pad_spacing=0.8,
                  standoff_h = 2,
                  bolt_visible_h = 2,
                  perf_color="green",
                  pin_color="silver",
                  bus_pad_color="silver",
                  stand_up=true,
                  show_bolt = true,
                  show_standoff = true,
                  show_nut=true) {
  x = size[0];
  y = size[1];
  z = size[2];

  standoffs = calc_standoff_params(min_h=standoff_h, d=bolt_d);
  standoff_real_h = len(standoffs[1]) > 0 ? sum(standoffs[1]) : 0;

  translate([0, 0, stand_up ? with_default(standoff_real_h, 0) : 0]) {
    union() {
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
                perf_grid(d=perf_grid_d,
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
                  translate([-total_x / 2,
                             y / 2 -
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
            four_corner_holes_2d(size=bolt_spacing,
                                 hole_dia=bolt_d,
                                 center=true);
          }
        }
      }
    }
    if (show_standoff && !is_undef(standoff_h) && standoff_h > 0) {
      translate([0, 0, -standoff_real_h]) {
        four_corner_children(size=bolt_spacing, center=true) {
          standoffs_stack(d=bolt_d,
                          show_bolt=show_bolt,
                          nut_pos=standoff_h,
                          bolt_visible_h=bolt_visible_h,
                          min_h=standoff_h,
                          show_nut=show_nut);
        }
      }
    }
  }
}

module perf_bord_from_plist(plist,
                            bolt_visible_h=2,
                            stand_up=true,
                            show_bolt = true,
                            show_standoff = true,
                            show_nut=true,
                            center=true) {
  plist = with_default(plist, []);
  size = plist_get("size", plist, [20, 80, 1.6]);
  corner_r = plist_get("corner_r", plist, 1);
  pad_dia = plist_get("pad_dia", plist, 1.9);
  perf_grid_d = plist_get("perf_grid_d", plist, 1);
  spacing = plist_get("spacing", plist, 0.54);
  bolt_d = plist_get("d", plist, 2.0);
  bolt_spacing = plist_get("slot_size",
                           plist,
                           [16.0, 76.0]);
  rows = plist_get("rows", plist, 28);
  cols = plist_get("cols", plist, 6);
  $fn = plist_get("$fn", plist, 100);
  bus_pad_rx = plist_get("bus_pad_rx", plist, 1.9);
  bus_pad_ry = plist_get("bus_pad_ry", plist, 1.0);
  bus_pad_cols = plist_get("bus_pad_cols", plist, 4);
  bus_pad_offset = plist_get("bus_pad_offset", plist,  0.8);
  bus_pad_spacing = plist_get("bus_pad_spacing", plist, 0.8);
  perf_color = plist_get("perf_color", plist, "green");
  pin_color = plist_get("pin_color", plist, "silver");
  bus_pad_color = plist_get("bus_pad_color", plist, "silver");
  standoff_h = plist_get("standoff_h", plist,  2);

  translate([center ? 0 : size[0] / 2, center ? 0 : size[1] / 2, 0]) {
    perf_board(size=size,
               corner_r=corner_r,
               pad_dia=pad_dia,
               perf_grid_d=perf_grid_d,
               spacing=spacing,
               bolt_d=bolt_d,
               bolt_spacing=bolt_spacing,
               rows=rows,
               cols=cols,
               $fn=$fn,
               bus_pad_rx=bus_pad_rx,
               bus_pad_ry=bus_pad_ry,
               bus_pad_cols=bus_pad_cols,
               bus_pad_offset=bus_pad_offset,
               bus_pad_spacing=bus_pad_spacing,
               perf_color=perf_color,
               pin_color=pin_color,
               standoff_h=standoff_h,
               bolt_visible_h=bolt_visible_h,
               bus_pad_color=bus_pad_color,
               stand_up=stand_up,
               show_bolt=show_bolt,
               show_standoff=show_standoff,
               show_nut=show_nut);
  }
}

perf_bord_from_plist();