module assert_true(cond, msg="assert_true failed") {
  if (!cond) {
    echo(str("FAIL: ", msg));

    assert(cond, msg);
  } else {
    echo(str("PASS: ", msg));
  }
}

function _eq(a, b) = a == b;

module assert_eq(actual, expected, name="") {
  assert_true(_eq(actual, expected),
              str(name, " expected=", expected, " actual=", actual));
}
