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

test_plist_merge();
test_plist_remove_by_keys();