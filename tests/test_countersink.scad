include <../scad/parameters.scad>

use <../scad/lib/functions.scad>
use <../scad/lib/slots.scad>

hole_d  = m3_hole_dia;
bore_d  = hole_d * 2;
angle   = 90;

bore_h  = countersink_h(d=hole_d, sink_d=bore_d, angle=angle);

spacing = 5;

union() {
  counterbore(d=hole_d,
              h=bore_h * 2,
              bore_h=bore_h,
              bore_d=bore_d,
              sink=true,
              print_sink_angle=true);

  translate([hole_d + spacing, 0, 0]) {
    counterbore(d=hole_d,
                h=bore_h * 2,
                bore_h=bore_h,
                bore_d=bore_d,
                teardrop_angle=44,
                teardrop_both_sides=true,
                sink=true,
                print_sink_angle=true);
  }
}
