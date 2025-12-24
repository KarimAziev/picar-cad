include <../parameters.scad>
use <../lib/shapes2d.scad>
use <../lib/holes.scad>
use <smd_chip.scad>
use <../lib/transforms.scad>
use <../lib/shapes3d.scad>
use <../lib/functions.scad>

use <pin_headers.scad>
use <screw_terminal.scad>
use <../lib/placement.scad>

module pad_hole(bolt_d,
                thickness,
                specs) {
  sorted_specs = sort_by_idx(elems=specs, idx=0, asc=true);
  union() {
    for (i = [0 : len(sorted_specs) - 1]) {
      let (spec = specs[i],
           prev_spec_dia=i > 0 ? specs[i - 1][0] : bolt_d,
           dia = spec[0],
           colr = spec[1],
           w = (dia - prev_spec_dia) / 2) {
        color(colr, alpha=1) {
          translate([0, 0, -0.05]) {
            linear_extrude(height=thickness + 0.1,
                           center=false,
                           convexity=2) {
              ring_2d(w=w, r=dia / 2, fn=30);
            }
          }
        }
      }
    }
  }
}

pad_hole(bolt_d=2.0, thickness=2, specs=[[3.4, yellow_3],
                                         [4.0, "white"]]);