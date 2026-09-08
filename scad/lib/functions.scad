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
   lands on it exactly; otherwise, the last number is the largest value that
   does not exceed `to`.

   **Parameters:**

   `from`: start value (number)
   `to`: end value (number)
   `step`: increment (number)

   **Returns:**
   A list of numbers.

   **Example:**

   ```scad
   number_sequence(from=2, to=7, step=2) // -> [2, 4, 6]
   ```
*/

function number_sequence(from, to, step) = [for (i = [from : step : to]) i];

/**
   ─────────────────────────────────────────────────────────────────────────────
   truncate
   ─────────────────────────────────────────────────────────────────────────────

   Truncate a number to a specified number of decimal places.

   **Parameters:**

   `val`: The input number to truncate.
   `dec`: The number of decimal places to retain (default is 1).

   **Returns:**
   The truncated number.

   **Examples:**

   ```scad
   truncate(3.14159, 2)  // returns 3.14
   truncate(-2.718, 1)   // returns -2.7
   ```
*/
function truncate(val, dec=1) =
  (val >= 0) ? floor(val * pow(10, dec)) / pow(10, dec)
  : ceil(val * pow(10, dec)) / pow(10, dec);

/**
  ─────────────────────────────────────────────────────────────────────────────
  truncate_all_nums
  ─────────────────────────────────────────────────────────────────────────────

  Recursively truncates all numbers to a specified number of decimal places.

  **Example**:
  ```scad
  truncate_all_nums([[0, -2, 0], [10.7654, -1.84776, 0], [21.4142, 8.58579, 0]], 1) // ->
  [[0, -2, 0], [10.7, -1.8, 0], [21.4, 8.5, 0]]

  ```
  */

function truncate_all_nums(vals, dec=1) = is_num(vals)
  ? truncate(vals, dec)
  : is_list(vals)
  ? [for (v = vals) truncate_all_nums(v, dec)]
  : vals;

/**
   ─────────────────────────────────────────────────────────────────────────────
   calc_notch_width
   ─────────────────────────────────────────────────────────────────────────────

   Computes the depth (or reduction in width) at the notch on a circle.

   This function calculates the notch width by determining the chord’s offset
   from the circle’s edge. It subtracts two times the distance from the circle's
   center to the chord (computed using the Pythagorean theorem) from the full
   diameter.

   **Parameters:**

   `dia`: The diameter of the circle.
   `w`: The chord length corresponding to the notch width at the circle’s center.

   **Returns:**
   The calculated notch width (reduction in diameter due to the notch).

   **Example:**

   ```scad
   calc_notch_width(3.2, 10) // -> 1.33975
   ```
*/
function calc_notch_width(dia, w) =
  dia - 2 * sqrt(((dia / 2) * (dia / 2)) - ((w / 2) * (w / 2)));

/**
   ─────────────────────────────────────────────────────────────────────────────
   sum
   ─────────────────────────────────────────────────────────────────────────────

   Recursively sum elements of a numeric list.

   **Parameters:**

   `list`: the list of numeric values.
   `count`: optional number of first elements to sum. If omitted, the whole list
   is summed.

   **Returns:**
   The sum of the requested elements.

   **Examples:**

   ```scad
   sum([1, 5, 10]); // 16
   sum([1, 5, 10], 2); // 6
   sum([]); // 0
   ```
*/
function sum(list, count=undef) =
  let (length = is_undef(count) ? len(list) : count)
  length == 0
  ? 0
  : length < 2
  ? with_default(list[0], 0)
  : (with_default(list[length - 1], 0) + sum(list, length - 1));

/**
   ─────────────────────────────────────────────────────────────────────────────
   drop
   ─────────────────────────────────────────────────────────────────────────────

   Drop the first n elements from a list and return the remainder.

   **Parameters:**

   `a`: The input list.
   `n`: The number of elements to drop from the start (0-based count).

   **Returns:**
   A list containing the elements of `a` after the first `n` elements.

   **Behavior:**
   If `n` is greater than or equal to `len(a)`, an empty list is returned.

   **Examples:**

   ```scad
   drop([1, 2, 3, 4], 2)    // returns [3, 4]
   drop([1, 2], 0)         // returns [1, 2]
   drop([1, 2], 5)         // returns []
   drop([], 0)             // returns []
   ```
*/
function drop(a, n) = n >= len(a) ? [] : [for (i = [n : len(a)-1]) a[i]];
/**
   ─────────────────────────────────────────────────────────────────────────────
   slice
   ─────────────────────────────────────────────────────────────────────────────

   Return a sublist of elements between start and end indices (inclusive).

   Supports negative indices (from end). Indices are clamped to [0..len(a)].

   **Parameters:**

   `a`: The input list.
   `start`: The starting index (inclusive).
   `end`: The ending index (inclusive).

   **Examples:**

   ```scad
   a = [0, 1, 2, 3, 4, 5];

   slice(a, 0, 0) // -> []
   slice(a, 0, 1) // -> [0]
   slice(a, 2, 5) // -> [2, 3, 4]
   slice(a, 2) // -> [2, 3, 4, 5]
   slice(a) // -> [0, 1, 2, 3, 4, 5]
   slice(a, -1) // -> [5]
   slice(a, -3) // -> [3, 4, 5]
   slice(a, 1, -1) // -> [1, 2, 3, 4]
   slice(a, -4, -1) // -> [2, 3, 4]
   slice(a, 99, 100) -> [] // -> []
   slice(a, -99, 2) clamps start // -> [0, 1]
   slice(a, 2, -99) end before start // -> []
   slice(a, 0, 99) clamps end // -> [0, 1, 2, 3, 4, 5]
   ```
*/

function slice(a, start=0, end=undef) =
  let (n  = len(a),
       s0 = (start==undef) ? 0 : start,
       e0 = (end  ==undef) ? n : end,
       s1 = (s0 < 0) ? n + s0 : s0,
       e1 = (e0 < 0) ? n + e0 : e0,
       s  = (s1 < 0) ? 0 : (s1 > n) ? n : s1,
       e  = (e1 < 0) ? 0 : (e1 > n) ? n : e1)
  (e <= s) ? [] : [for (i = [s : e-1]) a[i]];

// function slice(a, start, end) = start > end
//   ? []
//   : [for (i = [start : end]) a[i]];

/**
   ─────────────────────────────────────────────────────────────────────────────
   reverse
   ─────────────────────────────────────────────────────────────────────────────

   Return a new list with the elements in reverse order.

   **Parameters:**

   `list`: The input list to reverse.

   **Returns:**
   A list with elements of `list` in reverse order.

   **Examples:**

   ```scad
   reverse([1, 2, 3])   // returns [3, 2, 1]
   reverse([42])        // returns [42]
   reverse([])          // returns []
   ```
*/
function reverse(list) = [for (i = [len(list)-1:-1:0]) list[i]];

/**
   ─────────────────────────────────────────────────────────────────────────────
   non_empty
   ─────────────────────────────────────────────────────────────────────────────

   Test whether a list exists and contains at least one element.

   **Parameters:**

   `items`: The list (or value) to test.

   **Returns:**
   `true` only if `items` is a truthy value and its length is greater than 0.

   **Examples:**

   ```scad
   non_empty([1, 2])   // returns true
   non_empty([])       // returns false
   non_empty([0])      // returns true   // list has one element (even if element is falsy)
   ```
*/
function non_empty(items) = items && len(items) > 0;

/**
   ─────────────────────────────────────────────────────────────────────────────
   map_idx
   ─────────────────────────────────────────────────────────────────────────────

   Extracts a column (index) from a list of records, providing a default value
   for missing entries.

   **Parameters:**

   `items`: list of lists (records)
   `idx`: integer index to extract from each item
   `def_val`: value to use when `items[i][idx]` is undefined

   **Returns:**
   A list where each element is `items[i][idx]` when defined, otherwise `def_val`.

   **Example:**

   ```scad
   map_idx([[10, 30, 50]], [[15, 35, 25]], 1) // ->  [30, 35]
   ```
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

   **Parameters:**

   `pts`: A list of 2D points defining the polygon, each point as `[x, y]`. The polygon is treated as closed (the last point connects to the first).
   `y_target`: The y coordinate of the horizontal scan line.

   **Returns:**
   The horizontal width at `y_target` (max(intersections) - min(intersections)).

   **Behavior and notes:**
   - The function computes x coordinates where each polygon edge (non-horizontal)
   intersects the horizontal line `y = y_target` and returns `max(intersections) - min(intersections)`.
   - Horizontal edges (edges with identical y values) are skipped to avoid
   division by zero; vertices that lie exactly on `y_target` can produce
   intersections through adjacent non-horizontal edges.
   - For a simple polygon the horizontal line typically produces an even number
   of intersections; if only one intersection occurs the function returns 0
   (`max == min`). If there are no intersections the result is undefined
   (an error occurs since `max/min` are called on an empty list). The caller
   should ensure the line intersects the polygon (or guard against empty intersections).

   **Examples:**

   ```scad
   poly_width_at_y([[0, 0], [10, 0], [10, 5], [0, 5]], 2)
   // returns 10    (rectangle width at y=2)

   poly_width_at_y([[0, 0],[5, 10],[10, 0]], 5);
   // returns 5     (isosceles triangle intersects at x=2.5 and x=7.5)

   poly_width_at_y([[0, 0],[10, 0],[10, 5],[0, 5]], 0);
   // returns 10    (horizontal line along bottom edge: horizontal edges are ignored,
   // intersections come from vertical edges)

   poly_width_at_y([[0, 0],[5, 10],[10, 0]], 20);
   // undefined      (no intersections; caller should check / avoid this case)
   ```
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
   poly_width_at_x
   ─────────────────────────────────────────────────────────────────────────────

   Compute the vertical width of a polygon at a given x (distance between
   the bottommost and topmost intersections of the polygon with the vertical
   line x = x_target).

   **Parameters:**

   `pts`: A list of 2D points defining the polygon, each point as `[x, y]`. The polygon is treated as closed (the last point connects to the first).
   `x_target`: The x coordinate of the vertical scan line.

   **Returns:**
   The vertical width at `x_target` (max(intersections) - min(intersections)).

   **Behavior and notes:**
   - The function computes y coordinates where each polygon edge (non-vertical)
     intersects the vertical line `x = x_target` and returns
     `max(intersections) - min(intersections)`.
   - Vertical edges (edges with identical x values) are skipped to avoid
     division by zero; vertices that lie exactly on `x_target` can produce
     intersections through adjacent non-vertical edges.
   - For a simple polygon the vertical line typically produces an even number
     of intersections; if only one intersection occurs the function returns 0
     (`max == min`). If there are no intersections the result is undefined
     (an error occurs since `max/min` are called on an empty list). The caller
     should ensure the line intersects the polygon (or guard against empty intersections).

   **Examples:**

   ```scad
   poly_width_at_x([[0, 0], [10, 0], [10, 5], [0, 5]], 2)
   // returns 5     (rectangle height at x=2)

   poly_width_at_x([[0, 0],[5, 10],[10, 0]], 5);
   // returns 10    (triangle intersects at y=0 and y=10)

   poly_width_at_x([[0, 0],[10, 0],[10, 5],[0, 5]], 0);
   // returns 5     (vertical line along left edge: vertical edges are ignored,
   // intersections come from horizontal edges)

   poly_width_at_x([[0, 0],[5, 10],[10, 0]], 20);
   // undefined      (no intersections; caller should check / avoid this case)
   ```
*/
function poly_width_at_x(pts, x_target) =
  let (intersections = [for (i = [0 : len(pts)-1])
           if (((pts[i][0] - x_target)
                * (pts[(i + 1) % len(pts)][0] - x_target) <= 0)
               && (pts[(i + 1) % len(pts)][0] - pts[i][0] != 0))
             pts[i][1] + ((x_target - pts[i][0])
                          / (pts[(i + 1) % len(pts)][0] - pts[i][0]))
               * (pts[(i + 1) % len(pts)][1] - pts[i][1])])
  (max(intersections) - min(intersections));

/**
   ─────────────────────────────────────────────────────────────────────────────
   notched_circle_square_center_x
   ─────────────────────────────────────────────────────────────────────────────

   Compute the x-coordinate of the center of a square "notch" measured from
   the circle center when the square of width `cutout_w` is aligned so that
   its inner corner lies on the circle's circumference.

   **Parameters:**

   `r`: Radius of the circle (must be >= 0).
   `cutout_w`: Width of the square cutout (must satisfy `cutout_w <= 2 * r`).

   **Returns:**
   The x-coordinate (in same units as `r` and `cutout_w`).

   **Behavior:**
   Uses `L = sqrt(r^2 - (cutout_w/2)^2)` and returns `L + cutout_w/2`.
   The expression requires `cutout_w <= 2*r` (otherwise `sqrt` of a negative
   value occurs).

   **Examples:**

   ```scad
   notched_circle_square_center_x(10, 6)   // returns ~12.539387
   notched_circle_square_center_x(5, 10)   // returns 5
   notched_circle_square_center_x(5, 11)   // invalid: cutout_w > 2*r -> sqrt of negative
   ```
*/
function notched_circle_square_center_x(r, cutout_w) =
  let (L = sqrt(r * r - (cutout_w / 2) * (cutout_w / 2)))
  L + cutout_w / 2;

/**
   ─────────────────────────────────────────────────────────────────────────────
   cutout_depth
   ─────────────────────────────────────────────────────────────────────────────

   Compute the depth (radial intrusion) of a square cutout into a circle.

   **Parameters:**

   `r`: Radius of the circle (must be >= 0).
   `cutout_w`: Width of the square cutout (must satisfy `cutout_w <= 2 * r`).

   **Returns:**
   The radial depth of the cutout.

   **Behavior:**
   Returns `r - sqrt(r^2 - (cutout_w/2)^2)`. For `cutout_w = 0` the depth is 0;
   for `cutout_w = 2*r` the depth equals `r`. If `cutout_w > 2*r` a negative
   value under the square root occurs (invalid).

   **Examples:**

   ```scad
   cutout_depth(10, 6)   // returns 0.460608
   cutout_depth(5, 10)   // returns 5
   cutout_depth(5, 11)   // nan: cutout_w > 2*r -> sqrt of negative
   ```
*/
function cutout_depth(r, cutout_w) =
  r - sqrt(r * r - (cutout_w / 2) * (cutout_w / 2));

/**
   ─────────────────────────────────────────────────────────────────────────────
   calc_isosceles_trapezoid_top_width
   ─────────────────────────────────────────────────────────────────────────────

   Calculate the top (narrower) base width of an isosceles trapezoid.

   **Parameters:**

   `bottom_width`: Width of the bottom base.
   `side_length`: Length of each equal side (leg). A negative value is accepted but treated as its absolute value.
   `angle_deg`: Angle in degrees measured from vertical for each leg. (0° = leg vertical, 90° = leg horizontal).

   **Returns:**
   The top base width (clamped to a minimum of 0).

   **Behavior:**
   Horizontal inset on each side = `side_length * sin(angle_deg)`.
   `top = bottom_width - 2 * side_length * sin(angle_deg)`.
   The function clamps the result to a minimum of 0. OpenSCAD’s trigonometric
   functions operate on degrees, so `angle_deg` is passed directly to `sin()`.

   **Examples:**

   ```scad
   calc_isosceles_trapezoid_top_width(20, 5, 30)   // returns 15
   calc_isosceles_trapezoid_top_width(10, 10, 90)  // returns 0
   calc_isosceles_trapezoid_top_width(12, -3, 45)  // returns 7.75736
   ```
*/
function calc_isosceles_trapezoid_top_width(bottom_width,
                                            side_length,
                                            angle_deg) =
  let (s = abs(side_length),
       top = bottom_width - 2 * s * sin(angle_deg))
  max(0, top);

/**
   ─────────────────────────────────────────────────────────────────────────────
   bolt_x_offst
   ─────────────────────────────────────────────────────────────────────────────

   Calculates the translation positions for bolts.

   **Parameters:**

   `slot_w`: The width of the centered parent slot.
   `bolt_dia`: The diameter of the bolt.
   `distance`: The desired distance between the centered parent slot and the bolt.

   **Returns:**
   The x offset for placing the bolt relative to slot center.

   **Example:**

   ```scad
   bolt_x_offst(10, 3.5, 2) // -> 8.75
   ```
*/
function bolt_x_offst(slot_w, bolt_dia, distance) =
  (slot_w * 0.5 + bolt_dia * 0.5) + distance;

/**
   ─────────────────────────────────────────────────────────────────────────────
   sort_by_idx
   ─────────────────────────────────────────────────────────────────────────────

   Sorts a list of scalars or a list of lists by the element at a given index.
   Uses a simple recursive selection-sort style algorithm that preserves list
   elements (if elements are lists they are returned as whole items).

   **Parameters:**

   `elems`: A list of scalars or a list of lists to be sorted.
   `asc`:   Boolean, true for ascending order (default true), false for descending.
   `idx`:   When elements are lists, the index inside each element to use as the
   sort key. If elements are scalars or idx is out of range, the element
   itself is used as the key (default 0).

   **Returns:**
   A new list containing the elements of `elems` sorted according to the key.

   **Examples:**

   ```scad
   sort_by_idx([1,3,2], true);                     // -> [1, 2, 3]
   sort_by_idx([[1,5],[3,10],[2,4]], true, idx=0); // -> [[1,5], [2,4], [3,10]]
   sort_by_idx([[1,5],[3,10],[2,4]], false, idx=1);// -> [[3,10], [1,5], [2,4]]
   ```
*/
function sort_by_idx(elems, asc=true, idx=0) =
  len(elems) <= 1 ? elems :
  let (best_i = find_best_index(elems, idx, asc),
       best   = elems[best_i],
       rest   = [for (i=[0:len(elems)-1]) if (i != best_i) elems[i]])
  concat([best], sort_by_idx(rest, asc, idx));

/**
   ─────────────────────────────────────────────────────────────────────────────
   find_best_index
   ─────────────────────────────────────────────────────────────────────────────

   Finds the index of the "best" element in a list according to a key and sort
   direction. Used internally by sort_by_idx. Performs a linear scan to locate
   either the minimum (asc=true) or maximum (asc=false) element by key.

   **Parameters:**

   `elems`:  A list of scalars or a list of lists to search.
   `idx`:    When elements are lists, the index inside each element to use as the
   comparison key. If elements are scalars or idx is out of range,
   the element itself is used as the key.
   `asc`:    Boolean, true to select the minimum key (ascending), false to
   select the maximum key (descending).
   `i`:      Internal recursion parameter: current index being examined
   (do not set unless you know what you're doing; default 0).
   `best_i`: Internal recursion parameter: index of current best candidate
   (do not set unless you know what you're doing; default 0).

   **Returns:**
   The index (integer) of the best element in `elems` according to the key and
   direction. If `elems` is empty behavior is not defined (caller should ensure
   non-empty list).

   **Examples:**

   ```scad
   find_best_index([1,3,2], 0, true);                     // -> 0  (index of min 1)
   find_best_index([1,3,2], 0, false);                    // -> 1  (index of max 3)
   find_best_index([[1,5],[3,10],[2,4]], 0, true);        // -> 0  (index of [1,5])
   find_best_index([[1,5],[3,10],[2,4]], 0, false);       // -> 1  (index of [3,10])
   ```
*/
function find_best_index(elems, idx, asc, i=0, best_i=0) =
  i >= len(elems) ? best_i :
  let (k  = key(elems[i], idx),
       bk = key(elems[best_i], idx),
       better = asc ? (k < bk) : (k > bk))
  better ? find_best_index(elems, idx, asc, i + 1, i)
  : find_best_index(elems, idx, asc, i + 1, best_i);

/**
   ─────────────────────────────────────────────────────────────────────────────
   key
   ─────────────────────────────────────────────────────────────────────────────

   Extracts the comparison key from an item. If the item is a list and the
   requested index is within range, returns item[idx]. Otherwise returns the
   item itself (useful for mixing scalars and lists as sortable elements).

   **Parameters:**

   `item`: The element to extract the key from (scalar or list).
   `idx`:  Index to use when `item` is a list.

   **Returns:**
   The selected key value (either item[idx] or item).

   **Examples:**

   ```scad
   key([3,10], 1); // -> 10
   key([3,10], 2); // -> [3,10] (idx out of range, returns the whole item)
   key(5, 0);      // -> 5
   ```
*/
function key(item, idx) =
  is_list(item) && (idx >= 0) && (idx < len(item)) ? item[idx] : item;

/**
   ─────────────────────────────────────────────────────────────────────────────
   rot_x_bbox_align
   ─────────────────────────────────────────────────────────────────────────────

   Calculate the bounding box size of a rectangle rotated around the X axis.

   **Parameters:**

   `size`: A 3-element vector [dx, dy, dz] representing the size of the box.
   `angle`: The rotation angle in radians.
   `pos`: Optional 2-element vector [y0, z0] representing the position offset
   in the YZ plane (default is [0, 0]).

   **Returns:**
   A 6-element vector:
   [rotated_size_y, rotated_size_z, min_y, min_z, max_y, max_z]

   where rotated_size_y and rotated_size_z are the dimensions of the bounding
   box after rotation, and min_y, min_z, max_y, max_z are the extents in YZ
   plane.

   **Example:**

   ```scad
   bbox = rot_x_bbox_align([w, h, thickness], angle=angle);
   bbox_w = bbox[0];
   bbox_h = bbox[1];
   ```
*/
function rot_x_bbox_align(size, angle, pos=[0, 0]) =
  let (y0 = pos[0],
       y1 = pos[0] + size[1],
       z0 = pos[1],
       z1 = pos[1] + size[2],

       ya = y0*cos(angle) - z0*sin(angle),
       yb = y1*cos(angle) - z0*sin(angle),
       yc = y0*cos(angle) - z1*sin(angle),
       yd = y1*cos(angle) - z1*sin(angle),

       za = y0*sin(angle) + z0*cos(angle),
       zb = y1*sin(angle) + z0*cos(angle),
       zc = y0*sin(angle) + z1*cos(angle),
       zd = y1*sin(angle) + z1*cos(angle),

       min_y = min([ya, yb, yc, yd]),
       max_y = max([ya, yb, yc, yd]),
       min_z = min([za, zb, zc, zd]),
       max_z = max([za, zb, zc, zd]),

       rot_y_size = max_y - min_y,
       rot_z_size = max_z - min_z,
       z_shift = -min_z)
  [rot_y_size, rot_z_size, min_y, min_z, max_y, max_z];

/**
   ─────────────────────────────────────────────────────────────────────────────
   in_list
   ─────────────────────────────────────────────────────────────────────────────

   Check if an item is present in a list.

   **Parameters:**

   `item`: The item to search for.
   `list`: The list to search within.
   `i`: Internal recursion index (do not set unless you know what you're doing).

   **Returns:**
   `true` if `item` is found in `list`, otherwise `false`.

   **Examples:**

   ```scad
   in_list(3, [1, 2, 3]); // returns true
   in_list(4, [1, 2, 3]); // returns false
   ```
*/
function in_list(item, list, i = 0) =
  i >= len(list) ? false
  : (list[i] == item) ? true
  : in_list(item, list, i + 1);
/**
   ─────────────────────────────────────────────────────────────────────────────
   with_default
   ─────────────────────────────────────────────────────────────────────────────
   Returns `val` if it is defined and matches the specified type, otherwise,
   returns `default`.
   **Parameters:**
   `val`: The value to check.
   `default`: The default value to return if `val` is undefined or of the wrong type.
   `type`: A string specifying the expected type of `val`. Can be:
   - "any" (default) or undef
   - "number" or "n"
   - "string", "str" or "s"
   - "list", "l", "arr"
   **Returns:**
   `val` if it is defined and of the correct type, otherwise `default`.

*/
function with_default(val, default, type = "any") =
  (is_undef(type) || type == "any")
  ? (is_undef(val) ? default : val)
  : in_list(type, ["str", "string", "s"])
  ? (is_string(val) ? val : default)
  : in_list(type, ["l", "arr", "list"])
  ? (is_list(val) ? val : default)
  : in_list(type, ["n", "number"])
  ? (is_num(val) ? val : default)
  : default;

/*
  ─────────────────────────────────────────────────────────────────────────────
  calc_cols_params
  ─────────────────────────────────────────────────────────────────────────────

  **Example**:
  ```scad
  calc_cols_params(cols=4, w=10, gap=2); // -> [12, 46]

  ```
*/
function calc_cols_params(cols, w, gap) =
  let (step = gap + w,
       total_x = cols * w + (cols - 1)
       * gap)
  [step, total_x];

/**
   ─────────────────────────────────────────────────────────────────────────────
   constraint
   ─────────────────────────────────────────────────────────────────────────────

   **Example**:
   ```scad
   constraint(10, 12, 12) // ->  12
   constraint(10, 11, 12) // ->  11
   constraint(10, 10, 12) // ->  10
   constraint(13, 10, 12) // ->  12
   ```
*/
function constraint(val, min_val, max_val) =
  max(min_val, min(max_val, val));

/**
   ─────────────────────────────────────────────────────────────────────────────
   clamp
   ─────────────────────────────────────────────────────────────────────────────

   **Example**:
   ```scad
   clamp(1, 0, len([1, 2, 3])) // -> 1

   ```
*/
function clamp(x, lo, hi) = (x < lo) ? lo : (x > hi) ? hi : x;

/**
   ─────────────────────────────────────────────────────────────────────────────
   take
   ─────────────────────────────────────────────────────────────────────────────
   Take first n (clamped). If n <= 0 => []

   **Example**:
   ```scad
   take(["foo", "bar", "baz"], 1); // => ["foo"]
   take(["foo", "bar", "baz"], 2); // => ["foo", "bar"]
   take(["foo", "bar", "baz"], 3); // => ["foo", "bar", "baz"]
   take(["foo", "bar", "baz"], 4); // => ["foo", "bar", "baz"]
   take(["foo", "bar", "baz"], 0); // => []
   ```

*/
function take(l, n=1) =
  let (nn = with_default(n, 1))
  (nn <= 0) ? [] : slice(l, 0, nn);

/**
   ─────────────────────────────────────────────────────────────────────────────
   drop
   ─────────────────────────────────────────────────────────────────────────────
   Drop first n. If n <= 0 => original list

   **Example**:
   ```scad
   drop(["foo", "bar", "baz"], 1); //=> ["bar", "baz"]
   drop(["foo", "bar", "baz"], 2); //=> ["baz"]
   drop(["foo", "bar", "baz"], 3); //=> []
   drop(["foo", "bar", "baz"], 4); //=> []
   ```

*/
function drop(l, n=1) =
  let (nn = with_default(n, 1))
  (nn <= 0) ? l : slice(l, nn);

/**
   ─────────────────────────────────────────────────────────────────────────────
   drop_last
   ─────────────────────────────────────────────────────────────────────────────
   Drop last n. If n <= 0 => original list

   **Example**:

   ```scad
   drop_last(["foo", "bar", "baz"]); //=> ["foo", "bar"]
   drop_last(["foo", "bar", "baz"], 1); //=> ["foo", "bar"]
   drop_last(["foo", "bar", "baz"], 2); //=> ["foo"]
   drop_last(["foo", "bar", "baz"], 3); //=> []
   drop_last(["foo", "bar", "baz"], 4); //=> []
   drop_last(["foo", "bar", "baz"], 4 ); //=> []
   ```

*/
function drop_last(l, n=1) =
  let (nn  = clamp(with_default(n, 1), 0, len(l)))
  (nn <= 0) ? l : slice(l, 0, len(l) - nn);

/**
   ─────────────────────────────────────────────────────────────────────────────
   take_last
   ─────────────────────────────────────────────────────────────────────────────
   Take last n. If n <= 0 => []

   **Example**:
   ```scad
   take_last(["foo", "bar", "baz"], 1); // => ["baz"]
   take_last(["foo", "bar", "baz"], 2); // => ["bar", "baz"]
   take_last(["foo", "bar", "baz"], 3); // => ["foo", "bar", "baz"]
   take_last(["foo", "bar", "baz"], 4); // => ["foo", "bar", "baz"]
   ```

*/
function take_last(l, n=1) =
  let (nn  = clamp(with_default(n, 1), 0, len(l)))
  (nn <= 0) ? [] : slice(l, len(l) - nn, len(l));

/**
   ─────────────────────────────────────────────────────────────────────────────
   search_idxs
   ─────────────────────────────────────────────────────────────────────────────

   **Example**:
   ```scad
   search_idxs([2, 1, 2, 3], 2); // => [0, 2]
   ```
*/
function search_idxs(l, val) = [for (i = [0:len(l) - 1]) if (l[i] == val) i];

/**
   ─────────────────────────────────────────────────────────────────────────────
   search_idx
   ─────────────────────────────────────────────────────────────────────────────

   **Example**:
   ```scad
   search_idx([2, 1, 2, 3], 2); // => 0
   ```
*/
function search_idx(l, val) = search_idxs(l, val)[0];

/**
   ─────────────────────────────────────────────────────────────────────────────
   search_idx
   ─────────────────────────────────────────────────────────────────────────────

   **Example**:
   ```scad
   member(2, [2, 1, 2, 3]); // => true
   member(10, [2, 1, 2, 3]); // => false
   ```
*/
function member(x, xs) =
  true == [for (v = xs) if (v == x) true][0];

/**
   ─────────────────────────────────────────────────────────────────────────────
   flatten_pairs
   ─────────────────────────────────────────────────────────────────────────────
   Turns [[a,b], [c,d]] into [a, b, c, d]

   **Example**:
   ```scad
   flatten_pairs([[2, 1], [2, 3]]); // => [2, 1, 2, 3]
   ```
*/
function flatten_pairs(pairs) = [for (p = pairs) each p];

/**
   ─────────────────────────────────────────────────────────────────────────────
   list_sum
   ─────────────────────────────────────────────────────────────────────────────

   **Example**:
   ```scad
   list_sum([]); 0
   list_sum([1]); ->  1
   list_sum([1, 2]); // ->  3
   list_sum([1, 2, 3]); // ->  6
   list_sum([], 1); // -> 0
   list_sum([1], 1); // -> 0
   list_sum([1, 2], 1); // -> 2
   list_sum([1, 2], 2); // ->  0
   list_sum([1, 2], 0); // ->  3

   ```
*/
function list_sum(v, i=0) =
  i >= len(v) ? 0 : v[i] + list_sum(v, i + 1);

/**
   ─────────────────────────────────────────────────────────────────────────────
   best_by_lower_sum
   ─────────────────────────────────────────────────────────────────────────────
   Choose the “better” of two lists.

   Rules (in order):
   - If one list is empty (`[]`), return the other.
   - Prefer the list with the smaller `list_sum(...)`.
   - If sums are equal, prefer the lexicographically larger list (`a > b`).

   **Example**:
   ```scad
   best_by_lower_sum([], [1,2]);        //=> [1,2]
   best_by_lower_sum([1,2], []);        //=> [1,2]

   best_by_lower_sum([1,1,1], [3]);     //=> [1,1,1]   (sum 3 == sum 3, tie-break by lex order)
   best_by_lower_sum([1,2],   [4]);     //=> [1,2]     (3 < 4)
   best_by_lower_sum([2,2],   [1,3]);   //=> [2,2]     (sum tie: 4 == 4, and [2,2] > [1,3])
   ```
*/
function best_by_lower_sum(a, b) =
  a == [] ? b :
  b == [] ? a :
  list_sum(a) < list_sum(b) ? a :
  list_sum(a) > list_sum(b) ? b :
  a > b ? a : b;

/**
   ─────────────────────────────────────────────────────────────────────────────
   best_list_by_lower_sum
   ─────────────────────────────────────────────────────────────────────────────
   Return the “best” list from a list-of-lists `v`, using `best_by_lower_sum()`.


   **Example**:
   ```scad
   best_list_by_lower_sum([]);                              //=> []
   best_list_by_lower_sum([[], [1,2], [3]]);                //=> [3]      (sum tie 3==3, [3] > [1,2])
   best_list_by_lower_sum([[], []]);                        //=> []
   ```
*/
function best_list_by_lower_sum(v, i=0) =
  i == len(v) ? [] :
  best_by_lower_sum(v[i], best_list_by_lower_sum(v, i + 1));

/**
   ─────────────────────────────────────────────────────────────────────────────
   best_height_combo
   ─────────────────────────────────────────────────────────────────────────────
   Find the “best” combination of heights whose sum is >= `min_h`, using at most
   `limit` items, chosen from `heights` (repetition allowed).

   Notes:
   - Order matters for tie-breaking (because lexicographic comparison is used),
   even if multiple permutations represent the same multiset.
   - A result may overshoot `min_h`; overshoot is allowed and minimized.

   **Example**:
   ```scad
   best_height_combo(6, [1,3,4], 2);   //=> [3,3]   (sum 6)
   best_height_combo(6, [4,5],   2);   //=> [4,4]   (sum 8; [5,5] is 10)
   best_height_combo(6, [4,5],   1);   //=> []      (can't reach 6 with one item)
   best_height_combo(1, [2,3],   3);   //=> [2]     (sum 2 is minimal >= 1)
   ```
*/
function best_height_combo(min_h, heights, limit) =
  min_h <= 0 ? [] :
  limit == 0 ? [] :
  let (candidates = [for (h = heights)
           let (r = best_height_combo(min_h - h, heights, limit - 1))
             r == [] && min_h - h > 0 ? [] : concat([h], r)])
  best_list_by_lower_sum(candidates);

/**
   ─────────────────────────────────────────────────────────────────────────────
   repeat
   ─────────────────────────────────────────────────────────────────────────────

   Returns a fixed list of size n containing a specified identical value.

   **Example**:
   ```scad
   repeat("a", 3) // ["a", "a", "a"]
   repeat("a", 2) // ["a", "a"]
   repeat("a", 1) // ["a"]
   repeat("a", 0) // []

   ```
*/
function repeat(v, n=1) =
  (n <= 0) ? [] : [for (i = [0 : n-1]) v];

/**
   ─────────────────────────────────────────────────────────────────────────────
   join
   ─────────────────────────────────────────────────────────────────────────────

   Joins strings with an optional separator and limit.


   **Example**:
   ```scad
   join(["a", "b", "c"]) // -> "abc"
   join(["a", "b", "c"], sep=" ") // -> "a b c"
   join([], sep=" ") // -> ""

   ```
*/

function join(parts, sep="", limit = undef) =
  let (n = is_undef(limit) ? len(parts) : limit)
  n == 0 ? "" :
  n == 1 ? parts[n-1] :
  str(join(parts, sep, n-1), sep, parts[n-1]);

/**
   ─────────────────────────────────────────────────────────────────────────────
   rot2
   ─────────────────────────────────────────────────────────────────────────────

   Rotates a 2D point `p` around the origin by `a` degrees (counter-clockwise).

   Parameters:
   - `p` (vec2): Point `[x, y]`
   - `a` (number): Angle in degrees

   Returns:
   - (vec2) Rotated point `[x, y]`

   **Example**:
   ```scad
   rot2([1, 0], 90);   // -> [0, 1]
   rot2([10, 5], -45); // -> [10.6066, -3.53553] rotates clockwise
   ```
*/
function rot2(p, a) =
  [p[0] * cos(a) - p[1] * sin(a),
   p[0] * sin(a) + p[1] * cos(a)];

/**
   ─────────────────────────────────────────────────────────────────────────────
   rotated_bbox2
   ─────────────────────────────────────────────────────────────────────────────

   Computes the axis-aligned bounding box (AABB) of the rectangle `[0..w]×[0..h]`
   after rotating it by `a` degrees around the origin.

   Parameters:
   - `w` (number): Rectangle width (X size)
   - `h` (number): Rectangle height (Y size)
   - `a` (number): Rotation angle in degrees (about Z / in XY plane)

   Returns:
   - (vec4) `[minx, miny, maxx, maxy]` of the rotated rectangle.

   **Example**:
   ```scad
   rotated_bbox2(20, 10, 90); // -> [-10, 0, 0, 20]
   rotated_bbox2(20, 10, 0);  // -> [0, 0, 20, 10]
   ```
*/
function rotated_bbox2(w, h, a) =
  let (p0 = rot2([0, 0], a),
       p1 = rot2([w, 0], a),
       p2 = rot2([0, h], a),
       p3 = rot2([w, h], a),
       minx = min(p0[0], p1[0], p2[0], p3[0]),
       miny = min(p0[1], p1[1], p2[1], p3[1]),
       maxx = max(p0[0], p1[0], p2[0], p3[0]),
       maxy = max(p0[1], p1[1], p2[1], p3[1]))
  [minx, miny, maxx, maxy];

/**
   ─────────────────────────────────────────────────────────────────────────────
   calc_rotated_bbox
   ─────────────────────────────────────────────────────────────────────────────

   Convenience wrapper around `rotated_bbox2()` that returns:

   - the rotated full extents (`fullx`, `fully`)
   - the translation (`sx`, `sy`) needed to move the rotated shape so that the
   bounding box minimum becomes `[0, 0]`.

   This is useful for rotating a non-centered rectangle/cube around the origin
   while keeping the final result entirely in the positive XY quadrant.

   Parameters:
   - `w` (number): Width in X
   - `h` (number): Height in Y
   - `a` (number): Rotation angle in degrees

   Returns:
   - (vec4) `[fullx, fully, sx, sy]`

   Where:
   - `fullx = maxx - minx`
   - `fully = maxy - miny`
   - `sx = -minx`
   - `sy = -miny`

   **Example**:
   ```scad
   calc_rotated_bbox(20, 10, 0); // [10, 20, 10, 0]
   calc_rotated_bbox(20, 10, 0); // [20, 10, 0, 0]
   calc_rotated_bbox(20, 10, 45) // [~21.2132, ~21.2132, ~7.07107, 0]
   ```
*/
function calc_rotated_bbox(w, h, a) =
  let (b = rotated_bbox2(w, h, a))
  [b[2] - b[0],   // fullx
   b[3] - b[1],   // fully
   -b[0],          // sx
   -b[1]           // sy
  ];

function percent_to_mm(percent, total_val) = percent * total_val / 100;

function to_percent(val, total_val) =
  (total_val == 0) ? 0 : (val * 100 / total_val);

/**
   ─────────────────────────────────────────────────────────────────────────────
   notch_depth
   ─────────────────────────────────────────────────────────────────────────────

   Computes the notch depth (sagitta) for a circle of diameter `dia` when a flat
   cut (chord) of width `chord` is applied.

   In other words, this returns how far the circle extends beyond the chord line:
   the distance from the chord to the circle arc measured perpendicular to the
   chord. This is useful for sizing a rectangular “filler”/“notch” block so a
   flat face of width `chord` can blend into or contact a cylinder of diameter `dia`.

   Parameters:
   - `dia`: Circle diameter (must be > 0)
   - `chord`: Chord length / flat width across the circle
                  (must satisfy `0 <= chord <= dia`)

   Returns:
   Notch depth (sagitta), in the same units as `dia` and `chord`.

   Notes:
   - If `chord > dia`, the square root becomes invalid (no real solution).
   - Result is `0` when `chord == 0`, and `dia/2` when `chord == dia`.

   **Example**:
   ```scad
   module notch_depth_example(dia=20, h=5, size=[12, 10, 5]) {
     notch_d = notch_depth(dia, size[1]);

     union() {
       cylinder(d=dia, h=h, $fn=150);

       translate([dia / 2 - notch_d / 2, 0, size[2] / 2]) {
         cube([notch_d, size[1], size[2]], center=true);
       }
       translate([dia / 2 + size[0] / 2, 0, size[2] / 2]) {
         cube(size=size,
              center=true);
       }
     }
   }

   notch_depth_example();

   ```
*/

function notch_depth(dia, chord) =
  let (r = dia / 2)
  r - sqrt((r * r) - ((chord / 2) * (chord / 2)));

/**
 ─────────────────────────────────────────────────────────────────────────────
taper_angle_from_axis
─────────────────────────────────────────────────────────────────────────────

Calculate the taper angle from the axis given two diameters and height.

**Parameters:**

`d1`: Diameter at one end.
`d2`: Diameter at the other end.
`h`: Height between the two diameters.

**Returns:**
The taper angle in radians.

**Behavior:**
Uses `atan(abs(d2 - d1) / 2 / h)` to compute the angle.

**Examples:**

```scad
taper_angle_from_axis(d1=10, d2=20, h=5) // 45 degrees
```
*/
function taper_angle_from_axis(d1, d2, h) =
  atan(abs(d2 - d1) / 2 / h);
/**
─────────────────────────────────────────────────────────────────────────────
diameter_at_z
─────────────────────────────────────────────────────────────────────────────

Calculate the diameter at a given height `z` for a tapered shape.

**Parameters:**

`d1`: Diameter at the base (z=0).
`d2`: Diameter at the top (z=h).
`h`: Height of the taper.
`z`: Height at which to calculate the diameter (0 <= z <= h).

**Returns:**

The diameter at height `z`.

**Behavior:**
Linearly interpolates between `d1` and `d2` based on `z`.

**Examples:**
```scad
diameter_at_z(d1=10, d2=15, h=5) // 13
```
*/

function diameter_at_z(d1, d2, h, z) =
  d1 + (d2 - d1) * (z / h);

/**
 ─────────────────────────────────────────────────────────────────────────────
 diameters_at_z
 ─────────────────────────────────────────────────────────────────────────────

 Calculate the diameters at heights `z` and `z + t` for a tapered shape

 **Parameters:**

 `d1`: Diameter at the base (z=0).
 `d2`: Diameter at the top (z=h).
 `h`: Height of the taper.
 `z`: Height at which to calculate the first diameter (0 <= z <= h).
 `t`: Thickness to add to `z` for the second diameter calculation.

 **Returns:**
 A 2-element list containing the diameters at heights `z` and `z + t`.

 **Examples:**
 ```scad
 diameters_at_z(d1=10, d2=15, h=10, z=7, t=3) // [13.5, 15]
````
*/

function diameters_at_z(d1, d2, h, z, t) =
  let (dz1 = diameter_at_z(d1=d1, d2=d2, h=h, z=z),
       dz2 = diameter_at_z(d1=d1, d2=d2, h=h, z=z + t))
  [dz1, dz2];

/**
─────────────────────────────────────────────────────────────────────────────
last
─────────────────────────────────────────────────────────────────────────────
Returns the last element of the given list or string.

**Example**:

```scad
last(["foo", "bar", "baz"]); // => "baz"
last("baz"); // => "z"
last([]); // => undef
last(""); // => undef
```

*/

function last(l) =
  (len(l) == 0) ? undef : l[len(l) - 1];

/**
  ─────────────────────────────────────────────────────────────────────────────
  qsort
  ─────────────────────────────────────────────────────────────────────────────

  Quicksort with selectable order.

  **Example**:
  ```scad
  nums = [5, 2, 9, 2, 1, 7];
  echo(qsort(nums, asc=true));   // [1, 2, 2, 5, 7, 9]
  echo(qsort(nums, asc=false));  // [9, 7, 5, 2, 2, 1]

  ```
  */

function qsort(v, asc=true) =
  len(v) <= 1
  ? v
  : let (pivot = v[0],
         left = [for (x=v) if (asc ? x < pivot : x > pivot) x],
         mid  = [for (x=v) if (x == pivot) x],
         right  = [for (x=v) if (asc ? x > pivot : x < pivot) x])
  concat(qsort(left, asc), mid, qsort(right, asc));

/**
─────────────────────────────────────────────────────────────────────────────
rotX
─────────────────────────────────────────────────────────────────────────────

Rotate a 3D point around the X axis.

**Parameters:**

`p`: 3D point `[x, y, z]`.
`a`: Rotation angle in degrees.

**Returns:**

A new 3D point `[x', y', z']` which is `p` rotated about the X axis by `a`.

**Behavior:**
Uses the standard right-handed rotation matrix for X-axis rotation.

**Examples:**
```scad
rotX([0, 1, 0], 90);  // -> [0, 0, 1]
```
*/
function rotX(p, a) =
  let (c=cos(a), s=sin(a)) [p[0],  c*p[1]-s*p[2], s*p[1] + c*p[2]];

/**
─────────────────────────────────────────────────────────────────────────────
rotY
─────────────────────────────────────────────────────────────────────────────

Rotate a 3D point around the Y axis.

**Parameters:**

`p`: 3D point `[x, y, z]`.
`a`: Rotation angle in degrees.

**Returns:**

A new 3D point `[x', y', z']` which is `p` rotated about the Y axis by `a`.

**Behavior:**
Uses the standard right-handed rotation matrix for Y-axis rotation.

**Examples:**
```scad
rotY([1, 0, 0], 90);  // -> [0, 0, -1]
```
*/
function rotY(p, a) =
  let (c=cos(a), s=sin(a)) [c*p[0] + s*p[2], p[1], -s*p[0] + c*p[2]];

/**
─────────────────────────────────────────────────────────────────────────────
rotZ
─────────────────────────────────────────────────────────────────────────────

Rotate a 3D point around the Z axis.

**Parameters:**

`p`: 3D point `[x, y, z]`.
`a`: Rotation angle in degrees.

**Returns:**

A new 3D point `[x', y', z']` which is `p` rotated about the Z axis by `a`.

**Behavior:**
Uses the standard right-handed rotation matrix for Z-axis rotation.

**Examples:**
```scad
rotZ([1, 0, 0], 90);  // -> [0, 1, 0]
```
*/
function rotZ(p, a) =
  let (c=cos(a), s=sin(a)) [c*p[0]-s*p[1], s*p[0] + c*p[1], p[2]];

/**
─────────────────────────────────────────────────────────────────────────────
rotate_euler_xyz
─────────────────────────────────────────────────────────────────────────────

Rotate a 3D point by Euler angles `a=[ax, ay, az]` (degrees), applied in X→Y→Z
order.

This is a helper used by the bounding-box functions to rotate each corner of a
box consistently.

**Parameters:**

`p`: 3D point `[x, y, z]`.
`a`: Rotation angles in degrees: `[ax, ay, az]`.

**Returns:**

The rotated 3D point.

**Behavior:**
Applies `rotX(p, ax)`, then `rotY(..., ay)`, then `rotZ(..., az)`.

**Examples:**
```scad
rotate_euler_xyz([10, 0, 0], [0, 0, 90]); // -> [0, 10, 0]
```
*/
function rotate_euler_xyz(p, a) =  // a = [ax,ay,az] in degrees
  rotZ(rotY(rotX(p, a[0]), a[1]), a[2]);

/**
─────────────────────────────────────────────────────────────────────────────
rotated_aabb_minmax
─────────────────────────────────────────────────────────────────────────────

Compute the axis-aligned bounding box (AABB) of a rectangular box after it is
rotated around the origin.

The unrotated box is defined by the 8 corners spanning:
`x ∈ [0, sx]`, `y ∈ [0, sy]`, `z ∈ [0, sz]`.

**Parameters:**

`sx`: Size along X (box extent in X before rotation).
`sy`: Size along Y (box extent in Y before rotation).
`sz`: Size along Z (box extent in Z before rotation).
`a`: Rotation angles in degrees `[ax, ay, az]` (default `[0,0,0]`).

**Returns:**

`[minx, miny, minz, maxx, maxy, maxz]` - the AABB of the rotated box.

**Behavior:**
Rotates all 8 corners of the original box by `a` (about the origin), then takes
component-wise minima and maxima to form the AABB.

**Examples:**
```scad
rotated_aabb_minmax(10, 20, 5, [0, 0, 45]);
```
*/
function rotated_aabb_minmax(sx, sy, sz, a=[0, 0, 0]) =
  let (pts = [rotate_euler_xyz([0 , 0 , 0], a),
              rotate_euler_xyz([sx, 0 , 0], a),
              rotate_euler_xyz([0 , sy, 0], a),
              rotate_euler_xyz([sx, sy, 0], a),
              rotate_euler_xyz([0 , 0 , sz], a),
              rotate_euler_xyz([sx, 0 , sz], a),
              rotate_euler_xyz([0 , sy, sz], a),
              rotate_euler_xyz([sx, sy, sz], a)],
       xs = [for (p=pts) p[0]],
       ys = [for (p=pts) p[1]],
       zs = [for (p=pts) p[2]],
       minx = min(xs),
       maxx = max(xs),
       miny = min(ys),
       maxy = max(ys),
       minz = min(zs),
       maxz = max(zs))
  [minx, miny, minz, maxx, maxy, maxz];

/**
─────────────────────────────────────────────────────────────────────────────
rotated_bbox
─────────────────────────────────────────────────────────────────────────────

Compute the full extents of the axis-aligned bounding box (AABB) of a box after
rotation, plus the translation required to shift that AABB so its minimum corner
lands at the origin.

This is convenient when you want to:
1) rotate a shape around the origin, and
2) then translate it so the resulting rotated AABB starts at `[0,0,0]`.

**Parameters:**

`size`: [`sx`, `sy`, `sz`]
         - `sx`: Size along X (box extent in X before rotation).
         - `sy`: Size along Y (box extent in Y before rotation).
         - `sz`: Size along Z (box extent in Z before rotation).
`a`: Rotation angles in degrees `[ax, ay, az]` (default `[0,0,0]`).

**Returns:**

`[fullx, fully, fullz, tx, ty, tz]`

Where:
- `fullx, fully, fullz` are the dimensions of the rotated AABB.
- `tx, ty, tz` is the translation that moves the rotated AABB min corner to
  `[0,0,0]` (i.e. `t = -[minx, miny, minz]`).

**Behavior:**
Calls `rotated_aabb_minmax(...)` to get `[min*, max*]`, converts it to extents, and
returns the translation needed to shift the min corner to the origin.

**Examples:**
```scad
w = 10;
l = 4;
h = 3;

x_angle = 0;
y_angle = 30;
z_angle = 0;

bb = rotated_bbox(size=[w, l, h], a=[x_angle, y_angle, z_angle]);
x_shift = bb[3];
y_shift = bb[4];
z_shift = bb[5];;

echo("z_shift", z_shift); // 5

// Place the rotated cube into the positive octant with its AABB min at [0, 0, 0]
translate([x_shift, y_shift, z_shift]) {
  rotate([x_angle, y_angle, z_angle]) {
    cube([w, l, h]);
  }
}

// show bbox
#cube([bb[0], bb[1], bb[2]]);
```
*/
function rotated_bbox(size, a=[0, 0, 0]) =
  let (sx=size[0],
       sy=size[1],
       sz=size[2],
       b = rotated_aabb_minmax(sx, sy, sz, a))
  [b[3]-b[0],  // fullx
   b[4]-b[1],  // fully
   b[5]-b[2],  // fullz
   -b[0],      // tx
   -b[1],      // ty
   -b[2]       // tz
  ];

/**
  ─────────────────────────────────────────────────────────────────────────────
  y_angle_from_zshift
  ─────────────────────────────────────────────────────────────────────────────

  **Example**:
  ```scad
  w = 10;
  l = 4;
  h = 3;

  target_h = 4;

  x_angle = 0;
  y_angle = y_angle_from_zshift(-target_h, w);
  z_angle = 0;

  bb = rotated_bbox(size=[w, l, h], a=[x_angle, y_angle, z_angle]);
  x_shift = bb[3];
  y_shift = bb[4];
  z_shift = bb[5];

  echo("y_angle", y_angle);

  echo("x_shift", x_shift); // 1.2

  // Place the rotated cube into the positive octant with its AABB min at [0,0,0]
  translate([x_shift, y_shift, z_shift]) {
    rotate([x_angle, y_angle, z_angle]) {
      cube([w, l, h]);
    }
  }

  ```
  */

function y_angle_from_zshift(target_h, w) =
  asin(target_h / w);

/**
─────────────────────────────────────────────────────────────────────────────
vlen
─────────────────────────────────────────────────────────────────────────────

Compute the Euclidean length of a 3D vector.

**Parameters:**

`v`: 3D vector `[x, y, z]`.

**Returns:**

The scalar magnitude of `v`.

**Behavior:**
Uses the standard formula `sqrt(x^2 + y^2 + z^2)`.

**Examples:**
```scad
vlen([3, 4, 0]);     // -> 5
vlen([1, 2, 2]);     // -> 3
```
*/
function vlen(v) = sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);

/**
─────────────────────────────────────────────────────────────────────────────
vunit
─────────────────────────────────────────────────────────────────────────────

Normalize a 3D vector to unit length.

**Parameters:**

`v`: 3D vector `[x, y, z]`.

**Returns:**

A normalized vector with length `1`, pointing in the same direction as `v`.

**Behavior:**
If the input vector is extremely small (`length < 1e-9`), returns `[0, 0, 0]`
instead of dividing by nearly zero.

**Examples:**
```scad
vunit([3, 0, 0]);    // -> [1, 0, 0]
vunit([0, 0, 0]);    // -> [0, 0, 0]
```
*/
function vunit(v) =
  let (L = vlen(v))
  (L < 1e-9 ? [0, 0, 0] : [v[0] / L, v[1] / L, v[2] / L]);

/**
─────────────────────────────────────────────────────────────────────────────
vcross
─────────────────────────────────────────────────────────────────────────────

Compute the cross product of two 3D vectors.

**Parameters:**

`a`: First 3D vector `[ax, ay, az]`.
`b`: Second 3D vector `[bx, by, bz]`.

**Returns:**

A new 3D vector perpendicular to both `a` and `b`, equal to `a × b`.

**Behavior:**
Uses the standard right-handed cross product. The result direction follows the
right-hand rule.

**Examples:**
```scad
vcross([1, 0, 0], [0, 1, 0]);   // -> [0, 0, 1]
vcross([0, 1, 0], [1, 0, 0]);   // -> [0, 0, -1]
```
*/
function vcross(a, b) = [a[1] * b[2] - a[2] * b[1],
                         a[2] * b[0] - a[0] * b[2],
                         a[0] * b[1] - a[1] * b[0]];

/**
─────────────────────────────────────────────────────────────────────────────
vadd
─────────────────────────────────────────────────────────────────────────────

Add two 3D vectors component-wise.

**Parameters:**

`a`: First 3D vector `[ax, ay, az]`.
`b`: Second 3D vector `[bx, by, bz]`.

**Returns:**

A new 3D vector `[ax + bx, ay + by, az + bz]`.

**Behavior:**
Performs simple component-wise addition.

**Examples:**
```scad
vadd([1, 2, 3], [4, 5, 6]);   // -> [5, 7, 9]
```
*/
function vadd(a, b) = [a[0] + b[0], a[1] + b[1], a[2] + b[2]];

/**
─────────────────────────────────────────────────────────────────────────────
vsub
─────────────────────────────────────────────────────────────────────────────

Subtract one 3D vector from another component-wise.

**Parameters:**

`a`: First 3D vector `[ax, ay, az]`.
`b`: Second 3D vector `[bx, by, bz]`.

**Returns:**

A new 3D vector `[ax - bx, ay - by, az - bz]`.

**Behavior:**
Performs simple component-wise subtraction.

**Examples:**
```scad
vsub([5, 7, 9], [1, 2, 3]);   // -> [4, 5, 6]
```
*/
function vsub(a, b) = [a[0]-b[0], a[1]-b[1], a[2]-b[2]];

/**
─────────────────────────────────────────────────────────────────────────────
vmul
─────────────────────────────────────────────────────────────────────────────

Multiply a 3D vector by a scalar.

**Parameters:**

`v`: 3D vector `[x, y, z]`.
`s`: Scalar multiplier.

**Returns:**

A new 3D vector `[x*s, y*s, z*s]`.

**Behavior:**
Scales the vector uniformly in all three components.

**Examples:**
```scad
vmul([1, 2, 3], 2);     // -> [2, 4, 6]
vmul([1, -1, 0], 0.5);  // -> [0.5, -0.5, 0]
```
*/
function vmul(v, s) = [v[0]*s, v[1]*s, v[2]*s];

/**
  ─────────────────────────────────────────────────────────────────────────────
  vec_is_zero
  ─────────────────────────────────────────────────────────────────────────────

Check if a 3D vector is effectively zero within a small epsilon threshold.

  **Example**:
  ```scad
  vec_is_zero([0, 0, 0]);           // -> true
  vec_is_zero([1e-10, 0, 0]);       // -> true

  ```
  */
function vec_is_zero(v, eps=1e-9) = vlen(v) <= eps;

/**
─────────────────────────────────────────────────────────────────────────────
point_tangent
─────────────────────────────────────────────────────────────────────────────

Estimate a tangent direction at a point along a 3D polyline.

**Parameters:**

`points`: List of 3D points `[[x, y, z], ...]`.
`i`: Index of the point whose tangent should be computed.

**Returns:**

A unit 3D vector representing the tangent direction at `points[i]`.

**Behavior:**
For the first point, uses the direction from `points[0]` to `points[1]`.
For the last point, uses the direction from `points[i-1]` to `points[i]`.
For interior points, averages the normalized incoming and outgoing segment
directions, then normalizes the result.

**Examples:**
```scad
pts = [[0,0,0], [1,0,0], [2,1,0]];
point_tangent(pts, 0);   // -> [1, 0, 0] - tangent of first segment
point_tangent(pts, 1);   // -> [~0.9, ~0.3, 0] - averaged corner tangent
point_tangent(pts, 2);   // -> [~0.7, ~0.7, 0] - tangent of last segment
```
*/
function point_tangent(points, i) =
  i == 0 ? vunit(vsub(points[1], points[0])) :
  i == len(points)-1 ? vunit(vsub(points[i], points[i-1])) :
  vunit(vadd(vunit(vsub(points[i], points[i-1])),
             vunit(vsub(points[i + 1], points[i]))));

/**
─────────────────────────────────────────────────────────────────────────────
safe_perp
─────────────────────────────────────────────────────────────────────────────

Compute a unit vector perpendicular to a tangent direction.

**Parameters:**

`tangent`: 3D direction vector.
`up`: Preferred reference up vector. Default: `[0, 0, 1]`.

**Returns:**

A unit 3D vector perpendicular to `tangent`.

**Behavior:**
First computes `cross(tangent, up)` to get a sideways perpendicular direction.
If `tangent` is nearly parallel to `up`, that cross product becomes too small,
so the function falls back to using `[0, 1, 0]` as an alternate reference
vector. The final result is normalized.

**Examples:**
```scad
safe_perp([1, 0, 0]);            // -> [0, -1, 0]
safe_perp([0, 0, 1]);            // -> [-1, 0, 0] uses fallback reference vector
safe_perp([1, 0, 0], [0, 1, 0]); // -> [0, 0, 1]
```
*/
function safe_perp(tangent, up=[0, 0, 1]) =
  let (n = vcross(tangent, up))
  vlen(n) < 1e-6
  ? vunit(vcross(tangent, [0, 1, 0]))
  : vunit(n);

/**
─────────────────────────────────────────────────────────────────────────────
offset_path
─────────────────────────────────────────────────────────────────────────────

Create an offset version of a 3D polyline.

**Parameters:**

`points`: List of 3D points `[[x, y, z], ...]`.
`offset`: Offset distance.
`up`: Preferred reference up vector used to define the perpendicular offset
direction. Default: `[0, 0, 1]`.

**Returns:**

A new list of 3D points where each input point has been shifted by `offset`
along a perpendicular direction derived from the local path tangent.

**Behavior:**
For each point:
- Computes the local tangent with `point_tangent()`.
- Computes a stable perpendicular direction with `safe_perp()`.
- Moves the point by `offset` along that perpendicular.

This is useful for generating parallel paths relative to a 3D polyline.
The exact offset direction depends on both the tangent and the chosen `up`
vector.

**Examples:**
```scad
offset_path([[0, 0, 0], [10, 0, 0], [20, 10, 0]], 2); // -> [[0, -2, 0], [10.7, -1.8, 0], [21.4, 8.5, 0]]

offset_path([[0,0,0], [0,10,0]], 1, [0,0,1]); // -> [[1, 0, 0], [1, 10, 0]]
```
*/

function offset_path(points, offset, up=[0, 0, 1]) =
  [for (i = [0:len(points)-1])
      let (t = point_tangent(points, i),
           p = safe_perp(t, up))
        vadd(points[i], vmul(p, offset))];

/**
─────────────────────────────────────────────────────────────────────────────
countersink_h
─────────────────────────────────────────────────────────────────────────────

Compute the height of a conical countersink from the through-hole diameter,
the countersink opening diameter, and the included angle.

**Parameters:**

`d`: Through-hole diameter.
`sink_d`: Countersink opening diameter at the wide end.
`angle`: Included countersink angle in degrees.

**Returns:**

The countersink height needed to transition from diameter `d` to diameter
`sink_d` at the given included angle.


For valid physical results, `sink_d` should be greater than or equal to `d`,
and `angle` should be greater than `0` and less than `180`.

**Examples:**
```scad
countersink_h(d=3, sink_d=6, angle=90); // -> 1.5
countersink_h(d=3, sink_d=6.5, angle=90); // -> 1.75
countersink_h(d=4, sink_d=8, angle=82);   // -> ~2.3
```
*/
function countersink_h(d, sink_d, angle) =
  ((sink_d - d) / 2) / tan(angle / 2);

/**
─────────────────────────────────────────────────────────────────────────────
normalize_anchor
─────────────────────────────────────────────────────────────────────────────

Normalize an anchor specification into a 3-element `[x, y, z]` vector.

Missing anchors default to `[1, 1, 1]`. Any individual `undef` component is
also replaced with `1`.

Anchor values use this convention per axis:

- `1`: near/min side
- `0`: center
- `-1`: far/max side

Only the values `-1`, `0`, and `1` are allowed.

**Parameters:**

`anchor`: Anchor vector as `[x, y, z]`, or `undef`.

**Returns:**

A normalized 3-element anchor vector.


**Examples:**
```scad
normalize_anchor();              // -> [1, 1, 1]
normalize_anchor([1, 0, -1]);    // -> [1, 0, -1]
normalize_anchor([undef, 0, 1]); // -> [1, 0, 1]
```
*/
function normalize_anchor(anchor) =
  let (anchor = with_default(anchor, [1, 1, 1]),
       align_x = is_undef(anchor[0]) ? 1 : anchor[0],
       align_y = is_undef(anchor[1]) ? 1 : anchor[1],
       align_z = is_undef(anchor[2]) ? 1 : anchor[2])
  assert(is_list(anchor) && len(anchor) == 3,
         "Anchor must be a list of 3 elements")
  assert(is_num(anchor[0]) && in_list(abs(anchor[0]), [0, 1]),
         "Invalid value in anchor[0]")
  assert(is_num(anchor[1]) && in_list(abs(anchor[1]), [0, 1]),
         "Invalid value in anchor[1]")
  assert(is_num(anchor[2]) && in_list(abs(anchor[2]), [0, 1]),
         "Invalid value in anchor[2]")
  [align_x, align_y, align_z];

/**
─────────────────────────────────────────────────────────────────────────────
to_anchor
─────────────────────────────────────────────────────────────────────────────

Convert an anchor specification into a translation vector for an object of
the given size.

The anchor convention per axis is:

- `1`: near/min side
- `0`: center
- `-1`: far/max side

For non-centered geometry (`centered=false`), the object is assumed to span
from `0` to `size[i]` on each axis.

For centered geometry (`centered=true`), the object is assumed to span from
`-size[i]/2` to `size[i]/2` on each axis.

The returned translation places the requested anchor on the origin along each
axis.

**Parameters:**

`anchor`: Anchor vector as `[x, y, z]`.
`size`: Object size as `[x, y, z]`.
`centered`: Whether the object is already centered on each axis.

**Returns:**

A 3-element translation vector.


**Examples:**
```scad
to_anchor([1, 1, 1], [20, 30, 10], false);   // -> [0, 0, 0]
to_anchor([0, 0, 0], [20, 30, 10], false);   // -> [-10, -15, -5]
to_anchor([-1, 0, 1], [20, 30, 10], false);  // -> [-20, -15, 0]

to_anchor([1, 1, 1], [20, 30, 10], true);    // -> [10, 15, 5]
to_anchor([0, 0, 0], [20, 30, 10], true);    // -> [0, 0, 0]
to_anchor([-1, 0, 1], [20, 30, 10], true);   // -> [-10, 0, 5]
```
*/
function to_anchor(anchor, size, centered=false) =
  assert(is_list(anchor) && len(anchor) == 3,
         "Anchor must be a list of 3 elements")
  assert(is_num(anchor[0]) && in_list(abs(anchor[0]), [0, 1]),
         "Invalid value in anchor[0]")
  assert(is_num(anchor[1]) && in_list(abs(anchor[1]), [0, 1]),
         "Invalid value in anchor[1]")
  assert(is_num(anchor[2]) && in_list(abs(anchor[2]), [0, 1]),
         "Invalid value in anchor[2]")
  [for (i = [0:2])
      let (a = anchor[i],
           v = size[i])
        centered
        ? (a ==  1 ?  v/2 :
           a ==  0 ?  0   :
           -v/2)
        : (a ==  1 ?  0   :
           a ==  0 ? -v/2 :
           -v)];