/**
  * Module: T-Plug placeholders
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../colors.scad>

use <../lib/debug.scad>
use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/shapes3d.scad>
use <../lib/transforms.scad>

t_plug_body_w         = 13.3;
t_plug_body_size      = [13.3, 10.2, 8.0, 6.5]; // width, length, plus height, minus height
t_plug_plus_body_size = [t_plug_body_w / 2, 7.6, 8.0];

t_plug_depth          = 5;

t_plug_hole_l         = 5.2;
t_plug_hole_w         = 2.9;

t_plug_male_body_l    = 6.5;

t_plug_male_body_size = [t_plug_body_size[0],
                         t_plug_male_body_l,
                         t_plug_body_size[2],
                         t_plug_body_size[3]];

module t_plug_female(body_size=t_plug_body_size,
                     color="#96484D",
                     t_plug_depth=t_plug_depth,
                     t_plug_hole_w=t_plug_hole_w,
                     t_plug_hole_l=t_plug_hole_l,
                     anchor=[0, 0, 1],
                     spin,
                     orientation="wlh") {
  w = body_size[0] / 2;
  plus_h = body_size[2];
  minus_h = body_size[3];
  plus_body_size = [w, body_size[1], plus_h];
  minus_body_size = [w, body_size[1], minus_h];

  with_orientation(from="wlh",
                   to=orientation,
                   anchor=anchor,
                   size=[body_size[0], body_size[1], max(plus_h, minus_h)],
                   spin=spin) {
    translate([0, -body_size[1] / 2, 0]) {
      translate([-plus_body_size[0] / 2, 0, plus_h / 2]) {

        difference() {
          cuboid(size=plus_body_size, anchor=[0, 1, 0], color=color);
          translate([0, -0.1, 0]) {
            cuboid(size=[t_plug_hole_w, t_plug_depth + 0.1, t_plug_hole_l],
                   anchor=[0, 1, 0]);
          }
        }
        if ($children > 0) {
          children(0);
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
        if ($children > 1) {
          children(1);
        }
      }
    }
  }
}

module t_plug_male(body_size=t_plug_male_body_size,
                   color="#96484D",
                   t_plug_depth=t_plug_depth,
                   t_plug_hole_w=t_plug_hole_w,
                   t_plug_hole_l=t_plug_hole_l,
                   anchor=[0, 0, 1],
                   spin,
                   orientation="wlh") {
  t_plug_female(orientation=orientation,
                body_size=body_size,
                spin=spin,
                anchor=anchor,
                color=color,
                t_plug_depth=t_plug_depth,
                t_plug_hole_w=t_plug_hole_w,
                t_plug_hole_l=t_plug_hole_l) {
    cuboid(size=[t_plug_hole_w / 2, t_plug_depth * 2, t_plug_hole_l],
           anchor=[0, 0, 0],
           color=metallic_gold_2);
    cuboid(size=[t_plug_hole_l, t_plug_depth * 2, t_plug_hole_w / 2],
           anchor=[0, 0, 0],
           color=metallic_gold_2);
  }
}

t_plug_female(orientation="lwh", anchor=[1, 0, 1], spin=180);

translate([-10, 0, 0]) {
  t_plug_male(orientation="lwh", anchor=[-1, 0, 1]);
}
/**
  ─────────────────────────────────────────────────────────────────────────────
  t_plug_mated_props
  ─────────────────────────────────────────────────────────────────────────────
  Return mating and solder datums for the default keyed connector pair.
  **Returns:** Female body on +Y, male body on -Y, mating plane Y=0 and
  bottom Z=0. Ports are ordered positive, negative, in both halves.
 */
function t_plug_mated_props() =
  ["female_size", t_plug_body_size, "male_size", t_plug_male_body_size,
   "female_ports", [for (x = [-1, 1])
       [x * t_plug_body_size[0] / 4, t_plug_body_size[1], t_plug_body_size[2] / 2]],
   "male_ports", [for (x = [-1, 1])
       [x * t_plug_body_size[0] / 4, -t_plug_male_body_l, t_plug_body_size[2] / 2]]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  t_plug_mated
  ─────────────────────────────────────────────────────────────────────────────
  Display a keyed, connected pair in the t_plug_mated_props frame.
  **Parameters:**
  - `show_female`: Display the battery half.
  - `show_male`: Display the harness half, including inserted contact blades.
 */
module t_plug_mated(show_female=true, show_male=true) {
  if (show_female) {
    translate([0, t_plug_body_size[1] / 2, 0]) {
      t_plug_female();
    }
  }
  if (show_male) {
    translate([0, -t_plug_male_body_l / 2, 0]) {
      mirror([0, 1, 0]) {
        t_plug_male();
      }
    }
  }
}
