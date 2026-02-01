include <../../colors.scad>
include <../../parameters.scad>

use <../../lib/functions.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>

knuckle_lower_recess_size        = [22, 4];
knuckle_lower_recess_len         = 20;
knuckle_lower_recess_angle_l     = 40; //[0:1:360]
knuckle_lower_recess_angle_start = 0; //[0:1:360]
knuckle_lower_recess_h           = 4;
knuckle_lower_recess_z           = 1;
knuckle_lower_recess_depth       = 0.8;

knuckle_lower_recess_n           = 2;
knuckle_lower_hole_d             = 0.8;
knuckle_lower_hole_gap           = [0.0, 0.0];
knuckle_lower_hole_depth         = 1.9;

knuckle_lower_vent_rect_size     = [1, 0.8, 0.5];
knuckle_lower_vent_rect_col_gap  = 0.4;
knuckle_lower_vent_rect_row_gap  = 0.35;
knuckle_lower_vent_rect_rows     = 3;

function arc_len_to_angle_deg(s, D) = 360 * s / (PI * D);

module hole_grid_fill_rect_2d(rect_size, hole_d=1, gap=[0, 0]) {
  pitch = [hole_d + gap[0], hole_d + gap[1]];

  cols = max(1, floor((rect_size[0] - hole_d) / pitch[0]) + 1);
  rows = max(1, floor((rect_size[1] - hole_d) / pitch[1]) + 1);

  for (cx = [0:cols-1])
    for (ry = [0:rows-1]) {
      x = (cx - (cols-1)/2) * pitch[0];
      y = (ry - (rows-1)/2) * pitch[1];
      translate([x, y]) {
        children();
      }
    }
}

module bend_rect(h, depth, angle, d, fn=200) {
  rotate_extrude(angle = angle, $fn=fn) {
    translate([d / 2 - depth, 0, 0]) {
      square(size = [depth, h],
             center = false);
    }
  }
}
function arc_len_to_angle_deg(s, D) = 360 * s / (PI * D);

module vent_grid(rows=3,
                 row_gap=0.4,
                 col_gap=0.4,
                 size=knuckle_lower_vent_rect_size,
                 recess_angle=180,
                 d1=knuckle_narrow_d,
                 d2=knuckle_base_d,
                 h=knuckle_narrow_h,
                 z=0) {
  factor = to_percent(recess_angle, 360) / 100;
  _size = [size[0], size[1], size[2]];
  a   = taper_angle_from_axis(d1, d2, h);

  sgn = (d2 >= d1) ? -1 : 1;
  angle = sgn * a;

  x_size = _size[0];
  y_size = _size[1];
  z_size = _size[2];
  rotated_bbox = calc_rotated_bbox(w=y_size, h=z_size, a=angle);

  full_x = rotated_bbox[0];
  full_y = rotated_bbox[1];
  sx = rotated_bbox[2];
  sy = rotated_bbox[3];

  max_d = max(d1, d2);

  difference() {

    intersection() {
      cylinder(d1=d1, d2=d2, h=h, $fn=360);
      translate([0, 0, z]) {
        union() {
          for (j = [0 : rows - 1]) {
            let (y = j * (z_size + row_gap),
                 d_at = diameter_at_z(d1, d2, h, z + y),
                 circumference = PI * d_at,
                 n = circumference / (size[0] + col_gap),
                 is_odd = (j % 2) != 0) {
              for (i = [0 : n],
                     ang = i * 360 / n) {
                let (odd_offst = (is_odd ? -y_size / 2 : 0),
                     bbox = calc_rotated_bbox(w=x_size, h=y_size, a=ang)) {

                  translate([0, 0, 0]) {
                    translate([0, 0, y]) {
                      translate([0, 0, 0]) {

                        rotate([0, 0, ang]) {

                          translate([d_at / 2 - y_size / 2,
                                     odd_offst,
                                     full_y / 2]) {
                            translate([0, 0, 0]) {
                              rotate([0, angle, 0]) {
                                cube([y_size, x_size, z_size], center=true);
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
      }
    }
    translate([0, factor * max_d, h / 2]) {
      cube([max_d, max_d, h + 1], center=true);
    }
  }
}

module cylinder_recess(d1,
                       d2,
                       d,
                       z,
                       h,
                       recess_angle=knuckle_lower_recess_angle_l,
                       recess_h,
                       recess_depth,
                       fn=360) {

  factor = to_percent(recess_angle, 360) / 100;
  d1 = with_default(d1, d);
  d2 = with_default(d2, d);

  recess_d1 = diameter_at_z(d1=d1, d2=d2, h=h, z=z);
  recess_d2 = diameter_at_z(d1=d1, d2=d2, h=h, z=z + recess_h);
  max_d = max(d1, d2);

  difference() {
    translate([0, 0, z]) {
      difference() {
        cylinder(d1=recess_d1 + 0.1, d2=recess_d2 + 0.1, h=recess_h, $fn=fn);
        translate([0, 0, -0.5]) {
          cylinder(d1=recess_d1 - recess_depth,
                   d2=recess_d2 - recess_depth,
                   h=recess_h + 1,
                   $fn=fn);
        }
      }
    }

    translate([0, factor * max(recess_d1, recess_d2), h / 2]) {
      cube([max_d, max_d, h + 1], center=true);
    }
  }
}

module knuckle_lower(d1=knuckle_narrow_d,
                     d2=knuckle_base_d,
                     color=cobalt_blue_metallic,
                     d=knuckle_bearing_hole_d,
                     h=knuckle_narrow_h,
                     z=knuckle_lower_recess_z,

                     recess_depth=knuckle_lower_recess_depth,
                     recess_angle=90,
                     recess_h=knuckle_lower_recess_h,
                     z_center,
                     vent_rect_size=knuckle_lower_vent_rect_size,
                     row_gap=knuckle_lower_vent_rect_row_gap,
                     col_gap=knuckle_lower_vent_rect_col_gap,
                     rows=knuckle_lower_vent_rect_rows,
                     $fn=360) {

  z_center = with_default(z_center, h / 2);

  total_vent_z = rows * vent_rect_size[2] + (rows - 1) * row_gap;
  ring_w = (knuckle_narrow_d - knuckle_bearing_hole_d) / 2;

  module _recess() {
    cylinder_recess(d1=d1,
                    d2=d2,
                    h=h,
                    z=z,
                    recess_depth=recess_depth,
                    recess_angle=recess_angle,
                    recess_h=recess_h);
    vent_grid(z=z + (recess_h / 2 - total_vent_z / 2),
              d1=d1 - recess_depth / 2,
              d2=d2 - recess_depth / 2,
              rows=3,
              size=vent_rect_size,
              row_gap=row_gap,
              col_gap=col_gap);
  }

  render() {
    union() {
      difference() {
        maybe_color(color) {
          cylinder(d1=d1, d2=d2, h=h, $fn=$fn);
        }
        translate([0, 0, -recess_depth]) {
          ring(outer_d1=knuckle_bearing_hole_d + ring_w * 2,
               outer_d2=knuckle_bearing_hole_d + ring_w,
               d1=(knuckle_bearing_hole_d + ring_w),
               d2=(knuckle_bearing_hole_d + ring_w) - 1.5,
               h=recess_depth * 2,
               fn=250);
        }

        translate([0, 0, -0.5]) {
          cylinder(d=d, h=h + 1);
        }

        _recess();

        rotate([0, 0, 180]) {
          _recess();
        }
      }
    }
  }
}
d1=knuckle_narrow_d;
d2=knuckle_base_d;
h=knuckle_narrow_h;
z = 0;
// knuckle_lower(recess_depth=knuckle_lower_recess_depth,
//               recess_size=knuckle_lower_recess_size,
//               n=knuckle_lower_recess_n,
//               hole_d=knuckle_lower_hole_d,
//               hole_gap=knuckle_lower_hole_gap,
//               hole_depth=knuckle_lower_hole_depth);

difference() {
  // knuckle_lower();
}

// cylinder_recess(d1=d1,
//                 d2=d2,
//                 h=h,
//                 z=z,
//                 recess_depth=knuckle_lower_recess_depth,
//                 recess_angle=100,
//                 recess_h=knuckle_lower_recess_h);

knuckle_lower();
