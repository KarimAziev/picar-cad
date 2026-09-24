"""Checks for OpenSCAD log parsing; no OpenSCAD process is needed."""

import unittest

from scad_test_support import echo_value


class EchoValueTests(unittest.TestCase):
    def test_reads_named_echo_among_other_output(self) -> None:
        log = "ECHO: other = 9\nECHO: bounds = [[0, 0, 0], [1, 2, 3]]\nDone\n"
        self.assertEqual(echo_value(log, "bounds"), "[[0, 0, 0], [1, 2, 3]]")

    def test_missing_echo_reports_name_and_log(self) -> None:
        log = "ECHO: another_bounds = 3"
        with self.assertRaises(AssertionError) as raised:
            echo_value(log, "bounds")
        self.assertIn("'bounds'", str(raised.exception))
        self.assertIn(log, str(raised.exception))


if __name__ == "__main__":
    unittest.main()
