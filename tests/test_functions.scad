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

test_slice();
test_take();
test_take_last();
test_drop();
test_drop_last();
