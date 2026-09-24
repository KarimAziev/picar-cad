use <../scad/lib/plist.scad>

module assert_true(cond, msg="assert_true failed") {
  if (!cond) {
    echo(str("FAIL: ", msg)); assert(cond, msg);
  }
  else echo(str("PASS: ", msg));
}
module assert_eq(actual, expected, name="") {
  assert_true(actual == expected, str(name, " expected=", expected, " actual=", actual));
}

module test_plist_remove_by_keys() {
  p = ["size",[5, 10], "dia", 4, "color","red"];

  assert_eq(plist_remove_by_keys("dia", p),
            ["size",[5, 10], "color","red"],
            "remove_by_keys one");

  assert_eq(plist_remove_by_keys(["dia","none"], p),
            ["size",[5, 10], "color","red"],
            "remove_by_keys many");

  assert_eq(plist_remove_by_keys(["size","color","dia"], p),
            [],
            "remove_by_keys all");

  assert_eq(plist_remove_by_keys([], p),
            p,
            "remove_by_keys empty list");
}

module test_plist_merge() {
  a = ["a", 1, "b", 2];
  b = ["b", 20, "c", 30];
  assert_eq(plist_merge(a, b),
            ["a", 1, "b", 20, "c", 30],
            "merge override + append");

  defaults = ["dia", 4, "size", [5, 10]];
  opts     = ["dia", 3.5];
  assert_eq(plist_merge(defaults, opts),
            ["dia", 3.5, "size", [5, 10]],
            "merge_with_defaults");

  new_opts     = ["dia", 3.5, "new_prop", 3];
  assert_eq(plist_merge(defaults, new_opts),
            ["dia", 3.5, "size", [5, 10], "new_prop", 3],
            "merge_with_defaults");
}

module test_plist_merge_all() {
  assert_eq(plist_merge_all([]), [], "merge_all empty input");
  assert_eq(plist_merge_all([[], [], []]), [], "merge_all empty plists");

  single = ["a", 1, "a", 2];
  assert_eq(plist_merge_all([single]), single,
            "merge_all single plist unchanged");

  assert_eq(plist_merge_all([["a", 1, "b", 2],
                             ["b", 20, "c", 30],
                             ["a", 10, "d", 40]]),
            ["a", 10, "b", 20, "c", 30, "d", 40],
            "merge_all later overrides preserve key order");

  assert_eq(plist_merge_all([[], ["a", 1], [], ["b", 2], []]),
            ["a", 1, "b", 2],
            "merge_all handles empty plists between values");

  assert_eq(plist_merge_all([["nested", ["a", 1, "b", 2], "value", 3],
                             ["nested", ["c", 4], "value", undef]]),
            ["nested", ["c", 4], "value", undef],
            "merge_all replaces nested lists and accepts undef values");

  assert_eq(plist_merge_all([["a", 1, "a", 2],
                             ["b", 3, "b", 4],
                             ["a", 5, "a", 6]]),
            ["a", 5, "a", 5, "b", 3, "b", 3],
            "merge_all preserves plist_merge duplicate key behavior");
}

module test_plist_maybe_from_percent() {
  p = ["width", "25%",
       "height", 12,
       "decimal", "12.5%",
       "suffix_optional", "40"];

  assert_eq(plist_maybe_from_percent("width", p, 0, 200),
            50,
            "convert percent property to absolute value");
  assert_eq(plist_maybe_from_percent("decimal", p, 0, 240),
            30,
            "convert decimal percent property");
  assert_eq(plist_maybe_from_percent("suffix_optional", p, 0, 200),
            80,
            "convert string without percent suffix");
  assert_eq(plist_maybe_from_percent("height", p, 0, 200),
            12,
            "leave numeric property unchanged");
  assert_eq(plist_maybe_from_percent("missing", p, "10%", 200),
            20,
            "convert string default");
  assert_eq(plist_maybe_from_percent("missing", p, 7, 200),
            7,
            "leave numeric default unchanged");
  assert_eq(plist_maybe_from_percent("width", p, 0, 0),
            0,
            "convert percent against zero total");
}

test_plist_merge();
test_plist_merge_all();
test_plist_remove_by_keys();
test_plist_maybe_from_percent();
