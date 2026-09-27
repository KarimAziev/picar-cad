use <../scad/lib/shapes2d.scad>
use <util.scad>

size = [40, 20];
names = ["all", "top", "bottom", "left", "right",
         "top_left", "top_right", "bottom_left", "bottom_right"];
expected = [[3, 3, 3, 3], [0, 0, 3, 3], [3, 3, 0, 0],
            [3, 0, 0, 3], [0, 3, 3, 0], [0, 0, 0, 3],
            [0, 0, 3, 0], [3, 0, 0, 0], [0, 3, 0, 0]];

for (i = [0:len(names)-1]) {
  assert_eq(rounded_rect_corner_radii(size, names[i], r=3),
            expected[i], str("string side ", names[i]));
  assert_eq(rounded_rect_corner_radii(size, [names[i]], r=3),
            expected[i], str("list side ", names[i]));
}

assert_eq(rounded_rect_corner_radii(size, undef, r=3), [3, 3, 3, 3],
          "omitted side selects all corners");
assert_eq(rounded_rect_corner_radii(size, [], r=3), [0, 0, 0, 0],
          "empty list selects no corners");
assert_eq(rounded_rect_corner_radii(size, ["top_left", "bottom_right"], r=3),
          [0, 3, 0, 3], "opposite corners");
assert_eq(rounded_rect_corner_radii(size, ["top", "left"], r="12.5%"),
          [2.5, 0, 2.5, 2.5], "overlapping sides with shared percentage");
assert_eq(rounded_rect_corner_radii(size, ["top", "bottom"], r_factor=0.2),
          [4, 4, 4, 4], "shared factor");
assert_eq(rounded_rect_corner_radii(size, [["top", 4], ["bottom", "10%"]]),
          [2, 2, 4, 4], "independent numeric and percentage radii");
assert_eq(rounded_rect_corner_radii(size, [["all", 4], ["top_left", 0]]),
          [4, 4, 4, 0], "zero overrides earlier radius");
assert_eq(rounded_rect_corner_radii(size, [["top_left", 0], ["all", 4]]),
          [4, 4, 4, 4], "last matching entry wins");
assert_eq(rounded_rect_corner_radii(size, ["top", ["left", "25"]], r=3),
          [5, 0, 3, 5], "mixed list and suffix-optional percentage");
assert_eq(rounded_rect_corner_radii(size, [["top", 100], ["bottom", "200%"]]),
          [10, 10, 10, 10], "radii clamp independently");
assert_eq(rounded_rect_corner_radii(size, [["right", 4]], r=0, r_factor=0),
          [0, 4, 4, 0], "pair radii work with zero shared radius");
