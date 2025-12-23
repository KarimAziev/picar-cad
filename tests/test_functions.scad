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
  assert_eq(slice(a, 2, -99),  [],           "slice(a, 2, -99) end before start");
  assert_eq(slice(a, 0, 99),   [0, 1, 2, 3, 4, 5], "slice(a, 0, 99) clamps end");
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

module test_best_by_lower_sum() {
  assert_eq(best_by_lower_sum([], [1, 2]), [1, 2],         "empty left => right");
  assert_eq(best_by_lower_sum([1, 2], []), [1, 2],         "empty right => left");

  assert_eq(best_by_lower_sum([1, 2], [4]), [1, 2],        "lower sum wins (3 < 4)");

  // sum tie (3 == 3), tie-break uses lexicographic compare: larger list wins
  assert_eq(best_by_lower_sum([1, 1, 1], [3]), [3],        "sum tie => lexicographically larger wins");

  // sum tie (4 == 4), [2,2] > [1,3] => [2,2]
  assert_eq(best_by_lower_sum([2, 2], [1, 3]), [2, 2],      "sum tie => lexicographically larger wins (2,2 > 1,3)");
}

module test_best_list_by_lower_sum() {
  assert_eq(best_list_by_lower_sum([]), [],                        "empty input => []");

  assert_eq(best_list_by_lower_sum([[], []]), [],                  "all empty => []");
  assert_eq(best_list_by_lower_sum([[], [1, 2]]), [1, 2],            "skip empty => non-empty");
  assert_eq(best_list_by_lower_sum([[1, 2], []]), [1, 2],            "non-empty beats empty");

  // among [1,2] and [3], sums tie (3==3), lexicographically larger wins => [3]
  assert_eq(best_list_by_lower_sum([[], [1, 2], [3]]), [3],         "sum tie => lexicographically larger");

  // sum tie (4==4), [2,2] > [1,3] => [2,2]
  assert_eq(best_list_by_lower_sum([[1, 3], [2, 2]]), [2, 2],         "sum tie => lexicographically larger (pair)");

  assert_eq(best_list_by_lower_sum([[7, 8]]), [7, 8],                "singleton => itself");
}

module test_best_height_combo_at_least() {
  assert_eq(best_height_combo(6, [1, 3, 4], 2), [3, 3],
            "exact reach with repetition: 6 from [1,3,4] limit 2 => [3,3]");

  assert_eq(best_height_combo(6, [4, 5], 2), [4, 4],
            "overshoot allowed, minimize sum: 6 from [4,5] limit 2 => [4,4] (8)");

  assert_eq(best_height_combo(6, [4, 5], 1), [],
            "no solution if limit too small");

  assert_eq(best_height_combo(1, [2, 3], 3), [2],
            "minimize overshoot: need >=1 from [2,3] => [2]");

  assert_eq(best_height_combo(0, [1, 2], 3), [],
            "min_h<=0 base case => [] (no pieces needed)");

  assert_eq(best_height_combo(10, [2, 3], 0), [],
            "limit==0 base case => []");

  assert_eq(best_height_combo(7, [2, 3], 3), [3, 2, 2],
            "reach 7 with limit 3: [2,2,3] sum 7");

  assert_eq(best_height_combo(6, [2, 3], 3), [3, 3],
            "tie on sum => lexicographically larger combo wins");
}

test_slice();
test_take();
test_take_last();
test_drop();
test_drop_last();
test_best_by_lower_sum();
test_best_list_by_lower_sum();
test_best_height_combo_at_least();