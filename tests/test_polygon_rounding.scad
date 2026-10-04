/**
  * Module: Selective polygon corner rounding assertions.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <../scad/lib/functions.scad>
use <../scad/lib/plist.scad>
use <../scad/lib/polygon_util.scad>
use <../scad/lipo_pack_case/multi_lipo_pack_case.scad>

rect            = [[0, 0], [10, 0], [10, 6], [0, 6]];
assert(rounded_polygon_points(rect, 0) == rect);
rounded         = rounded_polygon_points(rect, [0, 0, 2, 2]);
assert(rounded[0] == rect[0] && rounded[1] == rect[1]);
assert(abs(polygon_signed_area(rounded) - (60 - 2 * (4 - PI))) < 0.03);
assert(abs(polygon_signed_area(rounded)
           + polygon_signed_area(rounded_polygon_points(reverse(rect), [2, 2, 0, 0]))) < 0.000001);

concave         = [[0, 0], [6, 0], [6, 3], [3, 3], [3, 6], [0, 6]];
concave_rounded = rounded_polygon_points(concave, [0, 0, 0, 1, 0, 0]);
assert(polygon_signed_area(concave_rounded) > polygon_signed_area(concave));
assert(abs(polygon_signed_area(concave_rounded) - (27 + 1 - PI / 4)) < 0.01);
limited         = rounded_polygon_points(rect, 100);
assert(abs(polygon_x_len(limited) - 10) < 0.000001);
assert(abs(polygon_y_len(limited) - 6) < 0.000001);
assert(min([for (i = [0 : len(limited) - 1])
  norm(limited[i] - limited[(i + 1) % len(limited)])]) > 0.000000001);

wall            = multi_lipo_pack_wall_props(["shape", "custom",
                                              "shape_props", ["h", 20,
                                                              "corner_r", 2,
                                                              "round_bottom", false,
                                                              "debug", true,
                                                              "corner_radii", [5, 5, undef,"20%"],
                                                              "points", [[0, 0,"base"], ["100%", 0], ["100%","100%"], [0,"100%"]]]],
                                  40,
                                  20);
shape           = plist_get("shape_props", wall);
assert(plist_get("corner_radii", shape) == [0, 0, 2, 4]);
assert(plist_get("debug", shape));
assert(plist_get("points", shape)[0] == [0, 0,"base"]);
echo("PASS: selected/square vertices, concave fillets, winding, radius limits, percentages and debug annotations");
