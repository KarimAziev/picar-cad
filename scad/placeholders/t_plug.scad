include <../colors.scad>

use <../lib/debug.scad>
use <../lib/functions.scad>
use <../lib/shapes3d.scad>

t_plug_body_w         = 13.3;
t_plug_body_size      = [13.3, 10.2, 8.0, 6.5]; // width, length, plus height, minus height
t_plug_plus_body_size = [t_plug_body_w / 2, 7.6, 8.0];

module t_plug_female(body_size=t_plug_body_size, color="#96484D") {
  w = body_size[0] / 2;
  plus_h = body_size[2];
  minus_h = body_size[3];
  plus_body_size = [w, body_size[1], plus_h];
  minus_body_size = [w, body_size[1], minus_h];

  translate([0, 0, 0]) {
    color(color, alpha=1) {
      cuboid(size=plus_body_size, anchor=[-1, 0, 1]);
      translate([0, 0, (plus_h - minus_h) / 2]) {
        cuboid(size=minus_body_size, anchor=[1, 0, 1]);
      }
    }
  }
}

t_plug_female();