/**
 * Module: Reusable several utility functions
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
/**
   ─────────────────────────────────────────────────────────────────────────────
   number_sequence
   ─────────────────────────────────────────────────────────────────────────────
   Returns an array of numbers starting at `from` and incremented by `step`.

   The `from` value is always included, and `to` is included if the sequence
   lands on it exactly, otherwise, the last number is the largest value that
   does not exceed `to`.

   Example:
   number_sequence(from=2, to=7, step=2) // -> [2, 4, 6]
*/
use <trapezoids.scad>

function number_sequence(from, to, step) = [for (i = [from : step : to]) i];

/**
   ─────────────────────────────────────────────────────────────────────────────
   truncate
   ─────────────────────────────────────────────────────────────────────────────
   Truncate a number to a specified number of decimal places.

   Parameters:
   val:  The input number to truncate.
   dec:  The number of decimal places to retain (default is 1).

   Example:
   truncate(3.14159, 2)  // returns 3.14
   truncate(-2.718, 1)   // returns -2.7
*/
function truncate(val, dec=1) =
  (val >= 0) ? floor(val * pow(10, dec)) / pow(10, dec)
  : ceil(val * pow(10, dec)) / pow(10, dec);

/**
   ─────────────────────────────────────────────────────────────────────────────
   calc_notch_width
   ─────────────────────────────────────────────────────────────────────────────
   Computes the depth (or reduction in width) at the notch on a circle.

   This function calculates the notch width by determining the chord’s offset
   from the circle’s edge. It subtracts two times the distance from the circle's
   center to the chord (computed using the Pythagorean theorem) from the full
   diameter.

   Parameters:
   dia - The diameter of the circle.
   w   - The chord length corresponding to the notch width at the circle’s
   center.

   Returns: The calculated notch width, which is the reduction in the diameter
   due to the notch.

   Example:
   calc_notch_width(3.2, 10) // -> 1.33975
*/

function calc_notch_width(dia, w) =
  dia - 2 * sqrt(((dia / 2) * (dia / 2)) - ((w / 2) * (w / 2)));

/**
   ─────────────────────────────────────────────────────────────────────────────
   sum
   -─────────────────────────────────────────────────────────────────────────────
   Recursively sum elements of a numeric list.

   Parameters:
   list: the list of numeric values
   count: optional number of first elements to sum. If omitted, the whole list
   is summed.

   Returns:
   The sum of the requested elements.

   Example:
   sum([1, 5, 10]); // 16
   sum([1, 5, 10], 2); // 6
*/
function sum(list, count=undef) =
  let (length = is_undef(count) ? len(list) : count)
  length < 2
  ? list[0]
  : (list[length - 1] + sum(list, length - 1));

/**
   ─────────────────────────────────────────────────────────────────────────────
   drop
   ─────────────────────────────────────────────────────────────────────────────
   Drop the first n elements from a list and return the remainder.

   Parameters:
   a:  The input list.
   n:  The number of elements to drop from the start (0-based count).

   Behavior:
   If n is greater than or equal to len(a), an empty list is returned.

   Examples:
   drop([1, 2, 3, 4], 2)    // returns [3, 4]
   drop([1, 2], 0)         // returns [1, 2]
   drop([1, 2], 5)         // returns []
   drop([], 0)             // returns []
*/
function drop(a, n) = n >= len(a) ? [] : [for (i = [n : len(a)-1]) a[i]];
/**
   ─────────────────────────────────────────────────────────────────────────────
   slice
   ─────────────────────────────────────────────────────────────────────────────
   Return a sublist of elements between start and end indices (inclusive).

   Parameters:
   a:      The input list.
   start:  The starting index (inclusive).
   end:    The ending index (inclusive).

   Behavior:
   If start > end, an empty list is returned. Indices are inclusive and
   expected to be valid indices within the list.

   Examples:
   slice([10, 20, 30, 40], 1, 2)  // returns [20, 30]
   slice([10, 20, 30], 0, 0)      // returns [10]
   slice([1, 2, 3], 2, 1)         // returns []
   slice([], 0, 0)                // returns []
*/
function slice(a, start, end) = start > end
  ? []
  : [for (i = [start : end]) a[i]];

/**
   ─────────────────────────────────────────────────────────────────────────────
   reverse
   ─────────────────────────────────────────────────────────────────────────────
   Return a new list with the elements in reverse order.

   Parameters:
   list:  The input list to reverse.

   Examples:
   reverse([1, 2, 3])   // returns [3, 2, 1]
   reverse([42])        // returns [42]
   reverse([])          // returns []
*/
function reverse(list) = [for (i = [len(list)-1:-1:0]) list[i]];

/**
   ─────────────────────────────────────────────────────────────────────────────
   non_empty
   ─────────────────────────────────────────────────────────────────────────────
   Test whether a list exists and contains at least one element.

   Parameters:
   items:  The list (or value) to test.

   Behavior:
   Returns true only if items is a truthy value and its length is greater than 0.
   For lists, this effectively tests that the list is not empty.

   Examples:
   non_empty([1, 2])   // returns true
   non_empty([])       // returns false
   non_empty([0])      // returns true   // list has one element (even if element is falsy)
*/
function non_empty(items) = items && len(items) > 0;

/**
   ─────────────────────────────────────────────────────────────────────────────
   map_idx
   ─────────────────────────────────────────────────────────────────────────────
   Extracts a column (index) from a list of records, providing a default value
   for missing entries.

   Parameters:
   items: list of lists (records)
   idx: integer index to extract from each item
   def_val: value to use when items[i][idx] is undefined

   Returns:
   A list where each element is items[i][idx] when defined, otherwise def_val.

   Example:
   map_idx([[10, 30, 50]], [[15, 35, 25]], 1) // -> , [30, 35]
*/
function map_idx(items, idx, def_val) = [for (i = [0 : len(items) - 1])
    is_undef(items[i][idx])
      ? def_val
      : items[i][idx]];

/**
   ─────────────────────────────────────────────────────────────────────────────
   poly_width_at_y
   ─────────────────────────────────────────────────────────────────────────────
   Compute the horizontal width of a polygon at a given y (distance between
   the leftmost and rightmost intersections of the polygon with the horizontal
   line y = y_target).

   Parameters:
   pts:      A list of 2D points defining the polygon, each point as [x, y].
   The polygon is treated as closed (the last point connects to the first).
   y_target: The y coordinate of the horizontal scan line.

   Behavior and notes:
   - The function computes x coordinates where each polygon edge (non-horizontal)
   intersects the horizontal line y = y_target and returns max(intersections) -
   min(intersections).
   - Horizontal edges (edges with identical y values) are skipped to avoid
   division by zero; vertices that lie exactly on y_target can produce
   intersections through adjacent non-horizontal edges.
   - For a simple polygon the horizontal line typically produces an even number
   of intersections; if only one intersection occurs the function returns 0
   (max == min). If there are no intersections the result is undefined (will
   error since max/min are called on an empty list). The caller should ensure
   the line intersects the polygon (or guard against empty intersections).

   Examples:
   poly_width_at_y([[0, 0], [10, 0], [10, 5], [0, 5]], 2)
   // returns 10    (rectangle width at y=2)

   poly_width_at_y([[0, 0],[5, 10],[10, 0]], 5);
   // returns 5     (isosceles triangle intersects at x=2.5 and x=7.5)

   poly_width_at_y([[0, 0],[10, 0],[10, 5],[0, 5]], 0);
   // returns 10    (horizontal line along bottom edge: horizontal edges are ignored,
   // intersections come from vertical edges)

   poly_width_at_y([[0, 0],[5, 10],[10, 0]], 20);
   // undefined      (no intersections; caller should check / avoid this case)
   */
function poly_width_at_y(pts, y_target) =
  let (intersections = [for (i = [0 : len(pts)-1])
           if (((pts[i][1] - y_target)
                * (pts[(i + 1) % len(pts)][1] - y_target) <= 0)
               && (pts[(i + 1) % len(pts)][1] - pts[i][1] != 0))
             pts[i][0] + ((y_target - pts[i][1])
                          / (pts[(i + 1) % len(pts)][1] - pts[i][1]))
               * (pts[(i + 1) % len(pts)][0] - pts[i][0])])
  (max(intersections) - min(intersections));

/**
   ─────────────────────────────────────────────────────────────────────────────
   notched_circle_square_center_x
   ─────────────────────────────────────────────────────────────────────────────
   Compute the x-coordinate of the center of a square "notch" measured from
   the circle center when the square of width `cutout_w` is aligned so that
   its inner corner lies on the circle's circumference.

   Parameters:
   r:         Radius of the circle (must be >= 0).
   cutout_w:  Width of the square cutout (must satisfy cutout_w <= 2 * r).

   Behavior:
   Uses L = sqrt(r^2 - (cutout_w/2)^2) and returns L + cutout_w/2.
   The expression requires cutout_w <= 2*r (otherwise sqrt of a negative
   value occurs). The returned value is in the same units as r and cutout_w.

   Examples:
   notched_circle_square_center_x(10, 6)   // returns ~12.539387
   notched_circle_square_center_x(5, 10)   // returns 5
   notched_circle_square_center_x(5, 11)   // invalid: cutout_w > 2*r -> sqrt of negative
*/
function notched_circle_square_center_x(r, cutout_w) =
  let (L = sqrt(r * r - (cutout_w / 2) * (cutout_w / 2)))
  L + cutout_w / 2;

/**
   ─────────────────────────────────────────────────────────────────────────────
   cutout_depth
   ─────────────────────────────────────────────────────────────────────────────
   Compute the depth (radial intrusion) of a square cutout into a circle.

   Parameters:
   r:         Radius of the circle (must be >= 0).
   cutout_w:  Width of the square cutout (must satisfy cutout_w <= 2 * r).

   Behavior:
   Returns r - sqrt(r^2 - (cutout_w/2)^2). For cutout_w = 0 the depth is 0;
   for cutout_w = 2*r the depth equals r. If cutout_w > 2*r a negative
   value under the square root occurs (invalid).

   Examples:
   cutout_depth(10, 6)   // returns 0.460608
   cutout_depth(5, 10)   // returns 5
   cutout_depth(5, 11)   // nan: cutout_w > 2*r -> sqrt of negative
*/
function cutout_depth(r, cutout_w) =
  r - sqrt(r * r - (cutout_w / 2) * (cutout_w / 2));

/**
   ─────────────────────────────────────────────────────────────────────────────
   calc_isosceles_trapezoid_top_width
   ─────────────────────────────────────────────────────────────────────────────
   Calculate the top (narrower) base width of an isosceles trapezoid.

   Parameters:
   bottom_width:  Width of the bottom base.
   side_length:   Length of each equal side (leg). A negative value is
   accepted but treated as its absolute value.
   angle_deg:     Angle in degrees measured from vertical for each leg.
   (0° = leg vertical, 90° = leg horizontal).

   Behavior:
   Horizontal inset on each side = side_length * sin(angle_deg).
   Top width = bottom_width - 2 * side_length * sin(angle_deg).
   The function clamps the result to a minimum of 0.

   Examples:
   calc_isosceles_trapezoid_top_width(20, 5, 30)   // returns 19.9086
   calc_isosceles_trapezoid_top_width(10, 10, 90)  // returns 9.45176
   calc_isosceles_trapezoid_top_width(12, -3, 45)  // returns 11.9178
*/
function calc_isosceles_trapezoid_top_width(bottom_width,
                                            side_length,
                                            angle_deg) =
  let (a = angle_deg * PI / 180,
       s = abs(side_length),
       top = bottom_width - 2 * s * sin(a))
  max(0, top);

/**
   ─────────────────────────────────────────────────────────────────────────────
   screw_x_offst
   ─────────────────────────────────────────────────────────────────────────────
   Calculates the translation positions for screws.

   Parameters:
   slot_w:    The width of the centered parent slot.
   screw_dia: The diameter of the screw.
   distance:  The desired distance between the centered parent slot and the screw.
*/
function screw_x_offst(slot_w, screw_dia, distance) =
  (slot_w * 0.5 + screw_dia * 0.5) + distance;
