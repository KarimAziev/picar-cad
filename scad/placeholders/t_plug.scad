include <../colors.scad>

use <../lib/debug.scad>
use <../lib/functions.scad>
use <../lib/shapes3d.scad>
use <../lib/transforms.scad>

t_plug_body_w         = 13.3;
t_plug_body_size      = [13.3, 10.2, 8.0, 6.5]; // width, length, plus height, minus height
t_plug_plus_body_size = [t_plug_body_w / 2, 7.6, 8.0];

t_plug_depth          = 5;

t_plug_hole_l         = 5.2;
t_plug_hole_w         = 2.9;

module t_plug_female(body_size=t_plug_body_size,
                     color="#96484D",
                     t_plug_depth=t_plug_depth,
                     t_plug_hole_w=t_plug_hole_w,
                     t_plug_hole_l=t_plug_hole_l,
                     anchor=[0, 0, 1],
                     orientation="wlh") {
  w = body_size[0] / 2;
  plus_h = body_size[2];
  minus_h = body_size[3];
  plus_body_size = [w, body_size[1], plus_h];
  minus_body_size = [w, body_size[1], minus_h];

  with_orientation(from="wlh",
                   to=orientation,
                   anchor=anchor,
                   size=[w, body_size[1], max(plus_h, minus_h)]) {
    translate([0, -body_size[1] / 2, 0]) {
      translate([-plus_body_size[0] / 2, 0, plus_h / 2]) {
        difference() {
          cuboid(size=plus_body_size, anchor=[0, 1, 0], color=color);
          translate([0, -0.1, 0]) {
            cuboid(size=[t_plug_hole_w, t_plug_depth + 0.1, t_plug_hole_l],
                   anchor=[0, 1, 0]);
          }
        }
      }

      translate([minus_body_size[0] / 2, 0, plus_h / 2]) {
        difference() {
          cuboid(size=minus_body_size, anchor=[0, 1, 0], color=color);
          translate([0, -0.1, 0]) {
            cuboid(size=[t_plug_hole_l, t_plug_depth + 0.1, t_plug_hole_w],
                   anchor=[0, 1, 0]);
          }
        }
      }
    }
  }
}

t_plug_female(orientation="wlh");