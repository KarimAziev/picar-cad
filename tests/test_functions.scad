use <../scad/lib/functions.scad>
use <util.scad>

module test_slice() {
  a = [0, 1, 2, 3, 4, 5];

  assert_eq(slice(a, 0, 0),   [],            "slice(a, 0, 0)");
  assert_eq(slice(a, 0, 1),   [0],           "slice(a, 0, 1)");
  assert_eq(slice(a, 2, 5),   [2, 3, 4],       "slice(a, 2, 5)");
  assert_eq(slice(a, 2),      [2, 3, 4, 5],     "slice(a, 2)");
  assert_eq(slice(a),         [0, 1, 2, 3, 4, 5], "slice(a)");
  assert_eq(slice(a, -1),     [5],           "slice(a, -1)");
  assert_eq(slice(a, -3),     [3, 4, 5],       "slice(a, -3)");
  assert_eq(slice(a, 1, -1),  [1, 2, 3, 4],     "slice(a, 1, -1)");
  assert_eq(slice(a, -4, -1), [2, 3, 4],       "slice(a, -4, -1)");

  assert_eq(slice(a, 99, 100), [],           "slice(a, 99, 100) -> []");
  assert_eq(slice(a, -99, 2),  [0, 1],        "slice(a, -99, 2) clamps start");
  assert_eq(slice(a, 2, -99),
            [],
            "slice(a, 2, -99) end before start");
  assert_eq(slice(a, 0, 99),
            [0, 1, 2, 3, 4, 5],
            "slice(a, 0, 99) clamps end");
}

module test_take() {
  l = ["foo", "bar", "baz"];
  assert_eq(take(l, 1), ["foo"],               "take 1");
  assert_eq(take(l, 2), ["foo","bar"],         "take 2");
  assert_eq(take(l, 3), ["foo","bar","baz"],   "take 3");
  assert_eq(take(l, 4), ["foo","bar","baz"],   "take 4 (clamp)");
  assert_eq(take(l, 0), [],                    "take 0");
  assert_eq(take(l, -1), [],                   "take -1");
}

module test_take_last() {
  l = ["foo", "bar", "baz"];

  assert_eq(take_last(l),    ["baz"],          "take_last default");
  assert_eq(take_last(l, 1), ["baz"],          "take_last 1");
  assert_eq(take_last(l, 2), ["bar","baz"],    "take_last 2");
  assert_eq(take_last(l, 3), ["foo","bar","baz"], "take_last 3");
  assert_eq(take_last(l, 4), ["foo","bar","baz"], "take_last 4 (clamp)");
  assert_eq(take_last(l, 0), [],               "take_last 0");
  assert_eq(take_last(l, -2), [],              "take_last -2");
}

module test_drop() {
  l = ["foo", "bar", "baz"];

  assert_eq(drop(l, 0), l,                     "drop 0");
  assert_eq(drop(l, 1), ["bar","baz"],         "drop 1");
  assert_eq(drop(l, 2), ["baz"],               "drop 2");
  assert_eq(drop(l, 3), [],                    "drop 3");
  assert_eq(drop(l, 4), [],                    "drop 4 (clamp)");
  assert_eq(drop(l, -1), l,                    "drop -1");
}

module test_drop_last() {
  l = ["foo", "bar", "baz"];

  assert_eq(drop_last(l),    ["foo","bar"],    "drop_last default");
  assert_eq(drop_last(l, 1), ["foo","bar"],    "drop_last 1");
  assert_eq(drop_last(l, 2), ["foo"],          "drop_last 2");
  assert_eq(drop_last(l, 3), [],               "drop_last 3");
  assert_eq(drop_last(l, 4), [],               "drop_last 4 (clamp)");
  assert_eq(drop_last(l, 0), l,                "drop_last 0");
  assert_eq(drop_last(l, -1), l,               "drop_last -1");
}

module test_truncate_all_nums() {
  assert_eq(truncate_all_nums([[0, -2, 0], [10.7654, -1.84776, 0], [21.4142, 8.58579, 0]], 1),
            [[0, -2, 0], [10.7, -1.8, 0], [21.4, 8.5, 0]],
            "truncate_all_nums([[0, -2, 0], [10.7654, -1.84776, 0], [21.4142, 8.58579, 0]], 1)");
}

module test_best_by_lower_sum() {
  assert_eq(best_by_lower_sum([], [1, 2]),
            [1, 2],
            "empty left => right");
  assert_eq(best_by_lower_sum([1, 2], []),
            [1, 2],
            "empty right => left");

  assert_eq(best_by_lower_sum([1, 2], [4]),
            [1, 2],
            "lower sum wins (3 < 4)");

  // sum tie (3 == 3), tie-break uses lexicographic compare: larger list wins
  assert_eq(best_by_lower_sum([1, 1, 1], [3]),
            [3],
            "sum tie => lexicographically larger wins");

  // sum tie (4 == 4), [2,2] > [1,3] => [2,2]
  assert_eq(best_by_lower_sum([2, 2], [1, 3]),
            [2, 2],
            "sum tie => lexicographically larger wins (2,2 > 1,3)");
}

module test_best_list_by_lower_sum() {
  assert_eq(best_list_by_lower_sum([]),
            [],
            "empty input => []");

  assert_eq(best_list_by_lower_sum([[], []]),
            [],
            "all empty => []");
  assert_eq(best_list_by_lower_sum([[], [1, 2]]),
            [1, 2],
            "skip empty => non-empty");
  assert_eq(best_list_by_lower_sum([[1, 2], []]),
            [1, 2],
            "non-empty beats empty");

  // among [1,2] and [3], sums tie (3==3), lexicographically larger wins => [3]
  assert_eq(best_list_by_lower_sum([[], [1, 2], [3]]),
            [3],
            "sum tie => lexicographically larger");

  // sum tie (4==4), [2,2] > [1,3] => [2,2]
  assert_eq(best_list_by_lower_sum([[1, 3], [2, 2]]),
            [2, 2],
            "sum tie => lexicographically larger (pair)");

  assert_eq(best_list_by_lower_sum([[7, 8]]),
            [7, 8],
            "singleton => itself");
}

module test_best_height_combo_at_least() {
  assert_eq(best_height_combo(6, [1, 3, 4], 2),
            [3, 3],
            "exact reach with repetition: 6 from [1,3,4] limit 2 => [3,3]");

  assert_eq(best_height_combo(6, [4, 5], 2),
            [4, 4],
            "overshoot allowed, minimize sum: 6 from [4,5] limit 2 => [4,4] (8)");

  assert_eq(best_height_combo(6, [4, 5], 1),
            [],
            "no solution if limit too small");

  assert_eq(best_height_combo(1, [2, 3], 3),
            [2],
            "minimize overshoot: need >=1 from [2,3] => [2]");

  assert_eq(best_height_combo(0, [1, 2], 3),
            [],
            "min_h<=0 base case => [] (no pieces needed)");

  assert_eq(best_height_combo(10, [2, 3], 0),
            [],
            "limit==0 base case => []");

  assert_eq(best_height_combo(7, [2, 3], 3),
            [3, 2, 2],
            "reach 7 with limit 3: [2,2,3] sum 7");

  assert_eq(best_height_combo(6, [2, 3], 3),
            [3, 3],
            "tie on sum => lexicographically larger combo wins");
}

module test_sum() {
  assert_eq(sum([2, 3], 1), 2, "sum([2, 3], 1)");
  assert_eq(sum([2, 3], 2), 5, "sum([2, 3], 2)");
  assert_eq(sum([2, 3]), 5, "sum([2, 3])");
  assert_eq(sum([5, 2, 3]), 10, "sum([5, 2, 3])");
  assert_eq(sum([5, 2, 3], 3), 10, "sum([5, 2, 3], 3)");
  assert_eq(sum([5, 2, 3], 2), 7, "sum([5, 2, 3], 2)");
  assert_eq(sum([1, 2], 0), 0, "sum([1, 2], 0)");
  assert_eq(sum([1], 1), 1, "sum([1], 1)");
  assert_eq(sum([1], 2), 1, "sum([1], 2)");
  assert_eq(sum([1], 3), 1, "sum([1], 3)");
}

module test_rot2() {
  assert_eq(rot2([1, 0], 90), [0, 1], "rot2([1, 0], 90)");
  assert_eq([for (v = rot2([10, 5], -45)) truncate(v, 1)],
            [10.6, -3.5],
            "rot2([10, 5], -45)");
  assert_eq([for (v = rot2([10, 5], -31)) truncate(v, 1)],
            [11.1, -0.8],
            "rot2([10, 5], -31)");
}

module test_rotated_bbox2() {
  assert_eq(rotated_bbox2(20, 10, 90),
            [-10, 0, 0, 20],
            "rotated_bbox2(20, 10, 90)");
  assert_eq(rotated_bbox2(20, 10, 0),
            [0, 0, 20, 10],
            "rotated_bbox2(20, 10, 0)");

  assert_eq([for (v = rotated_bbox2(20, 10, 45)) truncate(v, 1)],
            [-7, 0, 14.1, 21.2],
            "rotated_bbox2(20, 10, 45)");

  assert_eq([for (v = rotated_bbox2(20, 10, 28)) truncate(v, 1)],
            [-4.6, 0, 17.6, 18.2],
            "rotated_bbox2(20, 10, 28)");
}

module test_calc_rotated_bbox() {
  assert_eq(calc_rotated_bbox(20, 10, 90),
            [10, 20, 10, 0],
            "calc_rotated_bbox(20, 10, 90)");
  assert_eq(calc_rotated_bbox(20, 10, 0),
            [20, 10, 0, 0],
            "calc_rotated_bbox(20, 10, 0)");

  assert_eq([for (v = calc_rotated_bbox(20, 10, 45)) truncate(v, 1)],
            [21.2, 21.2, 7, 0],
            "calc_rotated_bbox(20, 10, 45)");

  assert_eq([for (v = calc_rotated_bbox(20, 10, 17)) truncate(v, 1)],
            [22, 15.4, 2.9, 0],
            "calc_rotated_bbox(20, 10, 17)");
}

module test_rotated_bbox() {
  assert_eq(rotX([0, 1, 0], 90), [0, 0, 1], "rotX([0, 1, 0], 90)");
  assert_eq(rotY([1, 0, 0], 90), [0, 0, -1], "rotY([1, 0, 0], 90)");
  assert_eq(rotZ([1, 0, 0], 90), [0, 1, 0], "rotZ([1, 0, 0], 90)");
  assert_eq(rotate_euler_xyz([10, 0, 0], [0, 0, 90]),
            [0, 10, 0],
            "rotate_euler_xyz([10, 0, 0], [0, 0, 90])");
  assert_eq([for (v = rotated_aabb_minmax(10, 20, 5, [0, 0, 45])) truncate(v, 1)],
            [-14.1, 0, 0, 7, 21.2, 5],
            "rotated_aabb_minmax(10, 20, 5, [0, 0, 45])");

  assert_eq([for (v = rotated_bbox(size=[20, 10, 5], a=[50, 30, 45])) truncate(v, 1)],
            [17.9, 21, 19.4, 1.8, 1.5, 10],
            "rotated_bbox(20, 10, 5, [50, 30, 45])");
}

module test_vlen() {
  assert_eq(vlen([3, 4, 0]), 5, "vlen([3, 4, 0])");
  assert_eq(vlen([1, 2, 2]), 3, "vlen([1, 2, 2])");
}

module test_vunit() {
  assert_eq(vunit([3, 0, 0]), [1, 0, 0], "vunit([3, 0, 0])");
  assert_eq(vunit([0, 0, 0]), [0, 0, 0], "vunit([0, 0, 0])");
}

module test_vcross() {
  assert_eq(vcross([1, 0, 0], [0, 1, 0]),
            ([0, 0, 1]),
            "vcross([1, 0, 0], [0, 1, 0])");
  assert_eq(vcross([0, 1, 0], [1, 0, 0]),
            ([0, 0, -1]),
            "vcross([0, 1, 0], [1, 0, 0])");
}

module test_vadd() {
  assert_eq(vadd([1, 2, 3], [4, 5, 6]),
            ([5, 7, 9]),
            "vadd([1, 2, 3], [4, 5, 6])");
}

module test_vsub() {
  assert_eq(vsub([5, 7, 9], [1, 2, 3]),
            ([4, 5, 6]),
            "vsub([5, 7, 9], [1, 2, 3])");
}

module test_vmul() {
  assert_eq(vmul([1, 2, 3], 2), ([2, 4, 6]), "vmul([1, 2, 3], 2)");
  assert_eq(vmul([1, -1, 0], 0.5), ([0.5, -0.5, 0]), "vmul([1, -1, 0], 0.5)");
}

module test_safe_perp() {
  assert_eq(safe_perp([1, 0, 0]), [0, -1, 0], "safe_perp([1, 0, 0])");
  assert_eq(safe_perp([0, 0, 1]), [-1, 0, 0], "safe_perp([0, 0, 1])");
  assert_eq(safe_perp([1, 0, 0], [0, 1, 0]),
            [0, 0, 1],
            "safe_perp([1, 0, 0], [0, 1, 0])");
}

module test_point_tangent() {
  pts = [[0, 0, 0], [1, 0, 0], [2, 1, 0]];
  assert_eq(truncate_all_nums(point_tangent(pts, 0), 1),
            [1, 0, 0],
            "point_tangent(pts, 0)");
  assert_eq(truncate_all_nums(point_tangent(pts, 1), 1),
            [0.9, 0.3, 0],
            "point_tangent(pts, 1)");
  assert_eq(truncate_all_nums(point_tangent(pts, 2), 2),
            [0.7, 0.7, 0],
            "point_tangent(pts, 2)");
}

module test_offset_path() {
  assert_eq(truncate_all_nums(offset_path([[0, 0, 0], [10, 0, 0], [20, 10, 0]], 2)),
            [[0, -2, 0], [10.7, -1.8, 0], [21.4, 8.5, 0]],
            "offset_path([[0,0,0], [10,0,0], [20,10,0]], 2)");
  assert_eq(offset_path([[0, 0, 0], [0, 10, 0]], 1, [0, 0, 1]),
            [[1, 0, 0], [1, 10, 0]],
            "offset_path([[0,0,0], [0,10,0]], 1, [0,0,1])");
}

module test_qsort() {
  assert_eq(qsort([5, 2, 9, 2, 1, 7], asc=true),
            [1, 2, 2, 5, 7, 9],
            "qsort([5, 2, 9, 2, 1, 7], asc=true)");
  assert_eq(qsort([5, 2, 9, 2, 1, 7], asc=false),
            [9, 7, 5, 2, 2, 1],
            "qsort([5, 2, 9, 2, 1, 7], asc=false)");
}

module test_countersink_h() {
  assert_eq(countersink_h(d=3, sink_d=6, angle=90),
            1.5,
            "countersink_h(d=3, sink_d=6, angle=90)");
  assert_eq(countersink_h(d=3, sink_d=6.5, angle=90),
            1.75,
            "countersink_h(d=3, sink_d=6.5, angle=90)");
  assert_eq(truncate(countersink_h(d=4, sink_d=8, angle=82), 1),
            2.3,
            "truncate(countersink_h(d=4, sink_d=8, angle=82), 1)");
}

test_slice();
test_truncate_all_nums();
test_take();
test_take_last();
test_drop();
test_drop_last();
test_best_by_lower_sum();
test_best_list_by_lower_sum();
test_best_height_combo_at_least();
test_sum();
test_rot2();
test_rotated_bbox2();
test_calc_rotated_bbox();
test_rotated_bbox();
test_vlen();
test_vunit();
test_vcross();
test_vadd();
test_vsub();
test_vmul();
test_safe_perp();
test_offset_path();
test_point_tangent();
test_qsort();
test_countersink_h();