include <../../bolt_parameters.scad>
include <../../colors.scad>

use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>

// 36.7 mm × 10.1 mm × 21.1 mm (Width × Height × Depth)

waggo_conductor_size = [6.9, 21.1, 9.8];
waggo_hole_size_xy   = [6.1, 5.15];

waggo_lid_l          = 16.0;
waggo_lid_t          = 1.3;
waggo_thickness      = 0.7;
waggo_lid_corner_r   = 2;

module wago_conductor(lid_color="#F07F24") {
  hole_l = waggo_conductor_size[1] * 0.7;
  w = waggo_conductor_size[0];
  l = waggo_conductor_size[1];
  h = waggo_conductor_size[2];
  lid_w = w - waggo_thickness;
  lid_corner_r = lid_w / 2;
  lid_l = lid_corner_r + waggo_lid_l;

  translate([0, 0, 0]) {
  }

  difference() {
    union() {
      %color(metallic_silver_1, alpha=0.3) {
        cuboid(size=waggo_conductor_size);
      }
      translate([0, lid_l / 2 - l / 2 - lid_corner_r, h + 0.1]) {
        color(lid_color, alpha=1) {
          difference() {
            hull() {
              cuboid(size=[lid_w, lid_l, waggo_lid_t],
                     side="bottom",
                     r=lid_corner_r,
                     anchor=[0, 0, -1]);
              translate([0,
                         lid_l / 2,
                         0]) {
                cuboid(size=[lid_w,
                             0.2,
                             h - waggo_thickness],
                       side="bottom",
                       anchor=[0, 0, -1]);
                translate([0,
                           0,
                           0]) {
                  cuboid(size=[lid_w,
                               lid_l * 0.3,
                               h - waggo_thickness],
                         side="bottom",
                         anchor=[0, -1, -1]);
                }
              }
            }

            translate([0, lid_l / 2 - (lid_l * 0.3) / 2 + 0.1, 0.5]) {
              cuboid(size=[w - waggo_thickness * 4,
                           lid_l * 0.3 + 0.1,
                           h],
                     r="50%",
                     side="bottom",
                     anchor=[0, 0, -1]);
            }
          };
        }
      }
    }
    // translate([0, hole_l / 2 - l / 2, waggo_thickness]) {
    //   cuboid(size=[waggo_hole_size_xy[0], hole_l + 0.1, waggo_hole_size_xy[1]],
    //           anchor=[0, 0, 1]);
    // }
  }
}

wago_conductor();